import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/moderation_action.dart';
import '../entities/user_moderation_status.dart';

abstract class ModerationActionRepository {
  /// Create a new moderation action
  Future<Either<Failure, ModerationAction>> createModerationAction({
    required String moderatorId,
    String? reportId,
    required ModerationTargetType targetContentType,
    required String targetContentId,
    required String targetUserId,
    required ModerationActionType actionType,
    required String actionReason,
    Map<String, dynamic> actionDetails = const {},
    int? durationHours,
  });

  /// Get moderation actions by moderator
  Future<Either<Failure, List<ModerationAction>>> getModerationActionsByModerator(
    String moderatorId, {
    int limit = 50,
    int offset = 0,
  });

  /// Get moderation actions for a specific user
  Future<Either<Failure, List<ModerationAction>>> getModerationActionsForUser(
    String userId, {
    bool activeOnly = false,
    int limit = 50,
    int offset = 0,
  });

  /// Get moderation actions for specific content
  Future<Either<Failure, List<ModerationAction>>> getModerationActionsForContent({
    required ModerationTargetType contentType,
    required String contentId,
  });

  /// Update moderation action (deactivate, extend, etc.)
  Future<Either<Failure, ModerationAction>> updateModerationAction({
    required String actionId,
    bool? isActive,
    DateTime? expiresAt,
    Map<String, dynamic>? actionDetails,
  });

  /// Get user moderation status
  Future<Either<Failure, UserModerationStatus?>> getUserModerationStatus({
    required String userId,
    String? groupId,
  });

  /// Update user moderation status
  Future<Either<Failure, UserModerationStatus>> updateUserModerationStatus({
    required String userId,
    String? groupId,
    bool? isBanned,
    String? banReason,
    DateTime? banExpiresAt,
    int? warningCount,
  });

  /// Check if user is currently banned
  Future<Either<Failure, bool>> isUserBanned({
    required String userId,
    String? groupId,
  });

  /// Get active moderation actions for user
  Future<Either<Failure, List<ModerationAction>>> getActiveModerationActionsForUser(
    String userId, {
    String? groupId,
  });

  /// Expire temporary moderation actions
  Future<Either<Failure, int>> expireTemporaryActions();

  /// Get moderation statistics
  Future<Either<Failure, Map<String, dynamic>>> getModerationStatistics({
    String? moderatorId,
    String? groupId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Delete moderation action (admin only)
  Future<Either<Failure, void>> deleteModerationAction(String actionId);
}