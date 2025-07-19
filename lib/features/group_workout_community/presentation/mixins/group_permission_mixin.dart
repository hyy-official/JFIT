import 'package:flutter/material.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/entities/workout_group.dart';
import '../../domain/entities/group_permission.dart';
import '../../domain/services/group_permission_service.dart';

/// 그룹 권한 기반 UI 처리를 위한 Mixin
mixin GroupPermissionMixin<T extends StatefulWidget> on State<T> {
  /// 권한 기반 위젯 표시
  Widget buildWithPermission({
    required GroupMember member,
    required WorkoutGroup group,
    required GroupPermissionType permission,
    required Widget child,
    Widget? fallback,
  }) {
    final hasPermission = GroupPermissionService.hasPermission(
      member: member,
      group: group,
      permission: permission,
    );

    if (hasPermission) {
      return child;
    } else {
      return fallback ?? const SizedBox.shrink();
    }
  }

  /// 여러 권한 중 하나라도 있으면 표시
  Widget buildWithAnyPermission({
    required GroupMember member,
    required WorkoutGroup group,
    required List<GroupPermissionType> permissions,
    required Widget child,
    Widget? fallback,
  }) {
    final hasAnyPermission = GroupPermissionService.hasAnyPermission(
      member: member,
      group: group,
      permissions: permissions,
    );

    if (hasAnyPermission) {
      return child;
    } else {
      return fallback ?? const SizedBox.shrink();
    }
  }

  /// 모든 권한이 있어야 표시
  Widget buildWithAllPermissions({
    required GroupMember member,
    required WorkoutGroup group,
    required List<GroupPermissionType> permissions,
    required Widget child,
    Widget? fallback,
  }) {
    final hasAllPermissions = GroupPermissionService.hasAllPermissions(
      member: member,
      group: group,
      permissions: permissions,
    );

    if (hasAllPermissions) {
      return child;
    } else {
      return fallback ?? const SizedBox.shrink();
    }
  }

  /// 특정 작업 권한 기반 위젯 표시
  Widget buildWithAction({
    required GroupMember member,
    required WorkoutGroup group,
    required GroupAction action,
    required Widget child,
    GroupMember? targetMember,
    Widget? fallback,
  }) {
    final canPerform = GroupPermissionService.canPerformAction(
      member: member,
      group: group,
      action: action,
      targetMember: targetMember,
    );

    if (canPerform) {
      return child;
    } else {
      return fallback ?? const SizedBox.shrink();
    }
  }

  /// 권한 레벨 기반 위젯 표시
  Widget buildWithPermissionLevel({
    required GroupMember member,
    required WorkoutGroup group,
    required GroupPermissionLevel minimumLevel,
    required Widget child,
    Widget? fallback,
  }) {
    final currentLevel = GroupPermissionService.getPermissionLevel(
      member: member,
      group: group,
    );

    final hasRequiredLevel = _comparePermissionLevels(currentLevel, minimumLevel);

    if (hasRequiredLevel) {
      return child;
    } else {
      return fallback ?? const SizedBox.shrink();
    }
  }

  /// 권한 기반 버튼 (비활성화 처리)
  Widget buildPermissionButton({
    required GroupMember member,
    required WorkoutGroup group,
    required GroupPermissionType permission,
    required VoidCallback onPressed,
    required Widget child,
    String? disabledTooltip,
  }) {
    final hasPermission = GroupPermissionService.hasPermission(
      member: member,
      group: group,
      permission: permission,
    );

    if (hasPermission) {
      return ElevatedButton(
        onPressed: onPressed,
        child: child,
      );
    } else {
      final button = ElevatedButton(
        onPressed: null,
        child: child,
      );

      if (disabledTooltip != null) {
        return Tooltip(
          message: disabledTooltip,
          child: button,
        );
      }

      return button;
    }
  }

  /// 권한 기반 아이콘 버튼
  Widget buildPermissionIconButton({
    required GroupMember member,
    required WorkoutGroup group,
    required GroupPermissionType permission,
    required VoidCallback onPressed,
    required Icon icon,
    String? disabledTooltip,
  }) {
    final hasPermission = GroupPermissionService.hasPermission(
      member: member,
      group: group,
      permission: permission,
    );

    if (hasPermission) {
      return IconButton(
        onPressed: onPressed,
        icon: icon,
      );
    } else {
      final button = IconButton(
        onPressed: null,
        icon: icon,
      );

      if (disabledTooltip != null) {
        return Tooltip(
          message: disabledTooltip,
          child: button,
        );
      }

      return button;
    }
  }

  /// 권한 확인 헬퍼 메서드
  bool hasPermission({
    required GroupMember member,
    required WorkoutGroup group,
    required GroupPermissionType permission,
  }) {
    return GroupPermissionService.hasPermission(
      member: member,
      group: group,
      permission: permission,
    );
  }

  /// 작업 권한 확인 헬퍼 메서드
  bool canPerformAction({
    required GroupMember member,
    required WorkoutGroup group,
    required GroupAction action,
    GroupMember? targetMember,
  }) {
    return GroupPermissionService.canPerformAction(
      member: member,
      group: group,
      action: action,
      targetMember: targetMember,
    );
  }

  /// UI 권한 맵 가져오기
  Map<String, bool> getUIPermissions({
    required GroupMember member,
    required WorkoutGroup group,
  }) {
    return GroupPermissionService.getUIPermissions(
      member: member,
      group: group,
    );
  }

  /// 권한 레벨 비교
  bool _comparePermissionLevels(
    GroupPermissionLevel current,
    GroupPermissionLevel required,
  ) {
    const levelOrder = {
      GroupPermissionLevel.none: 0,
      GroupPermissionLevel.member: 1,
      GroupPermissionLevel.moderator: 2,
      GroupPermissionLevel.admin: 3,
    };

    return (levelOrder[current] ?? 0) >= (levelOrder[required] ?? 0);
  }

  /// 권한 부족 시 스낵바 표시
  void showPermissionDeniedSnackBar(BuildContext context, {String? message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? '이 작업을 수행할 권한이 없습니다.'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  /// 권한 확인 후 작업 실행
  void executeWithPermission({
    required BuildContext context,
    required GroupMember member,
    required WorkoutGroup group,
    required GroupPermissionType permission,
    required VoidCallback action,
    String? deniedMessage,
  }) {
    if (hasPermission(member: member, group: group, permission: permission)) {
      action();
    } else {
      showPermissionDeniedSnackBar(context, message: deniedMessage);
    }
  }

  /// 작업 권한 확인 후 실행
  void executeWithAction({
    required BuildContext context,
    required GroupMember member,
    required WorkoutGroup group,
    required GroupAction action,
    required VoidCallback callback,
    GroupMember? targetMember,
    String? deniedMessage,
  }) {
    if (canPerformAction(
      member: member,
      group: group,
      action: action,
      targetMember: targetMember,
    )) {
      callback();
    } else {
      showPermissionDeniedSnackBar(context, message: deniedMessage);
    }
  }
}