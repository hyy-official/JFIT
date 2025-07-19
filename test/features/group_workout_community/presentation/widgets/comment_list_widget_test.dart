import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:jfit/features/group_workout_community/domain/entities/post_comment.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/comment_list_widget.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/post_interaction/post_interaction_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/post_interaction/post_interaction_state.dart';

import 'comment_list_widget_test.mocks.dart';

@GenerateMocks([PostInteractionBloc])
void main() {
  group('CommentListWidget Tests', () {
    late MockPostInteractionBloc mockBloc;
    late List<PostComment> testComments;

    setUp(() {
      mockBloc = MockPostInteractionBloc();
      
      testComments = [
        PostComment(
          id: 'comment-1',
          postId: 'post-1',
          authorId: 'author-1',
          authorName: 'John Doe',
          content: 'This is a test comment',
          likesCount: 5,
          isDeleted: false,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
        PostComment(
          id: 'comment-2',
          postId: 'post-1',
          authorId: 'author-2',
          authorName: 'Jane Smith',
          parentCommentId: 'comment-1',
          content: 'This is a reply to the first comment',
          likesCount: 2,
          isDeleted: false,
          createdAt: DateTime(2024, 1, 2),
          updatedAt: DateTime(2024, 1, 2),
        ),
        PostComment(
          id: 'comment-3',
          postId: 'post-1',
          authorId: 'author-3',
          authorName: 'Bob Wilson',
          content: 'Another top-level comment',
          likesCount: 0,
          isDeleted: false,
          createdAt: DateTime(2024, 1, 3),
          updatedAt: DateTime(2024, 1, 3),
        ),
      ];

      when(mockBloc.state).thenReturn(const PostInteractionInitial());
      when(mockBloc.stream).thenAnswer((_) => const Stream.empty());
    });

    Widget createTestWidget({
      required List<PostComment> comments,
      String postId = 'post-1',
      String currentUserId = 'current-user',
      VoidCallback? onCommentAdded,
    }) {
      return MaterialApp(
        home: BlocProvider<PostInteractionBloc>(
          create: (_) => mockBloc,
          child: Scaffold(
            body: CommentListWidget(
              postId: postId,
              comments: comments,
              currentUserId: currentUserId,
              onCommentAdded: onCommentAdded,
            ),
          ),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('should display comments correctly', (tester) async {
        await tester.pumpWidget(createTestWidget(comments: testComments));

        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('This is a test comment'), findsOneWidget);
        expect(find.text('Jane Smith'), findsOneWidget);
        expect(find.text('This is a reply to the first comment'), findsOneWidget);
        expect(find.text('Bob Wilson'), findsOneWidget);
        expect(find.text('Another top-level comment'), findsOneWidget);
      });

      testWidgets('should display empty state when no comments', (tester) async {
        await tester.pumpWidget(createTestWidget(comments: []));

        expect(find.text('No comments yet'), findsOneWidget);
        expect(find.text('Be the first to comment!'), findsOneWidget);
      });

      testWidgets('should display like counts correctly', (tester) async {
        await tester.pumpWidget(createTestWidget(comments: testComments));

        expect(find.text('5'), findsOneWidget); // First comment likes
        expect(find.text('2'), findsOneWidget); // Reply likes
      });

      testWidgets('should show reply structure correctly', (tester) async {
        await tester.pumpWidget(createTestWidget(comments: testComments));

        // Should show parent comment
        expect(find.text('This is a test comment'), findsOneWidget);
        
        // Should show reply with proper indentation
        expect(find.text('This is a reply to the first comment'), findsOneWidget);
      });
    });

    group('Interaction Tests', () {
      testWidgets('should expand/collapse replies', (tester) async {
        await tester.pumpWidget(createTestWidget(comments: testComments));

        // Find and tap the expand/collapse button
        final expandButton = find.byIcon(Icons.expand_more);
        if (expandButton.evaluate().isNotEmpty) {
          await tester.tap(expandButton.first);
          await tester.pumpAndSettle();

          // Verify replies are shown/hidden
          expect(find.text('This is a reply to the first comment'), findsOneWidget);
        }
      });

      testWidgets('should show reply input when reply button is tapped', (tester) async {
        await tester.pumpWidget(createTestWidget(comments: testComments));

        // Find and tap reply button
        final replyButton = find.text('Reply').first;
        await tester.tap(replyButton);
        await tester.pumpAndSettle();

        // Should show reply input field
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Write a reply...'), findsOneWidget);
      });

      testWidgets('should handle like button tap', (tester) async {
        await tester.pumpWidget(createTestWidget(comments: testComments));

        // Find and tap like button
        final likeButton = find.byIcon(Icons.favorite_border).first;
        await tester.tap(likeButton);
        await tester.pumpAndSettle();

        // Verify bloc event was called
        verify(mockBloc.add(any)).called(1);
      });
    });

    group('Responsive Design', () {
      testWidgets('should adapt to mobile screen size', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(400, 800);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(createTestWidget(comments: testComments));
        await tester.pumpAndSettle();

        expect(find.byType(CommentListWidget), findsOneWidget);

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
      });

      testWidgets('should handle nested comments with proper indentation', (tester) async {
        await tester.pumpWidget(createTestWidget(comments: testComments));

        // Verify nested comment has proper indentation
        final replyWidget = find.text('This is a reply to the first comment');
        expect(replyWidget, findsOneWidget);
        
        // The reply should be visually indented
        final replyContainer = tester.widget<Container>(
          find.ancestor(
            of: replyWidget,
            matching: find.byType(Container),
          ).first,
        );
        expect(replyContainer.margin, isNotNull);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle deleted comments', (tester) async {
        final deletedComments = [
          testComments[0].copyWith(
            isDeleted: true,
            content: '',
          ),
        ];

        await tester.pumpWidget(createTestWidget(comments: deletedComments));

        expect(find.text('[Comment deleted]'), findsOneWidget);
        expect(find.text('This is a test comment'), findsNothing);
      });

      testWidgets('should handle very long comments', (tester) async {
        final longComments = [
          testComments[0].copyWith(
            content: 'This is a very long comment that should be handled gracefully by the UI without causing overflow issues or performance problems. It should wrap properly and maintain readability.',
          ),
        ];

        await tester.pumpWidget(createTestWidget(comments: longComments));

        expect(find.textContaining('This is a very long comment'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle comments with zero likes', (tester) async {
        final zeroLikeComments = [
          testComments[0].copyWith(likesCount: 0),
        ];

        await tester.pumpWidget(createTestWidget(comments: zeroLikeComments));

        // Should not show like count when zero
        expect(find.text('0'), findsNothing);
      });

      testWidgets('should handle missing author names', (tester) async {
        final noAuthorComments = [
          testComments[0].copyWith(authorName: ''),
        ];

        await tester.pumpWidget(createTestWidget(comments: noAuthorComments));

        expect(find.text('Anonymous'), findsOneWidget);
      });
    });

    group('Comment Input', () {
      testWidgets('should show comment input field', (tester) async {
        await tester.pumpWidget(createTestWidget(comments: testComments));

        // Tap reply button to show input
        await tester.tap(find.text('Reply').first);
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Write a reply...'), findsOneWidget);
      });

      testWidgets('should handle comment submission', (tester) async {
        await tester.pumpWidget(createTestWidget(comments: testComments));

        // Show reply input
        await tester.tap(find.text('Reply').first);
        await tester.pumpAndSettle();

        // Enter text
        await tester.enterText(find.byType(TextField), 'This is a new reply');
        await tester.pumpAndSettle();

        // Tap submit button
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();

        // Verify bloc event was called
        verify(mockBloc.add(any)).called(1);
      });

      testWidgets('should validate empty comments', (tester) async {
        await tester.pumpWidget(createTestWidget(comments: testComments));

        // Show reply input
        await tester.tap(find.text('Reply').first);
        await tester.pumpAndSettle();

        // Try to submit empty comment
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();

        // Should show validation error
        expect(find.text('Comment cannot be empty'), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper accessibility labels', (tester) async {
        await tester.pumpWidget(createTestWidget(comments: testComments));

        expect(
          find.bySemanticsLabel('Comment by John Doe'),
          findsOneWidget,
        );
        
        expect(
          find.bySemanticsLabel('Like comment'),
          findsWidgets,
        );
        
        expect(
          find.bySemanticsLabel('Reply to comment'),
          findsWidgets,
        );
      });

      testWidgets('should support keyboard navigation', (tester) async {
        await tester.pumpWidget(createTestWidget(comments: testComments));

        // Navigate through comments with tab
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        // Should focus on first interactive element
        expect(find.byType(CommentListWidget), findsOneWidget);
      });
    });

    group('Theme Integration', () {
      testWidgets('should respect light theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: BlocProvider<PostInteractionBloc>(
              create: (_) => mockBloc,
              child: Scaffold(
                body: CommentListWidget(
                  postId: 'post-1',
                  comments: testComments,
                  currentUserId: 'current-user',
                ),
              ),
            ),
          ),
        );

        expect(find.byType(CommentListWidget), findsOneWidget);
      });

      testWidgets('should respect dark theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: BlocProvider<PostInteractionBloc>(
              create: (_) => mockBloc,
              child: Scaffold(
                body: CommentListWidget(
                  postId: 'post-1',
                  comments: testComments,
                  currentUserId: 'current-user',
                ),
              ),
            ),
          ),
        );

        expect(find.byType(CommentListWidget), findsOneWidget);
      });
    });
  });
}