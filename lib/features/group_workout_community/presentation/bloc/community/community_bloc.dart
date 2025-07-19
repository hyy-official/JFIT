import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/bloc/base_bloc.dart';
import 'package:jfit/core/bloc/bloc_event_bus.dart';
import 'package:jfit/core/error/bloc_errors.dart';

import 'package:jfit/features/group_workout_community/domain/entities/community_post.dart';
import 'package:jfit/features/group_workout_community/domain/entities/post_category.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/community_repository.dart';
import 'package:jfit/features/group_workout_community/data/services/group_realtime_manager.dart';
import '../../../data/services/pagination_service.dart';
import '../../../data/services/group_cache_service.dart';
import 'community_event.dart';
import 'community_state.dart';

/// BLoC for managing community operations
/// Handles posts, categories, media upload, and search functionality
class CommunityBloc extends BaseBloc<CommunityEvent, CommunityState> {
  final CommunityRepository _repository;

  // Cache for performance optimization
  final Map<String, List<CommunityPost>> _postsCache = {};
  final Map<String, CommunityPost> _postDetailsCache = {};
  final Map<String, List<PostCategory>> _categoriesCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiration = Duration(minutes: 5);

  // Pagination tracking
  final Map<String, int> _currentOffsets = {};
  final Map<String, bool> _hasMoreData = {};

  // Current filters and sorting
  String? _currentCategoryId;
  String? _currentGroupId;
  PostType? _currentPostType;
  String _currentOrderBy = 'recent';
  String? _currentSearchQuery;
  List<String>? _currentTags;

  // Real-time subscriptions
  final Map<String, StreamSubscription> _realtimeSubscriptions = {};

  // Performance metrics
  int _cacheHits = 0;
  int _cacheMisses = 0;

  final GroupRealtimeManager? _realtimeManager;

  CommunityBloc({
    required CommunityRepository repository,
    GroupRealtimeManager? realtimeManager,
  })  : _repository = repository,
        _realtimeManager = realtimeManager,
        super(const CommunityInitial()) {
    // Register event handlers
    on<LoadPosts>(_onLoadPosts);
    on<LoadMorePosts>(_onLoadMorePosts);
    on<LoadPostById>(_onLoadPostById);
    on<CreatePost>(_onCreatePost);
    on<UpdatePost>(_onUpdatePost);
    on<DeletePost>(_onDeletePost);
    on<SearchPosts>(_onSearchPosts);
    on<LoadMoreSearchResults>(_onLoadMoreSearchResults);
    on<ClearSearchResults>(_onClearSearchResults);
    on<LoadCategories>(_onLoadCategories);
    on<LoadPostsByTags>(_onLoadPostsByTags);
    on<LoadAllTags>(_onLoadAllTags);
    on<LoadPostStats>(_onLoadPostStats);
    on<LoadCategoryStats>(_onLoadCategoryStats);
    on<ReportPost>(_onReportPost);
    on<LoadReportedPosts>(_onLoadReportedPosts);
    on<ResolvePostReport>(_onResolvePostReport);
    on<RefreshPosts>(_onRefreshPosts);
    on<FilterPostsByCategory>(_onFilterPostsByCategory);
    on<FilterPostsByType>(_onFilterPostsByType);
    on<SortPosts>(_onSortPosts);
    on<ClearAllFilters>(_onClearAllFilters);
    on<HandlePostUpdate>(_onHandlePostUpdate);
    on<HandleNewPost>(_onHandleNewPost);
    on<SearchPostsWithCriteria>(_onSearchPostsWithCriteria);
    on<LoadMoreEnhancedSearchResults>(_onLoadMoreEnhancedSearchResults);
    on<LoadSuggestedPosts>(_onLoadSuggestedPosts);
    on<LoadRelatedPosts>(_onLoadRelatedPosts);
    on<SearchTags>(_onSearchTags);
    on<LoadSearchSuggestions>(_onLoadSearchSuggestions);
    on<SaveSearchQuery>(_onSaveSearchQuery);
  }

  /// Handle load posts event
  Future<void> _onLoadPosts(
    LoadPosts event,
    Emitter<CommunityState> emit,
  ) async {
    emit(const CommunityLoading(
      message: '게시글을 불러오고 있습니다...',
      operationType: 'loading_posts',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getPosts(event.request);
        
        result.fold(
          (failure) => emit(CommunityErrorState.fromError(
            failure,
            operationType: 'loading_posts',
          )),
          (posts) {
            emit(PostsLoaded(
              posts: posts,
              hasMore: posts.length == event.request.limit,
              categoryId: event.request.categoryId,
              groupId: event.request.groupId,
              postType: event.request.postType,
              orderBy: event.request.orderBy,
              searchQuery: event.request.query,
              tags: event.request.tags,
              loadedAt: DateTime.now(),
            ));
          },
        );
      },
      (error) => emit(CommunityErrorState.fromError(
        error,
        operationType: 'loading_posts',
      )),
    );
  }

