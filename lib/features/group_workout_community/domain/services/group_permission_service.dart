import '../entities/group_permission.dart';
import '../entities/workout_group.dart';
import '../entities/group_member.dart';

/// 그룹 권한 확인 서비스
class GroupPermissionService {
  /// 사용자가 그룹에서 특정 권한을 가지고 있는지 확인
  static bool hasPermission({
    required GroupMember member,
    required WorkoutGroup group,
    required GroupPermissionType permission,
  }) {
    // 비활성 멤버는 권한 없음
    if (!member.isActive) return false;
    
    // 기본 권한 확인
    if (!GroupPermissionManager.hasPermission(member.role, permission)) {
      return false;
    }
    
    // PT 그룹 전용 권한 확인
    final ptPermissions = {
      GroupPermissionType.viewMemberDiets,
      GroupPermissionType.provideDietFeedback,
      GroupPermissionType.accessDietAnalytics,
    };
    
    if (ptPermissions.contains(permission)) {
      return GroupPermissionManager.hasPTPermission(member.role, permission, group.isPTGroup);
    }
    
    return true;
  }

  /// 사용자가 그룹에서 여러 권한을 모두 가지고 있는지 확인
  static bool hasAllPermissions({
    required GroupMember member,
    required WorkoutGroup group,
    required List<GroupPermissionType> permissions,
  }) {
    return permissions.every((permission) => hasPermission(
      member: member,
      group: group,
      permission: permission,
    ));
  }

  /// 사용자가 그룹에서 여러 권한 중 하나라도 가지고 있는지 확인
  static bool hasAnyPermission({
    required GroupMember member,
    required WorkoutGroup group,
    required List<GroupPermissionType> permissions,
  }) {
    return permissions.any((permission) => hasPermission(
      member: member,
      group: group,
      permission: permission,
    ));
  }

  /// 사용자가 다른 멤버를 관리할 수 있는지 확인
  static bool canManageMember({
    required GroupMember manager,
    required GroupMember target,
    required WorkoutGroup group,
  }) {
    // 비활성 관리자는 권한 없음
    if (!manager.isActive) return false;
    
    // 자기 자신은 관리할 수 없음
    if (manager.userId == target.userId) return false;
    
    // 그룹 관리자는 항상 관리 가능
    if (manager.userId == group.adminId) return true;
    
    // 역할 기반 관리 권한 확인
    return GroupPermissionManager.canManageRole(manager.role, target.role);
  }

  /// 사용자가 특정 작업을 수행할 수 있는지 확인
  static bool canPerformAction({
    required GroupMember member,
    required WorkoutGroup group,
    required GroupAction action,
    GroupMember? targetMember,
  }) {
    switch (action) {
      case GroupAction.inviteMember:
        return hasPermission(
          member: member,
          group: group,
          permission: GroupPermissionType.inviteMembers,
        );
      
      case GroupAction.removeMember:
        if (targetMember == null) return false;
        return hasPermission(
          member: member,
          group: group,
          permission: GroupPermissionType.removeMembers,
        ) && canManageMember(
          manager: member,
          target: targetMember,
          group: group,
        );
      
      case GroupAction.promoteMember:
        if (targetMember == null) return false;
        return hasPermission(
          member: member,
          group: group,
          permission: GroupPermissionType.promoteMembers,
        ) && canManageMember(
          manager: member,
          target: targetMember,
          group: group,
        );
      
      case GroupAction.demoteMember:
        if (targetMember == null) return false;
        return hasPermission(
          member: member,
          group: group,
          permission: GroupPermissionType.demoteMembers,
        ) && canManageMember(
          manager: member,
          target: targetMember,
          group: group,
        );
      
      case GroupAction.editGroupInfo:
        return hasPermission(
          member: member,
          group: group,
          permission: GroupPermissionType.editGroupInfo,
        );
      
      case GroupAction.deleteGroup:
        return member.userId == group.adminId && hasPermission(
          member: member,
          group: group,
          permission: GroupPermissionType.deleteGroup,
        );
      
      case GroupAction.moderateContent:
        return hasPermission(
          member: member,
          group: group,
          permission: GroupPermissionType.moderateContent,
        );
      
      case GroupAction.viewDietData:
        return hasPermission(
          member: member,
          group: group,
          permission: GroupPermissionType.viewMemberDiets,
        );
      
      case GroupAction.provideDietFeedback:
        return hasPermission(
          member: member,
          group: group,
          permission: GroupPermissionType.provideDietFeedback,
        );
    }
  }

  /// 사용자의 그룹 내 권한 레벨 반환
  static GroupPermissionLevel getPermissionLevel({
    required GroupMember member,
    required WorkoutGroup group,
  }) {
    if (!member.isActive) return GroupPermissionLevel.none;
    
    if (member.userId == group.adminId) {
      return GroupPermissionLevel.admin;
    }
    
    switch (member.role) {
      case GroupRole.admin:
        return GroupPermissionLevel.admin;
      case GroupRole.moderator:
        return GroupPermissionLevel.moderator;
      case GroupRole.member:
        return GroupPermissionLevel.member;
    }
  }

  /// UI 표시를 위한 권한 확인
  static Map<String, bool> getUIPermissions({
    required GroupMember member,
    required WorkoutGroup group,
  }) {
    return {
      'canInviteMembers': hasPermission(
        member: member,
        group: group,
        permission: GroupPermissionType.inviteMembers,
      ),
      'canRemoveMembers': hasPermission(
        member: member,
        group: group,
        permission: GroupPermissionType.removeMembers,
      ),
      'canEditGroup': hasPermission(
        member: member,
        group: group,
        permission: GroupPermissionType.editGroupInfo,
      ),
      'canDeleteGroup': canPerformAction(
        member: member,
        group: group,
        action: GroupAction.deleteGroup,
      ),
      'canModerateContent': hasPermission(
        member: member,
        group: group,
        permission: GroupPermissionType.moderateContent,
      ),
      'canManageInviteCode': hasPermission(
        member: member,
        group: group,
        permission: GroupPermissionType.manageInviteCode,
      ),
      'canViewDietData': hasPermission(
        member: member,
        group: group,
        permission: GroupPermissionType.viewMemberDiets,
      ),
      'canProvideDietFeedback': hasPermission(
        member: member,
        group: group,
        permission: GroupPermissionType.provideDietFeedback,
      ),
      'canAccessDietAnalytics': hasPermission(
        member: member,
        group: group,
        permission: GroupPermissionType.accessDietAnalytics,
      ),
    };
  }
}

/// 그룹 내 작업 타입
enum GroupAction {
  inviteMember,
  removeMember,
  promoteMember,
  demoteMember,
  editGroupInfo,
  deleteGroup,
  moderateContent,
  viewDietData,
  provideDietFeedback,
}

/// 권한 레벨
enum GroupPermissionLevel {
  none,
  member,
  moderator,
  admin,
}