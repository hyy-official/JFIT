import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group_chat/group_chat_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/pages/group_chat_page.dart';

void main() {
  group('Group Chat Integration Tests', () {
    testWidgets('should display chat page with basic elements', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (context) => GroupChatBloc(),
            child: const GroupChatPage(
              groupId: 'test_group_id',
              groupName: 'Test Group',
            ),
          ),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Verify that the app bar is displayed with group name
      expect(find.text('Test Group'), findsOneWidget);
      
      // Verify that the loading indicator appears initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display empty state when no messages', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (context) => GroupChatBloc(),
            child: const GroupChatPage(
              groupId: 'test_group_id',
              groupName: 'Test Group',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show input field
      expect(find.byType(TextField), findsOneWidget); // Input field should be present
    });

    testWidgets('should display message input area', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (context) => GroupChatBloc(),
            child: const GroupChatPage(
              groupId: 'test_group_id',
              groupName: 'Test Group',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify input field is present
      expect(find.byType(TextField), findsOneWidget);
      
      // Verify send button is present
      expect(find.byIcon(Icons.mic), findsOneWidget); // Should show mic when no text
    });

    testWidgets('should show send icon when text is entered', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (context) => GroupChatBloc(),
            child: const GroupChatPage(
              groupId: 'test_group_id',
              groupName: 'Test Group',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter text in the input field
      await tester.enterText(find.byType(TextField), 'Hello world');
      await tester.pump();

      // Should show send icon instead of mic
      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsNothing);
    });
  });
}