import 'package:flutter/foundation.dart';
import 'package:jfit/core/bloc/base_bloc.dart';
import 'package:jfit/core/error/bloc_errors.dart';
import 'package:jfit/features/group_workout_community/domain/entities/community_post.dart';
import 'package:jfit/features/group_workout_community/domain/entities/post_category.dart';
import 'package:jfit/features/group_workout_community/domain/entities/post_search_criteria.dart';

/// Base class for all Community-related states
abstract class CommunityState extends BaseState {
  const CommunityState();
}

/// Initial state when CommunityBloc is first created
class CommunityInitial extends CommunityState {
  const CommunityInitial();

  @override
  List<Object?> get props => [];
}

/// State when community operations are in progress
class CommunityLoading extends CommunityState {
  final String? message;
  final String? operationType;

  const CommunityLoading({
    this.message,
    this.operationType,
  });

  @override
  List<Object?> get props => [message, operationType];
}

/// State when posts are loaded
class PostsLoaded extends CommunityState {
  final List<CommunityPost> posts;
  final bool hasMore;
  final int totalCount;
  final String? categoryId;
  final String? groupId;
  final String? searchQuery;
  final List<String>? tags;
  final PostType? postType;
  final String orderBy;
  final DateTime loadedAt;

  const PostsLoaded({
    required this.posts,
    this.hasMore = false,
    this.totalCount = 0,
    this.categoryId,
    this.groupId,
    this.searchQuery,
    this.tags,
    this.postType,
    this.orderBy = 'recent',
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [
        posts,
        hasMore,
        totalCount,
        categoryId,
        groupId,
        searchQuery,
        tags,
        postType,
        orderBy,
        loadedAt,
      ];

  PostsLoaded copyWith({
    List<CommunityPost>? posts,
    bool? hasMore,
    int? totalCount,
    String? categoryId,
    String? groupId,
    String? searchQuery,
    List<String>? tags,
    PostType? postType,
    String? orderBy,
    DateTime? loadedAt,
  }) {
    return PostsLoaded(
      posts: posts ?? this.posts,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
      categoryId: categoryId ?? this.categoryId,
      groupId: groupId ?? this.groupId,
      searchQuery: searchQuery ?? this.searchQuery,
      tags: tags ?? this.tags,
      postType: postType ?? this.postType,
      orderBy: orderBy ?? this.orderBy,
      loadedAt: loadedAt ?? this.loadedAt,
    );
  }

  /// Add more posts (for pagination)
  PostsLoaded addMorePosts(List<CommunityPost> newPosts) {
    return copyWith(
      posts: [...posts, ...newPosts],
      hasMore: newPosts.isNotEmpty,
      totalCount: totalCount + newPosts.length,
      loadedAt: DateTime.now(),
    );
  }

  /// Update a specific post
  PostsLoaded updatePost(CommunityPost updatedPost) {
    final updatedPosts = posts.map((post) {
      return post.id == updatedPost.id ? updatedPost : post;
    }).toList();

    return copyWith(
      posts: updatedPosts,
      loadedAt: DateTime.now(),
    );
  }

  /// Remove a post
  PostsLoaded removePost(String postId) {
    final filteredPosts = posts.where((post) => post.id != postId).toList();

    return copyWith(
      posts: filteredPosts,
      totalCount: totalCount - 1,
      loadedAt: DateTime.now(),
    );
  }

  /// Add a new post at the beginning
  PostsLoaded addNewPost(CommunityPost newPost) {
    return copyWith(
      posts: [newPost, ...posts],
      totalCount: totalCount + 1,
      loadedAt: DateTime.now(),
    );
  }
}

/// State when a specific post is loaded
class PostDetailsLoaded extends CommunityState {
  final CommunityPost post;
  final DateTime loadedAt;

  const PostDetailsLoaded({
    required this.post,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [post, loadedAt];
}

/// State when a post is successfully created
class PostCreated extends CommunityState {
  final CommunityPost post;
  final DateTime createdAt;

  const PostCreated({
    required this.post,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [post, createdAt];
}

/// State when a post is successfully updated
class PostUpdated extends CommunityState {
  final CommunityPost post;
  final DateTime updatedAt;

  const PostUpdated({
    required this.post,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [post, updatedAt];
}

/// State when a post is successfully deleted
class PostDeleted extends CommunityState {
  final String postId;
  final DateTime deletedAt;

  const PostDeleted({
    required this.postId,
    required this.deletedAt,
  });

  @override
  List<Object?> get props => [postId, deletedAt];
}

/// State when categories are loaded
class CategoriesLoaded extends CommunityState {
  final List<PostCategory> categories;
  final DateTime loadedAt;

  const CategoriesLoaded({
    required this.categories,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [categories, loadedAt];
}

/// State when a specific category is loaded
class CategoryDetailsLoaded extends CommunityState {
  final PostCategory category;
  final DateTime loadedAt;

  const CategoryDetailsLoaded({
    required this.category,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [category, loadedAt];
}

/// State when a category is successfully created
class CategoryCreated extends CommunityState {
  final PostCategory category;
  final DateTime createdAt;

  const CategoryCreated({
    required this.category,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [category, createdAt];
}

/// State when a category is successfully updated
class CategoryUpdated extends CommunityState {
  final PostCategory category;
  final DateTime updatedAt;

  const CategoryUpdated({
    required this.category,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [category, updatedAt];
}

/// State when a category is successfully deleted
class CategoryDeleted extends CommunityState {
  final String categoryId;
  final DateTime deletedAt;

  const CategoryDeleted({
    required this.categoryId,
    required this.deletedAt,
  });

  @override
  List<Object?> get props => [categoryId, deletedAt];
}

/// State when media is successfully uploaded
class MediaUploaded extends CommunityState {
  final List<String> mediaUrls;
  final DateTime uploadedAt;

  const MediaUploaded({
    required this.mediaUrls,
    required this.uploadedAt,
  });

  @override
  List<Object?> get props => [mediaUrls, uploadedAt];
}

/// State when media is successfully deleted
class MediaDeleted extends CommunityState {
  final List<String> deletedUrls;
  final DateTime deletedAt;

  const MediaDeleted({
    required this.deletedUrls,
    required this.deletedAt,
  });

  @override
  List<Object?> get props => [deletedUrls, deletedAt];
}

/// State when posts by author are loaded
class PostsByAuthorLoaded extends CommunityState {
  final String authorId;
  final List<CommunityPost> posts;
  final bool hasMore;
  final DateTime loadedAt;

  const PostsByAuthorLoaded({
    required this.authorId,
    required this.posts,
    this.hasMore = false,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [authorId, posts, hasMore, loadedAt];
}

/// State when popular posts are loaded
class PopularPostsLoaded extends CommunityState {
  final List<CommunityPost> posts;
  final String? categoryId;
  final String? groupId;
  final int days;
  final DateTime loadedAt;

  const PopularPostsLoaded({
    required this.posts,
    this.categoryId,
    this.groupId,
    required this.days,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [posts, categoryId, groupId, days, loadedAt];
}

/// State when trending posts are loaded
class TrendingPostsLoaded extends CommunityState {
  final List<CommunityPost> posts;
  final String? categoryId;
  final String? groupId;
  final DateTime loadedAt;

  const TrendingPostsLoaded({
    required this.posts,
    this.categoryId,
    this.groupId,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [posts, categoryId, groupId, loadedAt];
}

/// State when pinned posts are loaded
class PinnedPostsLoaded extends CommunityState {
  final List<CommunityPost> posts;
  final String? categoryId;
  final String? groupId;
  final DateTime loadedAt;

  const PinnedPostsLoaded({
    required this.posts,
    this.categoryId,
    this.groupId,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [posts, categoryId, groupId, loadedAt];
}

/// State when post pin status is toggled
class PostPinToggled extends CommunityState {
  final String postId;
  final bool isPinned;
  final DateTime toggledAt;

  const PostPinToggled({
    required this.postId,
    required this.isPinned,
    required this.toggledAt,
  });

  @override
  List<Object?> get props => [postId, isPinned, toggledAt];
}

/// State when search results are loaded
class SearchResultsLoaded extends CommunityState {
  final String query;
  final List<CommunityPost> posts;
  final bool hasMore;
  final int totalCount;
  final String? categoryId;
  final String? groupId;
  final DateTime loadedAt;

  const SearchResultsLoaded({
    required this.query,
    required this.posts,
    this.hasMore = false,
    this.totalCount = 0,
    this.categoryId,
    this.groupId,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [query, posts, hasMore, totalCount, categoryId, groupId, loadedAt];

  SearchResultsLoaded copyWith({
    String? query,
    List<CommunityPost>? posts,
    bool? hasMore,
    int? totalCount,
    String? categoryId,
    String? groupId,
    DateTime? loadedAt,
  }) {
    return SearchResultsLoaded(
      query: query ?? this.query,
      posts: posts ?? this.posts,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
      categoryId: categoryId ?? this.categoryId,
      groupId: groupId ?? this.groupId,
      loadedAt: loadedAt ?? this.loadedAt,
    );
  }

  /// Add more search results (for pagination)
  SearchResultsLoaded addMoreResults(List<CommunityPost> newPosts) {
    return copyWith(
      posts: [...posts, ...newPosts],
      hasMore: newPosts.isNotEmpty,
      totalCount: totalCount + newPosts.length,
      loadedAt: DateTime.now(),
    );
  }
}

/// State when search results are cleared
class SearchResultsCleared extends CommunityState {
  const SearchResultsCleared();

  @override
  List<Object?> get props => [];
}

/// State when posts by tags are loaded
class PostsByTagsLoaded extends CommunityState {
  final List<String> tags;
  final List<CommunityPost> posts;
  final bool hasMore;
  final String? categoryId;
  final String? groupId;
  final DateTime loadedAt;

  const PostsByTagsLoaded({
    required this.tags,
    required this.posts,
    this.hasMore = false,
    this.categoryId,
    this.groupId,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [tags, posts, hasMore, categoryId, groupId, loadedAt];
}

/// State when all tags are loaded
class AllTagsLoaded extends CommunityState {
  final List<String> tags;
  final String? categoryId;
  final String? groupId;
  final DateTime loadedAt;

  const AllTagsLoaded({
    required this.tags,
    this.categoryId,
    this.groupId,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [tags, categoryId, groupId, loadedAt];
}

/// State when post statistics are loaded
class PostStatsLoaded extends CommunityState {
  final Map<String, dynamic> stats;
  final String? categoryId;
  final String? groupId;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime loadedAt;

  const PostStatsLoaded({
    required this.stats,
    this.categoryId,
    this.groupId,
    this.startDate,
    this.endDate,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [stats, categoryId, groupId, startDate, endDate, loadedAt];
}

/// State when category statistics are loaded
class CategoryStatsLoaded extends CommunityState {
  final Map<String, dynamic> stats;
  final DateTime loadedAt;

  const CategoryStatsLoaded({
    required this.stats,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [stats, loadedAt];
}

/// State when a post is successfully reported
class PostReported extends CommunityState {
  final String postId;
  final String reason;
  final DateTime reportedAt;

  const PostReported({
    required this.postId,
    required this.reason,
    required this.reportedAt,
  });

  @override
  List<Object?> get props => [postId, reason, reportedAt];
}

/// State when reported posts are loaded
class ReportedPostsLoaded extends CommunityState {
  final List<Map<String, dynamic>> reports;
  final bool hasMore;
  final DateTime loadedAt;

  const ReportedPostsLoaded({
    required this.reports,
    this.hasMore = false,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [reports, hasMore, loadedAt];
}

/// State when a post report is resolved
class PostReportResolved extends CommunityState {
  final String reportId;
  final String resolution;
  final DateTime resolvedAt;

  const PostReportResolved({
    required this.reportId,
    required this.resolution,
    required this.resolvedAt,
  });

  @override
  List<Object?> get props => [reportId, resolution, resolvedAt];
}

/// State when posts feed is refreshed
class PostsRefreshed extends CommunityState {
  final DateTime refreshedAt;

  const PostsRefreshed({
    required this.refreshedAt,
  });

  @override
  List<Object?> get props => [refreshedAt];
}

/// State when posts are filtered by category
class PostsFilteredByCategory extends CommunityState {
  final String? categoryId;
  final String? groupId;
  final DateTime filteredAt;

  const PostsFilteredByCategory({
    this.categoryId,
    this.groupId,
    required this.filteredAt,
  });

  @override
  List<Object?> get props => [categoryId, groupId, filteredAt];
}

/// State when posts are filtered by type
class PostsFilteredByType extends CommunityState {
  final PostType? postType;
  final String? categoryId;
  final String? groupId;
  final DateTime filteredAt;

  const PostsFilteredByType({
    this.postType,
    this.categoryId,
    this.groupId,
    required this.filteredAt,
  });

  @override
  List<Object?> get props => [postType, categoryId, groupId, filteredAt];
}

/// State when posts are sorted
class PostsSorted extends CommunityState {
  final String orderBy;
  final String? categoryId;
  final String? groupId;
  final DateTime sortedAt;

  const PostsSorted({
    required this.orderBy,
    this.categoryId,
    this.groupId,
    required this.sortedAt,
  });

  @override
  List<Object?> get props => [orderBy, categoryId, groupId, sortedAt];
}

/// State when all filters are cleared
class AllFiltersCleared extends CommunityState {
  final DateTime clearedAt;

  const AllFiltersCleared({
    required this.clearedAt,
  });

  @override
  List<Object?> get props => [clearedAt];
}

/// State when enhanced search results are loaded
class EnhancedSearchResultsLoaded extends CommunityState {
  final List<CommunityPost> posts;
  final PostSearchCriteria criteria;
  final bool hasMore;
  final int totalCount;
  final Duration? searchDuration;
  final DateTime searchedAt;

  const EnhancedSearchResultsLoaded({
    required this.posts,
    required this.criteria,
    this.hasMore = false,
    this.totalCount = 0,
    this.searchDuration,
    required this.searchedAt,
  });

  @override
  List<Object?> get props => [posts, criteria, hasMore, totalCount, searchDuration, searchedAt];

  EnhancedSearchResultsLoaded copyWith({
    List<CommunityPost>? posts,
    PostSearchCriteria? criteria,
    bool? hasMore,
    int? totalCount,
    Duration? searchDuration,
    DateTime? searchedAt,
  }) {
    return EnhancedSearchResultsLoaded(
      posts: posts ?? this.posts,
      criteria: criteria ?? this.criteria,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
      searchDuration: searchDuration ?? this.searchDuration,
      searchedAt: searchedAt ?? this.searchedAt,
    );
  }

  /// Add more search results (for pagination)
  EnhancedSearchResultsLoaded addMoreResults(List<CommunityPost> newPosts) {
    return copyWith(
      posts: [...posts, ...newPosts],
      hasMore: newPosts.length >= 20, // Assume more if we got a full page
      totalCount: totalCount + newPosts.length,
      searchedAt: DateTime.now(),
    );
  }
}

/// State when suggested posts are loaded
class SuggestedPostsLoaded extends CommunityState {
  final List<CommunityPost> posts;
  final String userId;
  final String? groupId;
  final DateTime loadedAt;

  const SuggestedPostsLoaded({
    required this.posts,
    required this.userId,
    this.groupId,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [posts, userId, groupId, loadedAt];
}

/// State when related posts are loaded
class RelatedPostsLoaded extends CommunityState {
  final List<CommunityPost> posts;
  final String originalPostId;
  final DateTime loadedAt;

  const RelatedPostsLoaded({
    required this.posts,
    required this.originalPostId,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [posts, originalPostId, loadedAt];
}

/// State when tag search results are loaded
class TagSearchResultsLoaded extends CommunityState {
  final List<String> tags;
  final String query;
  final String? categoryId;
  final String? groupId;
  final DateTime loadedAt;

  const TagSearchResultsLoaded({
    required this.tags,
    required this.query,
    this.categoryId,
    this.groupId,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [tags, query, categoryId, groupId, loadedAt];
}

/// State when search suggestions are loaded
class SearchSuggestionsLoaded extends CommunityState {
  final List<String> suggestions;
  final String userId;
  final String? partialQuery;
  final DateTime loadedAt;

  const SearchSuggestionsLoaded({
    required this.suggestions,
    required this.userId,
    this.partialQuery,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [suggestions, userId, partialQuery, loadedAt];
}

/// State when search query is saved
class SearchQuerySaved extends CommunityState {
  final String userId;
  final String query;
  final int resultCount;
  final DateTime savedAt;

  const SearchQuerySaved({
    required this.userId,
    required this.query,
    required this.resultCount,
    required this.savedAt,
  });

  @override
  List<Object?> get props => [userId, query, resultCount, savedAt];
}

/// State when real-time post update is received
class PostUpdatedRealtime extends CommunityState {
  final String postId;
  final Map<String, dynamic> updateData;
  final DateTime updatedAt;

  const PostUpdatedRealtime({
    required this.postId,
    required this.updateData,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [postId, updateData, updatedAt];
}

/// State when real-time new post is received
class NewPostReceivedRealtime extends CommunityState {
  final Map<String, dynamic> postData;
  final DateTime receivedAt;

  const NewPostReceivedRealtime({
    required this.postData,
    required this.receivedAt,
  });

  @override
  List<Object?> get props => [postData, receivedAt];
}

/// State when a community-related error occurs
class CommunityErrorState extends CommunityState {
  final BlocError error;
  final bool isRetryable;
  final VoidCallback? retryAction;
  final String? recoverySuggestion;
  final String? operationType;

  const CommunityErrorState(
    this.error, {
    this.isRetryable = false,
    this.retryAction,
    this.recoverySuggestion,
    this.operationType,
  });

  @override
  List<Object?> get props => [error, isRetryable, retryAction, recoverySuggestion, operationType];

  /// Get user-friendly Korean error message
  String get userMessage {
    switch (error.code) {
      case 'post_not_found':
        return '게시글을 찾을 수 없습니다.';
      case 'post_creation_failed':
        return '게시글 작성에 실패했습니다.';
      case 'post_update_failed':
        return '게시글 수정에 실패했습니다.';
      case 'post_delete_failed':
        return '게시글 삭제에 실패했습니다.';
      case 'category_not_found':
        return '카테고리를 찾을 수 없습니다.';
      case 'category_creation_failed':
        return '카테고리 생성에 실패했습니다.';
      case 'media_upload_failed':
        return '미디어 업로드에 실패했습니다.';
      case 'insufficient_permissions':
        return '이 작업을 수행할 권한이 없습니다.';
      case 'posts_load_failed':
        return '게시글을 불러오는데 실패했습니다.';
      case 'search_failed':
        return '검색에 실패했습니다.';
      case BlocErrorCodes.networkError:
        return '네트워크 연결을 확인해주세요.';
      case BlocErrorCodes.serverError:
        return '서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.';
      case BlocErrorCodes.connectionTimeout:
        return '연결 시간이 초과되었습니다. 다시 시도해주세요.';
      default:
        final message = error.message.toLowerCase();
        if (message.contains('network') || message.contains('connection')) {
          return '네트워크 연결을 확인해주세요.';
        } else if (message.contains('server') || message.contains('http')) {
          return '서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.';
        } else if (message.contains('timeout')) {
          return '연결 시간이 초과되었습니다. 다시 시도해주세요.';
        } else if (message.contains('permission')) {
          return '이 작업을 수행할 권한이 없습니다.';
        } else if (message.contains('not found')) {
          return '요청한 데이터를 찾을 수 없습니다.';
        } else {
          return '커뮤니티 작업 중 오류가 발생했습니다.';
        }
    }
  }

  /// Get action button text based on error type
  String get actionButtonText {
    if (!isRetryable) {
      return '확인';
    }

    switch (error.code) {
      case BlocErrorCodes.networkError:
      case BlocErrorCodes.connectionTimeout:
        return '다시 시도';
      case BlocErrorCodes.serverError:
        return '새로고침';
      case 'post_creation_failed':
        return '다시 작성';
      case 'post_update_failed':
        return '다시 수정';
      case 'post_delete_failed':
        return '다시 삭제';
      case 'media_upload_failed':
        return '다시 업로드';
      case 'posts_load_failed':
        return '새로고침';
      case 'search_failed':
        return '다시 검색';
      default:
        return '다시 시도';
    }
  }

  /// Get recovery suggestion message
  String get recoveryMessage {
    if (recoverySuggestion != null) {
      return recoverySuggestion!;
    }

    switch (error.code) {
      case 'post_not_found':
        return '게시글이 삭제되었거나 존재하지 않을 수 있습니다.';
      case 'post_creation_failed':
        return '게시글 내용을 확인하고 다시 시도해주세요.';
      case 'post_update_failed':
        return '수정 내용을 확인하고 다시 시도해주세요.';
      case 'post_delete_failed':
        return '게시글 삭제 권한을 확인해주세요.';
      case 'category_not_found':
        return '카테고리가 삭제되었거나 존재하지 않을 수 있습니다.';
      case 'media_upload_failed':
        return '파일 크기나 형식을 확인하고 다시 시도해주세요.';
      case 'insufficient_permissions':
        return '관리자에게 문의하거나 권한을 요청해주세요.';
      case 'posts_load_failed':
        return '네트워크 연결을 확인하고 새로고침해주세요.';
      case 'search_failed':
        return '검색어를 확인하고 다시 시도해주세요.';
      case BlocErrorCodes.networkError:
        return '네트워크 연결을 확인하고 다시 시도해주세요.';
      case BlocErrorCodes.serverError:
        return '잠시 후 다시 시도해주세요.';
      case BlocErrorCodes.connectionTimeout:
        return '연결 시간이 초과되었습니다. 다시 시도해주세요.';
      default:
        return '문제가 지속되면 고객센터에 문의해주세요.';
    }
  }

  /// Create a CommunityErrorState from a generic error
  factory CommunityErrorState.fromError(
    dynamic error, {
    String? code,
    String? operationType,
  }) {
    if (error is BlocError) {
      return CommunityErrorState(
        error,
        operationType: operationType,
      );
    }

    final communityError = CommunityError(
      error.toString(),
      code: code ?? BlocErrorCodes.unknown,
    );

    return CommunityErrorState(
      communityError,
      operationType: operationType,
    );
  }

  /// Create a CommunityErrorState with a specific message and code
  factory CommunityErrorState.withCode(
    String message,
    String code, {
    String? operationType,
  }) {
    return CommunityErrorState(
      CommunityError(message, code: code),
      operationType: operationType,
    );
  }

  /// Create retryable error state
  factory CommunityErrorState.withRetry({
    required BlocError error,
    required VoidCallback retryAction,
    String? recoverySuggestion,
    String? operationType,
  }) {
    return CommunityErrorState(
      error,
      isRetryable: true,
      retryAction: retryAction,
      recoverySuggestion: recoverySuggestion,
      operationType: operationType,
    );
  }

  /// Create specific error states
  factory CommunityErrorState.postNotFound(String postId) {
    return CommunityErrorState.withCode(
      '게시글을 찾을 수 없습니다: "$postId"',
      'post_not_found',
    );
  }

  factory CommunityErrorState.postCreationFailed([String? details]) {
    return CommunityErrorState.withCode(
      '게시글 작성에 실패했습니다${details != null ? ': $details' : ''}',
      'post_creation_failed',
      operationType: 'creating_post',
    );
  }

  factory CommunityErrorState.postUpdateFailed([String? details]) {
    return CommunityErrorState.withCode(
      '게시글 수정에 실패했습니다${details != null ? ': $details' : ''}',
      'post_update_failed',
      operationType: 'updating_post',
    );
  }

  factory CommunityErrorState.postDeleteFailed([String? details]) {
    return CommunityErrorState.withCode(
      '게시글 삭제에 실패했습니다${details != null ? ': $details' : ''}',
      'post_delete_failed',
      operationType: 'deleting_post',
    );
  }

  factory CommunityErrorState.categoryNotFound(String categoryId) {
    return CommunityErrorState.withCode(
      '카테고리를 찾을 수 없습니다: "$categoryId"',
      'category_not_found',
    );
  }

  factory CommunityErrorState.mediaUploadFailed([String? details]) {
    return CommunityErrorState.withCode(
      '미디어 업로드에 실패했습니다${details != null ? ': $details' : ''}',
      'media_upload_failed',
      operationType: 'uploading_media',
    );
  }

  factory CommunityErrorState.insufficientPermissions(String operation) {
    return CommunityErrorState.withCode(
      '권한이 부족합니다: $operation',
      'insufficient_permissions',
    );
  }

  factory CommunityErrorState.postsLoadFailed([String? details]) {
    return CommunityErrorState.withCode(
      '게시글을 불러오는데 실패했습니다${details != null ? ': $details' : ''}',
      'posts_load_failed',
      operationType: 'loading_posts',
    );
  }

  factory CommunityErrorState.searchFailed([String? details]) {
    return CommunityErrorState.withCode(
      '검색에 실패했습니다${details != null ? ': $details' : ''}',
      'search_failed',
      operationType: 'searching_posts',
    );
  }
}

/// Custom error class for community-related errors
class CommunityError extends BlocError {
  const CommunityError(String message, {String? code}) : super(message, code: code);
}