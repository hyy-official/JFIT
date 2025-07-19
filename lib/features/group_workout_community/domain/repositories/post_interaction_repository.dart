import 'package:dartz/dartz.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import '../entities/post_comment.dart';
import '../entities/community_post.dart';

/// Request models for post interaction operations
class AddCommentRequest {
  final String postId;
  final String authorId;
  final String content;
  final String? parentCommentId; // For replies

  const AddCommentRequest({
    required this.postId,
    required this.authorId,
    required this.content,
    this.parentCommentId,
  });
}

class UpdateCommentRequest {
  final String content;

  const UpdateCommentRequest({
    required this.content,
  });
}

class ToggleLikeRequest {
  final String? postId;
  final String? commentId;
  final String userId;
  final LikeType likeType;

  const ToggleLikeRequest({
    this.postId,
    this.commentId,
    required this.userId,
    required this.likeType,
  });

  bool get isPostLike => postId != null && commentId == null;
  bool get isCommentLike => commentId != null && postId == null;
}

class BookmarkRequest {
  final String postId;
  final String userId;

  const BookmarkRequest({
    required this.postId,
    required this.userId,
  });
}

/// Repository interface for post interaction operations
/// Handles comments, likes, bookmarks, and view tracking
abstract class PostInteractionRepository extends BaseRepository {
  /// Get comments for a specific post
  /// Supports pagination and nested comment structure
  Future<Either<Failure, List<PostComment>>> getComments(
    String postId, {
    int limit = 50,
    int offset = 0,
    String? parentCommentId, // null for top-level comments
  });

  /// Get a specific comment by ID
  Future<Either<Failure, PostComment?>> getCommentById(String commentId);

  /// Add a new comment to a post
  /// Can be a top-level comment or a reply to another comment
  Future<Either<Failure, PostComment>> addComment(AddCommentRequest request);

  /// Update an existing comment (author only)
  /// Only content can be updated
  Future<Either<Failure, PostComment>> updateComment(
    String commentId,
    UpdateCommentRequest request,
    String userId,
  );

  /// Delete a comment (author or admin only)
  /// Soft delete - marks as deleted but preserves data
  Future<Either<Failure, void>> deleteComment(String commentId, String userId);

  /// Toggle like/dislike on a post or comment
  /// If already liked with same type, removes the like
  /// If liked with different type, changes the like type
  Future<Either<Failure, void>> toggleLike(ToggleLikeRequest request);

  /// Check if user has liked a post or comment
  /// Returns the like type if liked, null if not liked
  Future<Either<Failure, LikeType?>> getUserLikeStatus(
    String userId, {
    String? postId,
    String? commentId,
  });

  /// Get like statistics for a post or comment
  /// Returns counts for likes and dislikes
  Future<Either<Failure, Map<String, int>>> getLikeStats({
    String? postId,
    String? commentId,
  });

  /// Increment view count for a post
  /// Called when a user views a post
  Future<Either<Failure, void>> incrementViewCount(String postId);

  /// Get view count for a post
  Future<Either<Failure, int>> getViewCount(String postId);

  /// Bookmark or unbookmark a post
  /// Toggle bookmark status for a user
  Future<Either<Failure, void>> toggleBookmark(BookmarkRequest request);

  /// Check if user has bookmarked a post
  Future<Either<Failure, bool>> isPostBookmarked(String postId, String userId);

  /// Get user's bookmarked posts
  /// Returns posts ordered by bookmark date
  Future<Either<Failure, List<CommunityPost>>> getUserBookmarks(
    String userId, {
    int limit = 20,
    int offset = 0,
  });

  /// Get comment thread (parent comment and all its replies)
  /// Useful for displaying nested comment structures
  Future<Either<Failure, List<PostComment>>> getCommentThread(
    String parentCommentId, {
    int maxDepth = 3,
  });

  /// Get top-level comments with reply counts
  /// Returns comments with metadata about replies
  Future<Either<Failure, List<Map<String, dynamic>>>> getCommentsWithReplyCounts(
    String postId, {
    int limit = 20,
    int offset = 0,
  });

  /// Get recent comments by a user
  /// Useful for user activity tracking
  Future<Either<Failure, List<PostComment>>> getUserRecentComments(
    String userId, {
    int limit = 20,
    int days = 30,
  });

  /// Get most liked comments for a post
  /// Returns comments ordered by like count
  Future<Either<Failure, List<PostComment>>> getMostLikedComments(
    String postId, {
    int limit = 10,
  });

  /// Report a comment for inappropriate content
  /// For content moderation
  Future<Either<Failure, void>> reportComment(
    String commentId,
    String reporterId,
    String reason,
    String? description,
  );

  /// Get interaction statistics for a post
  /// Returns comprehensive interaction metrics
  Future<Either<Failure, Map<String, dynamic>>> getPostInteractionStats(
    String postId,
  );

  /// Get user's interaction history with a post
  /// Returns likes, comments, bookmarks by the user
  Future<Either<Failure, Map<String, dynamic>>> getUserPostInteractions(
    String postId,
    String userId,
  );

  /// Get trending comments
  /// Based on recent likes and replies
  Future<Either<Failure, List<PostComment>>> getTrendingComments({
    String? postId,
    int hours = 24,
    int limit = 20,
  });

  /// Get comment statistics for a user
  /// Returns user's comment activity metrics
  Future<Either<Failure, Map<String, dynamic>>> getUserCommentStats(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Pin or unpin a comment (post author or admin only)
  /// Pinned comments appear at the top
  Future<Either<Failure, void>> toggleCommentPin(
    String commentId,
    String userId,
  );

  /// Get pinned comments for a post
  Future<Either<Failure, List<PostComment>>> getPinnedComments(String postId);

  /// Mark comments as read for notification purposes
  /// For tracking which comments user has seen
  Future<Either<Failure, void>> markCommentsAsRead(
    List<String> commentIds,
    String userId,
  );

  /// Get unread comment count for a user
  /// For notification badges
  Future<Either<Failure, int>> getUnreadCommentCount(String userId);

  /// Get comments that mention a specific user
  /// For notification purposes
  Future<Either<Failure, List<PostComment>>> getCommentsMentioningUser(
    String userId, {
    int limit = 20,
    bool unreadOnly = false,
  });
}