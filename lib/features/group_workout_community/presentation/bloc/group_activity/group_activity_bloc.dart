import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/bloc/base_bloc.dart';
import 'package:jfit/core/bloc/bloc_event_bus.dart';
import 'package:jfit/core/error/bloc_errors.dart';

import 'package:jfit/features/group_workout_community/domain/entities/group_activity.dart';
import 'package:jfit/features/group_workout_community/domain/entities/shared_routine.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/group_activity_repository.dart';
import 'package:jfit/features/group_workout_community/data/services/group_realtime_manager.dart';
import 'group_activity_event.dart';
import 'group_activity_state.dart';

/// BLoC for managing group activity operations
/// Handles activity feed loading, routine sharing, workout completion logging, and encouragement messages
class GroupActivityBloc extends BaseBloc<GroupActivityEvent, GroupActivityState> {
  final GroupActivityRepository _repository;
  final GroupRealtimeManager? _realtimeManager;

  // Cache for performance optimization
  final Map<String, List<GroupActivity>> _activitiesCache = {};
  final Map<String, List<SharedRoutine>> _routinesCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiration = Duration(minutes: 5);

  // Pagination tracking
  final Map<String, int> _currentOffsets = {};
  final Map<String, bool> _hasMoreData = {};

  // Real-time subscriptions
  final Map<String, StreamSubscription> _realtimeSubscriptions = {};

  // Performance metrics
  int _cacheHits = 0;
  int _cacheMisses = 0;

  GroupActivityBloc({
    required GroupActivityRepository repository,
    GroupRealtimeManager? realtimeManager,
  })  : _repository = repository,
        _realtimeManager = realtimeManager,
        super(const GroupActivityInitial()) {
    
    // Register event handlers
    on<LoadGroupActivities>(_onLoadGroupActivities);
    on<LoadMoreActivities>(_onLoadMoreActivities);
    on<LoadUserActivitiesInGroup>(_onLoadUserActivitiesInGroup);
    on<ShareRoutine>(_onShareRoutine);
    on<LogWorkoutCompletion>(_onLogWorkoutCompletion);
    on<SendEncouragement>(_onSendEncouragement);
    on<LoadSharedRoutines>(_onLoadSharedRoutines);
    on<LoadMoreSharedRoutines>(_onLoadMoreSharedRoutines);
    on<LoadSharedRoutineDetails>(_onLoadSharedRoutineDetails);
    on<CopySharedRoutine>(_onCopySharedRoutine);
    on<ToggleRoutineLike>(_onToggleRoutineLike);
    on<CheckRoutineLike>(_onCheckRoutineLike);
    on<LoadUserSharedRoutines>(_onLoadUserSharedRoutines);
    on<DeleteSharedRoutine>(_onDeleteSharedRoutine);
    on<LogMemberJoined>(_onLogMemberJoined);
    on<LogMemberLeft>(_onLogMemberLeft);
    on<LogAchievementUnlocked>(_onLogAchievementUnlocked);
    on<LogProgramStarted>(_onLogProgramStarted);
    on<LogMilestoneReached>(_onLogMilestoneReached);
    on<LoadGroupActivityStats>(_onLoadGroupActivityStats);
    on<LoadMostActiveMembers>(_onLoadMostActiveMembers);
    on<LoadActivitiesMentioningUser>(_onLoadActivitiesMentioningUser);
    on<MarkActivitiesAsRead>(_onMarkActivitiesAsRead);
    on<RefreshActivityFeed>(_onRefreshActivityFeed);
    on<HandleActivityUpdate>(_onHandleActivityUpdate);
    on<FilterActivitiesByType>(_onFilterActivitiesByType);
    on<ClearActivityFilters>(_onClearActivityFilters);
  }

