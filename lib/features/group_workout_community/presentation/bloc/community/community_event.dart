import 'package:jfit/core/bloc/base_bloc.dart';
import 'package:jfit/features/group_workout_community/domain/entities/community_post.dart';
import 'package:jfit/features/group_workout_community/domain/entities/post_search_criteria.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/community_repository.dart';

/// Base class for all Community-related events
abstract class CommunityEvent extends BaseEvent {
  const CommunityEvent();
}

/// Event to load posts with filtering and pagination
class LoadPosts extends CommunityEvent {
  final PostSearchRequest request;
  final bool forceRefresh;

  const LoadPosts({
    required this.request,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [request, forceRefresh];
}

/// Event to load more posts (pagination)
class LoadMorePosts extends CommunityEvent {
  final PostSearchRequest request;

  const LoadMorePosts(this.request);

  @override
  List<Object?> get props => [request];
}

/// Event to load a specific post by ID
class LoadPostById extends CommunityEvent {
  final String postId;

  const LoadPostById(this.postId);

  @override
  List<Object?> get props => [postId];
}

/// Event to create a new post
class CreatePost extends CommunityEvent {
  final CreatePostRequest request;

  const CreatePost(this.request);

  @override
  List<Object?> get props => [request];
}

/// Event to update an existing post
class UpdatePost extends CommunityEvent {
  final String postId;
  final UpdatePostRequest request;
  final String userId;

  const UpdatePost({
    required this.postId,
    required this.request,
    required this.userId,
  });

  @override
  List<Object?> get props => [postId, request, userId];
}

/// Event to delete a post
class DeletePost extends CommunityEvent {
  final String postId;
  final String userId;

  const DeletePost({
    required this.postId,
    required this.userId,
  });

  @override
  List<Object?> get props => [postId, userId];
}

/// Event to load post categories
class LoadCategories extends CommunityEvent {
  const LoadCategories();

  @override
  List<Object?> get props => [];
}

/// Event to load a specific category by ID
class LoadCategoryById extends CommunityEvent {
  final String categoryId;

  const LoadCategoryById(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Event to create a new category
class CreateCategory extends CommunityEvent {
  final CreateCategoryRequest request;

  const CreateCategory(this.request);

  @override
  List<Object?> get props => [request];
}

/// Event to update a category
class UpdateCategory extends CommunityEvent {
  final String categoryId;
  final CreateCategoryRequest request;

  const UpdateCategory({
    required this.categoryId,
    required this.request,
  });

  @override
  List<Object?> get props => [categoryId, request];
}

/// Event to delete a category
class DeleteCategory extends CommunityEvent {
  final String categoryId;

  const DeleteCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Event to upload media files
class UploadMedia extends CommunityEvent {
  final List<String> filePaths;

  const UploadMedia(this.filePaths);

  @override
  List<Object?> get props => [filePaths];
}

/// Event to delete media files
class DeleteMedia extends CommunityEvent {
  final List<String> mediaUrls;

  const DeleteMedia(this.mediaUrls);

  @override
  List<Object?> get props => [mediaUrls];
}

/// Event to load posts by author
class LoadPostsByAuthor extends CommunityEvent {
  final String authorId;
  final int limit;
  final int offset;

  const LoadPostsByAuthor({
    required this.authorId,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [authorId, limit, offset];
}

/// Event to load popular posts
class LoadPopularPosts extends CommunityEvent {
  final String? categoryId;
  final String? groupId;
  final int days;
  final int limit;

  const LoadPopularPosts({
    this.categoryId,
    this.groupId,
    this.days = 7,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [categoryId, groupId, days, limit];
}

/// Event to load trending posts
class LoadTrendingPosts extends CommunityEvent {
  final String? categoryId;
  final String? groupId;
  final int limit;

  const LoadTrendingPosts({
    this.categoryId,
    this.groupId,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [categoryId, groupId, limit];
}

/// Event to load pinned posts
class LoadPinnedPosts extends CommunityEvent {
  final String? categoryId;
  final String? groupId;

  const LoadPinnedPosts({
    this.categoryId,
    this.groupId,
  });

  @override
  List<Object?> get props => [categoryId, groupId];
}

/// Event to toggle post pin status
class TogglePostPin extends CommunityEvent {
  final String postId;
  final String adminId;

  const TogglePostPin({
    required this.postId,
    required this.adminId,
  });

  @override
  List<Object?> get props => [postId, adminId];
}

/// Event to search posts
class SearchPosts extends CommunityEvent {
  final String query;
  final String? categoryId;
  final String? groupId;
  final int limit;
  final int offset;

  const SearchPosts({
    required this.query,
    this.categoryId,
    this.groupId,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [query, categoryId, groupId, limit, offset];
}

/// Event to load more search results
class LoadMoreSearchResults extends CommunityEvent {
  final String query;
  final String? categoryId;
  final String? groupId;

  const LoadMoreSearchResults({
    required this.query,
    this.categoryId,
    this.groupId,
  });

  @override
  List<Object?> get props => [query, categoryId, groupId];
}

/// Event to clear search results
class ClearSearchResults extends CommunityEvent {
  const ClearSearchResults();

  @override
  List<Object?> get props => [];
}

/// Event to load posts by tags
class LoadPostsByTags extends CommunityEvent {
  final List<String> tags;
  final String? categoryId;
  final String? groupId;
  final int limit;
  final int offset;

  const LoadPostsByTags({
    required this.tags,
    this.categoryId,
    this.groupId,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [tags, categoryId, groupId, limit, offset];
}

/// Event to load all available tags
class LoadAllTags extends CommunityEvent {
  final String? categoryId;
  final String? groupId;
  final int limit;

  const LoadAllTags({
    this.categoryId,
    this.groupId,
    this.limit = 100,
  });

  @override
  List<Object?> get props => [categoryId, groupId, limit];
}

/// Event to load post statistics
class LoadPostStats extends CommunityEvent {
  final String? categoryId;
  final String? groupId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadPostStats({
    this.categoryId,
    this.groupId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [categoryId, groupId, startDate, endDate];
}

/// Event to load category statistics
class LoadCategoryStats extends CommunityEvent {
  const LoadCategoryStats();

  @override
  List<Object?> get props => [];
}

/// Event to report a post
class ReportPost extends CommunityEvent {
  final String postId;
  final String reporterId;
  final String reason;
  final String? description;

  const ReportPost({
    required this.postId,
    required this.reporterId,
    required this.reason,
    this.description,
  });

  @override
  List<Object?> get props => [postId, reporterId, reason, description];
}

/// Event to load reported posts (admin only)
class LoadReportedPosts extends CommunityEvent {
  final int limit;
  final int offset;

  const LoadReportedPosts({
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [limit, offset];
}

/// Event to resolve a post report
class ResolvePostReport extends CommunityEvent {
  final String reportId;
  final String adminId;
  final String resolution;

  const ResolvePostReport({
    required this.reportId,
    required this.adminId,
    required this.resolution,
  });

  @override
  List<Object?> get props => [reportId, adminId, resolution];
}

/// Event to refresh posts feed
class RefreshPosts extends CommunityEvent {
  final PostSearchRequest? request;

  const RefreshPosts({this.request});

  @override
  List<Object?> get props => [request];
}

/// Event to filter posts by category
class FilterPostsByCategory extends CommunityEvent {
  final String? categoryId;
  final String? groupId;

  const FilterPostsByCategory({
    this.categoryId,
    this.groupId,
  });

  @override
  List<Object?> get props => [categoryId, groupId];
}

/// Event to filter posts by type
class FilterPostsByType extends CommunityEvent {
  final PostType? postType;
  final String? categoryId;
  final String? groupId;

  const FilterPostsByType({
    this.postType,
    this.categoryId,
    this.groupId,
  });

  @override
  List<Object?> get props => [postType, categoryId, groupId];
}

/// Event to sort posts
class SortPosts extends CommunityEvent {
  final String orderBy; // 'recent', 'popular', 'views', 'comments'
  final String? categoryId;
  final String? groupId;

  const SortPosts({
    required this.orderBy,
    this.categoryId,
    this.groupId,
  });

  @override
  List<Object?> get props => [orderBy, categoryId, groupId];
}

/// Event to clear all filters
class ClearAllFilters extends CommunityEvent {
  const ClearAllFilters();

  @override
  List<Object?> get props => [];
}

/// Event to handle real-time post update
class HandlePostUpdate extends CommunityEvent {
  final String postId;
  final Map<String, dynamic> updateData;

  const HandlePostUpdate({
    required this.postId,
    required this.updateData,
  });

  @override
  List<Object?> get props => [postId, updateData];
}

/// Event to handle real-time new post
class HandleNewPost extends CommunityEvent {
  final Map<String, dynamic> postData;

  const HandleNewPost(this.postData);

  @override
  List<Object?> get props => [postData];
}

/// Event to search posts with enhanced criteria
class SearchPostsWithCriteria extends CommunityEvent {
  final PostSearchCriteria criteria;
  final int limit;
  final int offset;

  const SearchPostsWithCriteria({
    required this.criteria,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [criteria, limit, offset];
}

/// Event to load more enhanced search results
class LoadMoreEnhancedSearchResults extends CommunityEvent {
  const LoadMoreEnhancedSearchResults();

  @override
  List<Object?> get props => [];
}

/// Event to get suggested posts for a user
class LoadSuggestedPosts extends CommunityEvent {
  final String userId;
  final String? groupId;
  final int limit;

  const LoadSuggestedPosts({
    required this.userId,
    this.groupId,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [userId, groupId, limit];
}

/// Event to get related posts
class LoadRelatedPosts extends CommunityEvent {
  final String postId;
  final int limit;

  const LoadRelatedPosts({
    required this.postId,
    this.limit = 5,
  });

  @override
  List<Object?> get props => [postId, limit];
}

/// Event to search tags with autocomplete
class SearchTags extends CommunityEvent {
  final String query;
  final String? categoryId;
  final String? groupId;
  final int limit;

  const SearchTags({
    required this.query,
    this.categoryId,
    this.groupId,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [query, categoryId, groupId, limit];
}

/// Event to get search suggestions
class LoadSearchSuggestions extends CommunityEvent {
  final String userId;
  final String? partialQuery;
  final int limit;

  const LoadSearchSuggestions({
    required this.userId,
    this.partialQuery,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [userId, partialQuery, limit];
}

/// Event to save search query for analytics
class SaveSearchQuery extends CommunityEvent {
  final String userId;
  final String query;
  final int resultCount;

  const SaveSearchQuery({
    required this.userId,
    required this.query,
    required this.resultCount,
  });

  @override
  List<Object?> get props => [userId, query, resultCount];
}