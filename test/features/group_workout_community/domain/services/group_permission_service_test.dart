import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_member.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_permission.dart';
import 'package:jfit/features/group_workout_community/domain/services/group_permission_service.dart';

void main() {
  group('GroupPermissionService', () {
    late WorkoutGroup testGroup;
    late WorkoutGroup ptGroup;
    late GroupMember adminMember;
    late GroupMember moderatorMember;
    late GroupMember regularMember;
    late GroupMember inactiveMember;

    setUp(() {
      final now = DateTime.now();
      
      testGroup = WorkoutGroup(
        id: 'group1',
        name: 'Test Group',
        description: 'Test Description',
        adminId: 'admin1',
        privacyType: GroupPrivacyType.public,
        maxMembers: 50,
        currentMemberCount: 3,
        createdAt: now,
        updatedAt: now,
        isActive: true,
      );

      ptGroup = WorkoutGroup(
        id: 'ptgroup1',
        name: 'PT Group',
        description: 'PT Description',
        adminId: 'admin1',
        privacyType: GroupPrivacyType.private,
        maxMembers: 10,
        currentMemberCount: 3,
        createdAt: now,
        updatedAt: now,
        isActive: true,
        groupType: 'personal_training',
      );

      adminMember = GroupMember(
        id: 'member1',
        groupId: 'group1',
        userId: 'admin1',
        username: 'Admin User',
        role: GroupRole.admin,
        joinedAt: now,
        isActive: true,
      );

      moderatorMember = GroupMember(
        id: 'member2',
        groupId: 'group1',
        userId: 'mod1',
        username: 'Moderator User',
        role: GroupRole.moderator,
        joinedAt: now,
        isActive: true,
      );

      regularMember = GroupMember(
        id: 'member3',
        groupId: 'group1',
        userId: 'user1',
        username: 'Regular User',
        role: GroupRole.member,
        joinedAt: now,
        isActive: true,
      );

      inactiveMember = GroupMember(
        id: 'member4',
        groupId: 'group1',
        userId: 'inactive1',
        username: 'Inactive User',
        role: GroupRole.admin,
        joinedAt: now,
        isActive: false,
      );
    });

    group('hasPermission', () {
      test('admin should have all permissions', () {
        expect(
          GroupPermissionService.hasPermission(
            member: adminMember,
            group: testGroup,
            permission: GroupPermissionType.deleteGroup,
          ),
          isTrue,
        );

        expect(
          GroupPermissionService.hasPermission(
            member: adminMember,
            group: testGroup,
            permission: GroupPermissionType.removeMembers,
          ),
          isTrue,
        );

        expect(
          GroupPermissionService.hasPermission(
            member: adminMember,
            group: testGroup,
            permission: GroupPermissionType.sendMessages,
          ),
          isTrue,
        );
      });

      test('moderator should have limited permissions', () {
        expect(
          GroupPermissionService.hasPermission(
            member: moderatorMember,
            group: testGroup,
            permission: GroupPermissionType.moderateContent,
          ),
          isTrue,
        );

        expect(
          GroupPermissionService.hasPermission(
            member: moderatorMember,
            group: testGroup,
            permission: GroupPermissionType.deleteGroup,
          ),
          isFalse,
        );

        expect(
          GroupPermissionService.hasPermission(
            member: moderatorMember,
            group: testGroup,
            permission: GroupPermissionType.sendMessages,
          ),
          isTrue,
        );
      });

      test('regular member should have basic permissions only', () {
        expect(
          GroupPermissionService.hasPermission(
            member: regularMember,
            group: testGroup,
            permission: GroupPermissionType.sendMessages,
          ),
          isTrue,
        );

        expect(
          GroupPermissionService.hasPermission(
            member: regularMember,
            group: testGroup,
            permission: GroupPermissionType.removeMembers,
          ),
          isFalse,
        );

        expect(
          GroupPermissionService.hasPermission(
            member: regularMember,
            group: testGroup,
            permission: GroupPermissionType.deleteGroup,
          ),
          isFalse,
        );
      });

      test('inactive member should have no permissions', () {
        expect(
          GroupPermissionService.hasPermission(
            member: inactiveMember,
            group: testGroup,
            permission: GroupPermissionType.sendMessages,
          ),
          isFalse,
        );

        expect(
          GroupPermissionService.hasPermission(
            member: inactiveMember,
            group: testGroup,
            permission: GroupPermissionType.deleteGroup,
          ),
          isFalse,
        );
      });
    });

    group('PT Group Permissions', () {
      test('admin in PT group should have diet permissions', () {
        expect(
          GroupPermissionService.hasPermission(
            member: adminMember,
            group: ptGroup,
            permission: GroupPermissionType.viewMemberDiets,
          ),
          isTrue,
        );

        expect(
          GroupPermissionService.hasPermission(
            member: adminMember,
            group: ptGroup,
            permission: GroupPermissionType.provideDietFeedback,
          ),
          isTrue,
        );
      });

      test('non-admin in PT group should not have diet permissions', () {
        expect(
          GroupPermissionService.hasPermission(
            member: moderatorMember,
            group: ptGroup,
            permission: GroupPermissionType.viewMemberDiets,
          ),
          isFalse,
        );

        expect(
          GroupPermissionService.hasPermission(
            member: regularMember,
            group: ptGroup,
            permission: GroupPermissionType.provideDietFeedback,
          ),
          isFalse,
        );
      });

      test('diet permissions should not work in regular groups', () {
        expect(
          GroupPermissionService.hasPermission(
            member: adminMember,
            group: testGroup,
            permission: GroupPermissionType.viewMemberDiets,
          ),
          isFalse,
        );
      });
    });

    group('canManageMember', () {
      test('admin can manage all members', () {
        expect(
          GroupPermissionService.canManageMember(
            manager: adminMember,
            target: moderatorMember,
            group: testGroup,
          ),
          isTrue,
        );

        expect(
          GroupPermissionService.canManageMember(
            manager: adminMember,
            target: regularMember,
            group: testGroup,
          ),
          isTrue,
        );
      });

      test('moderator can manage regular members only', () {
        expect(
          GroupPermissionService.canManageMember(
            manager: moderatorMember,
            target: regularMember,
            group: testGroup,
          ),
          isTrue,
        );

        expect(
          GroupPermissionService.canManageMember(
            manager: moderatorMember,
            target: adminMember,
            group: testGroup,
          ),
          isFalse,
        );
      });

      test('regular member cannot manage anyone', () {
        expect(
          GroupPermissionService.canManageMember(
            manager: regularMember,
            target: adminMember,
            group: testGroup,
          ),
          isFalse,
        );

        expect(
          GroupPermissionService.canManageMember(
            manager: regularMember,
            target: moderatorMember,
            group: testGroup,
          ),
          isFalse,
        );
      });

      test('cannot manage self', () {
        expect(
          GroupPermissionService.canManageMember(
            manager: adminMember,
            target: adminMember,
            group: testGroup,
          ),
          isFalse,
        );
      });

      test('inactive member cannot manage anyone', () {
        expect(
          GroupPermissionService.canManageMember(
            manager: inactiveMember,
            target: regularMember,
            group: testGroup,
          ),
          isFalse,
        );
      });
    });

    group('canPerformAction', () {
      test('admin can perform delete group action', () {
        expect(
          GroupPermissionService.canPerformAction(
            member: adminMember,
            group: testGroup,
            action: GroupAction.deleteGroup,
          ),
          isTrue,
        );
      });

      test('non-admin cannot perform delete group action', () {
        expect(
          GroupPermissionService.canPerformAction(
            member: moderatorMember,
            group: testGroup,
            action: GroupAction.deleteGroup,
          ),
          isFalse,
        );
      });

      test('admin can remove members', () {
        expect(
          GroupPermissionService.canPerformAction(
            member: adminMember,
            group: testGroup,
            action: GroupAction.removeMember,
            targetMember: regularMember,
          ),
          isTrue,
        );
      });

      test('moderator can remove regular members', () {
        expect(
          GroupPermissionService.canPerformAction(
            member: moderatorMember,
            group: testGroup,
            action: GroupAction.removeMember,
            targetMember: regularMember,
          ),
          isTrue,
        );
      });

      test('moderator cannot remove admin', () {
        expect(
          GroupPermissionService.canPerformAction(
            member: moderatorMember,
            group: testGroup,
            action: GroupAction.removeMember,
            targetMember: adminMember,
          ),
          isFalse,
        );
      });
    });

    group('getPermissionLevel', () {
      test('should return correct permission levels', () {
        expect(
          GroupPermissionService.getPermissionLevel(
            member: adminMember,
            group: testGroup,
          ),
          equals(GroupPermissionLevel.admin),
        );

        expect(
          GroupPermissionService.getPermissionLevel(
            member: moderatorMember,
            group: testGroup,
          ),
          equals(GroupPermissionLevel.moderator),
        );

        expect(
          GroupPermissionService.getPermissionLevel(
            member: regularMember,
            group: testGroup,
          ),
          equals(GroupPermissionLevel.member),
        );

        expect(
          GroupPermissionService.getPermissionLevel(
            member: inactiveMember,
            group: testGroup,
          ),
          equals(GroupPermissionLevel.none),
        );
      });
    });

    group('getUIPermissions', () {
      test('should return correct UI permissions for admin', () {
        final permissions = GroupPermissionService.getUIPermissions(
          member: adminMember,
          group: testGroup,
        );

        expect(permissions['canInviteMembers'], isTrue);
        expect(permissions['canRemoveMembers'], isTrue);
        expect(permissions['canEditGroup'], isTrue);
        expect(permissions['canDeleteGroup'], isTrue);
        expect(permissions['canModerateContent'], isTrue);
      });

      test('should return correct UI permissions for moderator', () {
        final permissions = GroupPermissionService.getUIPermissions(
          member: moderatorMember,
          group: testGroup,
        );

        expect(permissions['canInviteMembers'], isTrue);
        expect(permissions['canRemoveMembers'], isTrue); // 모더레이터도 멤버 제거 가능
        expect(permissions['canEditGroup'], isFalse);
        expect(permissions['canDeleteGroup'], isFalse);
        expect(permissions['canModerateContent'], isTrue);
      });

      test('should return correct UI permissions for regular member', () {
        final permissions = GroupPermissionService.getUIPermissions(
          member: regularMember,
          group: testGroup,
        );

        expect(permissions['canInviteMembers'], isFalse);
        expect(permissions['canRemoveMembers'], isFalse);
        expect(permissions['canEditGroup'], isFalse);
        expect(permissions['canDeleteGroup'], isFalse);
        expect(permissions['canModerateContent'], isFalse);
      });

      test('should return PT permissions for PT group admin', () {
        final permissions = GroupPermissionService.getUIPermissions(
          member: adminMember,
          group: ptGroup,
        );

        expect(permissions['canViewDietData'], isTrue);
        expect(permissions['canProvideDietFeedback'], isTrue);
        expect(permissions['canAccessDietAnalytics'], isTrue);
      });
    });

    group('hasAllPermissions', () {
      test('admin should have all specified permissions', () {
        expect(
          GroupPermissionService.hasAllPermissions(
            member: adminMember,
            group: testGroup,
            permissions: [
              GroupPermissionType.sendMessages,
              GroupPermissionType.inviteMembers,
              GroupPermissionType.editGroupInfo,
            ],
          ),
          isTrue,
        );
      });

      test('regular member should not have admin permissions', () {
        expect(
          GroupPermissionService.hasAllPermissions(
            member: regularMember,
            group: testGroup,
            permissions: [
              GroupPermissionType.sendMessages,
              GroupPermissionType.removeMembers,
            ],
          ),
          isFalse,
        );
      });
    });

    group('hasAnyPermission', () {
      test('moderator should have at least one management permission', () {
        expect(
          GroupPermissionService.hasAnyPermission(
            member: moderatorMember,
            group: testGroup,
            permissions: [
              GroupPermissionType.removeMembers,
              GroupPermissionType.moderateContent,
              GroupPermissionType.deleteGroup,
            ],
          ),
          isTrue,
        );
      });

      test('regular member should not have any admin permissions', () {
        expect(
          GroupPermissionService.hasAnyPermission(
            member: regularMember,
            group: testGroup,
            permissions: [
              GroupPermissionType.removeMembers,
              GroupPermissionType.deleteGroup,
              GroupPermissionType.editGroupInfo,
            ],
          ),
          isFalse,
        );
      });
    });
  });

  group('GroupPermissionManager', () {
    test('should return correct permissions for each role', () {
      final adminPermissions = GroupPermissionManager.getPermissionForRole(GroupRole.admin);
      final moderatorPermissions = GroupPermissionManager.getPermissionForRole(GroupRole.moderator);
      final memberPermissions = GroupPermissionManager.getPermissionForRole(GroupRole.member);

      expect(adminPermissions.hasPermission(GroupPermissionType.deleteGroup), isTrue);
      expect(moderatorPermissions.hasPermission(GroupPermissionType.deleteGroup), isFalse);
      expect(memberPermissions.hasPermission(GroupPermissionType.deleteGroup), isFalse);

      expect(adminPermissions.hasPermission(GroupPermissionType.sendMessages), isTrue);
      expect(moderatorPermissions.hasPermission(GroupPermissionType.sendMessages), isTrue);
      expect(memberPermissions.hasPermission(GroupPermissionType.sendMessages), isTrue);
    });

    test('should correctly compare role management capabilities', () {
      expect(GroupPermissionManager.canManageRole(GroupRole.admin, GroupRole.moderator), isTrue);
      expect(GroupPermissionManager.canManageRole(GroupRole.admin, GroupRole.member), isTrue);
      expect(GroupPermissionManager.canManageRole(GroupRole.moderator, GroupRole.member), isTrue);
      expect(GroupPermissionManager.canManageRole(GroupRole.moderator, GroupRole.admin), isFalse);
      expect(GroupPermissionManager.canManageRole(GroupRole.member, GroupRole.admin), isFalse);
      expect(GroupPermissionManager.canManageRole(GroupRole.member, GroupRole.moderator), isFalse);
    });

    test('should handle PT permissions correctly', () {
      expect(
        GroupPermissionManager.hasPTPermission(
          GroupRole.admin,
          GroupPermissionType.viewMemberDiets,
          true,
        ),
        isTrue,
      );

      expect(
        GroupPermissionManager.hasPTPermission(
          GroupRole.moderator,
          GroupPermissionType.viewMemberDiets,
          true,
        ),
        isFalse,
      );

      expect(
        GroupPermissionManager.hasPTPermission(
          GroupRole.admin,
          GroupPermissionType.viewMemberDiets,
          false,
        ),
        isFalse,
      );
    });
  });
}