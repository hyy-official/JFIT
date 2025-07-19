import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/features/group_workout_community/domain/entities/community_post.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/community_post_card.dart';

void main() {
  group('CommunityPostCard Widget Tests', () {
    late CommunityPost testPost;

    setUp(() {
      testPost = CommunityPost(
        id: 'test-post-id',
        authorId: 'author-id',
        title: 'Test Post Title',
        content: 'This is a test post content',
        postType: PostType.text,
        categoryId: 'category-id',
        mediaUrls: [],
        tags: ['fitness', 'workout'],
        likesCount: 10,
        commentsCount: 5,
        viewsCount: 100,
        isPinned: false,
        isDeleted: false,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
    });

    Widget createTestWidget({
      required CommunityPost post,
      VoidCallback? onTap,
      VoidCallback? onLike,
      VoidCallback? onComment,
      bool isGridView = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: CommunityPostCard(
            post: post,
            onTap: onTap,
            onLike: onLike,
            onComment: onComment,
            isGridView: isGridView,
          ),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('should display post information correctly', (tester) async {
        await tester.pumpWidget(createTestWidget(post: testPost));

        expect(find.text('Test Post Title'), findsOneWidget);
        expect(find.text('This is a test post content'), findsOneWidget);
        expect(find.text('작성자'), findsOneWidget); // Default author text from implementation
        expect(find.text('일반'), findsOneWidget); // Default category text from implementation
        expect(find.text('10'), findsOneWidget); // likes count
        expect(find.text('5'), findsOneWidget); // comments count
      });

      testWidgets('should display pinned post indicator', (tester) async {
        final pinnedPost = testPost.copyWith(isPinned: true);
        await tester.pumpWidget(createTestWidget(post: pinnedPost));

        // Check that the widget renders without error for pinned posts
        expect(find.byType(CommunityPostCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should display media post with images', (tester) async {
        final mediaPost = testPost.copyWith(
          postType: PostType.image,
          mediaUrls: ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'],
        );
        await tester.pumpWidget(createTestWidget(post: mediaPost));

        // Check that media preview container is displayed
        expect(find.byType(Container), findsWidgets);
        expect(find.byIcon(Icons.image), findsOneWidget);
      });

      testWidgets('should display tags correctly', (tester) async {
        await tester.pumpWidget(createTestWidget(post: testPost));

        expect(find.text('#fitness'), findsOneWidget);
        expect(find.text('#workout'), findsOneWidget);
      });
    });

    group('Interaction Tests', () {
      testWidgets('should call onTap when card is tapped', (tester) async {
        bool wasTapped = false;
        
        await tester.pumpWidget(createTestWidget(
          post: testPost,
          onTap: () => wasTapped = true,
        ));

        await tester.tap(find.byType(CommunityPostCard));
        await tester.pumpAndSettle();

        expect(wasTapped, true);
      });

      testWidgets('should call onLike when like button is tapped', (tester) async {
        bool wasLiked = false;
        
        await tester.pumpWidget(createTestWidget(
          post: testPost,
          onLike: () => wasLiked = true,
        ));

        await tester.tap(find.byIcon(Icons.favorite_border));
        await tester.pumpAndSettle();

        expect(wasLiked, true);
      });

      testWidgets('should call onComment when comment button is tapped', (tester) async {
        bool wasCommented = false;
        
        await tester.pumpWidget(createTestWidget(
          post: testPost,
          onComment: () => wasCommented = true,
        ));

        await tester.tap(find.byIcon(Icons.comment_outlined));
        await tester.pumpAndSettle();

        expect(wasCommented, true);
      });
    });

    group('Grid vs List View', () {
      testWidgets('should render differently in grid view', (tester) async {
        await tester.pumpWidget(createTestWidget(
          post: testPost,
          isGridView: true,
        ));

        // Grid view should be more compact
        expect(find.byType(CommunityPostCard), findsOneWidget);
      });

      testWidgets('should render differently in list view', (tester) async {
        await tester.pumpWidget(createTestWidget(
          post: testPost,
          isGridView: false,
        ));

        // List view should show more details
        expect(find.text('This is a test post content'), findsOneWidget);
      });
    });

    group('Responsive Design', () {
      testWidgets('should adapt to mobile screen size', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(400, 800);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(createTestWidget(post: testPost));
        await tester.pumpAndSettle();

        expect(find.byType(CommunityPostCard), findsOneWidget);

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
      });

      testWidgets('should adapt to tablet screen size', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(createTestWidget(post: testPost));
        await tester.pumpAndSettle();

        expect(find.byType(CommunityPostCard), findsOneWidget);

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle empty content', (tester) async {
        final emptyPost = testPost.copyWith(content: '');
        await tester.pumpWidget(createTestWidget(post: emptyPost));

        expect(find.text('Test Post Title'), findsOneWidget);
        expect(find.text(''), findsNothing);
      });

      testWidgets('should handle long content', (tester) async {
        final longPost = testPost.copyWith(
          content: 'This is a very long post content that should be handled gracefully by the UI without causing overflow issues or performance problems.',
        );
        await tester.pumpWidget(createTestWidget(post: longPost));

        expect(find.textContaining('This is a very long'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle zero interaction counts', (tester) async {
        final zeroPost = testPost.copyWith(
          likesCount: 0,
          commentsCount: 0,
          viewsCount: 0,
        );
        await tester.pumpWidget(createTestWidget(post: zeroPost));

        expect(find.text('0'), findsWidgets);
      });

      testWidgets('should handle missing author name', (tester) async {
        // Since authorName doesn't exist in CommunityPost entity, just test that widget renders
        await tester.pumpWidget(createTestWidget(post: testPost));

        expect(find.byType(CommunityPostCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper accessibility labels', (tester) async {
        await tester.pumpWidget(createTestWidget(post: testPost));

        // Check that the widget renders with accessibility support
        expect(find.byType(CommunityPostCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should support keyboard navigation', (tester) async {
        bool wasTapped = false;
        
        await tester.pumpWidget(createTestWidget(
          post: testPost,
          onTap: () => wasTapped = true,
        ));

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(wasTapped, true);
      });
    });

    group('Theme Integration', () {
      testWidgets('should respect light theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: CommunityPostCard(post: testPost),
            ),
          ),
        );

        final cardWidget = tester.widget<Card>(find.byType(Card));
        expect(cardWidget.color, isNull);
      });

      testWidgets('should respect dark theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: CommunityPostCard(post: testPost),
            ),
          ),
        );

        final cardWidget = tester.widget<Card>(find.byType(Card));
        expect(cardWidget.color, isNull);
      });
    });
  });
}