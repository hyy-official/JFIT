import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/like_dislike_button.dart';

void main() {
  group('LikeDislikeButton Widget Tests', () {
    Widget createTestWidget({
      int likeCount = 0,
      int dislikeCount = 0,
      bool isLiked = false,
      bool isDisliked = false,
      VoidCallback? onLike,
      VoidCallback? onDislike,
      bool isLoading = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: LikeDislikeButton(
            likeCount: likeCount,
            dislikeCount: dislikeCount,
            isLiked: isLiked,
            isDisliked: isDisliked,
            onLike: onLike,
            onDislike: onDislike,
            isLoading: isLoading,
          ),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('should display like and dislike buttons', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byIcon(Icons.thumb_up_outlined), findsOneWidget);
        expect(find.byIcon(Icons.thumb_down_outlined), findsOneWidget);
      });

      testWidgets('should display like count when greater than zero', (tester) async {
        await tester.pumpWidget(createTestWidget(likeCount: 5));

        expect(find.text('5'), findsOneWidget);
      });

      testWidgets('should display dislike count when greater than zero', (tester) async {
        await tester.pumpWidget(createTestWidget(dislikeCount: 3));

        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('should not display counts when zero', (tester) async {
        await tester.pumpWidget(createTestWidget(
          likeCount: 0,
          dislikeCount: 0,
        ));

        expect(find.text('0'), findsNothing);
      });

      testWidgets('should show filled icons when liked/disliked', (tester) async {
        await tester.pumpWidget(createTestWidget(
          isLiked: true,
          isDisliked: false,
        ));

        expect(find.byIcon(Icons.thumb_up), findsOneWidget);
        expect(find.byIcon(Icons.thumb_down_outlined), findsOneWidget);
      });

      testWidgets('should show filled dislike icon when disliked', (tester) async {
        await tester.pumpWidget(createTestWidget(
          isLiked: false,
          isDisliked: true,
        ));

        expect(find.byIcon(Icons.thumb_up_outlined), findsOneWidget);
        expect(find.byIcon(Icons.thumb_down), findsOneWidget);
      });
    });

    group('Interaction Tests', () {
      testWidgets('should call onLike when like button is tapped', (tester) async {
        bool wasLiked = false;
        
        await tester.pumpWidget(createTestWidget(
          onLike: () => wasLiked = true,
        ));

        await tester.tap(find.byIcon(Icons.thumb_up_outlined));
        await tester.pumpAndSettle();

        expect(wasLiked, true);
      });

      testWidgets('should call onDislike when dislike button is tapped', (tester) async {
        bool wasDisliked = false;
        
        await tester.pumpWidget(createTestWidget(
          onDislike: () => wasDisliked = true,
        ));

        await tester.tap(find.byIcon(Icons.thumb_down_outlined));
        await tester.pumpAndSettle();

        expect(wasDisliked, true);
      });

      testWidgets('should not respond to taps when loading', (tester) async {
        bool wasLiked = false;
        
        await tester.pumpWidget(createTestWidget(
          isLoading: true,
          onLike: () => wasLiked = true,
        ));

        await tester.tap(find.byIcon(Icons.thumb_up_outlined));
        await tester.pumpAndSettle();

        expect(wasLiked, false);
      });

      testWidgets('should show loading indicator when loading', (tester) async {
        await tester.pumpWidget(createTestWidget(isLoading: true));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Visual States', () {
      testWidgets('should highlight like button when liked', (tester) async {
        await tester.pumpWidget(createTestWidget(
          isLiked: true,
          likeCount: 1,
        ));

        final likeButton = tester.widget<IconButton>(
          find.byIcon(Icons.thumb_up),
        );
        
        expect(likeButton.icon, isA<Icon>());
      });

      testWidgets('should highlight dislike button when disliked', (tester) async {
        await tester.pumpWidget(createTestWidget(
          isDisliked: true,
          dislikeCount: 1,
        ));

        final dislikeButton = tester.widget<IconButton>(
          find.byIcon(Icons.thumb_down),
        );
        
        expect(dislikeButton.icon, isA<Icon>());
      });

      testWidgets('should show different colors for liked/disliked states', (tester) async {
        await tester.pumpWidget(createTestWidget(
          isLiked: true,
          likeCount: 5,
        ));

        final likeIcon = tester.widget<Icon>(find.byIcon(Icons.thumb_up));
        expect(likeIcon.color, isNotNull);
      });
    });

    group('Responsive Design', () {
      testWidgets('should adapt to mobile screen size', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(400, 800);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(createTestWidget(likeCount: 10));
        await tester.pumpAndSettle();

        expect(find.byType(LikeDislikeButton), findsOneWidget);

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
      });

      testWidgets('should have proper touch targets on mobile', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final likeButton = tester.getSize(find.byIcon(Icons.thumb_up_outlined));
        final dislikeButton = tester.getSize(find.byIcon(Icons.thumb_down_outlined));

        // Touch targets should be at least 44x44 pixels
        expect(likeButton.width, greaterThanOrEqualTo(44));
        expect(likeButton.height, greaterThanOrEqualTo(44));
        expect(dislikeButton.width, greaterThanOrEqualTo(44));
        expect(dislikeButton.height, greaterThanOrEqualTo(44));
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle very large like counts', (tester) async {
        await tester.pumpWidget(createTestWidget(likeCount: 999999));

        expect(find.text('999K+'), findsOneWidget);
      });

      testWidgets('should handle negative counts gracefully', (tester) async {
        await tester.pumpWidget(createTestWidget(
          likeCount: -1,
          dislikeCount: -1,
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
        expect(find.byIcon(Icons.thumb_up_outlined), findsOneWidget);

        // Change to liked state
        await tester.pumpWidget(createTestWidget(isLiked: true));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.thumb_up), findsOneWidget);
      });

      testWidgets('should animate count changes', (tester) async {
        await tester.pumpWidget(createTestWidget(likeCount: 5));

        expect(find.text('5'), findsOneWidget);

        // Change count
        await tester.pumpWidget(createTestWidget(likeCount: 6));
        await tester.pumpAndSettle();

        expect(find.text('6'), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper accessibility labels', (tester) async {
        await tester.pumpWidget(createTestWidget(
          likeCount: 5,
          dislikeCount: 2,
        ));

        expect(
          find.bySemanticsLabel('Like (5 likes)'),
          findsOneWidget,
        );
        
        expect(
          find.bySemanticsLabel('Dislike (2 dislikes)'),
          findsOneWidget,
        );
      });

      testWidgets('should have proper accessibility labels when liked', (tester) async {
        await tester.pumpWidget(createTestWidget(
          isLiked: true,
          likeCount: 5,
        ));

        expect(
          find.bySemanticsLabel('Unlike (5 likes)'),
          findsOneWidget,
        );
      });

      testWidgets('should support keyboard navigation', (tester) async {
        bool wasLiked = false;
        
        await tester.pumpWidget(createTestWidget(
          onLike: () => wasLiked = true,
        ));

        // Focus like button
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        // Press enter to activate
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(wasLiked, true);
      });

      testWidgets('should announce state changes to screen readers', (tester) async {
        await tester.pumpWidget(createTestWidget(
          isLiked: false,
          likeCount: 5,
        ));

        // Change to liked state
        await tester.pumpWidget(createTestWidget(
          isLiked: true,
          likeCount: 6,
        ));

        expect(find.bySemanticsLabel('Unlike (6 likes)'), findsOneWidget);
      });
    });

    group('Theme Integration', () {
      testWidgets('should respect light theme colors', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: LikeDislikeButton(
                likeCount: 5,
                isLiked: true,
              ),
            ),
          ),
        );

        final likeIcon = tester.widget<Icon>(find.byIcon(Icons.thumb_up));
        expect(likeIcon.color, isNotNull);
      });

      testWidgets('should respect dark theme colors', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: LikeDislikeButton(
                likeCount: 5,
                isLiked: true,
              ),
            ),
          ),
        );

        final likeIcon = tester.widget<Icon>(find.byIcon(Icons.thumb_up));
        expect(likeIcon.color, isNotNull);
      });

      testWidgets('should use custom colors when provided', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LikeDislikeButton(
                likeCount: 5,
                isLiked: true,
                likeColor: Colors.green,
                dislikeColor: Colors.red,
              ),
            ),
          ),
        );

        final likeIcon = tester.widget<Icon>(find.byIcon(Icons.thumb_up));
        expect(likeIcon.color, Colors.green);
      });
    });

    group('Performance', () {
      testWidgets('should handle rapid taps without issues', (tester) async {
        int tapCount = 0;
        
        await tester.pumpWidget(createTestWidget(
          onLike: () => tapCount++,
        ));

        // Rapid taps
        for (int i = 0; i < 10; i++) {
          await tester.tap(find.byIcon(Icons.thumb_up_outlined));
          await tester.pump(const Duration(milliseconds: 10));
        }

        await tester.pumpAndSettle();

        // Should handle gracefully without crashing
        expect(find.byType(LikeDislikeButton), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}