  /// Handle load group activities event
  Future<void> _onLoadGroupActivities(
    LoadGroupActivities event,
    Emitter<GroupActivityState> emit,
  ) async {
    final cacheKey = _getActivitiesCacheKey(event.groupId, event.activityTypes);
    
    // Check cache first (unless force refresh)
    if (!event.forceRefresh && _isActivitiesCacheValid(cacheKey)) {
      _cacheHits++;
      final cachedActivities = _activitiesCache[cacheKey]!;
      emit(GroupActivitiesLoaded(
        groupId: event.groupId,
        activities: cachedActivities,
        hasMore: _hasMoreData[cacheKey] ?? false,
        totalCount: cachedActivities.length,
        appliedFilters: event.activityTypes,
        loadedAt: _cacheTimestamps[cacheKey]!,
      ));
      return;
    }

    _cacheMisses++;
    emit(const GroupActivityLoading(
      message: '활동 피드를 불러오고 있습니다...',
      operationType: 'loading_activities',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getGroupActivities(
          event.groupId,
          limit: event.limit,
          offset: event.offset,
          activityTypes: event.activityTypes,
        );
        
        result.fold(
          (failure) => emit(GroupActivityErrorState.fromError(
            failure,
            operationType: 'loading_activities',
          )),
          (activities) {
            // Update cache
            _updateActivitiesCache(cacheKey, activities);
            _currentOffsets[cacheKey] = event.offset + activities.length;
            _hasMoreData[cacheKey] = activities.length == event.limit;
            
            emit(GroupActivitiesLoaded(
              groupId: event.groupId,
              activities: activities,
              hasMore: activities.length == event.limit,
              totalCount: activities.length,
              appliedFilters: event.activityTypes,
              loadedAt: DateTime.now(),
            ));

            // Set up real-time subscription
            _setupActivityRealtimeSubscription(event.groupId);
          },
        );
      },
      (error) => emit(GroupActivityErrorState.fromError(
        error,
        operationType: 'loading_activities',
      )),
    );
  }

  /// Handle load more activities event
  Future<void> _onLoadMoreActivities(
    LoadMoreActivities event,
    Emitter<GroupActivityState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GroupActivitiesLoaded || !currentState.hasMore) {
      return;
    }

    emit(const GroupActivityLoading(
      message: '더 많은 활동을 불러오고 있습니다...',
      operationType: 'loading_more_activities',
    ));

