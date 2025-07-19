import 'package:jfit/core/bloc/base_bloc.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/group_activity_repository.dart';

/// Base class for all GroupActivity-related events
abstract class GroupActivityEvent extends BaseEvent {
  const GroupActivityEvent();
}

/// Event to load group activities feed
class LoadGroupActivities extends GroupActivityEvent {
  final String groupId;
  final int limit;
  final int offset;
  final List<GroupActivityType>? activityTypes;
  final bool forceRefresh;

  const LoadGroupActivities({
    required this.groupId,
    this.limit = 50,
    this.offset = 0,
    this.activityTypes,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [groupId, limit, offset, activityTypes, forceRefresh];
}

/// Event to load more activities (pagination)
class LoadMoreActivities extends GroupActivityEvent {
  final String groupId;
  final List<GroupActivityType>? activityTypes;

  const LoadMoreActivities({
    required this.groupId,
    this.activityTypes,
  });

  @override
  List<Object?> get props => [groupId, activityTypes];
}

/// Event to load user activities in a group
class LoadUserActivitiesInGroup extends GroupActivityEvent {
  final String groupId;
  final String userId;
  final int limit;
  final DateTime? since;

  const LoadUserActivitiesInGroup({
    required this.groupId,
    required this.userId,
    this.limit = 20,
    this.since,
  });

  @override
  List<Object?> get props => [groupId, userId, limit, since];
}

/// Event to share a workout routine
class ShareRoutine extends GroupActivityEvent {
  final ShareRoutineRequest request;

  const ShareRoutine(this.request);

  @override
  List<Object?> get props => [request];
}

/// Event to log workout completion
class LogWorkoutCompletion extends GroupActivityEvent {
  final WorkoutCompletionRequest request;

  const LogWorkoutCompletion(this.request);

  @override
  List<Object?> get props => [request];
}

/// Event to send encouragement message
class SendEncouragement extends GroupActivityEvent {
  final EncouragementRequest request;

  const SendEncouragement(this.request);

  @override
  List<Object?> get props => [request];
}

/// Event to load shared routines
class LoadSharedRoutines extends GroupActivityEvent {
  final String groupId;
  final int limit;
  final int offset;
  final String? orderBy; // 'recent', 'popular', 'likes'

  const LoadSharedRoutines({
    required this.groupId,
    this.limit = 20,
    this.offset = 0,
    this.orderBy,
  });

  @override
  List<Object?> get props => [groupId, limit, offset, orderBy];
}

/// Event to load more shared routines (pagination)
class LoadMoreSharedRoutines extends GroupActivityEvent {
  final String groupId;
  final String? orderBy;

  const LoadMoreSharedRoutines({
    required this.groupId,
    this.orderBy,
  });

  @override
  List<Object?> get props => [groupId, orderBy];
}

/// Event to load shared routine details
class LoadSharedRoutineDetails extends GroupActivityEvent {
  final String routineId;

  const LoadSharedRoutineDetails(this.routineId);

  @override
  List<Object?> get props => [routineId];
}

/// Event to copy a shared routine
class CopySharedRoutine extends GroupActivityEvent {
  final CopyRoutineRequest request;

  const CopySharedRoutine(this.request);

  @override
  List<Object?> get props => [request];
}

/// Event to toggle routine like
class ToggleRoutineLike extends GroupActivityEvent {
  final String sharedRoutineId;
  final String userId;

  const ToggleRoutineLike({
    required this.sharedRoutineId,
    required this.userId,
  });

  @override
  List<Object?> get props => [sharedRoutineId, userId];
}

/// Event to check if user liked a routine
class CheckRoutineLike extends GroupActivityEvent {
  final String sharedRoutineId;
  final String userId;

  const CheckRoutineLike({
    required this.sharedRoutineId,
    required this.userId,
  });

  @override
  List<Object?> get props => [sharedRoutineId, userId];
}

/// Event to load user's shared routines
class LoadUserSharedRoutines extends GroupActivityEvent {
  final String userId;
  final int limit;

  const LoadUserSharedRoutines({
    required this.userId,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [userId, limit];
}

/// Event to delete a shared routine
class DeleteSharedRoutine extends GroupActivityEvent {
  final String sharedRoutineId;
  final String userId;

  const DeleteSharedRoutine({
    required this.sharedRoutineId,
    required this.userId,
  });

  @override
  List<Object?> get props => [sharedRoutineId, userId];
}

/// Event to log member joined activity
class LogMemberJoined extends GroupActivityEvent {
  final String groupId;
  final String userId;
  final String? welcomeMessage;

  const LogMemberJoined({
    required this.groupId,
    required this.userId,
    this.welcomeMessage,
  });

  @override
  List<Object?> get props => [groupId, userId, welcomeMessage];
}

/// Event to log member left activity
class LogMemberLeft extends GroupActivityEvent {
  final String groupId;
  final String userId;
  final String? farewell;

  const LogMemberLeft({
    required this.groupId,
    required this.userId,
    this.farewell,
  });

  @override
  List<Object?> get props => [groupId, userId, farewell];
}

/// Event to log achievement unlocked
class LogAchievementUnlocked extends GroupActivityEvent {
  final String groupId;
  final String userId;
  final String achievementName;
  final String achievementDescription;

  const LogAchievementUnlocked({
    required this.groupId,
    required this.userId,
    required this.achievementName,
    required this.achievementDescription,
  });

  @override
  List<Object?> get props => [groupId, userId, achievementName, achievementDescription];
}

/// Event to log program started
class LogProgramStarted extends GroupActivityEvent {
  final String groupId;
  final String userId;
  final String programName;
  final int durationWeeks;

  const LogProgramStarted({
    required this.groupId,
    required this.userId,
    required this.programName,
    required this.durationWeeks,
  });

  @override
  List<Object?> get props => [groupId, userId, programName, durationWeeks];
}

/// Event to log milestone reached
class LogMilestoneReached extends GroupActivityEvent {
  final String groupId;
  final String userId;
  final String milestoneType;
  final Map<String, dynamic> milestoneData;

  const LogMilestoneReached({
    required this.groupId,
    required this.userId,
    required this.milestoneType,
    required this.milestoneData,
  });

  @override
  List<Object?> get props => [groupId, userId, milestoneType, milestoneData];
}

/// Event to load group activity statistics
class LoadGroupActivityStats extends GroupActivityEvent {
  final String groupId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadGroupActivityStats({
    required this.groupId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [groupId, startDate, endDate];
}

/// Event to load most active members
class LoadMostActiveMembers extends GroupActivityEvent {
  final String groupId;
  final int limit;
  final int days;

  const LoadMostActiveMembers({
    required this.groupId,
    this.limit = 10,
    this.days = 30,
  });

  @override
  List<Object?> get props => [groupId, limit, days];
}

/// Event to load activities mentioning user
class LoadActivitiesMentioningUser extends GroupActivityEvent {
  final String userId;
  final int limit;
  final bool unreadOnly;

  const LoadActivitiesMentioningUser({
    required this.userId,
    this.limit = 20,
    this.unreadOnly = false,
  });

  @override
  List<Object?> get props => [userId, limit, unreadOnly];
}

/// Event to mark activities as read
class MarkActivitiesAsRead extends GroupActivityEvent {
  final List<String> activityIds;
  final String userId;

  const MarkActivitiesAsRead({
    required this.activityIds,
    required this.userId,
  });

  @override
  List<Object?> get props => [activityIds, userId];
}

/// Event to refresh activity feed
class RefreshActivityFeed extends GroupActivityEvent {
  final String groupId;

  const RefreshActivityFeed(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

/// Event to handle real-time activity update
class HandleActivityUpdate extends GroupActivityEvent {
  final String groupId;
  final Map<String, dynamic> activityData;

  const HandleActivityUpdate({
    required this.groupId,
    required this.activityData,
  });

  @override
  List<Object?> get props => [groupId, activityData];
}

/// Event to filter activities by type
class FilterActivitiesByType extends GroupActivityEvent {
  final String groupId;
  final List<GroupActivityType>? activityTypes;

  const FilterActivitiesByType({
    required this.groupId,
    this.activityTypes,
  });

  @override
  List<Object?> get props => [groupId, activityTypes];
}

/// Event to clear activity filters
class ClearActivityFilters extends GroupActivityEvent {
  final String groupId;

  const ClearActivityFilters(this.groupId);

  @override
  List<Object?> get props => [groupId];
}