import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/moderation_action.dart';
import '../../domain/entities/user_moderation_status.dart';
import '../../domain/repositories/moderation_action_repository.dart';
import '../models/moderation_action_model.dart';

class ModerationActionRepositoryImpl implements ModerationActionRepository {
  final SupabaseClient _supabaseClient;

  ModerationActionRepositoryImpl(this._supabaseClient);

  @override
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
  }) async {
    try {
      DateTime? expiresAt;
      if (durationHours != null && durationHours > 0) {
        expiresAt = DateTime.now().add(Duration(hours: durationHours));
      }

      final response = await _supabaseClient
          .from('moderation_actions')
          .insert({
            'moderator_id': moderatorId,
            'report_id': reportId,
            'target_content_type': targetContentType.value,
            'target_content_id': targetContentId,
            'target_user_id': targetUserId,
            'action_type': actionType.value,
            'action_reason': actionReason,
            'action_details': actionDetails,
            'duration_hours': durationHours,
            'is_active': true,
            'expires_at': expiresAt?.toIso8601String(),
          })
          .select()
          .single();

      final action = ModerationActionModel.fromJson(response);

      // Update user moderation status if needed
      await _updateUserModerationStatusAfterAction(
        targetUserId,
        actionType,
        actionReason,
        expiresAt,
      );

      return Right(action);
    } catch (e) {
      return Left(ServerFailure('Failed to create moderation action: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ModerationAction>>> getModerationActionsByModerator(
    String moderatorId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _supabaseClient
          .from('moderation_actions')
          .select()
          .eq('moderator_id', moderatorId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final actions = (response as List<dynamic>)
          .map((json) => ModerationActionModel.fromJson(json))
          .toList();

      return Right(actions);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch moderation actions: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ModerationAction>>> getModerationActionsForUser(
    String userId, {
    bool activeOnly = false,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _supabaseClient
          .from('moderation_actions')
          .select()
          .eq('target_user_id', userId);

      if (activeOnly) {
        query = query.eq('is_active', true);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final actions = (response as List<dynamic>)
          .map((json) => ModerationActionModel.fromJson(json))
          .toList();

      return Right(actions);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch user moderation actions: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ModerationAction>>> getModerationActionsForContent({
    required ModerationTargetType contentType,
    required String contentId,
  }) async {
    try {
      final response = await _supabaseClient
          .from('moderation_actions')
          .select()
          .eq('target_content_type', contentType.value)
          .eq('target_content_id', contentId)
          .order('created_at', ascending: false);

      final actions = (response as List<dynamic>)
          .map((json) => ModerationActionModel.fromJson(json))
          .toList();

      return Right(actions);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch content moderation actions: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ModerationAction>> updateModerationAction({
    required String actionId,
    bool? isActive,
    DateTime? expiresAt,
    Map<String, dynamic>? actionDetails,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (isActive != null) updateData['is_active'] = isActive;
      if (expiresAt != null) updateData['expires_at'] = expiresAt.toIso8601String();
      if (actionDetails != null) updateData['action_details'] = actionDetails;

      final response = await _supabaseClient
          .from('moderation_actions')
          .update(updateData)
          .eq('id', actionId)
          .select()
          .single();

      final action = ModerationActionModel.fromJson(response);
      return Right(action);
    } catch (e) {
      return Left(ServerFailure('Failed to update moderation action: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserModerationStatus?>> getUserModerationStatus({
    required String userId,
    String? groupId,
  }) async {
    try {
      var query = _supabaseClient
          .from('user_moderation_status')
          .select()
          .eq('user_id', userId);

      if (groupId != null) {
        query = query.eq('group_id', groupId);
      } else {
        query = query.isFilter('group_id', null);
      }

      final response = await query.maybeSingle();

      if (response == null) {
        return const Right(null);
      }

      final status = _userModerationStatusFromJson(response);
      return Right(status);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch user moderation status: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserModerationStatus>> updateUserModerationStatus({
    required String userId,
    String? groupId,
    bool? isBanned,
    String? banReason,
    DateTime? banExpiresAt,
    int? warningCount,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'user_id': userId,
        'group_id': groupId,
      };

      if (isBanned != null) updateData['is_banned'] = isBanned;
      if (banReason != null) updateData['ban_reason'] = banReason;
      if (banExpiresAt != null) updateData['ban_expires_at'] = banExpiresAt.toIso8601String();
      if (warningCount != null) {
        updateData['warning_count'] = warningCount;
        if (warningCount > 0) {
          updateData['last_warning_at'] = DateTime.now().toIso8601String();
        }
      }

      final response = await _supabaseClient
          .from('user_moderation_status')
          .upsert(updateData)
          .select()
          .single();

      final status = _userModerationStatusFromJson(response);
      return Right(status);
    } catch (e) {
      return Left(ServerFailure('Failed to update user moderation status: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isUserBanned({
    required String userId,
    String? groupId,
  }) async {
    try {
      final statusResult = await getUserModerationStatus(
        userId: userId,
        groupId: groupId,
      );

      if (statusResult.isLeft()) {
        return Left(statusResult.fold((l) => l, (r) => throw Exception()));
      }

      final status = statusResult.fold((l) => null, (r) => r);
      if (status == null) {
        return const Right(false);
      }

      // Check if ban is active and not expired
      if (!status.isBanned) {
        return const Right(false);
      }

      if (status.banExpiresAt != null && status.banExpiresAt!.isBefore(DateTime.now())) {
        // Ban has expired, update status
        await updateUserModerationStatus(
          userId: userId,
          groupId: groupId,
          isBanned: false,
          banReason: null,
          banExpiresAt: null,
        );
        return const Right(false);
      }

      return const Right(true);
    } catch (e) {
      return Left(ServerFailure('Failed to check user ban status: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ModerationAction>>> getActiveModerationActionsForUser(
    String userId, {
    String? groupId,
  }) async {
    try {
      var query = _supabaseClient
          .from('moderation_actions')
          .select()
          .eq('target_user_id', userId)
          .eq('is_active', true);

      // Filter by actions that haven't expired
      final now = DateTime.now().toIso8601String();
      query = query.or('expires_at.is.null,expires_at.gt.$now');

      final response = await query.order('created_at', ascending: false);

      final actions = (response as List<dynamic>)
          .map((json) => ModerationActionModel.fromJson(json))
          .toList();

      return Right(actions);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch active moderation actions: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> expireTemporaryActions() async {
    try {
      final now = DateTime.now().toIso8601String();
      
      final response = await _supabaseClient
          .from('moderation_actions')
          .update({'is_active': false})
          .eq('is_active', true)
          .not('expires_at', 'is', null)
          .lt('expires_at', now)
          .select('id');

      final expiredCount = (response as List<dynamic>).length;
      return Right(expiredCount);
    } catch (e) {
      return Left(ServerFailure('Failed to expire temporary actions: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getModerationStatistics({
    String? moderatorId,
    String? groupId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabaseClient
          .from('moderation_actions')
          .select('action_type, is_active, created_at, target_user_id');

      if (moderatorId != null) {
        query = query.eq('moderator_id', moderatorId);
      }

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;
      final actions = response as List<dynamic>;

      // Calculate statistics
      final stats = <String, dynamic>{
        'total_actions': actions.length,
        'active_actions': actions.where((a) => a['is_active'] == true).length,
        'actions_by_type': <String, int>{},
        'actions_by_day': <String, int>{},
        'unique_users_moderated': <String>{},
      };

      // Group by action type
      final typeCounts = <String, int>{};
      final uniqueUsers = <String>{};
      
      for (final action in actions) {
        final actionType = action['action_type'] as String;
        typeCounts[actionType] = (typeCounts[actionType] ?? 0) + 1;
        
        final userId = action['target_user_id'] as String;
        uniqueUsers.add(userId);
        
        // Group by day
        final date = DateTime.parse(action['created_at'] as String);
        final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final dayCounts = stats['actions_by_day'] as Map<String, int>;
        dayCounts[dayKey] = (dayCounts[dayKey] ?? 0) + 1;
      }
      
      stats['actions_by_type'] = typeCounts;
      stats['unique_users_moderated_count'] = uniqueUsers.length;

      return Right(stats);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch moderation statistics: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteModerationAction(String actionId) async {
    try {
      await _supabaseClient
          .from('moderation_actions')
          .delete()
          .eq('id', actionId);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete moderation action: ${e.toString()}'));
    }
  }

  /// Update user moderation status after creating a moderation action
  Future<void> _updateUserModerationStatusAfterAction(
    String userId,
    ModerationActionType actionType,
    String actionReason,
    DateTime? expiresAt,
  ) async {
    try {
      switch (actionType) {
        case ModerationActionType.warning:
          // Increment warning count
          final currentStatus = await getUserModerationStatus(userId: userId);
          final warningCount = currentStatus.fold(
            (l) => 1,
            (r) => (r?.warningCount ?? 0) + 1,
          );
          
          await updateUserModerationStatus(
            userId: userId,
            warningCount: warningCount,
          );
          break;
          
        case ModerationActionType.temporaryBan:
          await updateUserModerationStatus(
            userId: userId,
            isBanned: true,
            banReason: actionReason,
            banExpiresAt: expiresAt,
          );
          break;
          
        case ModerationActionType.permanentBan:
          await updateUserModerationStatus(
            userId: userId,
            isBanned: true,
            banReason: actionReason,
            banExpiresAt: null,
          );
          break;
          
        case ModerationActionType.groupRemoval:
          // Group-specific ban
          // This would need group context which isn't available here
          // Should be handled at the service level
          break;
          
        default:
          // No status update needed for other action types
          break;
      }
    } catch (e) {
      // Log error but don't fail the main operation
      print('Failed to update user moderation status: $e');
    }
  }

  /// Convert JSON to UserModerationStatus entity
  UserModerationStatus _userModerationStatusFromJson(Map<String, dynamic> json) {
    return UserModerationStatus(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      groupId: json['group_id'] as String?,
      isBanned: json['is_banned'] as bool,
      banReason: json['ban_reason'] as String?,
      banExpiresAt: json['ban_expires_at'] != null
          ? DateTime.parse(json['ban_expires_at'] as String)
          : null,
      warningCount: json['warning_count'] as int,
      lastWarningAt: json['last_warning_at'] != null
          ? DateTime.parse(json['last_warning_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}