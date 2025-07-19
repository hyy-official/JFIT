import 'package:dartz/dartz.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import '../entities/group_activity.dart';
import '../entities/shared_routine.dart';
import '../entities/workout_group.dart';

/// Request models for group activity operations
class ShareRoutineRequest {
  final String groupId;
  final String userId;
  final String userProgramId;
  final String routineName;
  final String? description;
  final List<String> exerciseIds;

  const ShareRoutineRequest({
    required this.groupId,
    required this.userId,
    required this.userProgramId,
    required this.routineName,
    this.description,
    required this.exerciseIds,
  });
}

class WorkoutCompletionRequest {
  final String groupId;
  final String userId;
  final String sessionId;
  final int durationMinutes;
  final int exercisesCompleted;
  final String? note;
  final List<String> mentionedUserIds;

  const WorkoutCompletionRequest({
    required this.groupId,
    required this.userId,
    required this.sessionId,
    required this.durationMinutes,
    required this.exercisesCompleted,
    this.note,
    this.mentionedUserIds = const [],
  });
}

class EncouragementRequest {
  final String groupId;
  final String fromUserId;
  final String toUserId;
  final String message;
  final String? activityId; // Optional: specific activity being encouraged

  const EncouragementRequest({
    required this.groupId,
    required this.fromUserId,
    required this.toUserId,
    required this.message,
    this.activityId,
  });
}

class CopyRoutineRequest {
  final String sharedRoutineId;
  final String userId;
  final String? customName; // Optional: custom name for the copied routine

  const CopyRoutineRequest({
    required this.sharedRoutineId,
    required this.userId,
    this.customName,
  });
}

/// Repository interface for group activity operations
/// Handles routine sharing, workout completion logging, and encouragement messages
abstract class GroupActivityRepository extends BaseRepository {
  /// Get group activities feed with pagination
  /// Returns activities ordered by most recent first
  Future<Either<Failure, List<GroupActivity>>> getGroupActivities(
    String groupId, {
    int limit = 50,
    int offset = 0,
    List<GroupActivityType>? activityTypes,
  });

  /// Get activities for a specific user within a group
  /// Useful for user-specific activity tracking
  Future<Either<Failure, List<GroupActivity>>> getUserActivitiesInGroup(
    String groupId,
    String userId, {
    int limit = 20,
    DateTime? since,
  });

  /// Share a workout routine with the group
  /// Creates both a shared routine record and a group activity
  Future<Either<Failure, SharedRoutine>> shareRoutine(ShareRoutineRequest request);

  /// Log workout completion and notify group members
  /// Creates a group activity for workout completion
  Future<Either<Failure, GroupActivity>> logWorkoutCompletion(
    WorkoutCompletionRequest request,
  );

  /// Send encouragement message to a group member
  /// Creates an encouragement activity
  Future<Either<Failure, GroupActivity>> sendEncouragement(
    EncouragementRequest request,
  );

  /// Get shared routines in a group
  /// Returns routines ordered by most recent or most popular
  Future<Either<Failure, List<SharedRoutine>>> getSharedRoutines(
    String groupId, {
    int limit = 20,
    int offset = 0,
    String? orderBy, // 'recent', 'popular', 'likes'
  });

  /// Get details of a specific shared routine
  /// Includes exercise details and sharing user info
  Future<Either<Failure, SharedRoutine?>> getSharedRoutineById(String routineId);

  /// Copy a shared routine to user's personal routines
  /// Increments the copy count and creates user program
  Future<Either<Failure, String>> copySharedRoutine(CopyRoutineRequest request);

  /// Like or unlike a shared routine
  /// Updates the like count and tracks user likes
  Future<Either<Failure, void>> toggleRoutineLike(
    String sharedRoutineId,
    String userId,
  );

  /// Check if user has liked a specific routine
  Future<Either<Failure, bool>> hasUserLikedRoutine(
    String sharedRoutineId,
    String userId,
  );

  /// Get user's shared routines across all groups
  /// Useful for user profile and routine management
  Future<Either<Failure, List<SharedRoutine>>> getUserSharedRoutines(
    String userId, {
    int limit = 20,
  });

  /// Delete a shared routine (only by the sharer or group admin)
  /// Soft delete - marks as inactive but preserves data
  Future<Either<Failure, void>> deleteSharedRoutine(
    String sharedRoutineId,
    String userId,
  );

  /// Log member joining activity
  /// Called when a new member joins the group
  Future<Either<Failure, GroupActivity>> logMemberJoined(
    String groupId,
    String userId,
    String? welcomeMessage,
  );

  /// Log member leaving activity
  /// Called when a member leaves the group
  Future<Either<Failure, GroupActivity>> logMemberLeft(
    String groupId,
    String userId,
    String? farewell,
  );

  /// Log achievement unlocked activity
  /// Called when a user reaches a milestone
  Future<Either<Failure, GroupActivity>> logAchievementUnlocked(
    String groupId,
    String userId,
    String achievementName,
    String achievementDescription,
  );

  /// Log program started activity
  /// Called when a user starts a new workout program
  Future<Either<Failure, GroupActivity>> logProgramStarted(
    String groupId,
    String userId,
    String programName,
    int durationWeeks,
  );

  /// Log milestone reached activity
  /// Called when a user reaches a significant milestone
  Future<Either<Failure, GroupActivity>> logMilestoneReached(
    String groupId,
    String userId,
    String milestoneType,
    Map<String, dynamic> milestoneData,
  );

  /// Get activity statistics for a group
  /// Returns counts by activity type and time periods
  Future<Either<Failure, Map<String, dynamic>>> getGroupActivityStats(
    String groupId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get most active members in a group
  /// Based on activity count in specified time period
  Future<Either<Failure, List<Map<String, dynamic>>>> getMostActiveMembers(
    String groupId, {
    int limit = 10,
    int days = 30,
  });

  /// Get recent activities that mention a specific user
  /// For notification purposes
  Future<Either<Failure, List<GroupActivity>>> getActivitiesMentioningUser(
    String userId, {
    int limit = 20,
    bool unreadOnly = false,
  });

  /// Mark activities as read for a user
  /// For notification management
  Future<Either<Failure, void>> markActivitiesAsRead(
    List<String> activityIds,
    String userId,
  );
}