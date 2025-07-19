import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/features/group_workout_community/data/services/group_notification_service.dart';

void main() {
  group('GroupNotificationService', () {

    group('GroupNotification', () {
      test('should create from JSON correctly', () {
        // Arrange
        final json = {
          'id': 'test-id',
          'user_id': 'user-id',
          'group_id': 'group-id',
          'notification_type': 'newMember',
          'title': 'Test Title',
          'message': 'Test Message',
          'data': {'key': 'value'},
          'created_at': '2023-01-01T00:00:00Z',
          'is_read': false,
        };

        // Act
        final notification = GroupNotification.fromJson(json);

        // Assert
        expect(notification.id, 'test-id');
        expect(notification.userId, 'user-id');
        expect(notification.groupId, 'group-id');
        expect(notification.type, GroupNotificationType.newMember);
        expect(notification.title, 'Test Title');
        expect(notification.message, 'Test Message');
        expect(notification.data, {'key': 'value'});
        expect(notification.isRead, false);
      });

      test('should convert to JSON correctly', () {
        // Arrange
        final notification = GroupNotification(
          id: 'test-id',
          userId: 'user-id',
          groupId: 'group-id',
          type: GroupNotificationType.routineShared,
          title: 'Test Title',
          message: 'Test Message',
          data: {'key': 'value'},
          createdAt: DateTime.parse('2023-01-01T00:00:00Z'),
          isRead: true,
        );

        // Act
        final json = notification.toJson();

        // Assert
        expect(json['id'], 'test-id');
        expect(json['user_id'], 'user-id');
        expect(json['group_id'], 'group-id');
        expect(json['notification_type'], 'routineShared');
        expect(json['title'], 'Test Title');
        expect(json['message'], 'Test Message');
        expect(json['data'], {'key': 'value'});
        expect(json['is_read'], true);
      });

      test('should copy with new values', () {
        // Arrange
        final original = GroupNotification(
          id: 'test-id',
          userId: 'user-id',
          groupId: 'group-id',
          type: GroupNotificationType.newMember,
          title: 'Original Title',
          message: 'Original Message',
          data: {'key': 'value'},
          createdAt: DateTime.parse('2023-01-01T00:00:00Z'),
          isRead: false,
        );

        // Act
        final copied = original.copyWith(
          title: 'New Title',
          isRead: true,
        );

        // Assert
        expect(copied.id, original.id);
        expect(copied.userId, original.userId);
        expect(copied.groupId, original.groupId);
        expect(copied.type, original.type);
        expect(copied.title, 'New Title');
        expect(copied.message, original.message);
        expect(copied.data, original.data);
        expect(copied.createdAt, original.createdAt);
        expect(copied.isRead, true);
      });
    });
  });
}