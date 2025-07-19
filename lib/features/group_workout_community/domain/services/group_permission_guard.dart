import 'package:flutter/material.dart';
import '../entities/group_member.dart';
import '../entities/workout_group.dart';
import '../entities/group_permission.dart';
import 'group_permission_service.dart';

/// 권한 기반 가드 서비스
class GroupPermissionGuard {
  /// 권한 확인 후 작업 실행
  static Future<bool> executeWithPermission({
    required BuildContext context,
    required GroupMember member,
    required WorkoutGroup group,
    required GroupPermissionType permission,
    required Future<void> Function() action,
    String? deniedMessage,
    bool showSnackBar = true,
  }) async {
    if (!GroupPermissionService.hasPermission(
      member: member,
      group: group,
      permission: permission,
    )) {
      if (showSnackBar) {
        _showPermissionDeniedSnackBar(
          context,
          deniedMessage ?? '이 작업을 수행할 권한이 없습니다.',
        );
      }
      return false;
    }

    try {
      await action();
      return true;
    } catch (e) {
      if (showSnackBar) {
        _showErrorSnackBar(context, '작업 실행 중 오류가 발생했습니다: $e');
      }
      return false;
    }
  }

  /// 작업 권한 확인 후 실행
  static Future<bool> executeWithAction({
    required BuildContext context,
    required GroupMember member,
    required WorkoutGroup group,
    required GroupAction action,
    required Future<void> Function() callback,
    GroupMember? targetMember,
    String? deniedMessage,
    bool showSnackBar = true,
  }) async {
    if (!GroupPermissionService.canPerformAction(
      member: member,
      group: group,
      action: action,
      targetMember: targetMember,
    )) {
      if (showSnackBar) {
        _showPermissionDeniedSnackBar(
          context,
          deniedMessage ?? '이 작업을 수행할 권한이 없습니다.',
        );
      }
      return false;
    }

    try {
      await callback();
      return true;
    } catch (e) {
      if (showSnackBar) {
        _showErrorSnackBar(context, '작업 실행 중 오류가 발생했습니다: $e');
      }
      return false;
    }
  }

  /// 권한 확인 후 페이지 이동
  static Future<bool> navigateWithPermission({
    required BuildContext context,
    required GroupMember member,
    required WorkoutGroup group,
    required GroupPermissionType permission,
    required String routeName,
    Object? arguments,
    String? deniedMessage,
    bool showSnackBar = true,
  }) async {
    if (!GroupPermissionService.hasPermission(
      member: member,
      group: group,
      permission: permission,
    )) {
      if (showSnackBar) {
        _showPermissionDeniedSnackBar(
          context,
          deniedMessage ?? '이 페이지에 접근할 권한이 없습니다.',
        );
      }
      return false;
    }

    Navigator.of(context).pushNamed(routeName, arguments: arguments);
    return true;
  }

  /// 권한 확인 후 다이얼로그 표시
  static Future<T?> showDialogWithPermission<T>({
    required BuildContext context,
    required GroupMember member,
    required WorkoutGroup group,
    required GroupPermissionType permission,
    required Widget Function(BuildContext) builder,
    String? deniedMessage,
    bool showSnackBar = true,
    bool barrierDismissible = true,
  }) async {
    if (!GroupPermissionService.hasPermission(
      member: member,
      group: group,
      permission: permission,
    )) {
      if (showSnackBar) {
        _showPermissionDeniedSnackBar(
          context,
          deniedMessage ?? '이 기능을 사용할 권한이 없습니다.',
        );
      }
      return null;
    }

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }

  /// 권한 확인 후 바텀 시트 표시
  static Future<T?> showBottomSheetWithPermission<T>({
    required BuildContext context,
    required GroupMember member,
    required WorkoutGroup group,
    required GroupPermissionType permission,
    required Widget Function(BuildContext) builder,
    String? deniedMessage,
    bool showSnackBar = true,
    bool isScrollControlled = false,
  }) async {
    if (!GroupPermissionService.hasPermission(
      member: member,
      group: group,
      permission: permission,
    )) {
      if (showSnackBar) {
        _showPermissionDeniedSnackBar(
          context,
          deniedMessage ?? '이 기능을 사용할 권한이 없습니다.',
        );
      }
      return null;
    }

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      builder: builder,
    );
  }

  /// 멤버 관리 권한 확인
  static bool canManageMember({
    required GroupMember manager,
    required GroupMember target,
    required WorkoutGroup group,
  }) {
    return GroupPermissionService.canManageMember(
      manager: manager,
      target: target,
      group: group,
    );
  }

  /// 위험한 작업에 대한 확인 다이얼로그
  static Future<bool> confirmDangerousAction({
    required BuildContext context,
    required GroupMember member,
    required WorkoutGroup group,
    required GroupPermissionType permission,
    required String title,
    required String content,
    String confirmText = '확인',
    String cancelText = '취소',
    String? deniedMessage,
  }) async {
    if (!GroupPermissionService.hasPermission(
      member: member,
      group: group,
      permission: permission,
    )) {
      _showPermissionDeniedSnackBar(
        context,
        deniedMessage ?? '이 작업을 수행할 권한이 없습니다.',
      );
      return false;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// 권한 레벨 확인
  static bool hasMinimumPermissionLevel({
    required GroupMember member,
    required WorkoutGroup group,
    required GroupPermissionLevel minimumLevel,
  }) {
    final currentLevel = GroupPermissionService.getPermissionLevel(
      member: member,
      group: group,
    );

    const levelOrder = {
      GroupPermissionLevel.none: 0,
      GroupPermissionLevel.member: 1,
      GroupPermissionLevel.moderator: 2,
      GroupPermissionLevel.admin: 3,
    };

    return (levelOrder[currentLevel] ?? 0) >= (levelOrder[minimumLevel] ?? 0);
  }

  /// 권한 기반 기능 가용성 확인
  static Map<String, bool> getFeatureAvailability({
    required GroupMember member,
    required WorkoutGroup group,
  }) {
    return {
      'memberManagement': GroupPermissionService.hasAnyPermission(
        member: member,
        group: group,
        permissions: [
          GroupPermissionType.inviteMembers,
          GroupPermissionType.removeMembers,
          GroupPermissionType.promoteMembers,
          GroupPermissionType.demoteMembers,
        ],
      ),
      'groupSettings': GroupPermissionService.hasAnyPermission(
        member: member,
        group: group,
        permissions: [
          GroupPermissionType.editGroupInfo,
          GroupPermissionType.changeGroupSettings,
          GroupPermissionType.manageInviteCode,
        ],
      ),
      'contentModeration': GroupPermissionService.hasAnyPermission(
        member: member,
        group: group,
        permissions: [
          GroupPermissionType.deleteMessages,
          GroupPermissionType.deleteActivities,
          GroupPermissionType.moderateContent,
          GroupPermissionType.deletePosts,
          GroupPermissionType.deleteComments,
        ],
      ),
      'dietManagement': group.isPTGroup && GroupPermissionService.hasAnyPermission(
        member: member,
        group: group,
        permissions: [
          GroupPermissionType.viewMemberDiets,
          GroupPermissionType.provideDietFeedback,
          GroupPermissionType.accessDietAnalytics,
        ],
      ),
    };
  }

  static void _showPermissionDeniedSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}