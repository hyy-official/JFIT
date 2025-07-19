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
        senderName: 'John Doe',
        messageText: 'Hello everyone! Great workout today!',
        messageType: MessageType.text,
        createdAt: DateTime(2024, 1, 1, 10, 30),
        updatedAt: DateTime(2024, 1, 1, 10, 30),
        isDeleted: false,
      );
    });

    Widget createTestWidget({
      required GroupMessage message,
      bool isCurrentUser = false,
      VoidCallback? onTap,
      VoidCallback? onLongPress,
      VoidCallback? onReactionTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ChatMessageBubble(
            message: message,
            isCurrentUser: isCurrentUser,
            onTap: onTap,
            onLongPress: onLongPress,
            onReactionTap: onReactionTap,
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

      testWidgets('should display timestamp', (tester) async {
        await tester.pumpWidget(createTestWidget(message: testMessage));

        expect(find.text('10:30'), findsOneWidget);
      });

      testWidgets('should align message to right for current user', (tester) async {
        await tester.pumpWidget(createTestWidget(
          message: testMessage,
          isCurrentUser: true,
        ));

        final alignment = tester.widget<Align>(find.byType(Align).first);
        expect(alignment.alignment, Alignment.centerRight);
      });

      testWidgets('should align message to left for other users', (tester) async {
        await tester.pumpWidget(createTestWidget(
          message: testMessage,
          isCurrentUser: false,
        ));

        final alignment = tester.widget<Align>(find.byType(Align).first);
        expect(alignment.alignment, Alignment.centerLeft);
      });

      testWidgets('should not show sender name for current user', (tester) async {
        await tester.pumpWidget(createTestWidget(
          message: testMessage,
          isCurrentUser: true,
        ));

        expect(find.text('John Doe'), findsNothing);
      });

      testWidgets('should show sender name for other users', (tester) async {
        await tester.pumpWidget(createTestWidget(
          message: testMessage,
          isCurrentUser: false,
        ));

        expect(find.text('John Doe'), findsOneWidget);
      });
    });

    group('Message Types', () {
      testWidgets('should display image message correctly', (tester) async {
        final imageMessage = testMessage.copyWith(
          messageType: MessageType.image,
          messageText: 'https://example.com/workout.jpg',
        );

        await tester.pumpWidget(createTestWidget(message: imageMessage));

        expect(find.byType(Image), findsOneWidget);
        expect(find.byIcon(Icons.image), findsOneWidget);
      });

      testWidgets('should display workout share message correctly', (tester) async {
        final workoutMessage = testMessage.copyWith(
          messageType: MessageType.workoutShare,
          messageText: 'Shared workout: Push Day',
          workoutData: {
            'workoutName': 'Push Day',
            'exercises': 8,
            'duration': 45,
          },
        );

        await tester.pumpWidget(createTestWidget(message: workoutMessage));

        expect(find.text('Push Day'), findsOneWidget);
        expect(find.text('8 exercises'), findsOneWidget);
        expect(find.text('45 min'), findsOneWidget);
        expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      });

      testWidgets('should display achievement message correctly', (tester) async {
        final achievementMessage = testMessage.copyWith(
          messageType: MessageType.achievement,
          messageText: 'Completed 100 workouts!',
        );

        await tester.pumpWidget(createTestWidget(message: achievementMessage));

        expect(find.text('Completed 100 workouts!'), findsOneWidget);
        expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      });

      testWidgets('should display deleted message correctly', (tester) async {
        final deletedMessage = testMessage.copyWith(
          isDeleted: true,
          messageText: '',
        );

        await tester.pumpWidget(createTestWidget(message: deletedMessage));

        expect(find.text('This message was deleted'), findsOneWidget);
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      });
    });

    group('Reply Messages', () {
      testWidgets('should display reply indicator', (tester) async {
        final replyMessage = testMessage.copyWith(
          replyToMessageId: 'original-message',
          replyToText: 'Original message text',
          replyToSenderName: 'Jane Smith',
        );

        await tester.pumpWidget(createTestWidget(message: replyMessage));

        expect(find.text('Jane Smith'), findsOneWidget);
        expect(find.text('Original message text'), findsOneWidget);
        expect(find.byIcon(Icons.reply), findsOneWidget);
      });

      testWidgets('should handle reply to deleted message', (tester) async {
        final replyMessage = testMessage.copyWith(
          replyToMessageId: 'deleted-message',
          replyToText: '',
          replyToSenderName: 'Jane Smith',
          isReplyToDeleted: true,
        );

        await tester.pumpWidget(createTestWidget(message: replyMessage));

        expect(find.text('Message deleted'), findsOneWidget);
      });
    });

    group('Message Reactions', () {
      testWidgets('should display message reactions', (tester) async {
        final messageWithReactions = testMessage.copyWith(
          reactions: {
            '👍': ['user1', 'user2'],
            '❤️': ['user3'],
            '😂': ['user1', 'user4', 'user5'],
          },
        );

        await tester.pumpWidget(createTestWidget(message: messageWithReactions));

        expect(find.text('👍 2'), findsOneWidget);
        expect(find.text('❤️ 1'), findsOneWidget);
        expect(find.text('😂 3'), findsOneWidget);
      });

      testWidgets('should call onReactionTap when reaction is tapped', (tester) async {
        bool wasReactionTapped = false;
        
        final messageWithReactions = testMessage.copyWith(
          reactions: {'👍': ['user1']},
        );

        await tester.pumpWidget(createTestWidget(
          message: messageWithReactions,
          onReactionTap: () => wasReactionTapped = true,
        ));

        await tester.tap(find.text('👍 1'));
        await tester.pumpAndSettle();

        expect(wasReactionTapped, true);
      });

      testWidgets('should highlight user\'s own reactions', (tester) async {
        final messageWithReactions = testMessage.copyWith(
          reactions: {'👍': ['current-user', 'user1']},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChatMessageBubble(
                message: messageWithReactions,
                currentUserId: 'current-user',
              ),
            ),
          ),
        );

        // Should highlight the reaction the current user made
        final reactionChip = tester.widget<Chip>(find.byType(Chip).first);
        expect(reactionChip.backgroundColor, isNotNull);
      });
    });

    group('Interaction Tests', () {
      testWidgets('should call onTap when message is tapped', (tester) async {
        bool wasTapped = false;
        
        await tester.pumpWidget(createTestWidget(
          message: testMessage,
          onTap: () => wasTapped = true,
        ));

        await tester.tap(find.byType(ChatMessageBubble));
        await tester.pumpAndSettle();

        expect(wasTapped, true);
      });

      testWidgets('should call onLongPress when message is long pressed', (tester) async {
        bool wasLongPressed = false;
        
        await tester.pumpWidget(createTestWidget(
          message: testMessage,
          onLongPress: () => wasLongPressed = true,
        ));

        await tester.longPress(find.byType(ChatMessageBubble));
        await tester.pumpAndSettle();

        expect(wasLongPressed, true);
      });
    });

    group('Message Status', () {
      testWidgets('should display sending status', (tester) async {
        final sendingMessage = testMessage.copyWith(
          status: MessageStatus.sending,
        );

        await tester.pumpWidget(createTestWidget(
          message: sendingMessage,
          isCurrentUser: true,
        ));

        expect(find.byIcon(Icons.access_time), findsOneWidget);
      });

      testWidgets('should display sent status', (tester) async {
        final sentMessage = testMessage.copyWith(
          status: MessageStatus.sent,
        );

        await tester.pumpWidget(createTestWidget(
          message: sentMessage,
          isCurrentUser: true,
        ));

        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('should display delivered status', (tester) async {
        final deliveredMessage = testMessage.copyWith(
          status: MessageStatus.delivered,
        );

        await tester.pumpWidget(createTestWidget(
          message: deliveredMessage,
          isCurrentUser: true,
        ));

        expect(find.byIcon(Icons.done_all), findsOneWidget);
      });

      testWidgets('should display failed status', (tester) async {
        final failedMessage = testMessage.copyWith(
          status: MessageStatus.failed,
        );

        await tester.pumpWidget(createTestWidget(
          message: failedMessage,
          isCurrentUser: true,
        ));

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });
    });

    group('Responsive Design', () {
      testWidgets('should adapt to mobile screen size', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(400, 800);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(createTestWidget(message: testMessage));
        await tester.pumpAndSettle();

        expect(find.byType(ChatMessageBubble), findsOneWidget);

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
      });

      testWidgets('should handle long messages gracefully', (tester) async {
        final longMessage = testMessage.copyWith(
          messageText: 'This is a very long message that should wrap properly and not cause any overflow issues in the chat bubble widget. It should maintain readability and proper formatting.',
        );

        await tester.pumpWidget(createTestWidget(message: longMessage));

        expect(find.textContaining('This is a very long message'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should limit bubble width on larger screens', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1200, 800);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(createTestWidget(message: testMessage));
        await tester.pumpAndSettle();

        final bubbleContainer = tester.widget<Container>(
          find.descendant(
            of: find.byType(ChatMessageBubble),
            matching: find.byType(Container),
          ).first,
        );

        expect(bubbleContainer.constraints?.maxWidth, isNotNull);

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle empty message text', (tester) async {
        final emptyMessage = testMessage.copyWith(messageText: '');

        await tester.pumpWidget(createTestWidget(message: emptyMessage));

        expect(find.text(''), findsNothing);
        expect(find.byType(ChatMessageBubble), findsOneWidget);
      });

      testWidgets('should handle missing sender name', (tester) async {
        final noSenderMessage = testMessage.copyWith(senderName: '');

        await tester.pumpWidget(createTestWidget(message: noSenderMessage));

        expect(find.text('Anonymous'), findsOneWidget);
      });

      testWidgets('should handle invalid timestamps', (tester) async {
        final invalidTimeMessage = testMessage.copyWith(
          createdAt: DateTime(1970, 1, 1),
        );

        await tester.pumpWidget(createTestWidget(message: invalidTimeMessage));

        expect(find.byType(ChatMessageBubble), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper accessibility labels', (tester) async {
        await tester.pumpWidget(createTestWidget(message: testMessage));

        expect(
          find.bySemanticsLabel('Message from John Doe at 10:30: Hello everyone! Great workout today!'),
          findsOneWidget,
        );
      });

      testWidgets('should support keyboard navigation', (tester) async {
        bool wasTapped = false;
        
        await tester.pumpWidget(createTestWidget(
          message: testMessage,
          onTap: () => wasTapped = true,
        ));

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(wasTapped, true);
      });

      testWidgets('should announce message status to screen readers', (tester) async {
        final failedMessage = testMessage.copyWith(
          status: MessageStatus.failed,
        );

        await tester.pumpWidget(createTestWidget(
          message: failedMessage,
          isCurrentUser: true,
        ));

        expect(
          find.bySemanticsLabel('Message failed to send'),
          findsOneWidget,
        );
      });
    });

    group('Theme Integration', () {
      testWidgets('should respect light theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: ChatMessageBubble(message: testMessage),
            ),
          ),
        );

        expect(find.byType(ChatMessageBubble), findsOneWidget);
      });

      testWidgets('should respect dark theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: ChatMessageBubble(message: testMessage),
            ),
          ),
        );

        expect(find.byType(ChatMessageBubble), findsOneWidget);
      });

      testWidgets('should use different colors for current user vs others', (tester) async {
        await tester.pumpWidget(createTestWidget(
          message: testMessage,
          isCurrentUser: true,
        ));

        final bubbleContainer = tester.widget<Container>(
          find.descendant(
            of: find.byType(ChatMessageBubble),
            matching: find.byType(Container),
          ).first,
        );

        expect(bubbleContainer.decoration, isA<BoxDecoration>());
      });
    });

    group('Animation Tests', () {
      testWidgets('should animate message appearance', (tester) async {
        await tester.pumpWidget(createTestWidget(message: testMessage));

        // Should animate in
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(ChatMessageBubble), findsOneWidget);
      });

      testWidgets('should animate status changes', (tester) async {
        await tester.pumpWidget(createTestWidget(
          message: testMessage.copyWith(status: MessageStatus.sending),
          isCurrentUser: true,
        ));

        expect(find.byIcon(Icons.access_time), findsOneWidget);

        // Change status
        await tester.pumpWidget(createTestWidget(
          message: testMessage.copyWith(status: MessageStatus.sent),
          isCurrentUser: true,
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.check), findsOneWidget);
      });
    });
  });
}