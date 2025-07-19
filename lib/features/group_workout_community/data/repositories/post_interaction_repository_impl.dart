import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import '../../domain/repositories/post_interaction_repository.dart';
import '../../domain/entities/post_comment.dart';
import '../../domain/entities/community_post.dart';
import '../models/post_comment_model.dart';
import '../models/community_post_model.dart';

/// Implementation of PostInteractionRepository using Supabase as the data source
class PostInteractionRepositoryImpl extends PostInteractionRepository with BaseRepositoryMixin {
  final SupabaseClient _supabaseClient;
  final Uuid _uuid = const Uuid();

  PostInteractionRepositoryImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<Either<Failure, List<PostComment>>> getComments(
    String postId, {
    int limit = 50,
    int offset = 0,
    String? parentCommentId,
  }) async {
    return safeCall(() async {
      var query = _supabaseClient
          .from('post_comments')
          .select('''
            *,
            user_profiles!inner(
              username,
              profile_image_url
            )
          ''')
          .eq('post_id', postId)
          .eq('is_deleted', false);

      if (parentCommentId != null) {
        query = query.eq('parent_comment_id', parentCommentId);
      } else {
        query = query.isFilter('parent_comment_id', null);
      }

      final response = await query
          .order('created_at', ascending: true)
          .range(offset, offset + limit - 1);

      return (response as List).map((json) {
        // Add user profile data for easier access
        final userProfile = json['user_profiles'] as Map<String, dynamic>;
        json['author_username'] = userProfile['username'];
        json['author_profile_image'] = userProfile['profile_image_url'];
        
        return PostCommentModel.fromJson(json).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, PostComment?>> getCommentById(String commentId) async {
    return safeCall(() async {
      try {
        final response = await _supabaseClient
            .from('post_comments')
            .select('''
              *,
              user_profiles!inner(
                username,
                profile_image_url
              )
            ''')
            .eq('id', commentId)
            .eq('is_deleted', false)
            .single();

        final userProfile = response['user_profiles'] as Map<String, dynamic>;
        response['author_username'] = userProfile['username'];
        response['author_profile_image'] = userProfile['profile_image_url'];
        
        return PostCommentModel.fromJson(response).toEntity();
      } catch (e) {
        if (e is PostgrestException && (e.code == 'PGRST116' || e.message.contains('0 rows'))) {
          return null;
        }
        rethrow;
      }
    });
  }

  @override
  Future<Either<Failure, PostComment>> addComment(AddCommentRequest request) async {
    return safeCall(() async {
      final commentId = _uuid.v4();
      final now = DateTime.now();

      final commentData = {
        'id': commentId,
        'post_id': request.postId,
        'author_id': request.authorId,
        'parent_comment_id': request.parentCommentId,
        'content': request.content,
        'likes_count': 0,
        'is_deleted': false,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      await _supabaseClient
          .from('post_comments')
          .insert(commentData);

      // Increment comment count on the post
      await _supabaseClient.rpc('increment_post_comments', params: {
        'post_id': request.postId,
      });

      return PostCommentModel.fromJson(commentData).toEntity();
    });
  }

  @override
  Future<Either<Failure, PostComment>> updateComment(
    String commentId,
    UpdateCommentRequest request,
    String userId,
  ) async {
    return safeCall(() async {
      // Verify user can edit this comment
      final existingComment = await getCommentById(commentId);
      final comment = existingComment.fold(
        (failure) => throw failure,
        (comment) => comment,
      );

      if (comment == null) {
        throw const DatabaseFailure('댓글을 찾을 수 없습니다');
      }

      if (comment.authorId != userId) {
        throw const DatabaseFailure('댓글을 수정할 권한이 없습니다');
      }

      await _supabaseClient
          .from('post_comments')
          .update({
            'content': request.content,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', commentId);

      // Return updated comment
      final updatedCommentResult = await getCommentById(commentId);
      return updatedCommentResult.fold(
        (failure) => throw failure,
        (comment) => comment!,
      );
    });
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId, String userId) async {
    return safeCall(() async {
      // Verify user can delete this comment
      final existingComment = await getCommentById(commentId);
      final comment = existingComment.fold(
        (failure) => throw failure,
        (comment) => comment,
      );

      if (comment == null) {
        throw const DatabaseFailure('댓글을 찾을 수 없습니다');
      }

      // Check if user is author or admin
      bool canDelete = comment.authorId == userId;
      
      if (!canDelete) {
        // Check if user is post author or group admin
        final postResponse = await _supabaseClient
            .from('community_posts')
            .select('author_id, group_id')
            .eq('id', comment.postId)
            .single();

        final postAuthorId = postResponse['author_id'] as String;
        final groupId = postResponse['group_id'] as String?;

        // Post author can delete comments on their post
        canDelete = postAuthorId == userId;

        // Group admin can delete comments in group posts
        if (!canDelete && groupId != null) {
          final memberResponse = await _supabaseClient
              .from('group_members')
              .select('role')
              .eq('group_id', groupId)
              .eq('user_id', userId)
              .eq('is_active', true)
              .maybeSingle();

          canDelete = memberResponse != null && memberResponse['role'] == 'admin';
        }
      }

      if (!canDelete) {
        throw const DatabaseFailure('댓글을 삭제할 권한이 없습니다');
      }

      // Soft delete
      await _supabaseClient
          .from('post_comments')
          .update({
            'is_deleted': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', commentId);

      // Decrement comment count on the post
      await _supabaseClient.rpc('decrement_post_comments', params: {
        'post_id': comment.postId,
      });
    });
  }

  @override
  Future<Either<Failure, void>> toggleLike(ToggleLikeRequest request) async {
    return safeCall(() async {
      if (!request.isPostLike && !request.isCommentLike) {
        throw const DatabaseFailure('게시글 또는 댓글 ID가 필요합니다');
      }

      // Check if user already liked this item
      final existingLike = await _supabaseClient
          .from('post_likes')
          .select('id, like_type')
          .eq('user_id', request.userId)
          .eq('post_id', request.postId ?? '')
          .eq('comment_id', request.commentId ?? '')
          .maybeSingle();

      if (existingLike != null) {
        final currentLikeType = existingLike['like_type'] as String;
        final requestLikeTypeString = _likeTypeToString(request.likeType);

        if (currentLikeType == requestLikeTypeString) {
          // Same like type - remove the like
          await _supabaseClient
              .from('post_likes')
              .delete()
              .eq('id', existingLike['id']);

          // Decrement like count
          if (request.isPostLike) {
            await _supabaseClient.rpc('decrement_post_likes', params: {
              'post_id': request.postId!,
            });
          } else {
            await _supabaseClient.rpc('decrement_comment_likes', params: {
              'comment_id': request.commentId!,
            });
          }
        } else {
          // Different like type - update the like
          await _supabaseClient
              .from('post_likes')
              .update({
                'like_type': requestLikeTypeString,
              })
              .eq('id', existingLike['id']);
        }
      } else {
        // No existing like - create new like
        await _supabaseClient
            .from('post_likes')
            .insert({
              'id': _uuid.v4(),
              'post_id': request.postId,
              'comment_id': request.commentId,
              'user_id': request.userId,
              'like_type': _likeTypeToString(request.likeType),
              'created_at': DateTime.now().toIso8601String(),
            });

        // Increment like count
        if (request.isPostLike) {
          await _supabaseClient.rpc('increment_post_likes', params: {
            'post_id': request.postId!,
          });
        } else {
          await _supabaseClient.rpc('increment_comment_likes', params: {
            'comment_id': request.commentId!,
          });
        }
      }
    });
  }

  @override
  Future<Either<Failure, LikeType?>> getUserLikeStatus(
    String userId, {
    String? postId,
    String? commentId,
  }) async {
    return safeCall(() async {
      if (postId == null && commentId == null) {
        throw const DatabaseFailure('게시글 또는 댓글 ID가 필요합니다');
      }

      final response = await _supabaseClient
          .from('post_likes')
          .select('like_type')
          .eq('user_id', userId)
          .eq('post_id', postId ?? '')
          .eq('comment_id', commentId ?? '')
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return _parseLikeType(response['like_type'] as String);
    });
  }

  @override
  Future<Either<Failure, Map<String, int>>> getLikeStats({
    String? postId,
    String? commentId,
  }) async {
    return safeCall(() async {
      if (postId == null && commentId == null) {
        throw const DatabaseFailure('게시글 또는 댓글 ID가 필요합니다');
      }

      var query = _supabaseClient
          .from('post_likes')
          .select('like_type');

      if (postId != null) {
        query = query.eq('post_id', postId);
      }
      if (commentId != null) {
        query = query.eq('comment_id', commentId);
      }

      final response = await query;
      final likes = response as List;

      int likeCount = 0;
      int dislikeCount = 0;

      for (final like in likes) {
        final likeType = like['like_type'] as String;
        if (likeType == 'like') {
          likeCount++;
        } else if (likeType == 'dislike') {
          dislikeCount++;
        }
      }

      return {
        'likes': likeCount,
        'dislikes': dislikeCount,
        'total': likeCount + dislikeCount,
      };
    });
  }

  @override
  Future<Either<Failure, void>> incrementViewCount(String postId) async {
    return safeCall(() async {
      await _supabaseClient.rpc('increment_post_views', params: {
        'post_id': postId,
      });
    });
  }

  @override
  Future<Either<Failure, int>> getViewCount(String postId) async {
    return safeCall(() async {
      final response = await _supabaseClient
          .from('community_posts')
          .select('views_count')
          .eq('id', postId)
          .single();

      return response['views_count'] as int;
    });
  }

  @override
  Future<Either<Failure, void>> toggleBookmark(BookmarkRequest request) async {
    return safeCall(() async {
      // Check if bookmark already exists
      final existingBookmark = await _supabaseClient
          .from('post_bookmarks')
          .select('id')
          .eq('post_id', request.postId)
          .eq('user_id', request.userId)
          .maybeSingle();

      if (existingBookmark != null) {
        // Remove bookmark
        await _supabaseClient
            .from('post_bookmarks')
            .delete()
            .eq('id', existingBookmark['id']);
      } else {
        // Add bookmark
        await _supabaseClient
            .from('post_bookmarks')
            .insert({
              'id': _uuid.v4(),
              'post_id': request.postId,
              'user_id': request.userId,
              'created_at': DateTime.now().toIso8601String(),
            });
      }
    });
  }

  @override
  Future<Either<Failure, bool>> isPostBookmarked(String postId, String userId) async {
    return safeCall(() async {
      final response = await _supabaseClient
          .from('post_bookmarks')
          .select('id')
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    });
  }

  @override
  Future<Either<Failure, List<CommunityPost>>> getUserBookmarks(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    return safeCall(() async {
      final response = await _supabaseClient
          .from('post_bookmarks')
          .select('''
            community_posts!inner(
              *,
              user_profiles!inner(
                username,
                profile_image_url
              ),
              post_categories!inner(
                name,
                color_code
              )
            )
          ''')
          .eq('user_id', userId)
          .eq('community_posts.is_deleted', false)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).map((json) {
        final postData = json['community_posts'] as Map<String, dynamic>;
        final userProfile = postData['user_profiles'] as Map<String, dynamic>;
        final category = postData['post_categories'] as Map<String, dynamic>;
        
        postData['author_username'] = userProfile['username'];
        postData['author_profile_image'] = userProfile['profile_image_url'];
        postData['category_name'] = category['name'];
        postData['category_color'] = category['color_code'];
        
        return CommunityPostModel.fromJson(postData).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, List<PostComment>>> getCommentThread(
    String parentCommentId, {
    int maxDepth = 3,
  }) async {
    return safeCall(() async {
      // Get parent comment first
      final parentResult = await getCommentById(parentCommentId);
      final parentComment = parentResult.fold(
        (failure) => throw failure,
        (comment) => comment,
      );

      if (parentComment == null) {
        return <PostComment>[];
      }

      final allComments = <PostComment>[parentComment];

      // Recursively get replies
      await _getCommentReplies(parentCommentId, allComments, 1, maxDepth);

      return allComments;
    });
  }

  /// Helper method to recursively get comment replies
  Future<void> _getCommentReplies(
    String parentId,
    List<PostComment> allComments,
    int currentDepth,
    int maxDepth,
  ) async {
    if (currentDepth >= maxDepth) return;

    final repliesResult = await getComments(
      allComments.first.postId,
      parentCommentId: parentId,
    );

    final replies = repliesResult.fold(
      (failure) => <PostComment>[],
      (comments) => comments,
    );

    allComments.addAll(replies);

    // Get replies to replies
    for (final reply in replies) {
      await _getCommentReplies(reply.id, allComments, currentDepth + 1, maxDepth);
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getCommentsWithReplyCounts(
    String postId, {
    int limit = 20,
    int offset = 0,
  }) async {
    return safeCall(() async {
      final topLevelComments = await getComments(
        postId,
        limit: limit,
        offset: offset,
      );

      final comments = topLevelComments.fold(
        (failure) => throw failure,
        (comments) => comments,
      );

      final commentsWithCounts = <Map<String, dynamic>>[];

      for (final comment in comments) {
        // Get reply count for each comment
        final replyCountResponse = await _supabaseClient
            .from('post_comments')
            .select('id')
            .eq('parent_comment_id', comment.id)
            .eq('is_deleted', false);

        commentsWithCounts.add({
          'comment': comment,
          'reply_count': (replyCountResponse as List).length,
        });
      }

      return commentsWithCounts;
    });
  }

  @override
  Future<Either<Failure, List<PostComment>>> getUserRecentComments(
    String userId, {
    int limit = 20,
    int days = 30,
  }) async {
    return safeCall(() async {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final response = await _supabaseClient
          .from('post_comments')
          .select('''
            *,
            user_profiles!inner(
              username,
              profile_image_url
            )
          ''')
          .eq('author_id', userId)
          .eq('is_deleted', false)
          .gte('created_at', startDate.toIso8601String())
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) {
        final userProfile = json['user_profiles'] as Map<String, dynamic>;
        json['author_username'] = userProfile['username'];
        json['author_profile_image'] = userProfile['profile_image_url'];
        
        return PostCommentModel.fromJson(json).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, List<PostComment>>> getMostLikedComments(
    String postId, {
    int limit = 10,
  }) async {
    return safeCall(() async {
      final response = await _supabaseClient
          .from('post_comments')
          .select('''
            *,
            user_profiles!inner(
              username,
              profile_image_url
            )
          ''')
          .eq('post_id', postId)
          .eq('is_deleted', false)
          .order('likes_count', ascending: false)
          .limit(limit);

      return (response as List).map((json) {
        final userProfile = json['user_profiles'] as Map<String, dynamic>;
        json['author_username'] = userProfile['username'];
        json['author_profile_image'] = userProfile['profile_image_url'];
        
        return PostCommentModel.fromJson(json).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, void>> reportComment(
    String commentId,
    String reporterId,
    String reason,
    String? description,
  ) async {
    return safeCall(() async {
      await _supabaseClient
          .from('comment_reports')
          .insert({
            'id': _uuid.v4(),
            'comment_id': commentId,
            'reporter_id': reporterId,
            'reason': reason,
            'description': description,
            'status': 'pending',
            'created_at': DateTime.now().toIso8601String(),
          });
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPostInteractionStats(
    String postId,
  ) async {
    return safeCall(() async {
      // Get like stats
      final likeStatsResult = await getLikeStats(postId: postId);
      final likeStats = likeStatsResult.fold(
        (failure) => throw failure,
        (stats) => stats,
      );

      // Get comment count
      final commentCountResponse = await _supabaseClient
          .from('post_comments')
          .select('id')
          .eq('post_id', postId)
          .eq('is_deleted', false);

      // Get bookmark count
      final bookmarkCountResponse = await _supabaseClient
          .from('post_bookmarks')
          .select('id')
          .eq('post_id', postId);

      // Get view count
      final viewCountResult = await getViewCount(postId);
      final viewCount = viewCountResult.fold(
        (failure) => throw failure,
        (count) => count,
      );

      return {
        'likes': likeStats['likes'],
        'dislikes': likeStats['dislikes'],
        'comments': (commentCountResponse as List).length,
        'bookmarks': (bookmarkCountResponse as List).length,
        'views': viewCount,
      };
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserPostInteractions(
    String postId,
    String userId,
  ) async {
    return safeCall(() async {
      // Get user's like status
      final likeStatusResult = await getUserLikeStatus(userId, postId: postId);
      final likeStatus = likeStatusResult.fold(
        (failure) => null,
        (status) => status,
      );

      // Check if bookmarked
      final isBookmarkedResult = await isPostBookmarked(postId, userId);
      final isBookmarked = isBookmarkedResult.fold(
        (failure) => false,
        (bookmarked) => bookmarked,
      );

      // Get user's comments on this post
      final userCommentsResponse = await _supabaseClient
          .from('post_comments')
          .select('id')
          .eq('post_id', postId)
          .eq('author_id', userId)
          .eq('is_deleted', false);

      return {
        'liked': likeStatus?.name,
        'bookmarked': isBookmarked,
        'comment_count': (userCommentsResponse as List).length,
      };
    });
  }

  @override
  Future<Either<Failure, List<PostComment>>> getTrendingComments({
    String? postId,
    int hours = 24,
    int limit = 20,
  }) async {
    return safeCall(() async {
      final startTime = DateTime.now().subtract(Duration(hours: hours));

      var query = _supabaseClient
          .from('post_comments')
          .select('''
            *,
            user_profiles!inner(
              username,
              profile_image_url
            )
          ''')
          .eq('is_deleted', false)
          .gte('created_at', startTime.toIso8601String());

      if (postId != null) {
        query = query.eq('post_id', postId);
      }

      final response = await query
          .order('likes_count', ascending: false)
          .limit(limit);

      return (response as List).map((json) {
        final userProfile = json['user_profiles'] as Map<String, dynamic>;
        json['author_username'] = userProfile['username'];
        json['author_profile_image'] = userProfile['profile_image_url'];
        
        return PostCommentModel.fromJson(json).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserCommentStats(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return safeCall(() async {
      var query = _supabaseClient
          .from('post_comments')
          .select('created_at, likes_count')
          .eq('author_id', userId)
          .eq('is_deleted', false);

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;
      final comments = response as List;

      final totalLikes = comments.fold<int>(
        0,
        (sum, comment) => sum + (comment['likes_count'] as int),
      );

      return {
        'total_comments': comments.length,
        'total_likes_received': totalLikes,
        'average_likes_per_comment': comments.isNotEmpty ? totalLikes / comments.length : 0.0,
      };
    });
  }

  @override
  Future<Either<Failure, void>> toggleCommentPin(
    String commentId,
    String userId,
  ) async {
    return safeCall(() async {
      // Get comment to verify permissions
      final commentResult = await getCommentById(commentId);
      final comment = commentResult.fold(
        (failure) => throw failure,
        (comment) => comment,
      );

      if (comment == null) {
        throw const DatabaseFailure('댓글을 찾을 수 없습니다');
      }

      // Check if user is post author or admin
      final postResponse = await _supabaseClient
          .from('community_posts')
          .select('author_id, group_id')
          .eq('id', comment.postId)
          .single();

      final postAuthorId = postResponse['author_id'] as String;
      final groupId = postResponse['group_id'] as String?;

      bool canPin = postAuthorId == userId;

      if (!canPin && groupId != null) {
        final memberResponse = await _supabaseClient
            .from('group_members')
            .select('role')
            .eq('group_id', groupId)
            .eq('user_id', userId)
            .eq('is_active', true)
            .maybeSingle();

        canPin = memberResponse != null && memberResponse['role'] == 'admin';
      }

      if (!canPin) {
        throw const DatabaseFailure('댓글을 고정할 권한이 없습니다');
      }

      // Toggle pin status (this would require adding is_pinned column to post_comments table)
      // For now, we'll implement this as a separate pinned_comments table
      final existingPin = await _supabaseClient
          .from('pinned_comments')
          .select('id')
          .eq('comment_id', commentId)
          .maybeSingle();

      if (existingPin != null) {
        await _supabaseClient
            .from('pinned_comments')
            .delete()
            .eq('id', existingPin['id']);
      } else {
        await _supabaseClient
            .from('pinned_comments')
            .insert({
              'id': _uuid.v4(),
              'comment_id': commentId,
              'pinned_by': userId,
              'created_at': DateTime.now().toIso8601String(),
            });
      }
    });
  }

  @override
  Future<Either<Failure, List<PostComment>>> getPinnedComments(String postId) async {
    return safeCall(() async {
      final response = await _supabaseClient
          .from('pinned_comments')
          .select('''
            post_comments!inner(
              *,
              user_profiles!inner(
                username,
                profile_image_url
              )
            )
          ''')
          .eq('post_comments.post_id', postId)
          .eq('post_comments.is_deleted', false)
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        final commentData = json['post_comments'] as Map<String, dynamic>;
        final userProfile = commentData['user_profiles'] as Map<String, dynamic>;
        
        commentData['author_username'] = userProfile['username'];
        commentData['author_profile_image'] = userProfile['profile_image_url'];
        
        return PostCommentModel.fromJson(commentData).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, void>> markCommentsAsRead(
    List<String> commentIds,
    String userId,
  ) async {
    return safeCall(() async {
      final readRecords = commentIds.map((commentId) => {
        'id': _uuid.v4(),
        'comment_id': commentId,
        'user_id': userId,
        'read_at': DateTime.now().toIso8601String(),
      }).toList();

      await _supabaseClient
          .from('comment_reads')
          .upsert(readRecords, onConflict: 'comment_id,user_id');
    });
  }

  @override
  Future<Either<Failure, int>> getUnreadCommentCount(String userId) async {
    return safeCall(() async {
      // This would require a more complex query to determine unread comments
      // For now, we'll return a simple count based on recent comments
      final recentComments = await _supabaseClient
          .from('post_comments')
          .select('id')
          .gte('created_at', DateTime.now().subtract(const Duration(days: 7)).toIso8601String())
          .neq('author_id', userId);

      final readComments = await _supabaseClient
          .from('comment_reads')
          .select('comment_id')
          .eq('user_id', userId);

      final readCommentIds = (readComments as List).map((r) => r['comment_id']).toSet();
      final unreadCount = (recentComments as List)
          .where((c) => !readCommentIds.contains(c['id']))
          .length;

      return unreadCount;
    });
  }

  @override
  Future<Either<Failure, List<PostComment>>> getCommentsMentioningUser(
    String userId, {
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    return safeCall(() async {
      // This would require implementing user mentions in comments
      // For now, we'll return an empty list as this feature needs @mention parsing
      return <PostComment>[];
    });
  }

  /// Helper method to convert LikeType to string
  String _likeTypeToString(LikeType type) {
    switch (type) {
      case LikeType.like:
        return 'like';
      case LikeType.dislike:
        return 'dislike';
    }
  }

  /// Helper method to parse string to LikeType
  LikeType _parseLikeType(String value) {
    switch (value) {
      case 'dislike':
        return LikeType.dislike;
      case 'like':
      default:
        return LikeType.like;
    }
  }
}