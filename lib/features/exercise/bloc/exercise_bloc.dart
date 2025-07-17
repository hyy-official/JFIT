import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/bloc/base_bloc.dart';
import 'package:jfit/core/error/bloc_errors.dart';
import 'package:jfit/core/models/exercise.dart';
import 'package:jfit/features/exercise/bloc/exercise_event.dart';
import 'package:jfit/features/exercise/bloc/exercise_state.dart';
import 'package:jfit/features/exercise/data/repositories/exercise_repository.dart';

/// BLoC for managing exercise-related operations
/// Handles exercise search, details loading, and caching
class ExerciseBloc extends BaseBloc<ExerciseEvent, ExerciseState> {
  final ExerciseRepository _repository;
  
  // Debounce timer for search operations
  Timer? _searchDebounceTimer;
  static const Duration _searchDebounceDelay = Duration(milliseconds: 300);
  
  // Performance optimization: Cache search results and exercise details
  final Map<String, List<Exercise>> _searchCache = {};
  final Map<String, Exercise> _exerciseDetailsCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiration = Duration(minutes: 15);
  
  // Performance metrics
  int _searchCacheHits = 0;
  int _searchCacheMisses = 0;
  int _detailsCacheHits = 0;
  int _detailsCacheMisses = 0;

  ExerciseBloc({
    required ExerciseRepository repository,
  })  : _repository = repository,
        super(const ExerciseInitial()) {
    
    // Register event handlers
    on<SearchExercises>(_onSearchExercises);
    on<LoadExerciseDetails>(_onLoadExerciseDetails);
    on<LoadMultipleExerciseDetails>(_onLoadMultipleExerciseDetails);
    on<ClearSearchResults>(_onClearSearchResults);
    on<LoadPopularExercises>(_onLoadPopularExercises);
    on<LoadExercisesByCategory>(_onLoadExercisesByCategory);
    on<LoadExercisesByMuscleGroup>(_onLoadExercisesByMuscleGroup);
    on<RefreshExerciseCache>(_onRefreshExerciseCache);
  }

  /// Handle search exercises event with debouncing and caching
  Future<void> _onSearchExercises(
    SearchExercises event,
    Emitter<ExerciseState> emit,
  ) async {
    // Cancel previous search timer
    _searchDebounceTimer?.cancel();
    
    // If query is empty, clear results
    if (event.query.trim().isEmpty) {
      emit(const ExerciseSearchCleared());
      return;
    }

    final searchKey = _getSearchCacheKey(event.query.trim(), event.filters, event.limit);
    
    // Check cache first
    if (_isSearchCacheValid(searchKey)) {
      _searchCacheHits++;
      final cachedResults = _searchCache[searchKey]!;
      emit(ExerciseSearchResults(
        exercises: cachedResults,
        query: event.query.trim(),
        hasMore: cachedResults.length == (event.limit ?? 20),
        totalCount: cachedResults.length,
      ));
      return;
    }
    
    _searchCacheMisses++;

    // Show loading state immediately for user feedback
    emit(const ExerciseLoading(message: '운동을 검색하고 있습니다...'));

    // Create a completer to handle the debounced operation
    final completer = Completer<void>();
    
    // Set up debounced search
    _searchDebounceTimer = Timer(_searchDebounceDelay, () async {
      try {
        final result = event.filters != null && event.filters!.isNotEmpty
            ? await _repository.searchWithFilters(
                event.query.trim(),
                event.filters!,
                limit: event.limit,
              )
            : await _repository.search(
                event.query.trim(),
                limit: event.limit,
              );

        if (!emit.isDone) {
          result.fold(
            (failure) => emit(ExerciseErrorState.withRetry(
              error: ExerciseError(
                failure.message,
                code: BlocErrorCodes.exerciseSearchFailed,
              ),
              retryAction: () => add(SearchExercises(
                query: event.query,
                limit: event.limit,
                filters: event.filters,
              )),
            )),
            (exercises) {
              // Cache the search results
              _updateSearchCache(searchKey, exercises);
              
              emit(ExerciseSearchResults(
                exercises: exercises,
                query: event.query.trim(),
                hasMore: exercises.length == (event.limit ?? 20),
                totalCount: exercises.length,
              ));
            },
          );
        }
        completer.complete();
      } catch (error) {
        if (!emit.isDone) {
          emit(ExerciseErrorState.searchFailed(event.query.trim()));
        }
        completer.complete();
      }
    });

    // Wait for the debounced operation to complete
    await completer.future;
  }

