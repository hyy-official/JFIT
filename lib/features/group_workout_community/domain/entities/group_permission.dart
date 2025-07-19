import 'package:equatable/equatable.dart';
import 'workout_group.dart';

/// 그룹 권한 타입
enum GroupPermissionType {
  // 멤버 관리 권한
  inviteMembers,
  removeMembers,
  promoteMembers,
  demoteMembers,
  
  // 그룹 설정 권한
  editGroupInfo,
  changeGroupSettings,
  deleteGroup,
  manageInviteCode,
  
  // 콘텐츠 관리 권한
  deleteMessages,
  deleteActivities,
  moderateContent,
  pinMessages,
  
  // 커뮤니티 관리 권한
  deletePosts,
  deleteComments,
  moderatePosts,
  banUsers,
  
  // 기본 권한
  viewGroup,
  sendMessages,
  shareRoutines,
  viewActivities,
  createPosts,
  commentOnPosts,
  
  // PT 그룹 전용 권한
  viewMemberDiets,
  provideDietFeedback,
  accessDietAnalytics,
}

/// 그룹 권한 정보
class GroupPermission extends Equatable {
  final GroupRole role;
  final Set<GroupPermissionType> permissions;

  const GroupPermission({
    required this.role,
    required this.permissions,
  });

  @override
  List<Object> get props => [role, permissions];

  /// 특정 권한을 가지고 있는지 확인
  bool hasPermission(GroupPermissionType permission) {
    return permissions.contains(permission);
  }

  /// 여러 권한을 모두 가지고 있는지 확인
  bool hasAllPermissions(List<GroupPermissionType> requiredPermissions) {
    return requiredPermissions.every((permission) => permissions.contains(permission));
  }

  /// 여러 권한 중 하나라도 가지고 있는지 확인
  bool hasAnyPermission(List<GroupPermissionType> requiredPermissions) {
    return requiredPermissions.any((permission) => permissions.contains(permission));
  }
}

/// 그룹 권한 매니저
class GroupPermissionManager {
  static const Map<GroupRole, Set<GroupPermissionType>> _rolePermissions = {
    GroupRole.admin: {
      // 모든 권한
      GroupPermissionType.inviteMembers,
      GroupPermissionType.removeMembers,
      GroupPermissionType.promoteMembers,
      GroupPermissionType.demoteMembers,
      GroupPermissionType.editGroupInfo,
      GroupPermissionType.changeGroupSettings,
      GroupPermissionType.deleteGroup,
      GroupPermissionType.manageInviteCode,
      GroupPermissionType.deleteMessages,
      GroupPermissionType.deleteActivities,
      GroupPermissionType.moderateContent,
      GroupPermissionType.pinMessages,
      GroupPermissionType.deletePosts,
      GroupPermissionType.deleteComments,
      GroupPermissionType.moderatePosts,
      GroupPermissionType.banUsers,
      GroupPermissionType.viewGroup,
      GroupPermissionType.sendMessages,
      GroupPermissionType.shareRoutines,
      GroupPermissionType.viewActivities,
      GroupPermissionType.createPosts,
      GroupPermissionType.commentOnPosts,
      GroupPermissionType.viewMemberDiets,
      GroupPermissionType.provideDietFeedback,
      GroupPermissionType.accessDietAnalytics,
    },
    GroupRole.moderator: {
      // 콘텐츠 관리 및 기본 권한
      GroupPermissionType.inviteMembers,
      GroupPermissionType.removeMembers, // 모더레이터도 멤버 제거 가능
      GroupPermissionType.deleteMessages,
      GroupPermissionType.deleteActivities,
      GroupPermissionType.moderateContent,
      GroupPermissionType.pinMessages,
      GroupPermissionType.deletePosts,
      GroupPermissionType.deleteComments,
      GroupPermissionType.moderatePosts,
      GroupPermissionType.viewGroup,
      GroupPermissionType.sendMessages,
      GroupPermissionType.shareRoutines,
      GroupPermissionType.viewActivities,
      GroupPermissionType.createPosts,
      GroupPermissionType.commentOnPosts,
    },
    GroupRole.member: {
      // 기본 권한만
      GroupPermissionType.viewGroup,
      GroupPermissionType.sendMessages,
      GroupPermissionType.shareRoutines,
      GroupPermissionType.viewActivities,
      GroupPermissionType.createPosts,
      GroupPermissionType.commentOnPosts,
    },
  };

  /// 역할에 따른 권한 정보 반환
  static GroupPermission getPermissionForRole(GroupRole role) {
    final permissions = _rolePermissions[role] ?? <GroupPermissionType>{};
    return GroupPermission(role: role, permissions: permissions);
  }

  /// 사용자가 특정 권한을 가지고 있는지 확인
  static bool hasPermission(GroupRole userRole, GroupPermissionType permission) {
    final userPermissions = _rolePermissions[userRole] ?? <GroupPermissionType>{};
    return userPermissions.contains(permission);
  }

  /// 사용자가 여러 권한을 모두 가지고 있는지 확인
  static bool hasAllPermissions(GroupRole userRole, List<GroupPermissionType> permissions) {
    final userPermissions = _rolePermissions[userRole] ?? <GroupPermissionType>{};
    return permissions.every((permission) => userPermissions.contains(permission));
  }

  /// 사용자가 여러 권한 중 하나라도 가지고 있는지 확인
  static bool hasAnyPermission(GroupRole userRole, List<GroupPermissionType> permissions) {
    final userPermissions = _rolePermissions[userRole] ?? <GroupPermissionType>{};
    return permissions.any((permission) => userPermissions.contains(permission));
  }

  /// 역할 간 권한 비교 (상위 역할인지 확인)
  static bool canManageRole(GroupRole managerRole, GroupRole targetRole) {
    // 관리자는 모든 역할을 관리할 수 있음
    if (managerRole == GroupRole.admin) return true;
    
    // 모더레이터는 일반 멤버만 관리할 수 있음
    if (managerRole == GroupRole.moderator && targetRole == GroupRole.member) return true;
    
    // 일반 멤버는 아무도 관리할 수 없음
    return false;
  }

  /// PT 그룹에서 추가 권한 확인
  static bool hasPTPermission(GroupRole userRole, GroupPermissionType permission, bool isPTGroup) {
    if (!isPTGroup) return false;
    
    final ptPermissions = {
      GroupPermissionType.viewMemberDiets,
      GroupPermissionType.provideDietFeedback,
      GroupPermissionType.accessDietAnalytics,
    };
    
    if (!ptPermissions.contains(permission)) return false;
    
    // PT 그룹에서는 관리자만 식단 관련 권한을 가짐
    return userRole == GroupRole.admin;
  }
}