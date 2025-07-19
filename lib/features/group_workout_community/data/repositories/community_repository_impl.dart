import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import '../../domain/repositories/community_repository.dart';
import '../../domain/entities/community_post.dart';
import '../../domain/entities/post_category.dart';
import '../../domain/entities/post_search_criteria.dart';
import '../models/community_post_model.dart';
import '../models/post_category_model.dart';
import '../services/group_cache_service.dart';

/// Implementation of CommunityRepository using Supabase as the data source
class CommunityRepositoryImpl extends CommunityRepository with BaseRepositoryMixin {
  final SupabaseClient _supabaseClient;
  final GroupCacheService _cacheService;
  final Uuid _uuid = const Uuid();

  CommunityRepositoryImpl({
    SupabaseClient? supabaseClient,
    GroupCacheService? cacheService,
  }) : _supabaseClient = supabaseClient ?? Supabase.instance.client,
       _cacheService = cacheService ?? GroupCacheService();

  @override
  Future<Either<Failure, List<CommunityPost>>> getPosts(PostSearchRequest request) async {
    return safeCall(() async {
      // Generate cache key for this request
      final cacheKey = _cacheService.generatePostsCacheKey(
        categoryId: request.categoryId,
        groupId: request.groupId,
        searchQuery: request.query,
        sortBy: request.orderBy,
        limit: request.limit,
        offset: request.offset,
      );

      // Try to get from cache first
      final cachedPosts = await _cacheService.getCachedPosts(cacheKey);
      if (cachedPosts != null) {
        return cachedPosts;
      }

      var query = _supabaseClient
          .from('community_posts')
          .select('''
            *,
            user_profiles!inner(
              username,
              profile_image_url
            ),
            post_categories!inner(
              name,
              color_code
            )
          ''')
          .eq('is_deleted', false);

      // Apply filters
      if (request.categoryId != null) {
        query = query.eq('category_id', request.categoryId!);
      }

      if (request.groupId != null) {
        query = query.eq('group_id', request.groupId!);
      } else if (request.groupId == '') {
        // Only public posts (group_id is null)
        query = query.isFilter('group_id', null);
      }

      if (request.postType != null) {
        query = query.eq('post_type', _postTypeToString(request.postType!));
      }

      if (request.authorId != null) {
        query = query.eq('author_id', request.authorId!);
      }

      if (request.startDate != null) {
        query = query.gte('created_at', request.startDate!.toIso8601String());
      }

      if (request.endDate != null) {
        query = query.lte('created_at', request.endDate!.toIso8601String());
      }

      if (request.tags != null && request.tags!.isNotEmpty) {
        query = query.overlaps('tags', request.tags!);
      }

      if (request.query != null && request.query!.isNotEmpty) {
        query = query.or('title.ilike.%${request.query}%,content.ilike.%${request.query}%');
      }

      // Apply ordering and execute query
      switch (request.orderBy) {
        case 'popular':
          final response = await query
              .order('likes_count', ascending: false)
              .range(request.offset, request.offset + request.limit - 1);
          return _processPostsResponse(response);
        case 'views':
          final response = await query
              .order('views_count', ascending: false)
              .range(request.offset, request.offset + request.limit - 1);
          return _processPostsResponse(response);
        case 'comments':
          final response = await query
              .order('comments_count', ascending: false)
              .range(request.offset, request.offset + request.limit - 1);
          return _processPostsResponse(response);
        case 'recent':
        default:
          final response = await query
              .order('created_at', ascending: false)
              .range(request.offset, request.offset + request.limit - 1);
          return _processPostsResponse(response);
      }

      final response = await query.range(request.offset, request.offset + request.limit - 1);

      final posts = (response as List).map((json) {
        // Add user profile and category data for easier access
        final userProfile = json['user_profiles'] as Map<String, dynamic>;
        final category = json['post_categories'] as Map<String, dynamic>;
        
        json['author_username'] = userProfile['username'];
        json['author_profile_image'] = userProfile['profile_image_url'];
        json['category_name'] = category['name'];
        json['category_color'] = category['color_code'];
        
        return CommunityPostModel.fromJson(json).toEntity();
      }).toList();

      // Cache the results
      await _cacheService.cachePosts(cacheKey, posts);

      return posts;
    });
  }

