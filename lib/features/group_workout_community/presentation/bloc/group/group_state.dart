import 'package:flutter/foundation.dart';
import 'package:jfit/core/bloc/base_bloc.dart';
import 'package:jfit/core/error/bloc_errors.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_member.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_search_criteria.dart';

/// Base class for all Group-related states
abstract class GroupState extends BaseState {
  const GroupState();
}

/// Initial state when GroupBloc is first created
class GroupInitial extends GroupState {
  const GroupInitial();

  @override
  List<Object?> get props => [];
}

/// State when group operations are in progress
class GroupLoading extends GroupState {
  final String? message;
  final String? operationType; // 'loading_groups', 'creating_group', 'joining_group', etc.

  const GroupLoading({
    this.message,
    this.operationType,
  });

  @override
  List<Object?> get props => [message, operationType];
}

/// State when user's groups are loaded
class UserGroupsLoaded extends GroupState {
  final List<WorkoutGroup> groups;
  final DateTime loadedAt;

  const UserGroupsLoaded({
    required this.groups,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [groups, loadedAt];

  UserGroupsLoaded copyWith({
    List<WorkoutGroup>? groups,
    DateTime? loadedAt,
  }) {
    return UserGroupsLoaded(
      groups: groups ?? this.groups,
      loadedAt: loadedAt ?? this.loadedAt,
    );
  }
}

/// State when public groups are loaded
class PublicGroupsLoaded extends GroupState {
  final List<WorkoutGroup> groups;
  final bool hasMore;
  final int totalCount;
  final String? searchQuery;

  const PublicGroupsLoaded({
    required this.groups,
    this.hasMore = false,
    this.totalCount = 0,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [groups, hasMore, totalCount, searchQuery];

  PublicGroupsLoaded copyWith({
    List<WorkoutGroup>? groups,
    bool? hasMore,
    int? totalCount,
    String? searchQuery,
  }) {
    return PublicGroupsLoaded(
      groups: groups ?? this.groups,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// State when group details are loaded
class GroupDetailsLoaded extends GroupState {
  final WorkoutGroup group;
  final DateTime loadedAt;

  const GroupDetailsLoaded({
    required this.group,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [group, loadedAt];

  GroupDetailsLoaded copyWith({
    WorkoutGroup? group,
    DateTime? loadedAt,
  }) {
    return GroupDetailsLoaded(
      group: group ?? this.group,
      loadedAt: loadedAt ?? this.loadedAt,
    );
  }
}

/// State when group members are loaded
class GroupMembersLoaded extends GroupState {
  final String groupId;
  final List<GroupMember> members;
  final DateTime loadedAt;

  const GroupMembersLoaded({
    required this.groupId,
    required this.members,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [groupId, members, loadedAt];

  GroupMembersLoaded copyWith({
    String? groupId,
    List<GroupMember>? members,
    DateTime? loadedAt,
  }) {
    return GroupMembersLoaded(
      groupId: groupId ?? this.groupId,
      members: members ?? this.members,
      loadedAt: loadedAt ?? this.loadedAt,
    );
  }
}

/// State when a group is successfully created
class GroupCreated extends GroupState {
  final WorkoutGroup group;
  final DateTime createdAt;

  const GroupCreated({
    required this.group,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [group, createdAt];
}

/// State when successfully joined a group
class GroupJoined extends GroupState {
  final String groupId;
  final String groupName;
  final DateTime joinedAt;

  const GroupJoined({
    required this.groupId,
    required this.groupName,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [groupId, groupName, joinedAt];
}

/// State when successfully left a group
class GroupLeft extends GroupState {
  final String groupId;
  final String groupName;
  final DateTime leftAt;

  const GroupLeft({
    required this.groupId,
    required this.groupName,
    required this.leftAt,
  });

  @override
  List<Object?> get props => [groupId, groupName, leftAt];
}

/// State when group settings are updated
class GroupSettingsUpdated extends GroupState {
  final WorkoutGroup updatedGroup;
  final DateTime updatedAt;

  const GroupSettingsUpdated({
    required this.updatedGroup,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [updatedGroup, updatedAt];
}

/// State when a member is removed from the group
class GroupMemberRemoved extends GroupState {
  final String groupId;
  final String removedMemberId;
  final String removedMemberName;
  final DateTime removedAt;

  const GroupMemberRemoved({
    required this.groupId,
    required this.removedMemberId,
    required this.removedMemberName,
    required this.removedAt,
  });

  @override
  List<Object?> get props => [groupId, removedMemberId, removedMemberName, removedAt];
}

/// State when member role is updated
class MemberRoleUpdated extends GroupState {
  final String groupId;
  final String memberId;
  final GroupRole newRole;
  final DateTime updatedAt;

  const MemberRoleUpdated({
    required this.groupId,
    required this.memberId,
    required this.newRole,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [groupId, memberId, newRole, updatedAt];
}

/// State when group ownership is transferred
class OwnershipTransferred extends GroupState {
  final String groupId;
  final String newAdminId;
  final String previousAdminId;
  final DateTime transferredAt;

  const OwnershipTransferred({
    required this.groupId,
    required this.newAdminId,
    required this.previousAdminId,
    required this.transferredAt,
  });

  @override
  List<Object?> get props => [groupId, newAdminId, previousAdminId, transferredAt];
}

/// State when invite code is generated
class InviteCodeGenerated extends GroupState {
  final String groupId;
  final String inviteCode;
  final DateTime generatedAt;

  const InviteCodeGenerated({
    required this.groupId,
    required this.inviteCode,
    required this.generatedAt,
  });

  @override
  List<Object?> get props => [groupId, inviteCode, generatedAt];
}

/// State when invite code is validated
class InviteCodeValidated extends GroupState {
  final String groupId;
  final String inviteCode;
  final bool isValid;
  final DateTime validatedAt;

  const InviteCodeValidated({
    required this.groupId,
    required this.inviteCode,
    required this.isValid,
    required this.validatedAt,
  });

  @override
  List<Object?> get props => [groupId, inviteCode, isValid, validatedAt];
}

/// State when group membership is checked
class GroupMembershipChecked extends GroupState {
  final String groupId;
  final String userId;
  final GroupMember? membership;
  final DateTime checkedAt;

  const GroupMembershipChecked({
    required this.groupId,
    required this.userId,
    this.membership,
    required this.checkedAt,
  });

  @override
  List<Object?> get props => [groupId, userId, membership, checkedAt];

  bool get isMember => membership != null;
}

/// State when managed groups are loaded
class ManagedGroupsLoaded extends GroupState {
  final List<WorkoutGroup> groups;
  final DateTime loadedAt;

  const ManagedGroupsLoaded({
    required this.groups,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [groups, loadedAt];
}

/// State when a group is deactivated
class GroupDeactivated extends GroupState {
  final String groupId;
  final String groupName;
  final DateTime deactivatedAt;

  const GroupDeactivated({
    required this.groupId,
    required this.groupName,
    required this.deactivatedAt,
  });

  @override
  List<Object?> get props => [groupId, groupName, deactivatedAt];
}

/// State when group statistics are loaded
class GroupStatsLoaded extends GroupState {
  final String groupId;
  final Map<String, dynamic> stats;
  final DateTime loadedAt;

  const GroupStatsLoaded({
    required this.groupId,
    required this.stats,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [groupId, stats, loadedAt];
}

/// State when enhanced group search results are loaded
class EnhancedGroupSearchResults extends GroupState {
  final List<WorkoutGroup> groups;
  final GroupSearchCriteria criteria;
  final bool hasMore;
  final int totalCount;
  final Duration? searchDuration;
  final DateTime searchedAt;

  const EnhancedGroupSearchResults({
    required this.groups,
    required this.criteria,
    this.hasMore = false,
    this.totalCount = 0,
    this.searchDuration,
    required this.searchedAt,
  });

  @override
  List<Object?> get props => [groups, criteria, hasMore, totalCount, searchDuration, searchedAt];

  EnhancedGroupSearchResults copyWith({
    List<WorkoutGroup>? groups,
    GroupSearchCriteria? criteria,
    bool? hasMore,
    int? totalCount,
    Duration? searchDuration,
    DateTime? searchedAt,
  }) {
    return EnhancedGroupSearchResults(
      groups: groups ?? this.groups,
      criteria: criteria ?? this.criteria,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
      searchDuration: searchDuration ?? this.searchDuration,
      searchedAt: searchedAt ?? this.searchedAt,
    );
  }
}

/// State when suggested groups are loaded
class SuggestedGroupsLoaded extends GroupState {
  final List<WorkoutGroup> groups;
  final String userId;
  final DateTime loadedAt;

  const SuggestedGroupsLoaded({
    required this.groups,
    required this.userId,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [groups, userId, loadedAt];
}

/// State when trending groups are loaded
class TrendingGroupsLoaded extends GroupState {
  final List<WorkoutGroup> groups;
  final DateTime loadedAt;

  const TrendingGroupsLoaded({
    required this.groups,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [groups, loadedAt];
}

/// State when group search results are loaded (legacy - kept for backward compatibility)
class GroupSearchResults extends GroupState {
  final List<WorkoutGroup> groups;
  final String query;
  final bool hasMore;
  final int totalCount;

  const GroupSearchResults({
    required this.groups,
    required this.query,
    this.hasMore = false,
    this.totalCount = 0,
  });

  @override
  List<Object?> get props => [groups, query, hasMore, totalCount];
}

/// State when group search is cleared
class GroupSearchCleared extends GroupState {
  const GroupSearchCleared();

  @override
  List<Object?> get props => [];
}

/// State when real-time group update is received
class GroupUpdatedRealtime extends GroupState {
  final String groupId;
  final Map<String, dynamic> updateData;
  final DateTime updatedAt;

  const GroupUpdatedRealtime({
    required this.groupId,
    required this.updateData,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [groupId, updateData, updatedAt];
}

/// State when real-time member update is received
class MemberUpdatedRealtime extends GroupState {
  final String groupId;
  final String memberId;
  final String updateType;
  final Map<String, dynamic>? updateData;
  final DateTime updatedAt;

  const MemberUpdatedRealtime({
    required this.groupId,
    required this.memberId,
    required this.updateType,
    this.updateData,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [groupId, memberId, updateType, updateData, updatedAt];
}

/// State when a group-related error occurs
class GroupErrorState extends GroupState {
  final BlocError error;
  final bool isRetryable;
  final VoidCallback? retryAction;
  final String? recoverySuggestion;
  final String? operationType; // What operation failed

  const GroupErrorState(
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
      case 'group_not_found':
        return '그룹을 찾을 수 없습니다.';
      case 'group_full':
        return '그룹이 가득 찼습니다.';
      case 'insufficient_permissions':
        return '이 작업을 수행할 권한이 없습니다.';
      case 'invalid_invite_code':
        return '유효하지 않거나 만료된 초대 코드입니다.';
      case 'already_member':
        return '이미 이 그룹의 멤버입니다.';
      case 'cannot_leave_as_admin':
        return '관리자는 그룹을 떠날 수 없습니다. 먼저 관리자 권한을 이양해주세요.';
      case 'group_creation_failed':
        return '그룹 생성에 실패했습니다.';
      case 'group_join_failed':
        return '그룹 가입에 실패했습니다.';
      case 'member_removal_failed':
        return '멤버 제거에 실패했습니다.';
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
          return '그룹을 찾을 수 없습니다.';
        } else {
          return '그룹 작업 중 오류가 발생했습니다.';
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
      case 'group_creation_failed':
        return '다시 생성';
      case 'group_join_failed':
        return '다시 가입';
      case 'invalid_invite_code':
        return '코드 재입력';
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
      case 'group_not_found':
        return '그룹이 삭제되었거나 존재하지 않을 수 있습니다.';
      case 'group_full':
        return '다른 그룹을 찾아보거나 나중에 다시 시도해주세요.';
      case 'insufficient_permissions':
        return '그룹 관리자에게 문의하거나 권한을 요청해주세요.';
      case 'invalid_invite_code':
        return '그룹 관리자에게 새로운 초대 코드를 요청해주세요.';
      case 'already_member':
        return '이미 그룹의 멤버이므로 그룹 페이지로 이동하세요.';
      case 'cannot_leave_as_admin':
        return '다른 멤버에게 관리자 권한을 이양한 후 그룹을 떠날 수 있습니다.';
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

  /// Create a GroupErrorState from a generic error
  factory GroupErrorState.fromError(
    dynamic error, {
    String? code,
    String? operationType,
  }) {
    if (error is BlocError) {
      return GroupErrorState(
        error,
        operationType: operationType,
      );
    }

    final groupError = GroupError(
      error.toString(),
      code: code ?? BlocErrorCodes.unknown,
    );

    return GroupErrorState(
      groupError,
      operationType: operationType,
    );
  }

  /// Create a GroupErrorState with a specific message and code
  factory GroupErrorState.withCode(
    String message,
    String code, {
    String? operationType,
  }) {
    return GroupErrorState(
      GroupError(message, code: code),
      operationType: operationType,
    );
  }

  /// Create retryable error state
  factory GroupErrorState.withRetry({
    required BlocError error,
    required VoidCallback retryAction,
    String? recoverySuggestion,
    String? operationType,
  }) {
    return GroupErrorState(
      error,
      isRetryable: true,
      retryAction: retryAction,
      recoverySuggestion: recoverySuggestion,
      operationType: operationType,
    );
  }

  /// Create specific error states
  factory GroupErrorState.groupNotFound(String groupId) {
    return GroupErrorState.withCode(
      '그룹을 찾을 수 없습니다: "$groupId"',
      'group_not_found',
    );
  }

  factory GroupErrorState.groupFull(String groupName) {
    return GroupErrorState.withCode(
      '그룹이 가득 찼습니다: "$groupName"',
      'group_full',
    );
  }

  factory GroupErrorState.insufficientPermissions(String operation) {
    return GroupErrorState.withCode(
      '권한이 부족합니다: $operation',
      'insufficient_permissions',
    );
  }

  factory GroupErrorState.invalidInviteCode() {
    return GroupErrorState.withCode(
      '유효하지 않거나 만료된 초대 코드입니다',
      'invalid_invite_code',
    );
  }

  factory GroupErrorState.alreadyMember(String groupName) {
    return GroupErrorState.withCode(
      '이미 그룹의 멤버입니다: "$groupName"',
      'already_member',
    );
  }

  factory GroupErrorState.cannotLeaveAsAdmin() {
    return GroupErrorState.withCode(
      '관리자는 그룹을 떠날 수 없습니다',
      'cannot_leave_as_admin',
    );
  }

  factory GroupErrorState.operationFailed(String operation, [String? details]) {
    return GroupErrorState.withCode(
      '$operation 실패${details != null ? ': $details' : ''}',
      '${operation.toLowerCase()}_failed',
      operationType: operation,
    );
  }
}

/// Custom error class for group-related errors
class GroupError extends BlocError {
  const GroupError(String message, {String? code}) : super(message, code: code);
}