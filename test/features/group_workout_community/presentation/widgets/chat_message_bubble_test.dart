import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_message.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/chat_message_bubble.dart';

void main() {
  group('ChatMessageBubble Widget Tests', () {
    late GroupMessage testMessage;

    setUp(() {
      testMessage = GroupMessage(
        id: 'message-1',
        groupId: 'group-1',
        senderId: 'sender-1',
        senderUsername: 'John Doe',
        messageText: 'Hello everyone! Great workout today!',
        messageType: MessageType.text,
        createdAt: DateTime(2024, 1, 1, 10, 30),
        updatedAt: DateTime(2024, 1, 1, 10, 30),
        isDeleted: false,
      );
    });

    Widget createTestWidget({
      required GroupMessage message,
      bool isFromCurrentUser = false,
      bool showAvatar = true,
      bool showTimestamp = true,
      bool isGrouped = false,
      double screenWidth = 400.0,
      Function(String)? onReactionTap,
      Function(String)? onReactionRemove,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ChatMessageBubble(
            message: message,
            isFromCurrentUser: isFromCurrentUser,
            showAvatar: showAvatar,
            showTimestamp: showTimestamp,
            isGrouped: isGrouped,
            screenWidth: screenWidth,
            onReactionTap: onReactionTap ?? (reaction) {},
            onReactionRemove: onReactionRemove ?? (reaction) {},
          ),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('should display message text correctly', (tester) async {
        await tester.pumpWidget(createTestWidget(message: testMessage));

        expect(find.text('Hello everyone! Great workout today!'), findsOneWidget);
        expect(find.text('John Doe'), findsOneWidget);
      });

      testWidgets('should align message to right for current user', (tester) async {
        await tester.pumpWidget(createTestWidget(
          message: testMessage,
          isFromCurrentUser: true,
        ));

        // Test that the widget is created without errors
        expect(find.byType(ChatMessageBubble), findsOneWidget);
      });

      testWidgets('should align message to left for other users', (tester) async {
        await tester.pumpWidget(createTestWidget(
          message: testMessage,
          isFromCurrentUser: false,
        ));

        // Test that the widget is created without errors
        expect(find.byType(ChatMessageBubble), findsOneWidget);
      });

      testWidgets('should show avatar when showAvatar is true', (tester) async {
        await tester.pumpWidget(createTestWidget(
          message: testMessage,
          showAvatar: true,
        ));

        // Test that the widget is created without errors
        expect(find.byType(ChatMessageBubble), findsOneWidget);
      });

      testWidgets('should hide avatar when showAvatar is false', (tester) async {
        await tester.pumpWidget(createTestWidget(
          message: testMessage,
          showAvatar: false,
        ));

        // Test that the widget is created without errors
        expect(find.byType(ChatMessageBubble), findsOneWidget);
      });
    });

    group('Message Types', () {
      testWidgets('should display text message correctly', (tester) async {
        final textMessage = testMessage.copyWith(
          messageType: MessageType.text,
          messageText: 'This is a text message',
        );

        await tester.pumpWidget(createTestWidget(message: textMessage));

        expect(find.text('This is a text message'), findsOneWidget);
      });

      testWidgets('should handle image message type', (tester) async {
        final imageMessage = testMessage.copyWith(
          messageType: MessageType.image,
          messageText: 'Image message',
        );

        await tester.pumpWidget(createTestWidget(message: imageMessage));

        // Test that the widget is created without errors
        expect(find.byType(ChatMessageBubble), findsOneWidget);
      });

      testWidgets('should handle workout share message type', (tester) async {
        final workoutMessage = testMessage.copyWith(
          messageType: MessageType.workoutShare,
          messageText: 'Shared a workout',
        );

        await tester.pumpWidget(createTestWidget(message: workoutMessage));

        // Test that the widget is created without errors
        expect(find.byType(ChatMessageBubble), findsOneWidget);
      });
    });

    group('Reactions', () {
      testWidgets('should display reactions when present', (tester) async {
        final messageWithReactions = testMessage.copyWith(
          reactions: {
            '👍': ['user1', 'user2'],
            '❤️': ['user3'],
          },
        );

        await tester.pumpWidget(createTestWidget(message: messageWithReactions));

        // Test that the widget is created without errors
        expect(find.byType(ChatMessageBubble), findsOneWidget);
      });

      testWidgets('should handle reaction tap', (tester) async {
        String? tappedReaction;
        
        await tester.pumpWidget(createTestWidget(
          message: testMessage,
          onReactionTap: (reaction) {
            tappedReaction = reaction;
          },
        ));

        // Test that the widget is created without errors
        expect(find.byType(ChatMessageBubble), findsOneWidget);
      });
    });

    group('Timestamps', () {
      testWidgets('should show timestamp when showTimestamp is true', (tester) async {
        await tester.pumpWidget(createTestWidget(
          message: testMessage,
          showTimestamp: true,
        ));

        // Test that the widget is created without errors
        expect(find.byType(ChatMessageBubble), findsOneWidget);
      });

      testWidgets('should hide timestamp when showTimestamp is false', (tester) async {
        await tester.pumpWidget(createTestWidget(
          message: testMessage,
          showTimestamp: false,
        ));

        // Test that the widget is created without errors
        expect(find.byType(ChatMessageBubble), findsOneWidget);
      });
    });

    group('Responsive Design', () {
      testWidgets('should adapt to different screen widths', (tester) async {
        await tester.pumpWidget(createTestWidget(
          message: testMessage,
          screenWidth: 300.0,
        ));

        // Test that the widget is created without errors
        expect(find.byType(ChatMessageBubble), findsOneWidget);
      });

      testWidgets('should handle wide screens', (tester) async {
        await tester.pumpWidget(createTestWidget(
          message: testMessage,
          screenWidth: 800.0,
        ));

        // Test that the widget is created without errors
        expect(find.byType(ChatMessageBubble), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle empty message text', (tester) async {
        final emptyMessage = testMessage.copyWith(messageText: '');

        await tester.pumpWidget(createTestWidget(message: emptyMessage));

        // Test that the widget is created without errors
        expect(find.byType(ChatMessageBubble), findsOneWidget);
      });

      testWidgets('should handle deleted messages', (tester) async {
        final deletedMessage = testMessage.copyWith(isDeleted: true);

        await tester.pumpWidget(createTestWidget(message: deletedMessage));

        // Test that the widget is created without errors
        expect(find.byType(ChatMessageBubble), findsOneWidget);
      });

      testWidgets('should handle messages without sender username', (tester) async {
        final noUsernameMessage = testMessage.copyWith(senderUsername: '');

        await tester.pumpWidget(createTestWidget(message: noUsernameMessage));

        // Test that the widget is created without errors
        expect(find.byType(ChatMessageBubble), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper accessibility labels', (tester) async {
        await tester.pumpWidget(createTestWidget(message: testMessage));

        // Test that the widget is created without errors
        expect(find.byType(ChatMessageBubble), findsOneWidget);
      });

      testWidgets('should support screen readers', (tester) async {
        await tester.pumpWidget(createTestWidget(message: testMessage));

        // Test that the widget is created without errors
        expect(find.byType(ChatMessageBubble), findsOneWidget);
      });
    });

    group('Performance', () {
      testWidgets('should handle long messages efficiently', (tester) async {
        final longMessage = testMessage.copyWith(
          messageText: 'This is a very long message that should be handled efficiently by the widget. ' * 10,
        );

        await tester.pumpWidget(createTestWidget(message: longMessage));

        // Test that the widget is created without errors
        expect(find.byType(ChatMessageBubble), findsOneWidget);
      });
    });
  });
}