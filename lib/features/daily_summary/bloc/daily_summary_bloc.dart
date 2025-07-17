import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/bloc/base_bloc.dart';
import 'package:jfit/core/bloc/bloc_event_bus.dart';
import 'package:jfit/features/daily_summary/bloc/daily_summary_event.dart';
import 'package:jfit/features/daily_summary/bloc/daily_summary_state.dart';
import 'package:jfit/features/daily_summary/data/repositories/daily_summary_repository.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';

/// BLoC responsible for managing daily summary data
/// Handles loading, updating, and caching of user daily summaries
/// Listens to meal and workout changes to automatically update summaries
class DailySummaryBloc extends BaseBloc<DailySummaryEvent, DailySummaryState> {
  final DailySummaryRepository _repository;
  
  // Cache for loaded summaries to improve performance
  final Map<String, UserDailySummary> _summaryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiration = Duration(minutes: 10);
  
  // Performance optimization: Track cache hits/misses
  int _cacheHits = 0;
  int _cacheMisses = 0;
  
  DailySummaryBloc({
    required DailySummaryRepository repository,
  }) : _repository = repository,
       super(const DailySummaryInitial()) {
    
    // Register event handlers
    on<LoadDailySummary>(_onLoadDailySummary);
    on<RefreshDailySummary>(_onRefreshDailySummary);
    on<UpdateSummaryFromMeal>(_onUpdateSummaryFromMeal);
    on<UpdateSummaryFromWorkout>(_onUpdateSummaryFromWorkout);
    on<LoadDailySummariesForRange>(_onLoadDailySummariesForRange);
    on<ClearDailySummaryCache>(_onClearDailySummaryCache);
    on<DeleteDailySummary>(_onDeleteDailySummary);
  }

  @override
  void handleCommunicationEvent(BlocCommunicationEvent event) {
    if (event is MealRecordChangedEvent) {
      add(UpdateSummaryFromMeal(
        userId: event.userId,
        date: event.date,
        mealRecordId: event.recordId,
      ));
    } else if (event is WorkoutSessionCompletedEvent) {
      add(UpdateSummaryFromWorkout(
        userId: event.userId,
        date: event.date,
        sessionId: event.sessionId,
      ));
    } else if (event is DailySummaryRefreshRequestedEvent) {
      add(RefreshDailySummary(
        userId: event.userId,
        date: event.date,
        forceRecalculation: true,
      ));
    } else if (event is WorkoutProgramProgressUpdatedEvent) {
      // Handle workout program progress updates
      _handleWorkoutProgramProgressUpdated(event);
    } else if (event is WorkoutProgramDayCompletedEvent) {
      // Handle workout program day completion
      _handleWorkoutProgramDayCompleted(event);
    }
  }

  /// Handle workout program progress updates
  void _handleWorkoutProgramProgressUpdated(WorkoutProgramProgressUpdatedEvent event) {
    // When program progress is updated, we might need to refresh summary data
    // This ensures consistency between program state and daily summaries
    try {
      // For now, we don't need to take specific action for program progress updates
      // But this handler is here for future enhancements
    } catch (e) {
      // Log error but don't fail the communication handling
    }
  }

  /// Handle workout program day completion
  void _handleWorkoutProgramDayCompleted(WorkoutProgramDayCompletedEvent event) {
    // When a program day is completed, refresh the daily summary for that date
    try {
      emitCommunicationEvent(DailySummaryRefreshRequestedEvent(
        userId: event.userProgramId, // TODO: Get actual userId from userProgramId
        date: event.completedAt,
        reason: RefreshReason.programProgressUpdated,
      ));
    } catch (e) {
      // Log error but don't fail the communication handling
    }
  }

