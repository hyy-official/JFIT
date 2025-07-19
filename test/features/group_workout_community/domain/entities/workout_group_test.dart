import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';

void main() {
  group('WorkoutGroup', () {
    final testGroup = WorkoutGroup(
      id: 'test-id',
      name: 'Test Group',
      description: 'Test Description',
      adminId: 'admin-id',
      privacyType: GroupPrivacyType.public,
      maxMembers: 50,
      currentMemberCount: 10,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      isActive: true,
    );

    group('Entity Creation', () {
      test('should create WorkoutGroup with required fields', () {
        expect(testGroup.id, 'test-id');
        expect(testGroup.name, 'Test Group');
        expect(testGroup.description, 'Test Description');
        expect(testGroup.adminId, 'admin-id');
        expect(testGroup.privacyType, GroupPrivacyType.public);
        expect(testGroup.maxMembers, 50);
        expect(testGroup.currentMemberCount, 10);
        expect(testGroup.isActive, true);
        expect(testGroup.inviteCode, null);
        expect(testGroup.groupType, null);
      });

      test('should create WorkoutGroup with optional fields', () {
        final groupWithOptionals = WorkoutGroup(
          id: 'test-id-2',
          name: 'PT Group',
          description: 'PT Description',
          adminId: 'pt-admin-id',
          privacyType: GroupPrivacyType.private,
          maxMembers: 20,
          currentMemberCount: 5,
          createdAt: DateTime(2024, 1, 2),
          updatedAt: DateTime(2024, 1, 2),
          inviteCode: 'ABC123',
          isActive: true,
          groupType: 'personal_training',
        );

        expect(groupWithOptionals.inviteCode, 'ABC123');
        expect(groupWithOptionals.groupType, 'personal_training');
        expect(groupWithOptionals.isPTGroup, true);
      });
    });

    group('Equality', () {
      test('should be equal when all properties are the same', () {
        final group1 = WorkoutGroup(
          id: 'test-id',
          name: 'Test Group',
          description: 'Test Description',
          adminId: 'admin-id',
          privacyType: GroupPrivacyType.public,
          maxMembers: 50,
          currentMemberCount: 10,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          isActive: true,
        );

        final group2 = WorkoutGroup(
          id: 'test-id',
          name: 'Test Group',
          description: 'Test Description',
          adminId: 'admin-id',
          privacyType: GroupPrivacyType.public,
          maxMembers: 50,
          currentMemberCount: 10,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          isActive: true,
        );

        expect(group1, equals(group2));
        expect(group1.hashCode, equals(group2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final group1 = testGroup;
        final group2 = testGroup.copyWith(name: 'Different Name');

        expect(group1, isNot(equals(group2)));
        expect(group1.hashCode, isNot(equals(group2.hashCode)));
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final updatedGroup = testGroup.copyWith(
          name: 'Updated Name',
          maxMembers: 100,
          currentMemberCount: 25,
        );

        expect(updatedGroup.id, testGroup.id);
        expect(updatedGroup.name, 'Updated Name');
        expect(updatedGroup.description, testGroup.description);
        expect(updatedGroup.maxMembers, 100);
        expect(updatedGroup.currentMemberCount, 25);
        expect(updatedGroup.adminId, testGroup.adminId);
        expect(updatedGroup.privacyType, testGroup.privacyType);
      });

      test('should create copy with same values when no changes', () {
        final copiedGroup = testGroup.copyWith();

        expect(copiedGroup, equals(testGroup));
        expect(copiedGroup.hashCode, equals(testGroup.hashCode));
      });

      test('should handle null values correctly', () {
        final groupWithInviteCode = testGroup.copyWith(inviteCode: 'ABC123');
        expect(groupWithInviteCode.inviteCode, 'ABC123');

        // Note: copyWith doesn't support explicit null assignment in this implementation
        // This test verifies the current behavior
        final groupWithoutInviteCode = groupWithInviteCode.copyWith();
        expect(groupWithoutInviteCode.inviteCode, 'ABC123'); // Keeps existing value
      });
    });

    group('Business Logic Properties', () {
      test('isPTGroup should return true for personal training groups', () {
        final ptGroup = testGroup.copyWith(groupType: 'personal_training');
        expect(ptGroup.isPTGroup, true);

        final regularGroup = testGroup.copyWith(groupType: null);
        expect(regularGroup.isPTGroup, false);

        final otherTypeGroup = testGroup.copyWith(groupType: 'other_type');
        expect(otherTypeGroup.isPTGroup, false);
      });

      test('isFull should return true when group is at capacity', () {
        final fullGroup = testGroup.copyWith(
          maxMembers: 10,
          currentMemberCount: 10,
        );
        expect(fullGroup.isFull, true);

        final notFullGroup = testGroup.copyWith(
          maxMembers: 10,
          currentMemberCount: 5,
        );
        expect(notFullGroup.isFull, false);

        final overCapacityGroup = testGroup.copyWith(
          maxMembers: 10,
          currentMemberCount: 15,
        );
        expect(overCapacityGroup.isFull, true);
      });

      test('isPublic should return correct privacy status', () {
        final publicGroup = testGroup.copyWith(privacyType: GroupPrivacyType.public);
        expect(publicGroup.isPublic, true);

        final privateGroup = testGroup.copyWith(privacyType: GroupPrivacyType.private);
        expect(privateGroup.isPublic, false);
      });
    });

    group('Validation Logic', () {
      test('should validate group name requirements', () {
        // Test empty name
        final emptyNameResult = testGroup.copyWith(name: '');
        expect(emptyNameResult.name, equals(''));
        
        // Test very long name
        final longName = 'A' * 200;
        final longNameResult = testGroup.copyWith(name: longName);
        expect(longNameResult.name, equals(longName));
        
        // Test name with special characters
        final specialNameResult = testGroup.copyWith(name: 'Group Special');
        expect(specialNameResult.name, equals('Group Special'));
      });

      test('should validate member count constraints', () {
        // Test negative current member count
        final negCountResult = testGroup.copyWith(currentMemberCount: -1);
        expect(negCountResult.currentMemberCount, equals(-1));
        
        // Test zero max members
        final zeroMaxResult = testGroup.copyWith(maxMembers: 0);
        expect(zeroMaxResult.maxMembers, equals(0));
        
        // Test very large max members
        final largeMaxResult = testGroup.copyWith(maxMembers: 10000);
        expect(largeMaxResult.maxMembers, equals(10000));
      });

      test('should handle edge cases for dates', () {
        final futureDate = DateTime.now().add(const Duration(days: 365));
        final pastDate = DateTime(2020, 1, 1);
        
        final futureResult = testGroup.copyWith(createdAt: futureDate);
        expect(futureResult.createdAt, equals(futureDate));
        final pastResult = testGroup.copyWith(updatedAt: pastDate);
        expect(pastResult.updatedAt, equals(pastDate));
      });
    });

    group('GroupPrivacyType Enum', () {
      test('should have correct enum values', () {
        expect(GroupPrivacyType.values.length, 2);
        expect(GroupPrivacyType.values, contains(GroupPrivacyType.public));
        expect(GroupPrivacyType.values, contains(GroupPrivacyType.private));
      });

      test('should convert to string correctly', () {
        expect(GroupPrivacyType.public.toString(), 'GroupPrivacyType.public');
        expect(GroupPrivacyType.private.toString(), 'GroupPrivacyType.private');
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
    });

    group('GroupActivityType Enum', () {
      test('should have correct enum values', () {
        expect(GroupActivityType.values.length, 8);
        expect(GroupActivityType.values, contains(GroupActivityType.workoutCompleted));
        expect(GroupActivityType.values, contains(GroupActivityType.routineShared));
        expect(GroupActivityType.values, contains(GroupActivityType.memberJoined));
        expect(GroupActivityType.values, contains(GroupActivityType.memberLeft));
        expect(GroupActivityType.values, contains(GroupActivityType.encouragementSent));
        expect(GroupActivityType.values, contains(GroupActivityType.achievementUnlocked));
        expect(GroupActivityType.values, contains(GroupActivityType.programStarted));
        expect(GroupActivityType.values, contains(GroupActivityType.milestoneReached));
      });
    });

    group('Edge Cases and Error Conditions', () {
      test('should handle null and empty string values appropriately', () {
        // Test with minimal required fields
        final minimalGroup = WorkoutGroup(
          id: '',
          name: '',
          description: '',
          adminId: '',
          privacyType: GroupPrivacyType.public,
          maxMembers: 1,
          currentMemberCount: 0,
          createdAt: DateTime(1970, 1, 1),
          updatedAt: DateTime(1970, 1, 1),
          isActive: false,
        );

        expect(minimalGroup.id, '');
        expect(minimalGroup.name, '');
        expect(minimalGroup.description, '');
        expect(minimalGroup.adminId, '');
        expect(minimalGroup.isActive, false);
      });

      test('should handle extreme date values', () {
        final extremeGroup = testGroup.copyWith(
          createdAt: DateTime(1900, 1, 1),
          updatedAt: DateTime(2100, 12, 31),
        );

        expect(extremeGroup.createdAt.year, 1900);
        expect(extremeGroup.updatedAt.year, 2100);
      });

      test('should handle boundary values for member counts', () {
        final boundaryGroup = testGroup.copyWith(
          maxMembers: 1,
          currentMemberCount: 1,
        );

        expect(boundaryGroup.maxMembers, 1);
        expect(boundaryGroup.currentMemberCount, 1);
        expect(boundaryGroup.isFull, true);
      });
    });
  });
}