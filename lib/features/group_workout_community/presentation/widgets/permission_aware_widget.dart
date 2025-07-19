import 'package:flutter/material.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/entities/workout_group.dart';
import '../../domain/entities/group_permission.dart';
import '../../domain/services/group_permission_service.dart';

/// 권한 기반으로 위젯을 표시하거나 숨기는 위젯
class PermissionAwareWidget extends StatelessWidget {
  final GroupMember member;
  final WorkoutGroup group;
  final Widget child;
  final Widget? fallback;
  final GroupPermissionType? permission;
  final List<GroupPermissionType>? anyPermissions;
  final List<GroupPermissionType>? allPermissions;
  final GroupAction? action;
  final GroupMember? targetMember;
  final GroupPermissionLevel? minimumLevel;

  const PermissionAwareWidget({
    super.key,
    required this.member,
    required this.group,
    required this.child,
    this.fallback,
    this.permission,
    this.anyPermissions,
    this.allPermissions,
    this.action,
    this.targetMember,
    this.minimumLevel,
  }) : assert(
          (permission != null) ^
              (anyPermissions != null) ^
              (allPermissions != null) ^
              (action != null) ^
              (minimumLevel != null),
          'Exactly one permission check type must be provided',
        );

  /// 단일 권한 확인용 생성자
  const PermissionAwareWidget.withPermission({
    super.key,
    required this.member,
    required this.group,
    required this.child,
    required this.permission,
    this.fallback,
  })  : anyPermissions = null,
        allPermissions = null,
        action = null,
        targetMember = null,
        minimumLevel = null;

  /// 여러 권한 중 하나 확인용 생성자
  const PermissionAwareWidget.withAnyPermissions({
    super.key,
    required this.member,
    required this.group,
    required this.child,
    required this.anyPermissions,
    this.fallback,
  })  : permission = null,
        allPermissions = null,
        action = null,
        targetMember = null,
        minimumLevel = null;

  /// 모든 권한 확인용 생성자
  const PermissionAwareWidget.withAllPermissions({
    super.key,
    required this.member,
    required this.group,
    required this.child,
    required this.allPermissions,
    this.fallback,
  })  : permission = null,
        anyPermissions = null,
        action = null,
        targetMember = null,
        minimumLevel = null;

  /// 작업 권한 확인용 생성자
  const PermissionAwareWidget.withAction({
    super.key,
    required this.member,
    required this.group,
    required this.child,
    required this.action,
    this.targetMember,
    this.fallback,
  })  : permission = null,
        anyPermissions = null,
        allPermissions = null,
        minimumLevel = null;

  /// 권한 레벨 확인용 생성자
  const PermissionAwareWidget.withLevel({
    super.key,
    required this.member,
    required this.group,
    required this.child,
    required this.minimumLevel,
    this.fallback,
  })  : permission = null,
        anyPermissions = null,
        allPermissions = null,
        action = null,
        targetMember = null;

  @override
  Widget build(BuildContext context) {
    bool hasRequiredPermission = false;

    if (permission != null) {
      hasRequiredPermission = GroupPermissionService.hasPermission(
        member: member,
        group: group,
        permission: permission!,
      );
    } else if (anyPermissions != null) {
      hasRequiredPermission = GroupPermissionService.hasAnyPermission(
        member: member,
        group: group,
        permissions: anyPermissions!,
      );
    } else if (allPermissions != null) {
      hasRequiredPermission = GroupPermissionService.hasAllPermissions(
        member: member,
        group: group,
        permissions: allPermissions!,
      );
    } else if (action != null) {
      hasRequiredPermission = GroupPermissionService.canPerformAction(
        member: member,
        group: group,
        action: action!,
        targetMember: targetMember,
      );
    } else if (minimumLevel != null) {
      final currentLevel = GroupPermissionService.getPermissionLevel(
        member: member,
        group: group,
      );
      hasRequiredPermission = _comparePermissionLevels(currentLevel, minimumLevel!);
    }

    if (hasRequiredPermission) {
      return child;
    } else {
      return fallback ?? const SizedBox.shrink();
    }
  }

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
}

/// 권한 기반 버튼 위젯
class PermissionAwareButton extends StatelessWidget {
  final GroupMember member;
  final WorkoutGroup group;
  final GroupPermissionType permission;
  final VoidCallback onPressed;
  final Widget child;
  final String? disabledTooltip;
  final ButtonStyle? style;

  const PermissionAwareButton({
    super.key,
    required this.member,
    required this.group,
    required this.permission,
    required this.onPressed,
    required this.child,
    this.disabledTooltip,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final hasPermission = GroupPermissionService.hasPermission(
      member: member,
      group: group,
      permission: permission,
    );

    final button = ElevatedButton(
      onPressed: hasPermission ? onPressed : null,
      style: style,
      child: child,
    );

    if (!hasPermission && disabledTooltip != null) {
      return Tooltip(
        message: disabledTooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// 권한 기반 아이콘 버튼 위젯
class PermissionAwareIconButton extends StatelessWidget {
  final GroupMember member;
  final WorkoutGroup group;
  final GroupPermissionType permission;
  final VoidCallback onPressed;
  final Widget icon;
  final String? disabledTooltip;
  final double? iconSize;
  final Color? color;

  const PermissionAwareIconButton({
    super.key,
    required this.member,
    required this.group,
    required this.permission,
    required this.onPressed,
    required this.icon,
    this.disabledTooltip,
    this.iconSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final hasPermission = GroupPermissionService.hasPermission(
      member: member,
      group: group,
      permission: permission,
    );

    final button = IconButton(
      onPressed: hasPermission ? onPressed : null,
      icon: icon,
      iconSize: iconSize,
      color: hasPermission ? color : Theme.of(context).disabledColor,
    );

    if (!hasPermission && disabledTooltip != null) {
      return Tooltip(
        message: disabledTooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// 권한 기반 메뉴 아이템 위젯
class PermissionAwareMenuItem extends StatelessWidget {
  final GroupMember member;
  final WorkoutGroup group;
  final GroupPermissionType permission;
  final VoidCallback onTap;
  final Widget child;
  final Widget? leading;
  final Widget? trailing;

  const PermissionAwareMenuItem({
    super.key,
    required this.member,
    required this.group,
    required this.permission,
    required this.onTap,
    required this.child,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionAwareWidget.withPermission(
      member: member,
      group: group,
      permission: permission,
      child: ListTile(
        leading: leading,
        title: child,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

/// 권한 기반 팝업 메뉴 버튼
class PermissionAwarePopupMenuButton<T> extends StatelessWidget {
  final GroupMember member;
  final WorkoutGroup group;
  final List<PermissionAwarePopupMenuItem<T>> itemBuilder;
  final void Function(T)? onSelected;
  final Widget? child;
  final Widget? icon;

  const PermissionAwarePopupMenuButton({
    super.key,
    required this.member,
    required this.group,
    required this.itemBuilder,
    this.onSelected,
    this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final availableItems = itemBuilder
        .where((item) => GroupPermissionService.hasPermission(
              member: member,
              group: group,
              permission: item.permission,
            ))
        .map((item) => PopupMenuItem<T>(
              value: item.value,
              child: item.child,
            ))
        .toList();

    if (availableItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<T>(
      onSelected: onSelected,
      itemBuilder: (context) => availableItems,
      child: child,
      icon: icon,
    );
  }
}

/// 권한 기반 팝업 메뉴 아이템
class PermissionAwarePopupMenuItem<T> {
  final T value;
  final Widget child;
  final GroupPermissionType permission;

  const PermissionAwarePopupMenuItem({
    required this.value,
    required this.child,
    required this.permission,
  });
}