  /// Handle load exercise details event
  Future<void> _onLoadExerciseDetails(
    LoadExerciseDetails event,
    Emitter<ExerciseState> emit,
  ) async {
    emit(const ExerciseLoading(message: '운동 정보를 불러오고 있습니다...'));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getExerciseById(event.exerciseId);
        
        result.fold(
          (failure) => emit(ExerciseErrorState.fromError(
            ExerciseError(
              failure.message,
              code: BlocErrorCodes.exerciseNotFound,
            ),
          )),
          (exercise) {
            if (exercise == null) {
              emit(ExerciseErrorState.notFound(event.exerciseId));
            } else {
              emit(ExerciseDetailsLoaded(exercise));
            }
          },
        );
      },
      (error) => emit(ExerciseErrorState.loadFailed(event.exerciseId)),
    );
  }

  /// Handle load multiple exercise details event
  Future<void> _onLoadMultipleExerciseDetails(
    LoadMultipleExerciseDetails event,
    Emitter<ExerciseState> emit,
  ) async {
    if (event.exerciseIds.isEmpty) {
      emit(const MultipleExerciseDetailsLoaded(
        exercises: [],
        requestedIds: [],
      ));
      return;
    }

    emit(const ExerciseLoading(message: '운동 정보들을 불러오고 있습니다...'));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getExercisesByIds(event.exerciseIds);
        
        result.fold(
          (failure) => emit(ExerciseErrorState.fromError(
            ExerciseError(
              failure.message,
              code: BlocErrorCodes.exerciseNotFound,
            ),
          )),
          (exercises) => emit(MultipleExerciseDetailsLoaded(
            exercises: exercises,
            requestedIds: event.exerciseIds,
          )),
        );
      },
      (error) => emit(ExerciseErrorState.fromError(error)),
    );
  }

  /// Handle clear search results event
  Future<void> _onClearSearchResults(
    ClearSearchResults event,
    Emitter<ExerciseState> emit,
  ) async {
    // Cancel any pending search
    _searchDebounceTimer?.cancel();
    emit(const ExerciseSearchCleared());
  }

  /// Handle load popular exercises event
  Future<void> _onLoadPopularExercises(
    LoadPopularExercises event,
    Emitter<ExerciseState> emit,
  ) async {
    emit(const ExerciseLoading(message: '인기 운동을 불러오고 있습니다...'));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getPopularExercises(
          limit: event.limit,
        );
        
        result.fold(
          (failure) => emit(ExerciseErrorState.fromError(
            ExerciseError(
              failure.message,
              code: BlocErrorCodes.exerciseSearchFailed,
            ),
          )),
          (exercises) => emit(PopularExercisesLoaded(exercises)),
        );
      },
      (error) => emit(ExerciseErrorState.fromError(error)),
    );
  }

  /// Handle load exercises by category event
  Future<void> _onLoadExercisesByCategory(
    LoadExercisesByCategory event,
    Emitter<ExerciseState> emit,
  ) async {
    emit(const ExerciseLoading(message: '카테고리별 운동을 불러오고 있습니다...'));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getExercisesByCategory(
          event.category,
          limit: event.limit,
        );
        
        result.fold(
          (failure) => emit(ExerciseErrorState.fromError(
            ExerciseError(
              failure.message,
              code: BlocErrorCodes.exerciseSearchFailed,
            ),
          )),
          (exercises) => emit(ExercisesByCategoryLoaded(
            exercises: exercises,
            category: event.category,
          )),
        );
      },
      (error) => emit(ExerciseErrorState.fromError(error)),
    );
  }

  /// Handle load exercises by muscle group event
  Future<void> _onLoadExercisesByMuscleGroup(
    LoadExercisesByMuscleGroup event,
    Emitter<ExerciseState> emit,
  ) async {
    emit(const ExerciseLoading(message: '근육별 운동을 불러오고 있습니다...'));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getExercisesByMuscleGroup(
          event.muscleGroup,
          limit: event.limit,
        );
        
        result.fold(
          (failure) => emit(ExerciseErrorState.fromError(
            ExerciseError(
              failure.message,
              code: BlocErrorCodes.exerciseSearchFailed,
            ),
          )),
          (exercises) => emit(ExercisesByMuscleGroupLoaded(
            exercises: exercises,
            muscleGroup: event.muscleGroup,
          )),
        );
      },
      (error) => emit(ExerciseErrorState.fromError(error)),
    );
  }

  /// Handle refresh exercise cache event
  Future<void> _onRefreshExerciseCache(
    RefreshExerciseCache event,
    Emitter<ExerciseState> emit,
  ) async {
    emit(const ExerciseLoading(message: '캐시를 새로고침하고 있습니다...'));

    await safeAsyncOperation(
      () async {
        final result = await _repository.refreshCache();
        
        result.fold(
          (failure) => emit(ExerciseErrorState.fromError(
            ExerciseError(
              failure.message,
              code: BlocErrorCodes.unknown,
            ),
          )),
          (_) => emit(ExerciseCacheRefreshed(DateTime.now())),
        );
      },
      (error) => emit(ExerciseErrorState.fromError(error)),
    );
  }



  /// Generate cache key for search operations
  String _getSearchCacheKey(String query, Map<String, dynamic>? filters, int? limit) {
    final filterStr = filters?.toString() ?? '';
    return 'search_${query}_${filterStr}_${limit ?? 20}';
  }

  /// Check if search cache entry is valid
  bool _isSearchCacheValid(String cacheKey) {
    if (!_searchCache.containsKey(cacheKey)) return false;
    
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _cacheExpiration;
  }

  /// Update search cache with new results
  void _updateSearchCache(String cacheKey, List<Exercise> results) {
    _searchCache[cacheKey] = results;
    _cacheTimestamps[cacheKey] = DateTime.now();
    
    // Clean up expired cache entries periodically
    _cleanupExpiredCache();
  }

  /// Clean up expired cache entries to prevent memory leaks
  void _cleanupExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) >= _cacheExpiration) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _searchCache.remove(key);
      _exerciseDetailsCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Get cache performance metrics
  Map<String, dynamic> getCacheMetrics() {
    final totalSearchRequests = _searchCacheHits + _searchCacheMisses;
    final totalDetailsRequests = _detailsCacheHits + _detailsCacheMisses;
    
    final searchHitRate = totalSearchRequests > 0 
        ? (_searchCacheHits / totalSearchRequests) * 100 
        : 0.0;
    final detailsHitRate = totalDetailsRequests > 0 
        ? (_detailsCacheHits / totalDetailsRequests) * 100 
        : 0.0;
    
    return {
      'search_cache_hits': _searchCacheHits,
      'search_cache_misses': _searchCacheMisses,
      'search_hit_rate_percentage': searchHitRate.toStringAsFixed(2),
      'details_cache_hits': _detailsCacheHits,
      'details_cache_misses': _detailsCacheMisses,
      'details_hit_rate_percentage': detailsHitRate.toStringAsFixed(2),
      'cached_search_entries': _searchCache.length,
      'cached_details_entries': _exerciseDetailsCache.length,
      'total_cache_size_kb': _estimateCacheSize(),
    };
  }

  /// Estimate total cache size in KB
  double _estimateCacheSize() {
    // Rough estimation: search results ~2KB each, details ~1KB each
    return (_searchCache.length * 2.0) + (_exerciseDetailsCache.length * 1.0);
  }

  @override
  void onInactivity() {
    // Clear caches when BLOC is inactive to free memory
    _searchCache.clear();
    _exerciseDetailsCache.clear();
    _cacheTimestamps.clear();
    _searchCacheHits = 0;
    _searchCacheMisses = 0;
    _detailsCacheHits = 0;
    _detailsCacheMisses = 0;
  }

  @override
  Future<void> close() {
    _searchDebounceTimer?.cancel();
    _searchCache.clear();
    _exerciseDetailsCache.clear();
    _cacheTimestamps.clear();
    return super.close();
  }

  /// Convenience method to search exercises with debouncing
  void searchExercises(
    String query, {
    int? limit,
    Map<String, dynamic>? filters,
  }) {
    add(SearchExercises(
      query: query,
      limit: limit,
      filters: filters,
    ));
  }

  /// Convenience method to load exercise details
  void loadExerciseDetails(String exerciseId) {
    add(LoadExerciseDetails(exerciseId));
  }

  /// Convenience method to load multiple exercise details
  void loadMultipleExerciseDetails(List<String> exerciseIds) {
    add(LoadMultipleExerciseDetails(exerciseIds));
  }

  /// Convenience method to clear search results
  void clearSearchResults() {
    add(const ClearSearchResults());
  }

  /// Convenience method to load popular exercises
  void loadPopularExercises({int? limit}) {
    add(LoadPopularExercises(limit: limit));
  }

  /// Convenience method to load exercises by category
  void loadExercisesByCategory(String category, {int? limit}) {
    add(LoadExercisesByCategory(category: category, limit: limit));
  }

  /// Convenience method to load exercises by muscle group
  void loadExercisesByMuscleGroup(String muscleGroup, {int? limit}) {
    add(LoadExercisesByMuscleGroup(muscleGroup: muscleGroup, limit: limit));
  }

  /// Convenience method to refresh cache
  void refreshCache() {
    add(const RefreshExerciseCache());
  }
}