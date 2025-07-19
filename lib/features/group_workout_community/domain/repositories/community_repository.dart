import 'package:dartz/dartz.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import '../entities/community_post.dart';
import '../entities/post_comment.dart';
import '../entities/post_category.dart';
import '../entities/post_search_criteria.dart';

/// Request models for community operations
class CreatePostRequest {
  final String authorId;
  final String? groupId; // null for public community posts
  final String title;
  final String content;
  final PostType postType;
  final String categoryId;
  final List<String> mediaUrls;
  final List<String> tags;

  const CreatePostRequest({
    required this.authorId,
    this.groupId,
    required this.title,
    required this.content,
    required this.postType,
    required this.categoryId,
    this.mediaUrls = const [],
    this.tags = const [],
  });
}

class UpdatePostRequest {
  final String? title;
  final String? content;
  final String? categoryId;
  final List<String>? mediaUrls;
  final List<String>? tags;
  final bool? isPinned;

  const UpdatePostRequest({
    this.title,
    this.content,
    this.categoryId,
    this.mediaUrls,
    this.tags,
    this.isPinned,
  });
}

class CreateCategoryRequest {
  final String name;
  final String description;
  final String? iconUrl;
  final String colorCode;
  final int sortOrder;

  const CreateCategoryRequest({
    required this.name,
    required this.description,
    this.iconUrl,
    required this.colorCode,
    required this.sortOrder,
  });
}

class PostSearchRequest {
  final String? query;
  final String? categoryId;
  final String? groupId;
  final List<String>? tags;
  final PostType? postType;
  final String? authorId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String orderBy; // 'recent', 'popular', 'views', 'comments'
  final int limit;
  final int offset;

  const PostSearchRequest({
    this.query,
    this.categoryId,
    this.groupId,
    this.tags,
    this.postType,
    this.authorId,
    this.startDate,
    this.endDate,
    this.orderBy = 'recent',
    this.limit = 20,
    this.offset = 0,
  });
}

/// Repository interface for community operations
/// Handles posts, categories, and media management
abstract class CommunityRepository extends BaseRepository {
  /// Get posts with filtering and pagination
  /// Supports various filters and sorting options
  Future<Either<Failure, List<CommunityPost>>> getPosts(PostSearchRequest request);

  /// Get a specific post by ID
  /// Returns null if post doesn't exist or is deleted
  Future<Either<Failure, CommunityPost?>> getPostById(String postId);

  /// Create a new community post
  /// Handles both public and group-specific posts
  Future<Either<Failure, CommunityPost>> createPost(CreatePostRequest request);

  /// Update an existing post (author or admin only)
  /// Allows updating content, category, media, etc.
  Future<Either<Failure, CommunityPost>> updatePost(
    String postId,
    UpdatePostRequest request,
    String userId,
  );

  /// Delete a post (author or admin only)
  /// Soft delete - marks as deleted but preserves data
  Future<Either<Failure, void>> deletePost(String postId, String userId);

  /// Get all available post categories
  /// Returns active categories ordered by sort order
  Future<Either<Failure, List<PostCategory>>> getCategories();

  /// Get a specific category by ID
  Future<Either<Failure, PostCategory?>> getCategoryById(String categoryId);

  /// Create a new post category (admin only)
  /// For organizing posts into different topics
  Future<Either<Failure, PostCategory>> createCategory(CreateCategoryRequest request);

  /// Update a category (admin only)
  Future<Either<Failure, PostCategory>> updateCategory(
    String categoryId,
    CreateCategoryRequest request,
  );

  /// Delete a category (admin only)
  /// Cannot delete if posts are using this category
  Future<Either<Failure, void>> deleteCategory(String categoryId);

  /// Upload media files (images/videos)
  /// Returns URLs of uploaded files
  Future<Either<Failure, List<String>>> uploadMedia(List<String> filePaths);

  /// Delete uploaded media files
  /// Removes files from storage
  Future<Either<Failure, void>> deleteMedia(List<String> mediaUrls);