  /// Handle loading daily summary for a specific date
  Future<void> _onLoadDailySummary(
    LoadDailySummary event,
    Emitter<DailySummaryState> emit,
  ) async {
    final cacheKey = _getCacheKey(event.userId, event.date);
    
    // Check cache first with expiration validation
    if (_isCacheValid(cacheKey)) {
      _cacheHits++;
      emit(DailySummaryLoaded(
        summary: _summaryCache[cacheKey]!,
        loadedAt: DateTime.now(),
      ));
      return;
    }
    
    _cacheMisses++;

    emit(DailySummaryLoading(
      message: 'Loading daily summary...',
      date: event.date,
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getDailySummary(event.userId, event.date);
        
        result.fold(
          (failure) => emit(DailySummaryError.withRetry(
            message: failure.message,
            code: 'summary_not_found',
            date: event.date,
            operation: 'load',
            retryAction: () => add(LoadDailySummary(userId: event.userId, date: event.date)),
          )),
          (summary) {
            if (summary != null) {
              _updateCache(cacheKey, summary);
              emit(DailySummaryLoaded(
                summary: summary,
                loadedAt: DateTime.now(),
              ));
            } else {
              emit(DailySummaryEmpty(
                userId: event.userId,
                date: event.date,
              ));
            }
          },
        );
      },
      (error) => emit(DailySummaryError(
        error.toString(),
        date: event.date,
        operation: 'load',
      )),
    );
  }

  /// Handle refreshing daily summary (recalculate from source data)
  Future<void> _onRefreshDailySummary(
    RefreshDailySummary event,
    Emitter<DailySummaryState> emit,
  ) async {
    final cacheKey = _getCacheKey(event.userId, event.date);
    
    emit(DailySummaryRefreshing(
      userId: event.userId,
      date: event.date,
      currentSummary: _summaryCache[cacheKey],
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.calculateAndUpdateDailySummary(
          event.userId,
          event.date,
        );
        
        result.fold(
          (failure) => emit(DailySummaryError.withRetry(
            message: failure.message,
            code: 'summary_update_failed',
            date: event.date,
            operation: 'refresh',
            retryAction: () => add(RefreshDailySummary(
              userId: event.userId,
              date: event.date,
              forceRecalculation: event.forceRecalculation,
            )),
          )),
          (summary) {
            _summaryCache[cacheKey] = summary;
            emit(DailySummaryUpdated(
              summary: summary,
              updatedAt: DateTime.now(),
              updateReason: 'Manual refresh',
            ));
          },
        );
      },
      (error) => emit(DailySummaryError(
        error.toString(),
        date: event.date,
        operation: 'refresh',
      )),
    );
  }

  /// Handle updating summary when meal data changes
  Future<void> _onUpdateSummaryFromMeal(
    UpdateSummaryFromMeal event,
    Emitter<DailySummaryState> emit,
  ) async {
    await _updateSummaryFromExternalChange(
      event.userId,
      event.date,
      'Meal data changed',
      emit,
    );
  }

  /// Handle updating summary when workout data changes
  Future<void> _onUpdateSummaryFromWorkout(
    UpdateSummaryFromWorkout event,
    Emitter<DailySummaryState> emit,
  ) async {
    await _updateSummaryFromExternalChange(
      event.userId,
      event.date,
      'Workout data changed',
      emit,
    );
  }

