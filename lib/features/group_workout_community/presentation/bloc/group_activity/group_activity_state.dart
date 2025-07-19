import 'package:flutter/foundation.dart';
import 'package:jfit/core/bloc/base_bloc.dart';
import 'package:jfit/core/error/bloc_errors.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_activity.dart';
import 'package:jfit/features/group_workout_community/domain/entities/shared_routine.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';

/// Base class for all GroupActivity-related states
abstract class GroupActivityState extends BaseState {
  const GroupActivityState();
}

/// Initial state when GroupActivityBloc is first created
class GroupActivityInitial extends GroupActivityState {
  const GroupActivityInitial();

  @override
  List<Object?> get props => [];
}

/// State when group activity operations are in progress
class GroupActivityLoading extends GroupActivityState {
  final String? message;
  final String? operationType;

  const GroupActivityLoading({
    this.message,
    this.operationType,
  });

  @override
  List<Object?> get props => [message, operationType];
}

/// State when group activities are loaded
class GroupActivitiesLoaded extends GroupActivityState {
  final String groupId;
  final List<GroupActivity> activities;
  final bool hasMore;
  final int totalCount;
  final List<GroupActivityType>? appliedFilters;
  final DateTime loadedAt;

  const GroupActivitiesLoaded({
    required this.groupId,
    required this.activities,
    this.hasMore = false,
    this.totalCount = 0,
    this.appliedFilters,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [
        groupId,
        activities,
        hasMore,
        totalCount,
        appliedFilters,
        loadedAt,
      ];

  GroupActivitiesLoaded copyWith({
    String? groupId,
    List<GroupActivity>? activities,
    bool? hasMore,
    int? totalCount,
    List<GroupActivityType>? appliedFilters,
    DateTime? loadedAt,
  }) {
    return GroupActivitiesLoaded(
      groupId: groupId ?? this.groupId,
      activities: activities ?? this.activities,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
      appliedFilters: appliedFilters ?? this.appliedFilters,
      loadedAt: loadedAt ?? this.loadedAt,
    );
  }

  /// Add more activities (for pagination)
  GroupActivitiesLoaded addMoreActivities(List<GroupActivity> newActivities) {
    return copyWith(
      activities: [...activities, ...newActivities],
      hasMore: newActivities.isNotEmpty,
      totalCount: totalCount + newActivities.length,
      loadedAt: DateTime.now(),
    );
  }

  /// Update a specific activity
  GroupActivitiesLoaded updateActivity(GroupActivity updatedActivity) {
    final updatedActivities = activities.map((activity) {
      return activity.id == updatedActivity.id ? updatedActivity : activity;
    }).toList();

    return copyWith(
      activities: updatedActivities,
      loadedAt: DateTime.now(),
    );
  }

  /// Remove an activity
  GroupActivitiesLoaded removeActivity(String activityId) {
    final filteredActivities = activities.where((activity) => activity.id != activityId).toList();

    return copyWith(
      activities: filteredActivities,
      totalCount: totalCount - 1,
      loadedAt: DateTime.now(),
    );
  }
}

/// State when user activities in group are loaded
class UserActivitiesInGroupLoaded extends GroupActivityState {
  final String groupId;
  final String userId;
  final List<GroupActivity> activities;
  final DateTime loadedAt;

  const UserActivitiesInGroupLoaded({
    required this.groupId,
    required this.userId,
    required this.activities,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [groupId, userId, activities, loadedAt];
}

/// State when a routine is successfully shared
class RoutineShared extends GroupActivityState {
  final SharedRoutine sharedRoutine;
  final DateTime sharedAt;

  const RoutineShared({
    required this.sharedRoutine,
    required this.sharedAt,
  });

  @override
  List<Object?> get props => [sharedRoutine, sharedAt];
}

/// State when workout completion is logged
class WorkoutCompletionLogged extends GroupActivityState {
  final GroupActivity activity;
  final DateTime loggedAt;

  const WorkoutCompletionLogged({
    required this.activity,
    required this.loggedAt,
  });

  @override
  List<Object?> get props => [activity, loggedAt];
}

/// State when encouragement is sent
class EncouragementSent extends GroupActivityState {
  final GroupActivity activity;
  final String toUserId;
  final DateTime sentAt;

  const EncouragementSent({
    required this.activity,
    required this.toUserId,
    required this.sentAt,
  });

  @override
  List<Object?> get props => [activity, toUserId, sentAt];
}

/// State when shared routines are loaded
class SharedRoutinesLoaded extends GroupActivityState {
  final String groupId;
  final List<SharedRoutine> routines;
  final bool hasMore;
  final int totalCount;
  final String? orderBy;
  final DateTime loadedAt;

  const SharedRoutinesLoaded({
    required this.groupId,
    required this.routines,
    this.hasMore = false,
    this.totalCount = 0,
    this.orderBy,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [
        groupId,
        routines,
        hasMore,
        totalCount,
        orderBy,
        loadedAt,
      ];

  SharedRoutinesLoaded copyWith({
    String? groupId,
    List<SharedRoutine>? routines,
    bool? hasMore,
    int? totalCount,
    String? orderBy,
    DateTime? loadedAt,
  }) {
    return SharedRoutinesLoaded(
      groupId: groupId ?? this.groupId,
      routines: routines ?? this.routines,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
      orderBy: orderBy ?? this.orderBy,
      loadedAt: loadedAt ?? this.loadedAt,
    );
  }

  /// Add more routines (for pagination)
  SharedRoutinesLoaded addMoreRoutines(List<SharedRoutine> newRoutines) {
    return copyWith(
      routines: [...routines, ...newRoutines],
      hasMore: newRoutines.isNotEmpty,
      totalCount: totalCount + newRoutines.length,
      loadedAt: DateTime.now(),
    );
  }

  /// Update a specific routine
  SharedRoutinesLoaded updateRoutine(SharedRoutine updatedRoutine) {
    final updatedRoutines = routines.map((routine) {
      return routine.id == updatedRoutine.id ? updatedRoutine : routine;
    }).toList();

    return copyWith(
      routines: updatedRoutines,
      loadedAt: DateTime.now(),
    );
  }
}

/// State when shared routine details are loaded
class SharedRoutineDetailsLoaded extends GroupActivityState {
  final SharedRoutine routine;
  final DateTime loadedAt;

  const SharedRoutineDetailsLoaded({
    required this.routine,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [routine, loadedAt];
}

/// State when a routine is successfully copied
class RoutineCopied extends GroupActivityState {
  final String copiedRoutineId;
  final String originalRoutineId;
  final String newUserProgramId;
  final DateTime copiedAt;

  const RoutineCopied({
    required this.copiedRoutineId,
    required this.originalRoutineId,
    required this.newUserProgramId,
    required this.copiedAt,
  });

  @override
  List<Object?> get props => [copiedRoutineId, originalRoutineId, newUserProgramId, copiedAt];
}

/// State when routine like is toggled
class RoutineLikeToggled extends GroupActivityState {
  final String sharedRoutineId;
  final String userId;
  final bool isLiked;
  final int newLikeCount;
  final DateTime toggledAt;

  const RoutineLikeToggled({
    required this.sharedRoutineId,
    required this.userId,
    required this.isLiked,
    required this.newLikeCount,
    required this.toggledAt,
  });

  @override
  List<Object?> get props => [sharedRoutineId, userId, isLiked, newLikeCount, toggledAt];
}

/// State when routine like status is checked
class RoutineLikeChecked extends GroupActivityState {
  final String sharedRoutineId;
  final String userId;
  final bool isLiked;
  final DateTime checkedAt;

  const RoutineLikeChecked({
    required this.sharedRoutineId,
    required this.userId,
    required this.isLiked,
    required this.checkedAt,
  });

  @override
  List<Object?> get props => [sharedRoutineId, userId, isLiked, checkedAt];
}

/// State when user's shared routines are loaded
class UserSharedRoutinesLoaded extends GroupActivityState {
  final String userId;
  final List<SharedRoutine> routines;
  final DateTime loadedAt;

  const UserSharedRoutinesLoaded({
    required this.userId,
    required this.routines,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [userId, routines, loadedAt];
}

/// State when a shared routine is deleted
class SharedRoutineDeleted extends GroupActivityState {
  final String sharedRoutineId;
  final DateTime deletedAt;

  const SharedRoutineDeleted({
    required this.sharedRoutineId,
    required this.deletedAt,
  });

  @override
  List<Object?> get props => [sharedRoutineId, deletedAt];
}

/// State when member activity is logged
class MemberActivityLogged extends GroupActivityState {
  final GroupActivity activity;
  final String activityType; // 'joined', 'left'
  final DateTime loggedAt;

  const MemberActivityLogged({
    required this.activity,
    required this.activityType,
    required this.loggedAt,
  });

  @override
  List<Object?> get props => [activity, activityType, loggedAt];
}

/// State when achievement activity is logged
class AchievementActivityLogged extends GroupActivityState {
  final GroupActivity activity;
  final String achievementName;
  final DateTime loggedAt;

  const AchievementActivityLogged({
    required this.activity,
    required this.achievementName,
    required this.loggedAt,
  });

  @override
  List<Object?> get props => [activity, achievementName, loggedAt];
}

/// State when program activity is logged
class ProgramActivityLogged extends GroupActivityState {
  final GroupActivity activity;
  final String programName;
  final DateTime loggedAt;

  const ProgramActivityLogged({
    required this.activity,
    required this.programName,
    required this.loggedAt,
  });

  @override
  List<Object?> get props => [activity, programName, loggedAt];
}

/// State when milestone activity is logged
class MilestoneActivityLogged extends GroupActivityState {
  final GroupActivity activity;
  final String milestoneType;
  final DateTime loggedAt;

  const MilestoneActivityLogged({
    required this.activity,
    required this.milestoneType,
    required this.loggedAt,
  });

  @override
  List<Object?> get props => [activity, milestoneType, loggedAt];
}

/// State when group activity statistics are loaded
class GroupActivityStatsLoaded extends GroupActivityState {
  final String groupId;
  final Map<String, dynamic> stats;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime loadedAt;

  const GroupActivityStatsLoaded({
    required this.groupId,
    required this.stats,
    this.startDate,
    this.endDate,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [groupId, stats, startDate, endDate, loadedAt];
}

/// State when most active members are loaded
class MostActiveMembersLoaded extends GroupActivityState {
  final String groupId;
  final List<Map<String, dynamic>> members;
  final int days;
  final DateTime loadedAt;

  const MostActiveMembersLoaded({
    required this.groupId,
    required this.members,
    required this.days,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [groupId, members, days, loadedAt];
}

/// State when activities mentioning user are loaded
class ActivitiesMentioningUserLoaded extends GroupActivityState {
  final String userId;
  final List<GroupActivity> activities;
  final bool unreadOnly;
  final DateTime loadedAt;

  const ActivitiesMentioningUserLoaded({
    required this.userId,
    required this.activities,
    required this.unreadOnly,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [userId, activities, unreadOnly, loadedAt];
}

/// State when activities are marked as read
class ActivitiesMarkedAsRead extends GroupActivityState {
  final List<String> activityIds;
  final String userId;
  final DateTime markedAt;

  const ActivitiesMarkedAsRead({
    required this.activityIds,
    required this.userId,
    required this.markedAt,
  });

  @override
  List<Object?> get props => [activityIds, userId, markedAt];
}

/// State when activity feed is refreshed
class ActivityFeedRefreshed extends GroupActivityState {
  final String groupId;
  final DateTime refreshedAt;

  const ActivityFeedRefreshed({
    required this.groupId,
    required this.refreshedAt,
  });

  @override
  List<Object?> get props => [groupId, refreshedAt];
}

/// State when real-time activity update is received
class ActivityUpdatedRealtime extends GroupActivityState {
  final String groupId;
  final Map<String, dynamic> activityData;
  final DateTime updatedAt;

  const ActivityUpdatedRealtime({
    required this.groupId,
    required this.activityData,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [groupId, activityData, updatedAt];
}

/// State when activities are filtered
class ActivitiesFiltered extends GroupActivityState {
  final String groupId;
  final List<GroupActivityType>? appliedFilters;
  final DateTime filteredAt;

  const ActivitiesFiltered({
    required this.groupId,
    this.appliedFilters,
    required this.filteredAt,
  });

  @override
  List<Object?> get props => [groupId, appliedFilters, filteredAt];
}

/// State when activity filters are cleared
class ActivityFiltersCleared extends GroupActivityState {
  final String groupId;
  final DateTime clearedAt;

  const ActivityFiltersCleared({
    required this.groupId,
    required this.clearedAt,
  });

  @override
  List<Object?> get props => [groupId, clearedAt];
}

/// State when a group activity-related error occurs
class GroupActivityErrorState extends GroupActivityState {
  final BlocError error;
  final bool isRetryable;
  final VoidCallback? retryAction;
  final String? recoverySuggestion;
  final String? operationType;

  const GroupActivityErrorState(
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
      case 'routine_share_failed':
        return '루틴 공유에 실패했습니다.';
      case 'workout_log_failed':
        return '운동 완료 기록에 실패했습니다.';
      case 'encouragement_send_failed':
        return '격려 메시지 전송에 실패했습니다.';
      case 'routine_copy_failed':
        return '루틴 복사에 실패했습니다.';
      case 'routine_not_found':
        return '루틴을 찾을 수 없습니다.';
      case 'insufficient_permissions':
        return '이 작업을 수행할 권한이 없습니다.';
      case 'activity_load_failed':
        return '활동 피드를 불러오는데 실패했습니다.';
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
          return '그룹 활동 처리 중 오류가 발생했습니다.';
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
      case 'routine_share_failed':
        return '다시 공유';
      case 'workout_log_failed':
        return '다시 기록';
      case 'encouragement_send_failed':
        return '다시 전송';
      case 'routine_copy_failed':
        return '다시 복사';
      case 'activity_load_failed':
        return '새로고침';
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
      case 'routine_share_failed':
        return '루틴 정보를 확인하고 다시 시도해주세요.';
      case 'workout_log_failed':
        return '운동 세션 정보를 확인하고 다시 시도해주세요.';
      case 'encouragement_send_failed':
        return '메시지 내용을 확인하고 다시 시도해주세요.';
      case 'routine_copy_failed':
        return '루틴이 존재하는지 확인하고 다시 시도해주세요.';
      case 'routine_not_found':
        return '루틴이 삭제되었거나 존재하지 않을 수 있습니다.';
      case 'insufficient_permissions':
        return '그룹 관리자에게 문의하거나 권한을 요청해주세요.';
      case 'activity_load_failed':
        return '네트워크 연결을 확인하고 새로고침해주세요.';
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

  /// Create a GroupActivityErrorState from a generic error
  factory GroupActivityErrorState.fromError(
    dynamic error, {
    String? code,
    String? operationType,
  }) {
    if (error is BlocError) {
      return GroupActivityErrorState(
        error,
        operationType: operationType,
      );
    }

    final activityError = GroupActivityError(
      error.toString(),
      code: code ?? BlocErrorCodes.unknown,
    );

    return GroupActivityErrorState(
      activityError,
      operationType: operationType,
    );
  }

  /// Create a GroupActivityErrorState with a specific message and code
  factory GroupActivityErrorState.withCode(
    String message,
    String code, {
    String? operationType,
  }) {
    return GroupActivityErrorState(
      GroupActivityError(message, code: code),
      operationType: operationType,
    );
  }

  /// Create retryable error state
  factory GroupActivityErrorState.withRetry({
    required BlocError error,
    required VoidCallback retryAction,
    String? recoverySuggestion,
    String? operationType,
  }) {
    return GroupActivityErrorState(
      error,
      isRetryable: true,
      retryAction: retryAction,
      recoverySuggestion: recoverySuggestion,
      operationType: operationType,
    );
  }

  /// Create specific error states
  factory GroupActivityErrorState.routineShareFailed([String? details]) {
    return GroupActivityErrorState.withCode(
      '루틴 공유에 실패했습니다${details != null ? ': $details' : ''}',
      'routine_share_failed',
      operationType: 'sharing_routine',
    );
  }

  factory GroupActivityErrorState.workoutLogFailed([String? details]) {
    return GroupActivityErrorState.withCode(
      '운동 완료 기록에 실패했습니다${details != null ? ': $details' : ''}',
      'workout_log_failed',
      operationType: 'logging_workout',
    );
  }

  factory GroupActivityErrorState.encouragementSendFailed([String? details]) {
    return GroupActivityErrorState.withCode(
      '격려 메시지 전송에 실패했습니다${details != null ? ': $details' : ''}',
      'encouragement_send_failed',
      operationType: 'sending_encouragement',
    );
  }

  factory GroupActivityErrorState.routineCopyFailed([String? details]) {
    return GroupActivityErrorState.withCode(
      '루틴 복사에 실패했습니다${details != null ? ': $details' : ''}',
      'routine_copy_failed',
      operationType: 'copying_routine',
    );
  }

  factory GroupActivityErrorState.routineNotFound(String routineId) {
    return GroupActivityErrorState.withCode(
      '루틴을 찾을 수 없습니다: "$routineId"',
      'routine_not_found',
    );
  }

  factory GroupActivityErrorState.activityLoadFailed([String? details]) {
    return GroupActivityErrorState.withCode(
      '활동 피드를 불러오는데 실패했습니다${details != null ? ': $details' : ''}',
      'activity_load_failed',
      operationType: 'loading_activities',
    );
  }

  factory GroupActivityErrorState.insufficientPermissions(String operation) {
    return GroupActivityErrorState.withCode(
      '권한이 부족합니다: $operation',
      'insufficient_permissions',
    );
  }
}

/// Custom error class for group activity-related errors
class GroupActivityError extends BlocError {
  const GroupActivityError(String message, {String? code}) : super(message, code: code);
}