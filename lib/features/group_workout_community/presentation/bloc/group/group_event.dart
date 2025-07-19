import 'package:jfit/core/bloc/base_bloc.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_search_criteria.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/group_repository.dart';

/// Base class for all Group-related events
abstract class GroupEvent extends BaseEvent {
  const GroupEvent();
}

/// Event to load user's groups
class LoadUserGroups extends GroupEvent {
  final String userId;
  final bool forceRefresh;

  const LoadUserGroups({
    required this.userId,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [userId, forceRefresh];
}

/// Event to load public groups for discovery
class LoadPublicGroups extends GroupEvent {
  final int limit;
  final int offset;
  final String? searchQuery;

  const LoadPublicGroups({
    this.limit = 20,
    this.offset = 0,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [limit, offset, searchQuery];
}

/// Event to load detailed information about a specific group
class LoadGroupDetails extends GroupEvent {
  final String groupId;

  const LoadGroupDetails(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

/// Event to create a new group
class CreateGroup extends GroupEvent {
  final CreateGroupRequest request;
  final String creatorId;

  const CreateGroup({
    required this.request,
    required this.creatorId,
  });

  @override
  List<Object?> get props => [request, creatorId];
}

/// Event to join an existing group
class JoinGroup extends GroupEvent {
  final JoinGroupRequest request;

  const JoinGroup(this.request);

  @override
  List<Object?> get props => [request];
}

/// Event to leave a group
class LeaveGroup extends GroupEvent {
  final String groupId;
  final String userId;

  const LeaveGroup({
    required this.groupId,
    required this.userId,
  });

  @override
  List<Object?> get props => [groupId, userId];
}

/// Event to load group members
class LoadGroupMembers extends GroupEvent {
  final String groupId;

  const LoadGroupMembers(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

/// Event to update group settings
class UpdateGroupSettings extends GroupEvent {
  final String groupId;
  final UpdateGroupRequest request;
  final String adminId;

  const UpdateGroupSettings({
    required this.groupId,
    required this.request,
    required this.adminId,
  });

  @override
  List<Object?> get props => [groupId, request, adminId];
}

/// Event to remove a member from the group
class RemoveGroupMember extends GroupEvent {
  final String groupId;
  final String memberUserId;
  final String adminId;

  const RemoveGroupMember({
    required this.groupId,
    required this.memberUserId,
    required this.adminId,
  });

  @override
  List<Object?> get props => [groupId, memberUserId, adminId];
}

/// Event to update member role
class UpdateMemberRole extends GroupEvent {
  final String groupId;
  final String memberUserId;
  final GroupRole newRole;
  final String adminId;

  const UpdateMemberRole({
    required this.groupId,
    required this.memberUserId,
    required this.newRole,
    required this.adminId,
  });

  @override
  List<Object?> get props => [groupId, memberUserId, newRole, adminId];
}

/// Event to transfer group ownership
class TransferOwnership extends GroupEvent {
  final String groupId;
  final String newAdminUserId;
  final String currentAdminId;

  const TransferOwnership({
    required this.groupId,
    required this.newAdminUserId,
    required this.currentAdminId,
  });

  @override
  List<Object?> get props => [groupId, newAdminUserId, currentAdminId];
}

/// Event to generate new invite code
class GenerateInviteCode extends GroupEvent {
  final String groupId;
  final String adminId;

  const GenerateInviteCode({
    required this.groupId,
    required this.adminId,
  });

  @override
  List<Object?> get props => [groupId, adminId];
}

/// Event to validate invite code
class ValidateInviteCode extends GroupEvent {
  final String groupId;
  final String inviteCode;

  const ValidateInviteCode({
    required this.groupId,
    required this.inviteCode,
  });

  @override
  List<Object?> get props => [groupId, inviteCode];
}

/// Event to check group membership
class CheckGroupMembership extends GroupEvent {
  final String groupId;
  final String userId;

  const CheckGroupMembership({
    required this.groupId,
    required this.userId,
  });

  @override
  List<Object?> get props => [groupId, userId];
}

/// Event to load managed groups (admin/moderator)
class LoadManagedGroups extends GroupEvent {
  final String userId;

  const LoadManagedGroups(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to deactivate a group
class DeactivateGroup extends GroupEvent {
  final String groupId;
  final String adminId;

  const DeactivateGroup({
    required this.groupId,
    required this.adminId,
  });

  @override
  List<Object?> get props => [groupId, adminId];
}

/// Event to load group statistics
class LoadGroupStats extends GroupEvent {
  final String groupId;

  const LoadGroupStats(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

/// Event to search groups with enhanced criteria
class SearchGroupsWithCriteria extends GroupEvent {
  final GroupSearchCriteria criteria;
  final int limit;
  final int offset;

  const SearchGroupsWithCriteria({
    required this.criteria,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [criteria, limit, offset];
}

/// Event to load more search results
class LoadMoreSearchResults extends GroupEvent {
  const LoadMoreSearchResults();

  @override
  List<Object?> get props => [];
}

/// Event to get suggested groups for a user
class LoadSuggestedGroups extends GroupEvent {
  final String userId;
  final int limit;

  const LoadSuggestedGroups({
    required this.userId,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [userId, limit];
}

/// Event to get trending groups
class LoadTrendingGroups extends GroupEvent {
  final int limit;

  const LoadTrendingGroups({
    this.limit = 10,
  });

  @override
  List<Object?> get props => [limit];
}

/// Event to search groups (legacy - kept for backward compatibility)
class SearchGroups extends GroupEvent {
  final String query;
  final int limit;

  const SearchGroups({
    required this.query,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, limit];
}

/// Event to clear search results
class ClearGroupSearch extends GroupEvent {
  const ClearGroupSearch();

  @override
  List<Object?> get props => [];
}

/// Event to refresh group data (for real-time updates)
class RefreshGroupData extends GroupEvent {
  final String? groupId; // null to refresh all data

  const RefreshGroupData({this.groupId});

  @override
  List<Object?> get props => [groupId];
}

/// Event to handle real-time group updates
class HandleGroupUpdate extends GroupEvent {
  final String groupId;
  final Map<String, dynamic> updateData;

  const HandleGroupUpdate({
    required this.groupId,
    required this.updateData,
  });

  @override
  List<Object?> get props => [groupId, updateData];
}

/// Event to handle real-time member updates
class HandleMemberUpdate extends GroupEvent {
  final String groupId;
  final String memberId;
  final String updateType; // 'joined', 'left', 'role_changed'
  final Map<String, dynamic>? updateData;

  const HandleMemberUpdate({
    required this.groupId,
    required this.memberId,
    required this.updateType,
    this.updateData,
  });

  @override
  List<Object?> get props => [groupId, memberId, updateType, updateData];
}