  /// Handle loading daily summaries for a date range
  Future<void> _onLoadDailySummariesForRange(
    LoadDailySummariesForRange event,
    Emitter<DailySummaryState> emit,
  ) async {
    emit(const DailySummaryLoading(message: 'Loading summaries for date range...'));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getDailySummariesForRange(
          event.userId,
          event.startDate,
          event.endDate,
        );
        
        result.fold(
          (failure) => emit(DailySummaryError.withRetry(
            message: failure.message,
            code: 'summary_not_found',
            operation: 'load_range',
            retryAction: () => add(LoadDailySummariesForRange(
              userId: event.userId,
              startDate: event.startDate,
              endDate: event.endDate,
            )),
          )),
          (summaries) {
            // Cache the loaded summaries
            for (final summary in summaries) {
              final cacheKey = _getCacheKey(summary.userId, summary.summaryDate);
              _summaryCache[cacheKey] = summary;
            }
            
            emit(DailySummariesLoaded(
              summaries: summaries,
              startDate: event.startDate,
              endDate: event.endDate,
              loadedAt: DateTime.now(),
            ));
          },
        );
      },
      (error) => emit(DailySummaryError(
        error.toString(),
        operation: 'load_range',
      )),
    );
  }

  /// Handle clearing the summary cache
  Future<void> _onClearDailySummaryCache(
    ClearDailySummaryCache event,
    Emitter<DailySummaryState> emit,
  ) async {
    _summaryCache.clear();
    emit(DailySummaryCacheCleared(clearedAt: DateTime.now()));
  }

  /// Handle deleting daily summary
  Future<void> _onDeleteDailySummary(
    DeleteDailySummary event,
    Emitter<DailySummaryState> emit,
  ) async {
    emit(DailySummaryLoading(
      message: 'Deleting daily summary...',
      date: event.date,
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.deleteDailySummary(event.userId, event.date);
        
        result.fold(
          (failure) => emit(DailySummaryError.withRetry(
            message: failure.message,
            code: 'summary_update_failed',
            date: event.date,
            operation: 'delete',
            retryAction: () => add(DeleteDailySummary(userId: event.userId, date: event.date)),
          )),
          (_) {
            final cacheKey = _getCacheKey(event.userId, event.date);
            _summaryCache.remove(cacheKey);
            
            emit(DailySummaryDeleted(
              userId: event.userId,
              date: event.date,
              deletedAt: DateTime.now(),
            ));
          },
        );
      },
      (error) => emit(DailySummaryError(
        error.toString(),
        date: event.date,
        operation: 'delete',
      )),
    );
  }

  /// Common method to update summary from external data changes
  Future<void> _updateSummaryFromExternalChange(
    String userId,
    DateTime date,
    String reason,
    Emitter<DailySummaryState> emit,
  ) async {
    await safeAsyncOperation(
      () async {
        final result = await _repository.calculateAndUpdateDailySummary(userId, date);
        
        result.fold(
          (failure) => emit(DailySummaryError(
            failure.message,
            code: 'summary_update_failed',
            date: date,
            operation: 'auto_update',
          )),
          (summary) {
            final cacheKey = _getCacheKey(userId, date);
            _summaryCache[cacheKey] = summary;
            
            emit(DailySummaryUpdated(
              summary: summary,
              updatedAt: DateTime.now(),
              updateReason: reason,
            ));
          },
        );
      },
      (error) => emit(DailySummaryError(
        error.toString(),
        date: date,
        operation: 'auto_update',
      )),
    );
  }

  /// Generate cache key for a user and date combination
  String _getCacheKey(String userId, DateTime date) {
    return '${userId}_${date.toIso8601String().split('T')[0]}';
  }

  /// Check if cache entry is valid (exists and not expired)
  bool _isCacheValid(String cacheKey) {
    if (!_summaryCache.containsKey(cacheKey)) return false;
    
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;
    
    final now = DateTime.now();
    return now.difference(timestamp) < _cacheExpiration;
  }

  /// Update cache with new summary and timestamp
  void _updateCache(String cacheKey, UserDailySummary summary) {
    _summaryCache[cacheKey] = summary;
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
      _summaryCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Get cache performance metrics
  Map<String, dynamic> getCacheMetrics() {
    final totalRequests = _cacheHits + _cacheMisses;
    final hitRate = totalRequests > 0 ? (_cacheHits / totalRequests) * 100 : 0.0;
    
    return {
      'cache_hits': _cacheHits,
      'cache_misses': _cacheMisses,
      'hit_rate_percentage': hitRate.toStringAsFixed(2),
      'cached_entries': _summaryCache.length,
      'cache_size_kb': _estimateCacheSize(),
    };
  }

  /// Estimate cache size in KB (rough approximation)
  double _estimateCacheSize() {
    // Rough estimation: each summary entry ~1KB
    return _summaryCache.length * 1.0;
  }

  @override
  void onInactivity() {
    // Clear cache when BLOC is inactive to free memory
    _summaryCache.clear();
    _cacheTimestamps.clear();
    _cacheHits = 0;
    _cacheMisses = 0;
  }

  @override
  Future<void> close() {
    _summaryCache.clear();
    _cacheTimestamps.clear();
    return super.close();
  }
}