  /// Handle load more posts event
  Future<void> _onLoadMorePosts(
    LoadMorePosts event,
    Emitter<CommunityState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PostsLoaded || !currentState.hasMore) {
      return;
    }

    emit(const CommunityLoading(
      message: '더 많은 게시글을 불러오고 있습니다...',
      operationType: 'loading_more_posts',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getPosts(PostSearchRequest(
          categoryId: currentState.categoryId,
          groupId: currentState.groupId,
          postType: currentState.postType,
          orderBy: currentState.orderBy,
          limit: 20,
          offset: currentState.posts.length,
        ));
        
        result.fold(
          (failure) => emit(CommunityErrorState.fromError(
            failure,
            operationType: 'loading_more_posts',
          )),
          (newPosts) {
            final allPosts = [...currentState.posts, ...newPosts];
            
            emit(PostsLoaded(
              posts: allPosts,
              hasMore: newPosts.length == 20,
              categoryId: currentState.categoryId,
              groupId: currentState.groupId,
              postType: currentState.postType,
              orderBy: currentState.orderBy,
              searchQuery: currentState.searchQuery,
              tags: currentState.tags,
              loadedAt: DateTime.now(),
            ));
          },
        );
      },
      (error) => emit(CommunityErrorState.fromError(
        error,
        operationType: 'loading_more_posts',
      )),
    );
  }

  /// Handle load post by ID event
  Future<void> _onLoadPostById(
    LoadPostById event,
    Emitter<CommunityState> emit,
  ) async {
    emit(const CommunityLoading(
      message: '게시글을 불러오고 있습니다...',
      operationType: 'loading_post_details',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getPostById(event.postId);
        
        result.fold(
          (failure) => emit(CommunityErrorState.fromError(
            failure,
            operationType: 'loading_post_details',
          )),
          (post) {
            if (post != null) {
              emit(PostDetailsLoaded(
                post: post,
                loadedAt: DateTime.now(),
              ));
            } else {
              emit(CommunityErrorState(
                const BlocCommunicationError(
                  '게시글을 찾을 수 없습니다.',
                  code: 'POST_NOT_FOUND',
                ),
                operationType: 'loading_post_details',
              ));
            }
          },
        );
      },
      (error) => emit(CommunityErrorState.fromError(
        error,
        operationType: 'loading_post_details',
      )),
    );
  }

  /// Handle create post event
  Future<void> _onCreatePost(
    CreatePost event,
    Emitter<CommunityState> emit,
  ) async {
    emit(const CommunityLoading(
      message: '게시글을 작성하고 있습니다...',
      operationType: 'creating_post',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.createPost(event.request);
        
        result.fold(
          (failure) => emit(CommunityErrorState.fromError(
            failure,
            operationType: 'creating_post',
          )),
          (post) {
            emit(PostCreated(
              post: post,
              createdAt: DateTime.now(),
            ));
          },
        );
      },
      (error) => emit(CommunityErrorState.fromError(
        error,
        operationType: 'creating_post',
      )),
    );
  }

  /// Handle update post event
  Future<void> _onUpdatePost(
    UpdatePost event,
    Emitter<CommunityState> emit,
  ) async {
    emit(const CommunityLoading(
      message: '게시글을 수정하고 있습니다...',
      operationType: 'updating_post',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.updatePost(
          event.postId,
          event.request,
          event.userId,
        );
        
        result.fold(
          (failure) => emit(CommunityErrorState.fromError(
            failure,
            operationType: 'updating_post',
          )),
          (post) {
            emit(PostUpdated(
              post: post,
              updatedAt: DateTime.now(),
            ));
          },
        );
      },
      (error) => emit(CommunityErrorState.fromError(
        error,
        operationType: 'updating_post',
      )),
    );
  }

  /// Handle delete post event
  Future<void> _onDeletePost(
    DeletePost event,
    Emitter<CommunityState> emit,
  ) async {
    emit(const CommunityLoading(
      message: '게시글을 삭제하고 있습니다...',
      operationType: 'deleting_post',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.deletePost(event.postId, event.userId);
        
        result.fold(
          (failure) => emit(CommunityErrorState.fromError(
            failure,
            operationType: 'deleting_post',
          )),
          (_) {
            emit(PostDeleted(
              postId: event.postId,
              deletedAt: DateTime.now(),
            ));
          },
        );
      },
      (error) => emit(CommunityErrorState.fromError(
        error,
        operationType: 'deleting_post',
      )),
    );
  }

  /// Handle search posts event
  Future<void> _onSearchPosts(
    SearchPosts event,
    Emitter<CommunityState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const SearchResultsCleared());
      return;
    }

    emit(const CommunityLoading(
      message: '게시글을 검색하고 있습니다...',
      operationType: 'searching_posts',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.searchPosts(
          event.query.trim(),
          categoryId: event.categoryId,
          groupId: event.groupId,
          limit: event.limit,
          offset: event.offset,
        );
        
        result.fold(
          (failure) => emit(CommunityErrorState.fromError(
            failure,
            operationType: 'searching_posts',
          )),
          (posts) {
            emit(SearchResultsLoaded(
              posts: posts,
              query: event.query.trim(),
              hasMore: posts.length == event.limit,
              categoryId: event.categoryId,
              groupId: event.groupId,
              loadedAt: DateTime.now(),
            ));
          },
        );
      },
      (error) => emit(CommunityErrorState.fromError(
        error,
        operationType: 'searching_posts',
      )),
    );
  }

  /// Handle load categories event
  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CommunityState> emit,
  ) async {
    emit(const CommunityLoading(
      message: '카테고리를 불러오고 있습니다...',
      operationType: 'loading_categories',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getCategories();
        
        result.fold(
          (failure) => emit(CommunityErrorState.fromError(
            failure,
            operationType: 'loading_categories',
          )),
          (categories) {
            emit(CategoriesLoaded(
              categories: categories,
              loadedAt: DateTime.now(),
            ));
          },
        );
      },
      (error) => emit(CommunityErrorState.fromError(
        error,
        operationType: 'loading_categories',
      )),
    );
  }

  // Placeholder methods for events that need implementation
  Future<void> _onLoadMoreSearchResults(LoadMoreSearchResults event, Emitter<CommunityState> emit) async {
    // TODO: Implement
  }

  Future<void> _onClearSearchResults(ClearSearchResults event, Emitter<CommunityState> emit) async {
    emit(const SearchResultsCleared());
  }

  Future<void> _onLoadPostsByTags(LoadPostsByTags event, Emitter<CommunityState> emit) async {
    // TODO: Implement
  }

  Future<void> _onLoadAllTags(LoadAllTags event, Emitter<CommunityState> emit) async {
    // TODO: Implement
  }

  Future<void> _onLoadPostStats(LoadPostStats event, Emitter<CommunityState> emit) async {
    // TODO: Implement
  }

  Future<void> _onLoadCategoryStats(LoadCategoryStats event, Emitter<CommunityState> emit) async {
    // TODO: Implement
  }

  Future<void> _onReportPost(ReportPost event, Emitter<CommunityState> emit) async {
    // TODO: Implement
  }

  Future<void> _onLoadReportedPosts(LoadReportedPosts event, Emitter<CommunityState> emit) async {
    // TODO: Implement
  }

  Future<void> _onResolvePostReport(ResolvePostReport event, Emitter<CommunityState> emit) async {
    // TODO: Implement
  }

  Future<void> _onRefreshPosts(RefreshPosts event, Emitter<CommunityState> emit) async {
    // TODO: Implement
  }

  Future<void> _onFilterPostsByCategory(FilterPostsByCategory event, Emitter<CommunityState> emit) async {
    // TODO: Implement
  }

  Future<void> _onFilterPostsByType(FilterPostsByType event, Emitter<CommunityState> emit) async {
    // TODO: Implement
  }

  Future<void> _onSortPosts(SortPosts event, Emitter<CommunityState> emit) async {
    // TODO: Implement
  }

  Future<void> _onClearAllFilters(ClearAllFilters event, Emitter<CommunityState> emit) async {
    // TODO: Implement
  }

  Future<void> _onHandlePostUpdate(HandlePostUpdate event, Emitter<CommunityState> emit) async {
    // TODO: Implement
  }

  Future<void> _onHandleNewPost(HandleNewPost event, Emitter<CommunityState> emit) async {
    // TODO: Implement
  }

  Future<void> _onSearchPostsWithCriteria(SearchPostsWithCriteria event, Emitter<CommunityState> emit) async {
    // TODO: Implement
  }

  Future<void> _onLoadMoreEnhancedSearchResults(LoadMoreEnhancedSearchResults event, Emitter<CommunityState> emit) async {
    // TODO: Implement
  }

  Future<void> _onLoadSuggestedPosts(LoadSuggestedPosts event, Emitter<CommunityState> emit) async {
    // TODO: Implement
  }

  Future<void> _onLoadRelatedPosts(LoadRelatedPosts event, Emitter<CommunityState> emit) async {
    // TODO: Implement
  }

  Future<void> _onSearchTags(SearchTags event, Emitter<CommunityState> emit) async {
    // TODO: Implement
  }

  Future<void> _onLoadSearchSuggestions(LoadSearchSuggestions event, Emitter<CommunityState> emit) async {
    // TODO: Implement
  }

  Future<void> _onSaveSearchQuery(SaveSearchQuery event, Emitter<CommunityState> emit) async {
    // TODO: Implement
  }

  @override
  Future<void> close() async {
    // Cancel all real-time subscriptions
    for (final subscription in _realtimeSubscriptions.values) {
      await subscription.cancel();
    }
    _realtimeSubscriptions.clear();
    
    return super.close();
  }
}