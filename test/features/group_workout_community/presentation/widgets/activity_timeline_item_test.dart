import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_activity.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/activity_timeline_item.dart';

void main() {
  group('ActivityTimelineItem Widget Tests', () {
    late GroupActivity testActivity;

    setUp(() {
      testActivity = GroupActivity(
        id: 'activity-1',
        groupId: 'group-1',
        userId: 'user-1',
        userName: 'John Doe',
        activityType: GroupActivityType.workoutCompleted,
        activityData: {
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
      VoidCallback? onTap,
      bool isLast = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ActivityTimelineItem(
            activity: activity,
            onTap: onTap,
            isLast: isLast,
          ),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('should display workout completion activity correctly', (tester) async {
        await tester.pumpWidget(createTestWidget(activity: testActivity));

        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('completed a workout'), findsOneWidget);
        expect(find.text('Push Day'), findsOneWidget);
        expect(find.text('45 min'), findsOneWidget);
        expect(find.text('8 exercises'), findsOneWidget);
        expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      });

      testWidgets('should display routine sharing activity correctly', (tester) async {
        final routineActivity = testActivity.copyWith(
          activityType: GroupActivityType.routineShared,
          activityData: {
            'routineName': 'Full Body Workout',
            'description': 'Great for beginners',
          },
        );

        await tester.pumpWidget(createTestWidget(activity: routineActivity));

        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('shared a routine'), findsOneWidget);
        expect(find.text('Full Body Workout'), findsOneWidget);
        expect(find.text('Great for beginners'), findsOneWidget);
        expect(find.byIcon(Icons.share), findsOneWidget);
      });

      testWidgets('should display encouragement activity correctly', (tester) async {
        final encouragementActivity = testActivity.copyWith(
          activityType: GroupActivityType.encouragementSent,
          activityData: {
            'message': 'Keep up the great work!',
            'targetUserId': 'user-2',
            'targetUserName': 'Jane Smith',
          },
        );

        await tester.pumpWidget(createTestWidget(activity: encouragementActivity));

        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('sent encouragement to Jane Smith'), findsOneWidget);
        expect(find.text('Keep up the great work!'), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsOneWidget);
      });

      testWidgets('should display member joined activity correctly', (tester) async {
        final memberJoinedActivity = testActivity.copyWith(
          activityType: GroupActivityType.memberJoined,
          activityData: {
            'welcomeMessage': 'Welcome to the group!',
          },
        );

        await tester.pumpWidget(createTestWidget(activity: memberJoinedActivity));

        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('joined the group'), findsOneWidget);
        expect(find.text('Welcome to the group!'), findsOneWidget);
        expect(find.byIcon(Icons.person_add), findsOneWidget);
      });

      testWidgets('should display timestamp correctly', (tester) async {
        await tester.pumpWidget(createTestWidget(activity: testActivity));

        expect(find.text('10:30'), findsOneWidget);
      });
    });

    group('Timeline Visual Elements', () {
      testWidgets('should show timeline connector when not last item', (tester) async {
        await tester.pumpWidget(createTestWidget(
          activity: testActivity,
          isLast: false,
        ));

        // Should show connecting line to next item
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('should not show timeline connector when last item', (tester) async {
        await tester.pumpWidget(createTestWidget(
          activity: testActivity,
          isLast: true,
        ));

        // Timeline should end here
        expect(find.byType(ActivityTimelineItem), findsOneWidget);
      });

      testWidgets('should display activity icon correctly', (tester) async {
        await tester.pumpWidget(createTestWidget(activity: testActivity));

        // Should show workout icon for workout completion
        expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      });

      testWidgets('should use different colors for different activity types', (tester) async {
        await tester.pumpWidget(createTestWidget(activity: testActivity));

        final iconContainer = tester.widget<Container>(
          find.ancestor(
            of: find.byIcon(Icons.fitness_center),
            matching: find.byType(Container),
          ).first,
        );

        expect(iconContainer.decoration, isA<BoxDecoration>());
      });
    });

    group('Interaction Tests', () {
      testWidgets('should call onTap when activity is tapped', (tester) async {
        bool wasTapped = false;
        
        await tester.pumpWidget(createTestWidget(
          activity: testActivity,
          onTap: () => wasTapped = true,
        ));

        await tester.tap(find.byType(ActivityTimelineItem));
        await tester.pumpAndSettle();

        expect(wasTapped, true);
      });

      testWidgets('should not crash when onTap is null', (tester) async {
        await tester.pumpWidget(createTestWidget(activity: testActivity));

        await tester.tap(find.byType(ActivityTimelineItem));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
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

        expect(find.textContaining('This is a very long'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle missing activity data', (tester) async {
        final emptyDataActivity = testActivity.copyWith(
          activityData: {},
        );

        await tester.pumpWidget(createTestWidget(activity: emptyDataActivity));

        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('completed a workout'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle missing user name', (tester) async {
        final noUserActivity = testActivity.copyWith(
          userName: '',
        );

        await tester.pumpWidget(createTestWidget(activity: noUserActivity));

        expect(find.text('Anonymous'), findsOneWidget);
      });

      testWidgets('should handle unknown activity type', (tester) async {
        final unknownActivity = testActivity.copyWith(
          activityType: GroupActivityType.other,
          activityData: {'message': 'Unknown activity'},
        );

        await tester.pumpWidget(createTestWidget(activity: unknownActivity));

        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('performed an activity'), findsOneWidget);
        expect(find.byIcon(Icons.info), findsOneWidget);
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

        expect(
          find.bySemanticsLabel('Activity: John Doe completed a workout Push Day at 10:30'),
          findsOneWidget,
        );
      });

      testWidgets('should support keyboard navigation', (tester) async {
        bool wasTapped = false;
        
        await tester.pumpWidget(createTestWidget(
          activity: testActivity,
          onTap: () => wasTapped = true,
        ));

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(wasTapped, true);
      });

      testWidgets('should provide context for screen readers', (tester) async {
        await tester.pumpWidget(createTestWidget(activity: testActivity));

        expect(
          find.bySemanticsLabel('Workout completed'),
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