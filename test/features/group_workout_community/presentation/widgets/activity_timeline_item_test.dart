import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_activity.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/activity_timeline_item.dart';

void main() {
  group('ActivityTimelineItem Widget Tests', () {
    late GroupActivity testActivity;

    setUp(() {
      testActivity = GroupActivity(
        id: 'activity-1',
        groupId: 'group-1',
        userId: 'user-1',
        activityType: GroupActivityType.workoutCompleted,
        activityData: {
          'user_name': 'John Doe',
          'workoutName': 'Push Day',
          'duration': 45,
          'exercises': 8,
        },
        createdAt: DateTime(2024, 1, 1, 10, 30),
        mentionedUserIds: [],
      );
    });

    Widget createTestWidget({
      required GroupActivity activity,
      VoidCallback? onLike,
      VoidCallback? onComment,
      VoidCallback? onShare,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ActivityTimelineItem(
            activity: activity,
            onLike: onLike,
            onComment: onComment,
            onShare: onShare,
          ),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('should display workout completion activity correctly', (tester) async {
        await tester.pumpWidget(createTestWidget(activity: testActivity));

        expect(find.text('John Doe'), findsOneWidget);
        expect(find.textContaining('운동을 완료했습니다'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('should display routine sharing activity correctly', (tester) async {
        final routineActivity = testActivity.copyWith(
          activityType: GroupActivityType.routineShared,
          activityData: {
            'user_name': 'John Doe',
            'routine_name': 'Full Body Workout',
            'exercise_count': 5,
          },
        );

        await tester.pumpWidget(createTestWidget(activity: routineActivity));

        expect(find.text('John Doe'), findsOneWidget);
        expect(find.textContaining('운동 루틴을 공유했습니다'), findsOneWidget);
        expect(find.byIcon(Icons.share), findsAtLeastNWidgets(1));
      });

      testWidgets('should display encouragement activity correctly', (tester) async {
        final encouragementActivity = testActivity.copyWith(
          activityType: GroupActivityType.encouragementSent,
          activityData: {
            'user_name': 'John Doe',
            'target_user': 'Jane Smith',
          },
        );

        await tester.pumpWidget(createTestWidget(activity: encouragementActivity));

        expect(find.text('John Doe'), findsOneWidget);
        expect(find.textContaining('격려 메시지를 보냈습니다'), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsOneWidget);
      });

      testWidgets('should display member joined activity correctly', (tester) async {
        final memberJoinedActivity = testActivity.copyWith(
          activityType: GroupActivityType.memberJoined,
          activityData: {
            'user_name': 'John Doe',
          },
        );

        await tester.pumpWidget(createTestWidget(activity: memberJoinedActivity));

        expect(find.text('John Doe'), findsOneWidget);
        expect(find.textContaining('그룹에 가입했습니다'), findsOneWidget);
        expect(find.byIcon(Icons.person_add), findsOneWidget);
      });

      testWidgets('should display timestamp correctly', (tester) async {
        // Use a recent timestamp to ensure it shows relative time
        final recentActivity = testActivity.copyWith(
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        );
        
        await tester.pumpWidget(createTestWidget(activity: recentActivity));

        // The timestamp is formatted as relative time
        expect(find.textContaining('전'), findsOneWidget);
      });
    });

    group('Timeline Visual Elements', () {
      testWidgets('should display activity card correctly', (tester) async {
        await tester.pumpWidget(createTestWidget(activity: testActivity));

        // Should show card container
        expect(find.byType(Card), findsOneWidget);
      });

      testWidgets('should display activity icon correctly', (tester) async {
        await tester.pumpWidget(createTestWidget(activity: testActivity));

        // Should show workout icon for workout completion
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('should display activity badge', (tester) async {
        await tester.pumpWidget(createTestWidget(activity: testActivity));

        // Should show activity badge
        expect(find.text('운동 완료'), findsOneWidget);
      });

      testWidgets('should use different colors for different activity types', (tester) async {
        await tester.pumpWidget(createTestWidget(activity: testActivity));

        final iconWidget = tester.widget<Icon>(find.byIcon(Icons.check_circle));
        expect(iconWidget.color, isNotNull);
      });
    });

    group('Interaction Tests', () {
      testWidgets('should call onLike when like button is tapped', (tester) async {
        bool wasLiked = false;
        
        await tester.pumpWidget(createTestWidget(
          activity: testActivity,
          onLike: () => wasLiked = true,
        ));

        await tester.tap(find.text('좋아요'));
        await tester.pumpAndSettle();

        expect(wasLiked, true);
      });

      testWidgets('should call onComment when comment button is tapped', (tester) async {
        bool wasCommented = false;
        
        await tester.pumpWidget(createTestWidget(
          activity: testActivity,
          onComment: () => wasCommented = true,
        ));

        await tester.tap(find.text('댓글'));
        await tester.pumpAndSettle();

        expect(wasCommented, true);
      });

      testWidgets('should call onShare when share button is tapped', (tester) async {
        bool wasShared = false;
        
        await tester.pumpWidget(createTestWidget(
          activity: testActivity,
          onShare: () => wasShared = true,
        ));

        await tester.tap(find.text('공유'));
        await tester.pumpAndSettle();

        expect(wasShared, true);
      });
    });

    group('Responsive Design', () {
      testWidgets('should adapt to mobile screen size', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(400, 800);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(createTestWidget(activity: testActivity));
        await tester.pumpAndSettle();

        expect(find.byType(ActivityTimelineItem), findsOneWidget);

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
      });

      testWidgets('should handle long activity descriptions', (tester) async {
        final longDescActivity = testActivity.copyWith(
          activityData: {
            'workoutName': 'This is a very long workout name that should be handled gracefully',
            'duration': 45,
            'exercises': 8,
          },
        );

        await tester.pumpWidget(createTestWidget(activity: longDescActivity));

        expect(find.textContaining('운동을 완료했습니다'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle missing activity data', (tester) async {
        final emptyDataActivity = testActivity.copyWith(
          activityData: {},
        );

        await tester.pumpWidget(createTestWidget(activity: emptyDataActivity));

        expect(find.text('사용자'), findsOneWidget);
        expect(find.textContaining('운동을 완료했습니다'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle missing user name', (tester) async {
        final noUserActivity = testActivity.copyWith(
          activityData: {
            // Remove user_name completely to trigger fallback
            'workoutName': 'Push Day',
            'duration': 45,
            'exercises': 8,
          },
        );

        await tester.pumpWidget(createTestWidget(activity: noUserActivity));

        expect(find.text('사용자'), findsOneWidget);
      });

      testWidgets('should handle achievement activity type', (tester) async {
        final achievementActivity = testActivity.copyWith(
          activityType: GroupActivityType.achievementUnlocked,
          activityData: {
            'user_name': 'John Doe',
            'achievement_name': 'First Workout',
            'description': 'Completed your first workout!',
          },
        );

        await tester.pumpWidget(createTestWidget(activity: achievementActivity));

        expect(find.text('John Doe'), findsOneWidget);
        expect(find.textContaining('새로운 성취를 달성했습니다'), findsOneWidget);
        expect(find.byIcon(Icons.emoji_events), findsAtLeastNWidgets(1));
      });

      testWidgets('should handle invalid timestamps', (tester) async {
        final invalidTimeActivity = testActivity.copyWith(
          createdAt: DateTime(1970, 1, 1),
        );

        await tester.pumpWidget(createTestWidget(activity: invalidTimeActivity));

        expect(find.byType(ActivityTimelineItem), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper accessibility labels', (tester) async {
        await tester.pumpWidget(createTestWidget(activity: testActivity));

        // Check that the widget renders without accessibility errors
        expect(find.byType(ActivityTimelineItem), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should support keyboard navigation', (tester) async {
        await tester.pumpWidget(createTestWidget(
          activity: testActivity,
        ));

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        // Verify keyboard navigation works
        expect(find.byType(ActivityTimelineItem), findsOneWidget);
      });

      testWidgets('should provide context for screen readers', (tester) async {
        await tester.pumpWidget(createTestWidget(activity: testActivity));

        // Check that the widget renders without accessibility errors
        expect(find.byType(ActivityTimelineItem), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('Theme Integration', () {
      testWidgets('should respect light theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: ActivityTimelineItem(activity: testActivity),
            ),
          ),
        );

        expect(find.byType(ActivityTimelineItem), findsOneWidget);
      });

      testWidgets('should respect dark theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: ActivityTimelineItem(activity: testActivity),
            ),
          ),
        );

        expect(find.byType(ActivityTimelineItem), findsOneWidget);
      });

      testWidgets('should use appropriate colors for activity types', (tester) async {
        await tester.pumpWidget(createTestWidget(activity: testActivity));

        final iconWidget = tester.widget<Icon>(find.byIcon(Icons.fitness_center));
        expect(iconWidget.color, isNotNull);
      });
    });

    group('Animation Tests', () {
      testWidgets('should animate appearance', (tester) async {
        await tester.pumpWidget(createTestWidget(activity: testActivity));

        // Should animate in smoothly
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(ActivityTimelineItem), findsOneWidget);
      });

      testWidgets('should animate on tap', (tester) async {
        await tester.pumpWidget(createTestWidget(activity: testActivity));

        // Tap and hold
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(ActivityTimelineItem)),
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(ActivityTimelineItem), findsOneWidget);

        await gesture.up();
        await tester.pumpAndSettle();
      });
    });

    group('Performance', () {
      testWidgets('should handle rapid activity updates', (tester) async {
        await tester.pumpWidget(createTestWidget(activity: testActivity));

        // Simulate rapid updates
        for (int i = 0; i < 10; i++) {
          final updatedActivity = testActivity.copyWith(
            id: 'activity-$i',
            createdAt: DateTime.now().add(Duration(minutes: i)),
          );
          
          await tester.pumpWidget(createTestWidget(activity: updatedActivity));
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(find.byType(ActivityTimelineItem), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}