  @override
  Future<Either<Failure, CommunityPost?>> getPostById(String postId) async {
    return safeCall(() async {
      try {
        final response = await _supabaseClient
            .from('community_posts')
            .select('''
              *,
              user_profiles!inner(
                username,
                profile_image_url
              ),
              post_categories!inner(
                name,
                color_code
              )
            ''')
            .eq('id', postId)
            .eq('is_deleted', false)
            .single();

        // Increment view count
        await _supabaseClient.rpc('increment_post_views', params: {
          'post_id': postId,
        });

        final userProfile = response['user_profiles'] as Map<String, dynamic>;
        final category = response['post_categories'] as Map<String, dynamic>;
        
        response['author_username'] = userProfile['username'];
        response['author_profile_image'] = userProfile['profile_image_url'];
        response['category_name'] = category['name'];
        response['category_color'] = category['color_code'];
        
        return CommunityPostModel.fromJson(response).toEntity();
      } catch (e) {
        if (e is PostgrestException && (e.code == 'PGRST116' || e.message.contains('0 rows'))) {
          return null;
        }
        rethrow;
      }
    });
  }

  @override
  Future<Either<Failure, CommunityPost>> createPost(CreatePostRequest request) async {
    return safeCall(() async {
      final postId = _uuid.v4();
      final now = DateTime.now();

      final postData = {
        'id': postId,
        'author_id': request.authorId,
        'group_id': request.groupId,
        'title': request.title,
        'content': request.content,
        'post_type': _postTypeToString(request.postType),
        'category_id': request.categoryId,
        'media_urls': request.mediaUrls,
        'tags': request.tags,
        'likes_count': 0,
        'comments_count': 0,
        'views_count': 0,
        'is_pinned': false,
        'is_deleted': false,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      await _supabaseClient
          .from('community_posts')
          .insert(postData);

      return CommunityPostModel.fromJson(postData).toEntity();
    });
  }

  @override
  Future<Either<Failure, CommunityPost>> updatePost(
    String postId,
    UpdatePostRequest request,
    String userId,
  ) async {
    return safeCall(() async {
      // Verify user can edit this post
      final existingPost = await getPostById(postId);
      final post = existingPost.fold(
        (failure) => throw failure,
        (post) => post,
      );

      if (post == null) {
        throw const DatabaseFailure('게시글을 찾을 수 없습니다');
      }

      // Check if user is author or admin
      bool canEdit = post.authorId == userId;
      
      if (!canEdit && post.groupId != null) {
        // Check if user is group admin
        final memberResponse = await _supabaseClient
            .from('group_members')
            .select('role')
            .eq('group_id', post.groupId!)
            .eq('user_id', userId)
            .eq('is_active', true)
            .maybeSingle();

        canEdit = memberResponse != null && memberResponse['role'] == 'admin';
      }

      if (!canEdit) {
        throw const DatabaseFailure('게시글을 수정할 권한이 없습니다');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (request.title != null) updateData['title'] = request.title;
      if (request.content != null) updateData['content'] = request.content;
      if (request.categoryId != null) updateData['category_id'] = request.categoryId;
      if (request.mediaUrls != null) updateData['media_urls'] = request.mediaUrls;
      if (request.tags != null) updateData['tags'] = request.tags;
      if (request.isPinned != null) updateData['is_pinned'] = request.isPinned;

      await _supabaseClient
          .from('community_posts')
          .update(updateData)
          .eq('id', postId);

      // Return updated post
      final updatedPostResult = await getPostById(postId);
      return updatedPostResult.fold(
        (failure) => throw failure,
        (post) => post!,
      );
    });
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId, String userId) async {
    return safeCall(() async {
      // Verify user can delete this post
      final existingPost = await getPostById(postId);
      final post = existingPost.fold(
        (failure) => throw failure,
        (post) => post,
      );

      if (post == null) {
        throw const DatabaseFailure('게시글을 찾을 수 없습니다');
      }

      // Check if user is author or admin
      bool canDelete = post.authorId == userId;
      
      if (!canDelete && post.groupId != null) {
        // Check if user is group admin
        final memberResponse = await _supabaseClient
            .from('group_members')
            .select('role')
            .eq('group_id', post.groupId!)
            .eq('user_id', userId)
            .eq('is_active', true)
            .maybeSingle();

        canDelete = memberResponse != null && memberResponse['role'] == 'admin';
      }

      if (!canDelete) {
        throw const DatabaseFailure('게시글을 삭제할 권한이 없습니다');
      }

      // Soft delete
      await _supabaseClient
          .from('community_posts')
          .update({
            'is_deleted': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', postId);
    });
  }

  @override
  Future<Either<Failure, List<PostCategory>>> getCategories() async {
    return safeCall(() async {
      final response = await _supabaseClient
          .from('post_categories')
          .select('*')
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return (response as List).map((json) {
        return PostCategoryModel.fromJson(json).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, PostCategory?>> getCategoryById(String categoryId) async {
    return safeCall(() async {
      try {
        final response = await _supabaseClient
            .from('post_categories')
            .select('*')
            .eq('id', categoryId)
            .eq('is_active', true)
            .single();

        return PostCategoryModel.fromJson(response).toEntity();
      } catch (e) {
        if (e is PostgrestException && (e.code == 'PGRST116' || e.message.contains('0 rows'))) {
          return null;
        }
        rethrow;
      }
    });
  }

  @override
  Future<Either<Failure, PostCategory>> createCategory(CreateCategoryRequest request) async {
    return safeCall(() async {
      final categoryId = _uuid.v4();
      final now = DateTime.now();

      final categoryData = {
        'id': categoryId,
        'name': request.name,
        'description': request.description,
        'icon_url': request.iconUrl,
        'color_code': request.colorCode,
        'sort_order': request.sortOrder,
        'is_active': true,
        'created_at': now.toIso8601String(),
      };

      await _supabaseClient
          .from('post_categories')
          .insert(categoryData);

      return PostCategoryModel.fromJson(categoryData).toEntity();
    });
  }

  @override
  Future<Either<Failure, PostCategory>> updateCategory(
    String categoryId,
    CreateCategoryRequest request,
  ) async {
    return safeCall(() async {
      final updateData = {
        'name': request.name,
        'description': request.description,
        'icon_url': request.iconUrl,
        'color_code': request.colorCode,
        'sort_order': request.sortOrder,
      };

      await _supabaseClient
          .from('post_categories')
          .update(updateData)
          .eq('id', categoryId);

      // Return updated category
      final updatedCategoryResult = await getCategoryById(categoryId);
      return updatedCategoryResult.fold(
        (failure) => throw failure,
        (category) => category!,
      );
    });
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String categoryId) async {
    return safeCall(() async {
      // Check if any posts are using this category
      final postsUsingCategory = await _supabaseClient
          .from('community_posts')
          .select('id')
          .eq('category_id', categoryId)
          .eq('is_deleted', false)
          .limit(1);

      if ((postsUsingCategory as List).isNotEmpty) {
        throw const DatabaseFailure('이 카테고리를 사용하는 게시글이 있어 삭제할 수 없습니다');
      }

      await _supabaseClient
          .from('post_categories')
          .update({'is_active': false})
          .eq('id', categoryId);
    });
  }

  @override
  Future<Either<Failure, List<String>>> uploadMedia(List<String> filePaths) async {
    return safeCall(() async {
      final uploadedUrls = <String>[];

      for (final filePath in filePaths) {
        final file = File(filePath);
        final fileName = '${_uuid.v4()}_${file.path.split('/').last}';
        final bucketPath = 'community_media/$fileName';

        await _supabaseClient.storage
            .from('community')
            .upload(bucketPath, file);

        final publicUrl = _supabaseClient.storage
            .from('community')
            .getPublicUrl(bucketPath);

        uploadedUrls.add(publicUrl);
      }

      return uploadedUrls;
    });
  }

  @override
  Future<Either<Failure, void>> deleteMedia(List<String> mediaUrls) async {
    return safeCall(() async {
      for (final url in mediaUrls) {
        // Extract file path from URL
        final uri = Uri.parse(url);
        final pathSegments = uri.pathSegments;
        if (pathSegments.length >= 2) {
          final filePath = pathSegments.sublist(pathSegments.length - 2).join('/');
          
          await _supabaseClient.storage
              .from('community')
              .remove([filePath]);
        }
      }
    });
  }

  @override
  Future<Either<Failure, List<CommunityPost>>> getPostsByAuthor(
    String authorId, {
    int limit = 20,
    int offset = 0,
  }) async {
    return safeCall(() async {
      final request = PostSearchRequest(
        authorId: authorId,
        limit: limit,
        offset: offset,
        orderBy: 'recent',
      );
      
      final result = await getPosts(request);
      return result.fold(
        (failure) => throw failure,
        (posts) => posts,
      );
    });
  }

  @override
  Future<Either<Failure, List<CommunityPost>>> getPopularPosts({
    String? categoryId,
    String? groupId,
    int days = 7,
    int limit = 20,
  }) async {
    return safeCall(() async {
      final startDate = DateTime.now().subtract(Duration(days: days));
      
      final request = PostSearchRequest(
        categoryId: categoryId,
        groupId: groupId,
        startDate: startDate,
        orderBy: 'popular',
        limit: limit,
      );
      
      final result = await getPosts(request);
      return result.fold(
        (failure) => throw failure,
        (posts) => posts,
      );
    });
  }

  @override
  Future<Either<Failure, List<CommunityPost>>> getTrendingPosts({
    String? categoryId,
    String? groupId,
    int limit = 20,
  }) async {
    return safeCall(() async {
      // Trending posts are based on recent activity and engagement
      // We'll use a combination of recent posts with high engagement
      final request = PostSearchRequest(
        categoryId: categoryId,
        groupId: groupId,
        startDate: DateTime.now().subtract(const Duration(days: 3)),
        orderBy: 'popular',
        limit: limit,
      );
      
      final result = await getPosts(request);
      return result.fold(
        (failure) => throw failure,
        (posts) => posts,
      );
    });
  }

  @override
  Future<Either<Failure, List<CommunityPost>>> getPinnedPosts({
    String? categoryId,
    String? groupId,
  }) async {
    return safeCall(() async {
      var query = _supabaseClient
          .from('community_posts')
          .select('''
            *,
            user_profiles!inner(
              username,
              profile_image_url
            ),
            post_categories!inner(
              name,
              color_code
            )
          ''')
          .eq('is_deleted', false)
          .eq('is_pinned', true);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (groupId != null) {
        query = query.eq('group_id', groupId);
      } else {
        query = query.isFilter('group_id', null);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List).map((json) {
        final userProfile = json['user_profiles'] as Map<String, dynamic>;
        final category = json['post_categories'] as Map<String, dynamic>;
        
        json['author_username'] = userProfile['username'];
        json['author_profile_image'] = userProfile['profile_image_url'];
        json['category_name'] = category['name'];
        json['category_color'] = category['color_code'];
        
        return CommunityPostModel.fromJson(json).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, void>> togglePostPin(String postId, String adminId) async {
    return safeCall(() async {
      // Get the post to check current pin status and group
      final postResult = await getPostById(postId);
      final post = postResult.fold(
        (failure) => throw failure,
        (post) => post,
      );

      if (post == null) {
        throw const DatabaseFailure('게시글을 찾을 수 없습니다');
      }

      // Check admin permissions
      bool isAdmin = false;
      
      if (post.groupId != null) {
        // Check if user is group admin
        final memberResponse = await _supabaseClient
            .from('group_members')
            .select('role')
            .eq('group_id', post.groupId!)
            .eq('user_id', adminId)
            .eq('is_active', true)
            .maybeSingle();

        isAdmin = memberResponse != null && memberResponse['role'] == 'admin';
      } else {
        // For public posts, check if user is system admin
        // This would require an admin role system
        // For now, we'll allow post authors to pin their own posts
        isAdmin = post.authorId == adminId;
      }

      if (!isAdmin) {
        throw const DatabaseFailure('게시글을 고정할 권한이 없습니다');
      }

      await _supabaseClient
          .from('community_posts')
          .update({
            'is_pinned': !post.isPinned,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', postId);
    });
  }

  @override
  Future<Either<Failure, List<CommunityPost>>> searchPosts(
    String query, {
    String? categoryId,
    String? groupId,
    int limit = 20,
    int offset = 0,
  }) async {
    return safeCall(() async {
      final request = PostSearchRequest(
        query: query,
        categoryId: categoryId,
        groupId: groupId,
        limit: limit,
        offset: offset,
        orderBy: 'recent',
      );
      
      final result = await getPosts(request);
      return result.fold(
        (failure) => throw failure,
        (posts) => posts,
      );
    });
  }

  @override
  Future<Either<Failure, List<CommunityPost>>> getPostsByTags(
    List<String> tags, {
    String? categoryId,
    String? groupId,
    int limit = 20,
    int offset = 0,
  }) async {
    return safeCall(() async {
      final request = PostSearchRequest(
        tags: tags,
        categoryId: categoryId,
        groupId: groupId,
        limit: limit,
        offset: offset,
        orderBy: 'recent',
      );
      
      final result = await getPosts(request);
      return result.fold(
        (failure) => throw failure,
        (posts) => posts,
      );
    });
  }

  @override
  Future<Either<Failure, List<String>>> getAllTags({
    String? categoryId,
    String? groupId,
    int limit = 100,
  }) async {
    return safeCall(() async {
      var query = _supabaseClient
          .from('community_posts')
          .select('tags')
          .eq('is_deleted', false);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (groupId != null) {
        query = query.eq('group_id', groupId);
      } else {
        query = query.isFilter('group_id', null);
      }

      final response = await query;
      
      final allTags = <String>{};
      for (final post in response as List) {
        final tags = post['tags'] as List?;
        if (tags != null) {
          allTags.addAll(tags.cast<String>());
        }
      }

      final sortedTags = allTags.toList()..sort();
      return sortedTags.take(limit).toList();
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPostStats({
    String? categoryId,
    String? groupId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return safeCall(() async {
      var query = _supabaseClient
          .from('community_posts')
          .select('post_type, created_at, likes_count, comments_count, views_count')
          .eq('is_deleted', false);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (groupId != null) {
        query = query.eq('group_id', groupId);
      } else {
        query = query.isFilter('group_id', null);
      }

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;
      final posts = response as List;

      final stats = {
        'total_posts': posts.length,
        'total_likes': posts.fold<int>(0, (sum, post) => sum + (post['likes_count'] as int)),
        'total_comments': posts.fold<int>(0, (sum, post) => sum + (post['comments_count'] as int)),
        'total_views': posts.fold<int>(0, (sum, post) => sum + (post['views_count'] as int)),
        'post_types': <String, int>{},
      };

      // Count posts by type
      for (final post in posts) {
        final type = post['post_type'] as String;
        final postTypes = stats['post_types'] as Map<String, int>;
        postTypes[type] = (postTypes[type] ?? 0) + 1;
      }

      return stats;
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCategoryStats() async {
    return safeCall(() async {
      final response = await _supabaseClient
          .from('community_posts')
          .select('''
            category_id,
            post_categories!inner(name)
          ''')
          .eq('is_deleted', false);

      final categoryStats = <String, Map<String, dynamic>>{};
      
      for (final post in response as List) {
        final categoryId = post['category_id'] as String;
        final categoryName = post['post_categories']['name'] as String;
        
        if (categoryStats.containsKey(categoryId)) {
          categoryStats[categoryId]!['post_count'] = 
              (categoryStats[categoryId]!['post_count'] as int) + 1;
        } else {
          categoryStats[categoryId] = {
            'category_id': categoryId,
            'category_name': categoryName,
            'post_count': 1,
          };
        }
      }

      return {
        'categories': categoryStats.values.toList(),
        'total_categories': categoryStats.length,
      };
    });
  }

  @override
  Future<Either<Failure, void>> reportPost(
    String postId,
    String reporterId,
    String reason,
    String? description,
  ) async {
    return safeCall(() async {
      await _supabaseClient
          .from('post_reports')
          .insert({
            'id': _uuid.v4(),
            'post_id': postId,
            'reporter_id': reporterId,
            'reason': reason,
            'description': description,
            'status': 'pending',
            'created_at': DateTime.now().toIso8601String(),
          });
    });
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getReportedPosts({
    int limit = 20,
    int offset = 0,
  }) async {
    return safeCall(() async {
      final response = await _supabaseClient
          .from('post_reports')
          .select('''
            *,
            community_posts!inner(
              title,
              content,
              author_id
            ),
            user_profiles!inner(
              username
            )
          ''')
          .eq('status', 'pending')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).cast<Map<String, dynamic>>();
    });
  }

  @override
  Future<Either<Failure, void>> resolvePostReport(
    String reportId,
    String adminId,
    String resolution,
  ) async {
    return safeCall(() async {
      await _supabaseClient
          .from('post_reports')
          .update({
            'status': 'resolved',
            'resolution': resolution,
            'resolved_by': adminId,
            'resolved_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reportId);
    });
  }

  /// Helper method to process posts response
  List<CommunityPost> _processPostsResponse(List response) {
    return response.map((json) {
      // Add user profile and category data for easier access
      final userProfile = json['user_profiles'] as Map<String, dynamic>;
      final category = json['post_categories'] as Map<String, dynamic>;
      
      json['author_username'] = userProfile['username'];
      json['author_profile_image'] = userProfile['profile_image_url'];
      json['category_name'] = category['name'];
      json['category_color'] = category['color_code'];
      
      return CommunityPostModel.fromJson(json).toEntity();
    }).toList();
  }

  /// Helper method to convert PostType to string
  String _postTypeToString(PostType type) {
    switch (type) {
      case PostType.text:
        return 'text';
      case PostType.image:
        return 'image';
      case PostType.video:
        return 'video';
      case PostType.workoutShare:
        return 'workout_share';
    }
  }

  @override
  Future<Either<Failure, List<CommunityPost>>> searchPostsWithCriteria({
    required PostSearchCriteria criteria,
    int limit = 20,
    int offset = 0,
  }) async {
    return safeCall(() async {
      var query = _supabaseClient
          .from('community_posts')
          .select('''
            *,
            user_profiles!inner(
              username,
              profile_image_url
            ),
            post_categories!inner(
              name,
              color_code
            )
          ''')
          .eq('is_deleted', false);

      // Apply search query
      if (criteria.searchQuery != null && criteria.searchQuery!.trim().isNotEmpty) {
        final searchTerm = criteria.searchQuery!.trim();
        query = query.or('title.ilike.%$searchTerm%,content.ilike.%$searchTerm%');
      }

      // Apply category filter
      if (criteria.categoryId != null) {
        query = query.eq('category_id', criteria.categoryId!);
      }

      // Apply author filter
      if (criteria.authorId != null) {
        query = query.eq('author_id', criteria.authorId!);
      }

      // Apply group filter
      if (criteria.groupId != null) {
        query = query.eq('group_id', criteria.groupId!);
      } else if (criteria.groupId == '') {
        // Only public posts (group_id is null)
        query = query.isFilter('group_id', null);
      }

      // Apply post type filter
      if (criteria.postType != null) {
        query = query.eq('post_type', criteria.postType!.value);
      }

      // Apply pinned filter
      if (criteria.isPinned != null) {
        query = query.eq('is_pinned', criteria.isPinned!);
      }

      // Apply date range filters
      if (criteria.startDate != null) {
        query = query.gte('created_at', criteria.startDate!.toIso8601String());
      }

      if (criteria.endDate != null) {
        query = query.lte('created_at', criteria.endDate!.toIso8601String());
      }

      // Apply tags filter
      if (criteria.tags != null && criteria.tags!.isNotEmpty) {
        query = query.overlaps('tags', criteria.tags!);
      }

      // Apply engagement filters
      if (criteria.minLikes != null) {
        query = query.gte('likes_count', criteria.minLikes!);
      }

      if (criteria.minComments != null) {
        query = query.gte('comments_count', criteria.minComments!);
      }

      // Exclude specific posts
      if (criteria.excludePostIds != null && criteria.excludePostIds!.isNotEmpty) {
        query = query.not('id', 'in', '(${criteria.excludePostIds!.join(',')})');
      }

      // Apply sorting
      final orderBy = criteria.sortOption.sqlOrderBy;
      final parts = orderBy.split(' ');
      final column = parts[0];
      final ascending = parts.length > 1 ? parts[1] == 'ASC' : false;
      
      final response = await query
          .order(column, ascending: ascending)
          .range(offset, offset + limit - 1);
      
      return _processPostsResponse(response);
    });
  }

  @override
  Future<Either<Failure, List<CommunityPost>>> getSuggestedPosts(
    String userId, {
    String? groupId,
    int limit = 10,
  }) async {
    return safeCall(() async {
      // Get user's interaction history to understand preferences
      final userInteractions = await _supabaseClient
          .from('post_likes')
          .select('''
            community_posts!inner(
              category_id,
              tags,
              post_type
            )
          ''')
          .eq('user_id', userId)
          .eq('like_type', 'like')
          .limit(50);

      // Analyze user preferences
      final categoryPreferences = <String, int>{};
      final tagPreferences = <String, int>{};
      final typePreferences = <String, int>{};

      for (final interaction in userInteractions as List) {
        final post = interaction['community_posts'] as Map<String, dynamic>;
        
        // Count category preferences
        final categoryId = post['category_id'] as String?;
        if (categoryId != null) {
          categoryPreferences[categoryId] = (categoryPreferences[categoryId] ?? 0) + 1;
        }

        // Count tag preferences
        final tags = post['tags'] as List?;
        if (tags != null) {
          for (final tag in tags.cast<String>()) {
            tagPreferences[tag] = (tagPreferences[tag] ?? 0) + 1;
          }
        }

        // Count type preferences
        final postType = post['post_type'] as String?;
        if (postType != null) {
          typePreferences[postType] = (typePreferences[postType] ?? 0) + 1;
        }
      }

      // Get posts that user hasn't interacted with
      final userLikedPosts = await _supabaseClient
          .from('post_likes')
          .select('post_id')
          .eq('user_id', userId);

      final likedPostIds = (userLikedPosts as List)
          .map((like) => like['post_id'] as String)
          .toList();

      // Build suggestion criteria based on preferences
      var query = _supabaseClient
          .from('community_posts')
          .select('''
            *,
            user_profiles!inner(
              username,
              profile_image_url
            ),
            post_categories!inner(
              name,
              color_code
            )
          ''')
          .eq('is_deleted', false)
          .neq('author_id', userId); // Don't suggest user's own posts

      if (groupId != null) {
        query = query.eq('group_id', groupId);
      } else {
        query = query.isFilter('group_id', null);
      }

      // Exclude already liked posts
      if (likedPostIds.isNotEmpty) {
        query = query.not('id', 'in', '(${likedPostIds.join(',')})');
      }

      // Prefer posts from last 30 days
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      query = query.gte('created_at', thirtyDaysAgo.toIso8601String());

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit * 3); // Get more to filter better matches

      final allPosts = (response as List).map((json) {
        final userProfile = json['user_profiles'] as Map<String, dynamic>;
        final category = json['post_categories'] as Map<String, dynamic>;
        
        json['author_username'] = userProfile['username'];
        json['author_profile_image'] = userProfile['profile_image_url'];
        json['category_name'] = category['name'];
        json['category_color'] = category['color_code'];
        
        return CommunityPostModel.fromJson(json).toEntity();
      }).toList();

      // Score posts based on user preferences
      final scoredPosts = allPosts.map((post) {
        double score = 0.0;

        // Category preference score (40% weight)
        if (categoryPreferences.containsKey(post.categoryId)) {
          score += (categoryPreferences[post.categoryId]! / categoryPreferences.values.reduce((a, b) => a > b ? a : b)) * 40;
        }

        // Tag preference score (30% weight)
        for (final tag in post.tags) {
          if (tagPreferences.containsKey(tag)) {
            score += (tagPreferences[tag]! / tagPreferences.values.reduce((a, b) => a > b ? a : b)) * 30 / post.tags.length;
          }
        }

        // Post type preference score (20% weight)
        if (typePreferences.containsKey(post.postType.value)) {
          score += (typePreferences[post.postType.value]! / typePreferences.values.reduce((a, b) => a > b ? a : b)) * 20;
        }

        // Engagement score (10% weight)
        final engagementScore = (post.likesCount + post.commentsCount) / (post.viewsCount + 1);
        score += engagementScore * 10;

        return MapEntry(post, score);
      }).toList();

      // Sort by score and return top results
      scoredPosts.sort((a, b) => b.value.compareTo(a.value));
      
      return scoredPosts.take(limit).map((entry) => entry.key).toList();
    });
  }

  @override
  Future<Either<Failure, List<CommunityPost>>> getRelatedPosts(
    String postId, {
    int limit = 5,
  }) async {
    return safeCall(() async {
      // Get the original post to find related posts
      final originalPostResult = await getPostById(postId);
      final originalPost = originalPostResult.fold(
        (failure) => throw failure,
        (post) => post,
      );

      if (originalPost == null) {
        return <CommunityPost>[];
      }

      // Find posts with similar tags or same category
      var query = _supabaseClient
          .from('community_posts')
          .select('''
            *,
            user_profiles!inner(
              username,
              profile_image_url
            ),
            post_categories!inner(
              name,
              color_code
            )
          ''')
          .eq('is_deleted', false)
          .neq('id', postId); // Exclude the original post

      // Same group or public posts
      if (originalPost.groupId != null) {
        query = query.eq('group_id', originalPost.groupId!);
      } else {
        query = query.isFilter('group_id', null);
      }

      final response = await query.limit(limit * 3);

      final allPosts = (response as List).map((json) {
        final userProfile = json['user_profiles'] as Map<String, dynamic>;
        final category = json['post_categories'] as Map<String, dynamic>;
        
        json['author_username'] = userProfile['username'];
        json['author_profile_image'] = userProfile['profile_image_url'];
        json['category_name'] = category['name'];
        json['category_color'] = category['color_code'];
        
        return CommunityPostModel.fromJson(json).toEntity();
      }).toList();

      // Score posts based on similarity
      final scoredPosts = allPosts.map((post) {
        double score = 0.0;

        // Same category (50% weight)
        if (post.categoryId == originalPost.categoryId) {
          score += 50;
        }

        // Common tags (40% weight)
        final commonTags = post.tags.where((tag) => originalPost.tags.contains(tag)).length;
        if (originalPost.tags.isNotEmpty) {
          score += (commonTags / originalPost.tags.length) * 40;
        }

        // Same post type (10% weight)
        if (post.postType == originalPost.postType) {
          score += 10;
        }

        return MapEntry(post, score);
      }).toList();

      // Sort by score and return top results
      scoredPosts.sort((a, b) => b.value.compareTo(a.value));
      
      return scoredPosts.take(limit).map((entry) => entry.key).toList();
    });
  }

  @override
  Future<Either<Failure, List<String>>> searchTags(
    String query, {
    String? categoryId,
    String? groupId,
    int limit = 10,
  }) async {
    return safeCall(() async {
      var postQuery = _supabaseClient
          .from('community_posts')
          .select('tags')
          .eq('is_deleted', false);

      if (categoryId != null) {
        postQuery = postQuery.eq('category_id', categoryId);
      }

      if (groupId != null) {
        postQuery = postQuery.eq('group_id', groupId);
      } else {
        postQuery = postQuery.isFilter('group_id', null);
      }

      final response = await postQuery;
      
      final allTags = <String>{};
      for (final post in response as List) {
        final tags = post['tags'] as List?;
        if (tags != null) {
          allTags.addAll(tags.cast<String>());
        }
      }

      // Filter tags that match the query
      final matchingTags = allTags
          .where((tag) => tag.toLowerCase().contains(query.toLowerCase()))
          .toList();

      matchingTags.sort();
      return matchingTags.take(limit).toList();
    });
  }

  @override
  Future<Either<Failure, List<String>>> getSearchSuggestions(
    String userId, {
    String? partialQuery,
    int limit = 10,
  }) async {
    return safeCall(() async {
      // Get popular search terms from recent posts
      final recentPosts = await _supabaseClient
          .from('community_posts')
          .select('title, tags')
          .eq('is_deleted', false)
          .gte('created_at', DateTime.now().subtract(const Duration(days: 7)).toIso8601String())
          .order('views_count', ascending: false)
          .limit(100);

      final suggestions = <String>{};

      for (final post in recentPosts as List) {
        final title = post['title'] as String;
        final tags = post['tags'] as List?;

        // Extract keywords from titles
        final titleWords = title.toLowerCase().split(' ')
            .where((word) => word.length > 2)
            .toList();
        
        suggestions.addAll(titleWords);

        // Add tags
        if (tags != null) {
          suggestions.addAll(tags.cast<String>());
        }
      }

      // Filter by partial query if provided
      List<String> filteredSuggestions;
      if (partialQuery != null && partialQuery.isNotEmpty) {
        filteredSuggestions = suggestions
            .where((suggestion) => suggestion.toLowerCase().contains(partialQuery.toLowerCase()))
            .toList();
      } else {
        filteredSuggestions = suggestions.toList();
      }

      filteredSuggestions.sort();
      return filteredSuggestions.take(limit).toList();
    });
  }

  @override
  Future<Either<Failure, void>> saveSearchQuery(
    String userId,
    String query,
    int resultCount,
  ) async {
    return safeCall(() async {
      await _supabaseClient
          .from('user_search_history')
          .insert({
            'id': _uuid.v4(),
            'user_id': userId,
            'search_query': query,
            'result_count': resultCount,
            'searched_at': DateTime.now().toIso8601String(),
          });
    });
  }
}