    await safeAsyncOperation(
      () async {
        final cacheKey = _getActivitiesCacheKey(event.groupId, event.activityTypes);
        final currentOffset = _currentOffsets[cacheKey] ?? 0;
        
        final result = await _repository.getGroupActivities(
          event.groupId,
          limit: 20,
          offset: currentOffset,
          activityTypes: event.activityTypes,
        );
        
        result.fold(
          (failure) => emit(GroupActivityErrorState.fromError(
            failure,
            operationType: 'loading_more_activities',
          )),
          (newActivities) {
            // Update cache with new activities
            final existingActivities = _activitiesCache[cacheKey] ?? [];
            final allActivities = [...existingActivities, ...newActivities];
            _updateActivitiesCache(cacheKey, allActivities);
            
            _currentOffsets[cacheKey] = currentOffset + newActivities.length;
            _hasMoreData[cacheKey] = newActivities.length == 20;
            
            emit(currentState.addMoreActivities(newActivities));
          },
        );
      },
      (error) => emit(GroupActivityErrorState.fromError(
        error,
        operationType: 'loading_more_activities',
      )),
    );
  }

  /// Handle load user activities in group event
  Future<void> _onLoadUserActivitiesInGroup(
    LoadUserActivitiesInGroup event,
    Emitter<GroupActivityState> emit,
  ) async {
    emit(const GroupActivityLoading(
      message: '사용자 활동을 불러오고 있습니다...',
      operationType: 'loading_user_activities',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getUserActivitiesInGroup(
          event.groupId,
          event.userId,
          limit: event.limit,
          since: event.since,
        );
        
        result.fold(
          (failure) => emit(GroupActivityErrorState.fromError(
            failure,
            operationType: 'loading_user_activities',
          )),
          (activities) => emit(UserActivitiesInGroupLoaded(
            groupId: event.groupId,
            userId: event.userId,
            activities: activities,
            loadedAt: DateTime.now(),
          )),
        );
      },
      (error) => emit(GroupActivityErrorState.fromError(
        error,
        operationType: 'loading_user_activities',
      )),
    );
  }

  /// Handle share routine event
  Future<void> _onShareRoutine(
    ShareRoutine event,
    Emitter<GroupActivityState> emit,
  ) async {
    emit(const GroupActivityLoading(
      message: '루틴을 공유하고 있습니다...',
      operationType: 'sharing_routine',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.shareRoutine(event.request);
        
        result.fold(
          (failure) => emit(GroupActivityErrorState.fromError(
            failure,
            operationType: 'sharing_routine',
          )),
          (sharedRoutine) {
            // Invalidate activities cache to show new activity
            _invalidateActivitiesCache(event.request.groupId);
            
            emit(RoutineShared(
              sharedRoutine: sharedRoutine,
              sharedAt: DateTime.now(),
            ));

            // Emit communication event
            emitCommunicationEvent(RoutineSharedEvent(
              groupId: event.request.groupId,
              sharedByUserId: event.request.userId,
              routineName: sharedRoutine.routineName,
              sharedRoutineId: sharedRoutine.id,
            ));
          },
        );
      },
      (error) => emit(GroupActivityErrorState.fromError(
        error,
        operationType: 'sharing_routine',
      )),
    );
  }

  /// Handle log workout completion event
  Future<void> _onLogWorkoutCompletion(
    LogWorkoutCompletion event,
    Emitter<GroupActivityState> emit,
  ) async {
    emit(const GroupActivityLoading(
      message: '운동 완료를 기록하고 있습니다...',
      operationType: 'logging_workout',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.logWorkoutCompletion(event.request);
        
        result.fold(
          (failure) => emit(GroupActivityErrorState.fromError(
            failure,
            operationType: 'logging_workout',
          )),
          (activity) {
            // Invalidate activities cache to show new activity
            _invalidateActivitiesCache(event.request.groupId);
            
            emit(WorkoutCompletionLogged(
              activity: activity,
              loggedAt: DateTime.now(),
            ));

            // Emit communication event
            emitCommunicationEvent(GroupWorkoutCompletedEvent(
              groupId: event.request.groupId,
              userId: event.request.userId,
              sessionId: event.request.sessionId,
              completedAt: DateTime.now(),
            ));
          },
        );
      },
      (error) => emit(GroupActivityErrorState.fromError(
        error,
        operationType: 'logging_workout',
      )),
    );
  }

  /// Handle send encouragement event
  Future<void> _onSendEncouragement(
    SendEncouragement event,
    Emitter<GroupActivityState> emit,
  ) async {
    emit(const GroupActivityLoading(
      message: '격려 메시지를 전송하고 있습니다...',
      operationType: 'sending_encouragement',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.sendEncouragement(event.request);
        
        result.fold(
          (failure) => emit(GroupActivityErrorState.fromError(
            failure,
            operationType: 'sending_encouragement',
          )),
          (activity) {
            // Invalidate activities cache to show new activity
            _invalidateActivitiesCache(event.request.groupId);
            
            emit(EncouragementSent(
              activity: activity,
              toUserId: event.request.toUserId,
              sentAt: DateTime.now(),
            ));

            // Emit communication event
            emitCommunicationEvent(GenericBlocCommunicationEvent(
              type: 'encouragement_sent',
              data: {
                'group_id': event.request.groupId,
                'from_user_id': event.request.fromUserId,
                'to_user_id': event.request.toUserId,
                'message': event.request.message,
              },
            ));
          },
        );
      },
      (error) => emit(GroupActivityErrorState.fromError(
        error,
        operationType: 'sending_encouragement',
      )),
    );
  }

  /// Handle load shared routines event
  Future<void> _onLoadSharedRoutines(
    LoadSharedRoutines event,
    Emitter<GroupActivityState> emit,
  ) async {
    final cacheKey = _getRoutinesCacheKey(event.groupId, event.orderBy);
    
    // Check cache first
    if (_isRoutinesCacheValid(cacheKey)) {
      _cacheHits++;
      final cachedRoutines = _routinesCache[cacheKey]!;
      emit(SharedRoutinesLoaded(
        groupId: event.groupId,
        routines: cachedRoutines,
        hasMore: _hasMoreData[cacheKey] ?? false,
        totalCount: cachedRoutines.length,
        orderBy: event.orderBy,
        loadedAt: _cacheTimestamps[cacheKey]!,
      ));
      return;
    }

    _cacheMisses++;
    emit(const GroupActivityLoading(
      message: '공유된 루틴을 불러오고 있습니다...',
      operationType: 'loading_routines',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getSharedRoutines(
          event.groupId,
          limit: event.limit,
          offset: event.offset,
          orderBy: event.orderBy,
        );
        
        result.fold(
          (failure) => emit(GroupActivityErrorState.fromError(
            failure,
            operationType: 'loading_routines',
          )),
          (routines) {
            // Update cache
            _updateRoutinesCache(cacheKey, routines);
            _currentOffsets[cacheKey] = event.offset + routines.length;
            _hasMoreData[cacheKey] = routines.length == event.limit;
            
            emit(SharedRoutinesLoaded(
              groupId: event.groupId,
              routines: routines,
              hasMore: routines.length == event.limit,
              totalCount: routines.length,
              orderBy: event.orderBy,
              loadedAt: DateTime.now(),
            ));
          },
        );
      },
      (error) => emit(GroupActivityErrorState.fromError(
        error,
        operationType: 'loading_routines',
      )),
    );
  }

  /// Handle load more shared routines event
  Future<void> _onLoadMoreSharedRoutines(
    LoadMoreSharedRoutines event,
    Emitter<GroupActivityState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SharedRoutinesLoaded || !currentState.hasMore) {
      return;
    }

    emit(const GroupActivityLoading(
      message: '더 많은 루틴을 불러오고 있습니다...',
      operationType: 'loading_more_routines',
    ));

    await safeAsyncOperation(
      () async {
        final cacheKey = _getRoutinesCacheKey(event.groupId, event.orderBy);
        final currentOffset = _currentOffsets[cacheKey] ?? 0;
        
        final result = await _repository.getSharedRoutines(
          event.groupId,
          limit: 20,
          offset: currentOffset,
          orderBy: event.orderBy,
        );
        
        result.fold(
          (failure) => emit(GroupActivityErrorState.fromError(
            failure,
            operationType: 'loading_more_routines',
          )),
          (newRoutines) {
            // Update cache with new routines
            final existingRoutines = _routinesCache[cacheKey] ?? [];
            final allRoutines = [...existingRoutines, ...newRoutines];
            _updateRoutinesCache(cacheKey, allRoutines);
            
            _currentOffsets[cacheKey] = currentOffset + newRoutines.length;
            _hasMoreData[cacheKey] = newRoutines.length == 20;
            
            emit(currentState.addMoreRoutines(newRoutines));
          },
        );
      },
      (error) => emit(GroupActivityErrorState.fromError(
        error,
        operationType: 'loading_more_routines',
      )),
    );
  }

  /// Handle load shared routine details event
  Future<void> _onLoadSharedRoutineDetails(
    LoadSharedRoutineDetails event,
    Emitter<GroupActivityState> emit,
  ) async {
    emit(const GroupActivityLoading(
      message: '루틴 상세 정보를 불러오고 있습니다...',
      operationType: 'loading_routine_details',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getSharedRoutineById(event.routineId);
        
        result.fold(
          (failure) => emit(GroupActivityErrorState.fromError(
            failure,
            operationType: 'loading_routine_details',
          )),
          (routine) {
            if (routine == null) {
              emit(GroupActivityErrorState.routineNotFound(event.routineId));
            } else {
              emit(SharedRoutineDetailsLoaded(
                routine: routine,
                loadedAt: DateTime.now(),
              ));
            }
          },
        );
      },
      (error) => emit(GroupActivityErrorState.fromError(
        error,
        operationType: 'loading_routine_details',
      )),
    );
  }

  /// Handle copy shared routine event
  Future<void> _onCopySharedRoutine(
    CopySharedRoutine event,
    Emitter<GroupActivityState> emit,
  ) async {
    emit(const GroupActivityLoading(
      message: '루틴을 복사하고 있습니다...',
      operationType: 'copying_routine',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.copySharedRoutine(event.request);
        
        result.fold(
          (failure) => emit(GroupActivityErrorState.fromError(
            failure,
            operationType: 'copying_routine',
          )),
          (newUserProgramId) {
            emit(RoutineCopied(
              copiedRoutineId: event.request.sharedRoutineId,
              originalRoutineId: event.request.sharedRoutineId,
              newUserProgramId: newUserProgramId,
              copiedAt: DateTime.now(),
            ));

            // Emit communication event
            emitCommunicationEvent(GenericBlocCommunicationEvent(
              type: 'routine_copied',
              data: {
                'shared_routine_id': event.request.sharedRoutineId,
                'user_id': event.request.userId,
                'new_program_id': newUserProgramId,
              },
            ));
          },
        );
      },
      (error) => emit(GroupActivityErrorState.fromError(
        error,
        operationType: 'copying_routine',
      )),
    );
  }

  /// Handle toggle routine like event
  Future<void> _onToggleRoutineLike(
    ToggleRoutineLike event,
    Emitter<GroupActivityState> emit,
  ) async {
    await safeAsyncOperation(
      () async {
        final result = await _repository.toggleRoutineLike(
          event.sharedRoutineId,
          event.userId,
        );
        
        result.fold(
          (failure) => emit(GroupActivityErrorState.fromError(
            failure,
            operationType: 'toggling_like',
          )),
          (_) async {
            // Check new like status
            final likeResult = await _repository.hasUserLikedRoutine(
              event.sharedRoutineId,
              event.userId,
            );
            
            likeResult.fold(
              (failure) => emit(GroupActivityErrorState.fromError(failure)),
              (isLiked) {
                // Invalidate routines cache to reflect updated like count
                _invalidateRoutinesCache();
                
                emit(RoutineLikeToggled(
                  sharedRoutineId: event.sharedRoutineId,
                  userId: event.userId,
                  isLiked: isLiked,
                  newLikeCount: 0, // Would need to get actual count from API
                  toggledAt: DateTime.now(),
                ));
              },
            );
          },
        );
      },
      (error) => emit(GroupActivityErrorState.fromError(
        error,
        operationType: 'toggling_like',
      )),
    );
  }

  /// Handle check routine like event
  Future<void> _onCheckRoutineLike(
    CheckRoutineLike event,
    Emitter<GroupActivityState> emit,
  ) async {
    await safeAsyncOperation(
      () async {
        final result = await _repository.hasUserLikedRoutine(
          event.sharedRoutineId,
          event.userId,
        );
        
        result.fold(
          (failure) => emit(GroupActivityErrorState.fromError(
            failure,
            operationType: 'checking_like',
          )),
          (isLiked) => emit(RoutineLikeChecked(
            sharedRoutineId: event.sharedRoutineId,
            userId: event.userId,
            isLiked: isLiked,
            checkedAt: DateTime.now(),
          )),
        );
      },
      (error) => emit(GroupActivityErrorState.fromError(
        error,
        operationType: 'checking_like',
      )),
    );
  }

  /// Handle load user shared routines event
  Future<void> _onLoadUserSharedRoutines(
    LoadUserSharedRoutines event,
    Emitter<GroupActivityState> emit,
  ) async {
    emit(const GroupActivityLoading(
      message: '내가 공유한 루틴을 불러오고 있습니다...',
      operationType: 'loading_user_routines',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getUserSharedRoutines(
          event.userId,
          limit: event.limit,
        );
        
        result.fold(
          (failure) => emit(GroupActivityErrorState.fromError(
            failure,
            operationType: 'loading_user_routines',
          )),
          (routines) => emit(UserSharedRoutinesLoaded(
            userId: event.userId,
            routines: routines,
            loadedAt: DateTime.now(),
          )),
        );
      },
      (error) => emit(GroupActivityErrorState.fromError(
        error,
        operationType: 'loading_user_routines',
      )),
    );
  }

  /// Handle delete shared routine event
  Future<void> _onDeleteSharedRoutine(
    DeleteSharedRoutine event,
    Emitter<GroupActivityState> emit,
  ) async {
    emit(const GroupActivityLoading(
      message: '루틴을 삭제하고 있습니다...',
      operationType: 'deleting_routine',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.deleteSharedRoutine(
          event.sharedRoutineId,
          event.userId,
        );
        
        result.fold(
          (failure) {
            if (failure.message.contains('permission')) {
              emit(GroupActivityErrorState.insufficientPermissions('루틴 삭제'));
            } else {
              emit(GroupActivityErrorState.fromError(
                failure,
                operationType: 'deleting_routine',
              ));
            }
          },
          (_) {
            // Invalidate caches
            _invalidateRoutinesCache();
            
            emit(SharedRoutineDeleted(
              sharedRoutineId: event.sharedRoutineId,
              deletedAt: DateTime.now(),
            ));

            // Emit communication event
            emitCommunicationEvent(GenericBlocCommunicationEvent(
              type: 'routine_deleted',
              data: {
                'shared_routine_id': event.sharedRoutineId,
                'deleted_by': event.userId,
              },
            ));
          },
        );
      },
      (error) => emit(GroupActivityErrorState.fromError(
        error,
        operationType: 'deleting_routine',
      )),
    );
  }

  /// Handle log member joined event
  Future<void> _onLogMemberJoined(
    LogMemberJoined event,
    Emitter<GroupActivityState> emit,
  ) async {
    await safeAsyncOperation(
      () async {
        final result = await _repository.logMemberJoined(
          event.groupId,
          event.userId,
          event.welcomeMessage,
        );
        
        result.fold(
          (failure) => emit(GroupActivityErrorState.fromError(failure)),
          (activity) {
            // Invalidate activities cache
            _invalidateActivitiesCache(event.groupId);
            
            emit(MemberActivityLogged(
              activity: activity,
              activityType: 'joined',
              loggedAt: DateTime.now(),
            ));
          },
        );
      },
      (error) => emit(GroupActivityErrorState.fromError(error)),
    );
  }

  /// Handle log member left event
  Future<void> _onLogMemberLeft(
    LogMemberLeft event,
    Emitter<GroupActivityState> emit,
  ) async {
    await safeAsyncOperation(
      () async {
        final result = await _repository.logMemberLeft(
          event.groupId,
          event.userId,
          event.farewell,
        );
        
        result.fold(
          (failure) => emit(GroupActivityErrorState.fromError(failure)),
          (activity) {
            // Invalidate activities cache
            _invalidateActivitiesCache(event.groupId);
            
            emit(MemberActivityLogged(
              activity: activity,
              activityType: 'left',
              loggedAt: DateTime.now(),
            ));
          },
        );
      },
      (error) => emit(GroupActivityErrorState.fromError(error)),
    );
  }

  /// Handle log achievement unlocked event
  Future<void> _onLogAchievementUnlocked(
    LogAchievementUnlocked event,
    Emitter<GroupActivityState> emit,
  ) async {
    await safeAsyncOperation(
      () async {
        final result = await _repository.logAchievementUnlocked(
          event.groupId,
          event.userId,
          event.achievementName,
          event.achievementDescription,
        );
        
        result.fold(
          (failure) => emit(GroupActivityErrorState.fromError(failure)),
          (activity) {
            // Invalidate activities cache
            _invalidateActivitiesCache(event.groupId);
            
            emit(AchievementActivityLogged(
              activity: activity,
              achievementName: event.achievementName,
              loggedAt: DateTime.now(),
            ));
          },
        );
      },
      (error) => emit(GroupActivityErrorState.fromError(error)),
    );
  }

  /// Handle log program started event
  Future<void> _onLogProgramStarted(
    LogProgramStarted event,
    Emitter<GroupActivityState> emit,
  ) async {
    await safeAsyncOperation(
      () async {
        final result = await _repository.logProgramStarted(
          event.groupId,
          event.userId,
          event.programName,
          event.durationWeeks,
        );
        
        result.fold(
          (failure) => emit(GroupActivityErrorState.fromError(failure)),
          (activity) {
            // Invalidate activities cache
            _invalidateActivitiesCache(event.groupId);
            
            emit(ProgramActivityLogged(
              activity: activity,
              programName: event.programName,
              loggedAt: DateTime.now(),
            ));
          },
        );
      },
      (error) => emit(GroupActivityErrorState.fromError(error)),
    );
  }

  /// Handle log milestone reached event
  Future<void> _onLogMilestoneReached(
    LogMilestoneReached event,
    Emitter<GroupActivityState> emit,
  ) async {
    await safeAsyncOperation(
      () async {
        final result = await _repository.logMilestoneReached(
          event.groupId,
          event.userId,
          event.milestoneType,
          event.milestoneData,
        );
        
        result.fold(
          (failure) => emit(GroupActivityErrorState.fromError(failure)),
          (activity) {
            // Invalidate activities cache
            _invalidateActivitiesCache(event.groupId);
            
            emit(MilestoneActivityLogged(
              activity: activity,
              milestoneType: event.milestoneType,
              loggedAt: DateTime.now(),
            ));
          },
        );
      },
      (error) => emit(GroupActivityErrorState.fromError(error)),
    );
  }

  /// Handle load group activity stats event
  Future<void> _onLoadGroupActivityStats(
    LoadGroupActivityStats event,
    Emitter<GroupActivityState> emit,
  ) async {
    emit(const GroupActivityLoading(
      message: '그룹 활동 통계를 불러오고 있습니다...',
      operationType: 'loading_stats',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getGroupActivityStats(
          event.groupId,
          startDate: event.startDate,
          endDate: event.endDate,
        );
        
        result.fold(
          (failure) => emit(GroupActivityErrorState.fromError(
            failure,
            operationType: 'loading_stats',
          )),
          (stats) => emit(GroupActivityStatsLoaded(
            groupId: event.groupId,
            stats: stats,
            startDate: event.startDate,
            endDate: event.endDate,
            loadedAt: DateTime.now(),
          )),
        );
      },
      (error) => emit(GroupActivityErrorState.fromError(
        error,
        operationType: 'loading_stats',
      )),
    );
  }

  /// Handle load most active members event
  Future<void> _onLoadMostActiveMembers(
    LoadMostActiveMembers event,
    Emitter<GroupActivityState> emit,
  ) async {
    emit(const GroupActivityLoading(
      message: '가장 활발한 멤버를 불러오고 있습니다...',
      operationType: 'loading_active_members',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getMostActiveMembers(
          event.groupId,
          limit: event.limit,
          days: event.days,
        );
        
        result.fold(
          (failure) => emit(GroupActivityErrorState.fromError(
            failure,
            operationType: 'loading_active_members',
          )),
          (members) => emit(MostActiveMembersLoaded(
            groupId: event.groupId,
            members: members,
            days: event.days,
            loadedAt: DateTime.now(),
          )),
        );
      },
      (error) => emit(GroupActivityErrorState.fromError(
        error,
        operationType: 'loading_active_members',
      )),
    );
  }

  /// Handle load activities mentioning user event
  Future<void> _onLoadActivitiesMentioningUser(
    LoadActivitiesMentioningUser event,
    Emitter<GroupActivityState> emit,
  ) async {
    emit(const GroupActivityLoading(
      message: '나를 언급한 활동을 불러오고 있습니다...',
      operationType: 'loading_mentions',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getActivitiesMentioningUser(
          event.userId,
          limit: event.limit,
          unreadOnly: event.unreadOnly,
        );
        
        result.fold(
          (failure) => emit(GroupActivityErrorState.fromError(
            failure,
            operationType: 'loading_mentions',
          )),
          (activities) => emit(ActivitiesMentioningUserLoaded(
            userId: event.userId,
            activities: activities,
            unreadOnly: event.unreadOnly,
            loadedAt: DateTime.now(),
          )),
        );
      },
      (error) => emit(GroupActivityErrorState.fromError(
        error,
        operationType: 'loading_mentions',
      )),
    );
  }

  /// Handle mark activities as read event
  Future<void> _onMarkActivitiesAsRead(
    MarkActivitiesAsRead event,
    Emitter<GroupActivityState> emit,
  ) async {
    await safeAsyncOperation(
      () async {
        final result = await _repository.markActivitiesAsRead(
          event.activityIds,
          event.userId,
        );
        
        result.fold(
          (failure) => emit(GroupActivityErrorState.fromError(failure)),
          (_) => emit(ActivitiesMarkedAsRead(
            activityIds: event.activityIds,
            userId: event.userId,
            markedAt: DateTime.now(),
          )),
        );
      },
      (error) => emit(GroupActivityErrorState.fromError(error)),
    );
  }

  /// Handle refresh activity feed event
  Future<void> _onRefreshActivityFeed(
    RefreshActivityFeed event,
    Emitter<GroupActivityState> emit,
  ) async {
    // Invalidate cache and reload
    _invalidateActivitiesCache(event.groupId);
    
    add(LoadGroupActivities(
      groupId: event.groupId,
      forceRefresh: true,
    ));
    
    emit(ActivityFeedRefreshed(
      groupId: event.groupId,
      refreshedAt: DateTime.now(),
    ));
  }

  /// Handle real-time activity update event
  Future<void> _onHandleActivityUpdate(
    HandleActivityUpdate event,
    Emitter<GroupActivityState> emit,
  ) async {
    // Invalidate cache to force reload with new data
    _invalidateActivitiesCache(event.groupId);
    
    emit(ActivityUpdatedRealtime(
      groupId: event.groupId,
      activityData: event.activityData,
      updatedAt: DateTime.now(),
    ));
  }

  /// Handle filter activities by type event
  Future<void> _onFilterActivitiesByType(
    FilterActivitiesByType event,
    Emitter<GroupActivityState> emit,
  ) async {
    // Load activities with filters
    add(LoadGroupActivities(
      groupId: event.groupId,
      activityTypes: event.activityTypes,
      forceRefresh: true,
    ));
    
    emit(ActivitiesFiltered(
      groupId: event.groupId,
      appliedFilters: event.activityTypes,
      filteredAt: DateTime.now(),
    ));
  }

  /// Handle clear activity filters event
  Future<void> _onClearActivityFilters(
    ClearActivityFilters event,
    Emitter<GroupActivityState> emit,
  ) async {
    // Load activities without filters
    add(LoadGroupActivities(
      groupId: event.groupId,
      forceRefresh: true,
    ));
    
    emit(ActivityFiltersCleared(
      groupId: event.groupId,
      clearedAt: DateTime.now(),
    ));
  }

  /// Set up real-time subscription for activities
  void _setupActivityRealtimeSubscription(String groupId) {
    // Cancel existing subscription if any
    _realtimeSubscriptions[groupId]?.cancel();
    
    // Set up new subscription using GroupRealtimeManager
    if (_realtimeManager != null) {
      final stream = _realtimeManager!.subscribeToGroupActivities(groupId);
      _realtimeSubscriptions[groupId] = stream.listen(
        (activities) {
          // Update cache with new activities
          _activitiesCache[groupId] = activities;
          _cacheTimestamps[groupId] = DateTime.now();
          
          // Emit updated state if we're currently showing this group's activities
          if (state is GroupActivitiesLoaded) {
            final currentState = state as GroupActivitiesLoaded;
            if (currentState.groupId == groupId) {
              emit(currentState.copyWith(
                activities: activities,
                loadedAt: DateTime.now(),
              ));
            }
          }
        },
        onError: (error) {
          emit(GroupActivityErrorState.fromError(
            error,
            operationType: 'realtime_subscription',
          ));
        },
      );
    }
  }

  /// Generate cache key for activities
  String _getActivitiesCacheKey(String groupId, List<GroupActivityType>? activityTypes) {
    final typesStr = activityTypes?.map((t) => t.toString()).join(',') ?? 'all';
    return 'activities_${groupId}_$typesStr';
  }

  /// Generate cache key for routines
  String _getRoutinesCacheKey(String groupId, String? orderBy) {
    return 'routines_${groupId}_${orderBy ?? 'recent'}';
  }

  /// Check if activities cache is valid
  bool _isActivitiesCacheValid(String cacheKey) {
    if (!_activitiesCache.containsKey(cacheKey)) return false;
    
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _cacheExpiration;
  }

  /// Check if routines cache is valid
  bool _isRoutinesCacheValid(String cacheKey) {
    if (!_routinesCache.containsKey(cacheKey)) return false;
    
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _cacheExpiration;
  }

  /// Update activities cache
  void _updateActivitiesCache(String cacheKey, List<GroupActivity> activities) {
    _activitiesCache[cacheKey] = activities;
    _cacheTimestamps[cacheKey] = DateTime.now();
  }

  /// Update routines cache
  void _updateRoutinesCache(String cacheKey, List<SharedRoutine> routines) {
    _routinesCache[cacheKey] = routines;
    _cacheTimestamps[cacheKey] = DateTime.now();
  }

  /// Invalidate activities cache for a specific group
  void _invalidateActivitiesCache(String groupId) {
    final keysToRemove = _activitiesCache.keys
        .where((key) => key.startsWith('activities_$groupId'))
        .toList();
    
    for (final key in keysToRemove) {
      _activitiesCache.remove(key);
      _cacheTimestamps.remove(key);
      _currentOffsets.remove(key);
      _hasMoreData.remove(key);
    }
  }

  /// Invalidate all routines cache
  void _invalidateRoutinesCache() {
    final keysToRemove = _routinesCache.keys
        .where((key) => key.startsWith('routines_'))
        .toList();
    
    for (final key in keysToRemove) {
      _routinesCache.remove(key);
      _cacheTimestamps.remove(key);
      _currentOffsets.remove(key);
      _hasMoreData.remove(key);
    }
  }

  /// Clean up expired cache entries
  void _cleanupExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) >= _cacheExpiration) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      if (key.startsWith('activities_')) {
        _activitiesCache.remove(key);
      } else if (key.startsWith('routines_')) {
        _routinesCache.remove(key);
      }
      _cacheTimestamps.remove(key);
      _currentOffsets.remove(key);
      _hasMoreData.remove(key);
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
      'cached_activities': _activitiesCache.length,
      'cached_routines': _routinesCache.length,
      'total_cache_entries': _cacheTimestamps.length,
      'active_subscriptions': _realtimeSubscriptions.length,
    };
  }

  @override
  void onInactivity() {
    // Clean up caches and subscriptions when inactive
    _cleanupExpiredCache();
    
    // Cancel some subscriptions to save resources
    if (_realtimeSubscriptions.length > 3) {
      final oldestSubscriptions = _realtimeSubscriptions.entries.take(2);
      for (final entry in oldestSubscriptions) {
        entry.value.cancel();
        _realtimeSubscriptions.remove(entry.key);
      }
    }
  }

  @override
  Future<void> close() {
    // Cancel all real-time subscriptions
    for (final subscription in _realtimeSubscriptions.values) {
      subscription.cancel();
    }
    _realtimeSubscriptions.clear();
    
    // Clear caches
    _activitiesCache.clear();
    _routinesCache.clear();
    _cacheTimestamps.clear();
    _currentOffsets.clear();
    _hasMoreData.clear();
    
    return super.close();
  }

  // Convenience methods for easier usage
  void loadGroupActivities(String groupId, {bool forceRefresh = false, List<GroupActivityType>? activityTypes}) {
    add(LoadGroupActivities(groupId: groupId, forceRefresh: forceRefresh, activityTypes: activityTypes));
  }

  void loadMoreActivities(String groupId, {List<GroupActivityType>? activityTypes}) {
    add(LoadMoreActivities(groupId: groupId, activityTypes: activityTypes));
  }

  void shareRoutine(ShareRoutineRequest request) {
    add(ShareRoutine(request));
  }

  void logWorkoutCompletion(WorkoutCompletionRequest request) {
    add(LogWorkoutCompletion(request));
  }

  void sendEncouragement(EncouragementRequest request) {
    add(SendEncouragement(request));
  }

  void loadSharedRoutines(String groupId, {String? orderBy}) {
    add(LoadSharedRoutines(groupId: groupId, orderBy: orderBy));
  }

  void copySharedRoutine(CopyRoutineRequest request) {
    add(CopySharedRoutine(request));
  }

  void toggleRoutineLike(String sharedRoutineId, String userId) {
    add(ToggleRoutineLike(sharedRoutineId: sharedRoutineId, userId: userId));
  }

  void refreshActivityFeed(String groupId) {
    add(RefreshActivityFeed(groupId));
  }

  void filterActivitiesByType(String groupId, List<GroupActivityType>? activityTypes) {
    add(FilterActivitiesByType(groupId: groupId, activityTypes: activityTypes));
  }

  void clearActivityFilters(String groupId) {
    add(ClearActivityFilters(groupId));
  }
}