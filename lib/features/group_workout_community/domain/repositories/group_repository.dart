import 'package:dartz/dartz.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import '../entities/workout_group.dart';
import '../entities/group_member.dart';
import '../entities/group_search_criteria.dart';

/// Request models for group operations
class CreateGroupRequest {
  final String name;
  final String description;
  final GroupPrivacyType privacyType;
  final int maxMembers;
  final String? groupType; // 'personal_training' for PT groups

  const CreateGroupRequest({
    required this.name,
    required this.description,
    required this.privacyType,
    required this.maxMembers,
    this.groupType,
  });
}

class UpdateGroupRequest {
  final String? name;
  final String? description;
  final GroupPrivacyType? privacyType;
  final int? maxMembers;
  final bool? isActive;

  const UpdateGroupRequest({
    this.name,
    this.description,
    this.privacyType,
    this.maxMembers,
    this.isActive,
  });
}

class JoinGroupRequest {
  final String groupId;
  final String userId;
  final String? inviteCode;

  const JoinGroupRequest({
    required this.groupId,
    required this.userId,
    this.inviteCode,
  });
}

/// Repository interface for group management operations
/// Handles group creation, membership management, and group settings
abstract class GroupRepository extends BaseRepository {
  /// Get all groups that a user is a member of
  /// Returns list of groups ordered by most recently joined
  Future<Either<Failure, List<WorkoutGroup>>> getUserGroups(String userId);

  /// Get public groups that a user can join
  /// Supports pagination and filtering
  Future<Either<Failure, List<WorkoutGroup>>> getPublicGroups({
    int limit = 20,
    int offset = 0,
    String? searchQuery,
  });

  /// Get detailed information about a specific group
  /// Includes member count and admin information
  Future<Either<Failure, WorkoutGroup?>> getGroupById(String groupId);

  /// Create a new workout group
  /// The creator automatically becomes the admin
  Future<Either<Failure, WorkoutGroup>> createGroup(
    CreateGroupRequest request,
    String creatorId,
  );

  /// Join an existing group
  /// Handles both public groups and private groups with invite codes
  Future<Either<Failure, void>> joinGroup(JoinGroupRequest request);

  /// Leave a group
  /// Admin cannot leave unless they transfer ownership first
  Future<Either<Failure, void>> leaveGroup(String groupId, String userId);

  /// Get all members of a specific group
  /// Returns list ordered by join date
  Future<Either<Failure, List<GroupMember>>> getGroupMembers(String groupId);

  /// Update group settings (admin only)
  /// Allows updating name, description, privacy settings, etc.
  Future<Either<Failure, WorkoutGroup>> updateGroupSettings(
    String groupId,
    UpdateGroupRequest request,
    String adminId,
  );

  /// Remove a member from the group (admin/moderator only)
  /// Cannot remove other admins or moderators
  Future<Either<Failure, void>> removeGroupMember(
    String groupId,
    String memberUserId,
    String adminId,
  );

  /// Update member role (admin only)
  /// Can promote/demote members to moderator
  Future<Either<Failure, void>> updateMemberRole(
    String groupId,
    String memberUserId,
    GroupRole newRole,
    String adminId,
  );

  /// Transfer group ownership to another member (admin only)
  /// The current admin becomes a regular member
  Future<Either<Failure, void>> transferOwnership(
    String groupId,
    String newAdminUserId,
    String currentAdminId,
  );

  /// Generate a new invite code for private groups (admin only)
  /// Invalidates the previous invite code
  Future<Either<Failure, String>> generateInviteCode(
    String groupId,
    String adminId,
  );

  /// Validate an invite code for a private group
  /// Returns true if the code is valid and not expired
  Future<Either<Failure, bool>> validateInviteCode(
    String groupId,
    String inviteCode,
  );

  /// Check if a user is a member of a specific group
  /// Returns the member information if found
  Future<Either<Failure, GroupMember?>> getGroupMembership(
    String groupId,
    String userId,
  );

  /// Get groups where the user has admin or moderator privileges
  /// Used for management interfaces
  Future<Either<Failure, List<WorkoutGroup>>> getManagedGroups(String userId);

  /// Deactivate a group (admin only)
  /// Soft delete - marks group as inactive but preserves data
  Future<Either<Failure, void>> deactivateGroup(String groupId, String adminId);

  /// Get group statistics
  /// Returns member count, activity metrics, etc.
  Future<Either<Failure, Map<String, dynamic>>> getGroupStats(String groupId);

  /// Enhanced search for groups with advanced filtering and sorting
  /// Supports text search, privacy filters, size filters, and custom sorting
  Future<Either<Failure, List<WorkoutGroup>>> searchGroups({
    required GroupSearchCriteria criteria,
    int limit = 20,
    int offset = 0,
  });

  /// Get suggested groups for a user based on their activity and preferences
  /// Uses recommendation algorithm to suggest relevant groups
  Future<Either<Failure, List<WorkoutGroup>>> getSuggestedGroups(
    String userId, {
    int limit = 10,
  });

  /// Get trending groups based on recent activity and member growth
  /// Returns groups with high activity in the last 7 days
  Future<Either<Failure, List<WorkoutGroup>>> getTrendingGroups({
    int limit = 10,
  });
}