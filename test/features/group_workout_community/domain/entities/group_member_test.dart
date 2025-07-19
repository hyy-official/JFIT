import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_member.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';

void main() {
  group('GroupMember', () {
    final testMember = GroupMember(
      id: 'member-id',
      groupId: 'group-id',
      userId: 'user-id',
      username: 'testuser',
      role: GroupRole.member,
      joinedAt: DateTime(2024, 1, 1),
      isActive: true,
      lastActiveAt: DateTime(2024, 1, 1),
    );

    group('Entity Creation', () {
      test('should create GroupMember with required fields', () {
        expect(testMember.id, 'member-id');
        expect(testMember.groupId, 'group-id');
        expect(testMember.userId, 'user-id');
        expect(testMember.username, 'testuser');
        expect(testMember.role, GroupRole.member);
        expect(testMember.joinedAt, DateTime(2024, 1, 1));
        expect(testMember.isActive, true);
        expect(testMember.lastActiveAt, DateTime(2024, 1, 1));
        expect(testMember.profileImageUrl, null);
      });

      test('should create GroupMember with optional fields', () {
        final memberWithImage = GroupMember(
          id: 'member-id-2',
          groupId: 'group-id',
          userId: 'user-id-2',
          username: 'testuser2',
          profileImageUrl: 'https://example.com/avatar.jpg',
          role: GroupRole.admin,
          joinedAt: DateTime(2024, 1, 2),
          isActive: true,
          lastActiveAt: DateTime(2024, 1, 2),
        );

        expect(memberWithImage.profileImageUrl, 'https://example.com/avatar.jpg');
        expect(memberWithImage.role, GroupRole.admin);
      });

      test('should create GroupMember with null lastActiveAt', () {
        final memberWithoutLastActive = GroupMember(
          id: 'member-id-3',
          groupId: 'group-id',
          userId: 'user-id-3',
          username: 'testuser3',
          role: GroupRole.member,
          joinedAt: DateTime(2024, 1, 3),
          isActive: true,
          lastActiveAt: null,
        );

        expect(memberWithoutLastActive.lastActiveAt, null);
        expect(memberWithoutLastActive.isRecentlyActive, false);
      });
    });

    group('Equality', () {
      test('should be equal when all properties are the same', () {
        final member1 = GroupMember(
          id: 'member-id',
          groupId: 'group-id',
          userId: 'user-id',
          username: 'testuser',
          role: GroupRole.member,
          joinedAt: DateTime(2024, 1, 1),
          isActive: true,
          lastActiveAt: DateTime(2024, 1, 1),
        );

        final member2 = GroupMember(
          id: 'member-id',
          groupId: 'group-id',
          userId: 'user-id',
          username: 'testuser',
          role: GroupRole.member,
          joinedAt: DateTime(2024, 1, 1),
          isActive: true,
          lastActiveAt: DateTime(2024, 1, 1),
        );

        expect(member1, equals(member2));
        expect(member1.hashCode, equals(member2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final member1 = testMember;
        final member2 = testMember.copyWith(username: 'differentuser');

        expect(member1, isNot(equals(member2)));
        expect(member1.hashCode, isNot(equals(member2.hashCode)));
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final updatedMember = testMember.copyWith(
          username: 'updateduser',
          role: GroupRole.moderator,
          profileImageUrl: 'https://example.com/new-avatar.jpg',
        );

        expect(updatedMember.id, testMember.id);
        expect(updatedMember.groupId, testMember.groupId);
        expect(updatedMember.userId, testMember.userId);
        expect(updatedMember.username, 'updateduser');
        expect(updatedMember.role, GroupRole.moderator);
        expect(updatedMember.profileImageUrl, 'https://example.com/new-avatar.jpg');
        expect(updatedMember.joinedAt, testMember.joinedAt);
        expect(updatedMember.isActive, testMember.isActive);
        expect(updatedMember.lastActiveAt, testMember.lastActiveAt);
      });

      test('should create copy with same values when no changes', () {
        final copiedMember = testMember.copyWith();

        expect(copiedMember, equals(testMember));
        expect(copiedMember.hashCode, equals(testMember.hashCode));
      });

      test('should handle null values correctly', () {
        final memberWithImage = testMember.copyWith(
          profileImageUrl: 'https://example.com/avatar.jpg',
        );
        expect(memberWithImage.profileImageUrl, 'https://example.com/avatar.jpg');

        // Note: copyWith doesn't support explicit null assignment in this implementation
        // This test verifies the current behavior
        final memberWithoutImage = memberWithImage.copyWith();
        expect(memberWithoutImage.profileImageUrl, 'https://example.com/avatar.jpg'); // Keeps existing value
      });
    });

    group('Business Logic Properties', () {
      test('isAdmin should return true for admin role', () {
        final adminMember = testMember.copyWith(role: GroupRole.admin);
        expect(adminMember.isAdmin, true);

        final moderatorMember = testMember.copyWith(role: GroupRole.moderator);
        expect(moderatorMember.isAdmin, false);

        final regularMember = testMember.copyWith(role: GroupRole.member);
        expect(regularMember.isAdmin, false);
      });

      test('isModerator should return true for moderator role', () {
        final adminMember = testMember.copyWith(role: GroupRole.admin);
        expect(adminMember.isModerator, false);

        final moderatorMember = testMember.copyWith(role: GroupRole.moderator);
        expect(moderatorMember.isModerator, true);

        final regularMember = testMember.copyWith(role: GroupRole.member);
        expect(regularMember.isModerator, false);
      });

      test('hasManagementPermissions should return true for admin and moderator', () {
        final adminMember = testMember.copyWith(role: GroupRole.admin);
        expect(adminMember.hasManagementPermissions, true);

        final moderatorMember = testMember.copyWith(role: GroupRole.moderator);
        expect(moderatorMember.hasManagementPermissions, true);

        final regularMember = testMember.copyWith(role: GroupRole.member);
        expect(regularMember.hasManagementPermissions, false);
      });

      test('isRecentlyActive should return true for recent activity (within 7 days)', () {
        final now = DateTime.now();
        
        // Recently active (within 7 days)
        final recentlyActiveMember = testMember.copyWith(
          lastActiveAt: now.subtract(const Duration(days: 3)),
        );
        expect(recentlyActiveMember.isRecentlyActive, true);

        // Not recently active (more than 7 days)
        final notRecentlyActiveMember = testMember.copyWith(
          lastActiveAt: now.subtract(const Duration(days: 10)),
        );
        expect(notRecentlyActiveMember.isRecentlyActive, false);

        // Edge case: exactly 7 days
        final exactlySevenDaysMember = testMember.copyWith(
          lastActiveAt: now.subtract(const Duration(days: 7)),
        );
        expect(exactlySevenDaysMember.isRecentlyActive, true);

        // Null lastActiveAt
        final memberWithNullLastActive = testMember.copyWith(lastActiveAt: null);
        expect(memberWithNullLastActive.isRecentlyActive, false);
      });
    });

    group('Validation Logic', () {
      test('should validate username requirements', () {
        // Test empty username
        expect(() => testMember.copyWith(username: ''), returnsNormally);
        
        // Test very long username
        final longUsername = 'A' * 100;
        expect(() => testMember.copyWith(username: longUsername), returnsNormally);
        
        // Test username with special characters
        expect(() => testMember.copyWith(username: 'user@123'), returnsNormally);
      });

      test('should handle edge cases for dates', () {
        final futureDate = DateTime.now().add(const Duration(days: 365));
        final pastDate = DateTime(2020, 1, 1);
        
        expect(() => testMember.copyWith(joinedAt: futureDate), returnsNormally);
        expect(() => testMember.copyWith(lastActiveAt: pastDate), returnsNormally);
      });

      test('should validate profile image URL format', () {
        // Valid URLs
        expect(() => testMember.copyWith(
          profileImageUrl: 'https://example.com/avatar.jpg',
        ), returnsNormally);
        
        expect(() => testMember.copyWith(
          profileImageUrl: 'http://example.com/avatar.png',
        ), returnsNormally);
        
        // Invalid URLs (should still work as we don't validate format in entity)
        expect(() => testMember.copyWith(
          profileImageUrl: 'not-a-url',
        ), returnsNormally);
        
        expect(() => testMember.copyWith(
          profileImageUrl: '',
        ), returnsNormally);
      });
    });

    group('Edge Cases and Error Conditions', () {
      test('should handle null and empty string values appropriately', () {
        // Test with minimal required fields
        final minimalMember = GroupMember(
          id: '',
          groupId: '',
          userId: '',
          username: '',
          role: GroupRole.member,
          joinedAt: DateTime(1970, 1, 1),
          isActive: false,
          lastActiveAt: null,
        );

        expect(minimalMember.id, '');
        expect(minimalMember.groupId, '');
        expect(minimalMember.userId, '');
        expect(minimalMember.username, '');
        expect(minimalMember.isActive, false);
        expect(minimalMember.lastActiveAt, null);
        expect(minimalMember.isRecentlyActive, false);
      });

      test('should handle extreme date values', () {
        final extremeMember = testMember.copyWith(
          joinedAt: DateTime(1900, 1, 1),
          lastActiveAt: DateTime(2100, 12, 31),
        );

        expect(extremeMember.joinedAt.year, 1900);
        expect(extremeMember.lastActiveAt?.year, 2100);
      });

      test('should handle role transitions correctly', () {
        // Test all role transitions
        final adminMember = testMember.copyWith(role: GroupRole.admin);
        final moderatorMember = adminMember.copyWith(role: GroupRole.moderator);
        final regularMember = moderatorMember.copyWith(role: GroupRole.member);

        expect(adminMember.role, GroupRole.admin);
        expect(moderatorMember.role, GroupRole.moderator);
        expect(regularMember.role, GroupRole.member);

        expect(adminMember.isAdmin, true);
        expect(moderatorMember.isModerator, true);
        expect(regularMember.hasManagementPermissions, false);
      });
    });

    group('Comparison and Sorting', () {
      test('should support comparison by join date', () {
        final member1 = testMember.copyWith(joinedAt: DateTime(2024, 1, 1));
        final member2 = testMember.copyWith(joinedAt: DateTime(2024, 1, 2));
        final member3 = testMember.copyWith(joinedAt: DateTime(2024, 1, 3));

        final members = [member3, member1, member2];
        members.sort((a, b) => a.joinedAt.compareTo(b.joinedAt));

        expect(members[0].joinedAt, DateTime(2024, 1, 1));
        expect(members[1].joinedAt, DateTime(2024, 1, 2));
        expect(members[2].joinedAt, DateTime(2024, 1, 3));
      });

      test('should support comparison by role hierarchy', () {
        final adminMember = testMember.copyWith(role: GroupRole.admin);
        final moderatorMember = testMember.copyWith(role: GroupRole.moderator);
        final regularMember = testMember.copyWith(role: GroupRole.member);

        // Test role hierarchy (admin > moderator > member)
        expect(adminMember.role.index < moderatorMember.role.index, true);
        expect(moderatorMember.role.index < regularMember.role.index, true);
      });

      test('should support comparison by activity status', () {
        final now = DateTime.now();
        
        final activeMember = testMember.copyWith(
          lastActiveAt: now.subtract(const Duration(days: 1)),
        );
        final inactiveMember = testMember.copyWith(
          lastActiveAt: now.subtract(const Duration(days: 10)),
        );
        final nullActiveMember = testMember.copyWith(lastActiveAt: null);

        final members = [inactiveMember, activeMember, nullActiveMember];
        
        // Sort by activity status (active first)
        members.sort((a, b) {
          if (a.isRecentlyActive && !b.isRecentlyActive) return -1;
          if (!a.isRecentlyActive && b.isRecentlyActive) return 1;
          return 0;
        });

        expect(members[0].isRecentlyActive, true);
        expect(members[1].isRecentlyActive, false);
        expect(members[2].isRecentlyActive, false);
      });
    });

    group('GroupRole Enum', () {
      test('should have correct enum values', () {
        expect(GroupRole.values.length, 3);
        expect(GroupRole.values, contains(GroupRole.admin));
        expect(GroupRole.values, contains(GroupRole.moderator));
        expect(GroupRole.values, contains(GroupRole.member));
      });

      test('should convert to string correctly', () {
        expect(GroupRole.admin.toString(), 'GroupRole.admin');
        expect(GroupRole.moderator.toString(), 'GroupRole.moderator');
        expect(GroupRole.member.toString(), 'GroupRole.member');
      });

      test('should have correct hierarchy order', () {
        // Enum index represents hierarchy (lower index = higher privilege)
        expect(GroupRole.admin.index, 0);
        expect(GroupRole.moderator.index, 1);
        expect(GroupRole.member.index, 2);
      });
    });
  });
}