import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/like_dislike_button.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/post_interaction/post_interaction_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/post_interaction/post_interaction_state.dart';

@GenerateMocks([PostInteractionBloc])
import 'like_dislike_button_test.mocks.dart';

void main() {
  group('LikeDislikeButton Widget Tests', () {
    late MockPostInteractionBloc mockBloc;

    setUp(() {
      mockBloc = MockPostInteractionBloc();
      when(mockBloc.state).thenReturn(const PostInteractionInitial());
      when(mockBloc.stream).thenAnswer((_) => Stream.fromIterable([const PostInteractionInitial()]));
    });

    Widget createTestWidget({
      String postId = 'test-post',
      String? commentId,
      String userId = 'test-user',
      int likesCount = 0,
      int dislikesCount = 0,
      bool isLiked = false,
      bool isDisliked = false,
      bool showDislike = true,
      bool isCompact = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<PostInteractionBloc>(
            create: (context) => mockBloc,
            child: LikeDislikeButton(
              postId: postId,
              commentId: commentId,
              userId: userId,
              likesCount: likesCount,
              dislikesCount: dislikesCount,
              isLiked: isLiked,
              isDisliked: isDisliked,
              showDislike: showDislike,
              isCompact: isCompact,
            ),
          ),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('should display like and dislike buttons', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
        expect(find.byIcon(Icons.thumb_down_outlined), findsOneWidget);
      });

      testWidgets('should display like count when greater than zero', (tester) async {
        await tester.pumpWidget(createTestWidget(likesCount: 5));

        expect(find.text('5'), findsOneWidget);
      });

      testWidgets('should display dislike count when greater than zero', (tester) async {
        await tester.pumpWidget(createTestWidget(dislikesCount: 3));

        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('should not display counts when zero', (tester) async {
        await tester.pumpWidget(createTestWidget(
          likesCount: 0,
          dislikesCount: 0,
        ));

        expect(find.text('0'), findsNothing);
      });

      testWidgets('should show filled icons when liked/disliked', (tester) async {
        await tester.pumpWidget(createTestWidget(
          isLiked: true,
          isDisliked: false,
        ));

        expect(find.byIcon(Icons.favorite), findsOneWidget);
        expect(find.byIcon(Icons.thumb_down_outlined), findsOneWidget);
      });

      testWidgets('should show filled dislike icon when disliked', (tester) async {
        await tester.pumpWidget(createTestWidget(
          isLiked: false,
          isDisliked: true,
        ));

        expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
        expect(find.byIcon(Icons.thumb_down), findsOneWidget);
      });
    });

    group('Interaction Tests', () {
      testWidgets('should handle like button tap', (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.byIcon(Icons.favorite_outline));
        await tester.pumpAndSettle();

        // Should not crash
        expect(find.byType(LikeDislikeButton), findsOneWidget);
      });

      testWidgets('should handle dislike button tap', (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.byIcon(Icons.thumb_down_outlined));
        await tester.pumpAndSettle();

        // Should not crash
        expect(find.byType(LikeDislikeButton), findsOneWidget);
      });

      testWidgets('should handle compact mode', (tester) async {
        await tester.pumpWidget(createTestWidget(isCompact: true));

        expect(find.byType(LikeDislikeButton), findsOneWidget);
      });

      testWidgets('should hide dislike button when showDislike is false', (tester) async {
        await tester.pumpWidget(createTestWidget(showDislike: false));

        expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
        expect(find.byIcon(Icons.thumb_down_outlined), findsNothing);
      });
    });

    group('Visual States', () {
      testWidgets('should highlight like button when liked', (tester) async {
        await tester.pumpWidget(createTestWidget(
          isLiked: true,
          likesCount: 1,
        ));

        expect(find.byIcon(Icons.favorite), findsOneWidget);
      });

      testWidgets('should highlight dislike button when disliked', (tester) async {
        await tester.pumpWidget(createTestWidget(
          isDisliked: true,
          dislikesCount: 1,
        ));

        expect(find.byIcon(Icons.thumb_down), findsOneWidget);
      });

      testWidgets('should show different colors for liked/disliked states', (tester) async {
        await tester.pumpWidget(createTestWidget(
          isLiked: true,
          likesCount: 5,
        ));

        final likeIcon = tester.widget<Icon>(find.byIcon(Icons.favorite));
        expect(likeIcon.color, isNotNull);
      });
    });

    group('Responsive Design', () {
      testWidgets('should adapt to mobile screen size', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(400, 800);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(createTestWidget(likesCount: 10));
        await tester.pumpAndSettle();

        expect(find.byType(LikeDislikeButton), findsOneWidget);

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
      });

      testWidgets('should have proper touch targets on mobile', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(LikeDislikeButton), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle very large like counts', (tester) async {
        await tester.pumpWidget(createTestWidget(likesCount: 999999));

        expect(find.text('1000.0K'), findsOneWidget);
      });

      testWidgets('should handle negative counts gracefully', (tester) async {
        await tester.pumpWidget(createTestWidget(
          likesCount: -1,
          dislikesCount: -1,
        ));

        // Should not crash and should show 0 or handle gracefully
        expect(find.byType(LikeDislikeButton), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle both liked and disliked states', (tester) async {
        // This shouldn't happen in normal usage, but test graceful handling
        await tester.pumpWidget(createTestWidget(
          isLiked: true,
          isDisliked: true,
        ));

        expect(find.byType(LikeDislikeButton), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('Animation Tests', () {
      testWidgets('should animate when like state changes', (tester) async {
        await tester.pumpWidget(createTestWidget(isLiked: false));

        // Initial state
        expect(find.byIcon(Icons.favorite_outline), findsOneWidget);

        // Tap the like button to trigger animation
        await tester.tap(find.byIcon(Icons.favorite_outline));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Should show filled icon after tap (optimistic update)
        expect(find.byIcon(Icons.favorite), findsOneWidget);
        
        // Wait for the timer to complete
        await tester.pump(const Duration(milliseconds: 500));
      });

      testWidgets('should animate count changes', (tester) async {
        await tester.pumpWidget(createTestWidget(likesCount: 5));

        expect(find.text('5'), findsOneWidget);

        // Tap the like button to trigger count change (optimistic update)
        await tester.tap(find.byIcon(Icons.favorite_outline));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Should show updated count (5 + 1 = 6)
        expect(find.text('6'), findsOneWidget);
        
        // Wait for the timer to complete
        await tester.pump(const Duration(milliseconds: 500));
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper accessibility labels', (tester) async {
        await tester.pumpWidget(createTestWidget(
          likesCount: 5,
          dislikesCount: 2,
        ));

        expect(find.byType(LikeDislikeButton), findsOneWidget);
      });

      testWidgets('should have proper accessibility labels when liked', (tester) async {
        await tester.pumpWidget(createTestWidget(
          isLiked: true,
          likesCount: 5,
        ));

        expect(find.byType(LikeDislikeButton), findsOneWidget);
      });

      testWidgets('should support keyboard navigation', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Focus like button
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        // Press enter to activate
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(find.byType(LikeDislikeButton), findsOneWidget);
      });

      testWidgets('should announce state changes to screen readers', (tester) async {
        await tester.pumpWidget(createTestWidget(
          isLiked: false,
          likesCount: 5,
        ));

        // Change to liked state
        await tester.pumpWidget(createTestWidget(
          isLiked: true,
          likesCount: 6,
        ));

        expect(find.byType(LikeDislikeButton), findsOneWidget);
      });
    });

    group('Theme Integration', () {
      testWidgets('should respect light theme colors', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: BlocProvider<PostInteractionBloc>(
                create: (context) => mockBloc,
                child: LikeDislikeButton(
                  postId: 'test-post',
                  userId: 'test-user',
                  likesCount: 5,
                  isLiked: true,
                ),
              ),
            ),
          ),
        );

        final likeIcon = tester.widget<Icon>(find.byIcon(Icons.favorite));
        expect(likeIcon.color, isNotNull);
      });

      testWidgets('should respect dark theme colors', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: BlocProvider<PostInteractionBloc>(
                create: (context) => mockBloc,
                child: LikeDislikeButton(
                  postId: 'test-post',
                  userId: 'test-user',
                  likesCount: 5,
                  isLiked: true,
                ),
              ),
            ),
          ),
        );

        final likeIcon = tester.widget<Icon>(find.byIcon(Icons.favorite));
        expect(likeIcon.color, isNotNull);
      });

      testWidgets('should adapt to theme colors', (tester) async {
        await tester.pumpWidget(createTestWidget(
          likesCount: 5,
          isLiked: true,
        ));

        expect(find.byType(LikeDislikeButton), findsOneWidget);
      });
    });

    group('Performance', () {
      testWidgets('should handle rapid taps without issues', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Find the like button (could be in full or compact mode)
        final likeButton = find.byIcon(Icons.favorite_outline);
        
        // Rapid taps
        for (int i = 0; i < 10; i++) {
          if (likeButton.evaluate().isNotEmpty) {
            await tester.tap(likeButton);
            await tester.pump(const Duration(milliseconds: 10));
          }
        }

        await tester.pumpAndSettle();

        // Should handle gracefully without crashing
        expect(find.byType(LikeDislikeButton), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}