  /// Get posts by a specific author
  /// Useful for user profiles
  Future<Either<Failure, List<CommunityPost>>> getPostsByAuthor(
    String authorId, {
    int limit = 20,
    int offset = 0,
  });

  /// Get popular posts
  /// Based on likes, comments, and views
  Future<Either<Failure, List<CommunityPost>>> getPopularPosts({
    String? categoryId,
    String? groupId,
    int days = 7, // popularity within last N days
    int limit = 20,
  });

  /// Get trending posts
  /// Based on recent activity and engagement
  Future<Either<Failure, List<CommunityPost>>> getTrendingPosts({
    String? categoryId,
    String? groupId,
    int limit = 20,
  });

  /// Get pinned posts
  /// Posts that are pinned to the top
  Future<Either<Failure, List<CommunityPost>>> getPinnedPosts({
    String? categoryId,
    String? groupId,
  });

  /// Pin or unpin a post (admin only)
  Future<Either<Failure, void>> togglePostPin(String postId, String adminId);

  /// Search posts by content
  /// Full-text search in title and content
  Future<Either<Failure, List<CommunityPost>>> searchPosts(
    String query, {
    String? categoryId,
    String? groupId,
    int limit = 20,
    int offset = 0,
  });

  /// Get posts with specific tags
  Future<Either<Failure, List<CommunityPost>>> getPostsByTags(
    List<String> tags, {
    String? categoryId,
    String? groupId,
    int limit = 20,
    int offset = 0,
  });

  /// Get all unique tags used in posts
  /// For tag suggestions and filtering
  Future<Either<Failure, List<String>>> getAllTags({
    String? categoryId,
    String? groupId,
    int limit = 100,
  });

  /// Get post statistics
  /// Returns counts and metrics for posts
  Future<Either<Failure, Map<String, dynamic>>> getPostStats({
    String? categoryId,
    String? groupId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get category statistics
  /// Returns post counts per category
  Future<Either<Failure, Map<String, dynamic>>> getCategoryStats();

  /// Report a post for inappropriate content
  /// For content moderation
  Future<Either<Failure, void>> reportPost(
    String postId,
    String reporterId,
    String reason,
    String? description,
  );

  /// Get reported posts (admin only)
  /// For content moderation
  Future<Either<Failure, List<Map<String, dynamic>>>> getReportedPosts({
    int limit = 20,
    int offset = 0,
  });

  /// Resolve a post report (admin only)
  /// Mark report as handled
  Future<Either<Failure, void>> resolvePostReport(
    String reportId,
    String adminId,
    String resolution,
  );

  /// Enhanced search for posts with advanced filtering and sorting
  /// Supports comprehensive search criteria including content, metadata, and engagement filters
  Future<Either<Failure, List<CommunityPost>>> searchPostsWithCriteria({
    required PostSearchCriteria criteria,
    int limit = 20,
    int offset = 0,
  });

  /// Get suggested posts for a user based on their activity and preferences
  /// Uses recommendation algorithm to suggest relevant posts
  Future<Either<Failure, List<CommunityPost>>> getSuggestedPosts(
    String userId, {
    String? groupId,
    int limit = 10,
  });

  /// Get related posts based on tags and category
  /// Finds posts similar to the given post
  Future<Either<Failure, List<CommunityPost>>> getRelatedPosts(
    String postId, {
    int limit = 5,
  });

  /// Advanced tag search with autocomplete
  /// Returns tags matching the query for search suggestions
  Future<Either<Failure, List<String>>> searchTags(
    String query, {
    String? categoryId,
    String? groupId,
    int limit = 10,
  });

  /// Get post search suggestions based on user's search history
  /// Returns popular search terms and trending topics
  Future<Either<Failure, List<String>>> getSearchSuggestions(
    String userId, {
    String? partialQuery,
    int limit = 10,
  });

  /// Save user's search query for analytics and suggestions
  /// Helps improve search experience over time
  Future<Either<Failure, void>> saveSearchQuery(
    String userId,
    String query,
    int resultCount,
  );
}