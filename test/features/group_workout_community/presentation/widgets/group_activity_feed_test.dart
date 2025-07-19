import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_activity.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/group_activity_feed.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group_activity/group_activity_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group_activity/group_activity_state.dart';

import 'group_activity_feed_test.mocks.dart';

@GenerateMocks([GroupActivityBloc])
void main() {
  group('GroupActivityFeed Tests', () {
    late MockGroupActivityBloc mockBloc;
    late List<GroupActivity> testActivities;

    setUp(() {
      mockBloc = MockGroupActivityBloc();
      
      testActivities = [
        GroupActivity(
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
          createdAt: DateTime(2024, 1, 1),
          mentionedUserIds: [],
        ),
        GroupActivity(
          id: 'activity-2',
          groupId: 'group-1',
          userId: 'user-2',
          userName: 'Jane Smith',
          activityType: GroupActivityType.routineShared,
          activityData: {
            'routineName': 'Full Body Workout',
            'description': 'Great for beginners',
          },
          createdAt: DateTime(2024, 1, 2),
          mentionedUserIds: [],
        ),
        GroupActivity(
          id: 'activity-3',
          groupId: 'group-1',
          userId: 'user-3',
          userName: 'Bob Wilson',
          activityType: GroupActivityType.encouragementSent,
          activityData: {
            'message': 'Keep up the great work!',
            'targetUserId': 'user-1',
          },
          createdAt: DateTime(2024, 1, 3),
          mentionedUserIds: ['user-1'],
        ),
      ];

      when(mockBloc.state).thenReturn(const GroupActivityInitial());
      when(mockBloc.stream).thenAnswer((_) => const Stream.empty());
    });

    Widget createTestWidget({
      String groupId = 'group-1',
    }) {
      return MaterialApp(
        home: BlocProvider<GroupActivityBloc>(
          create: (_) => mockBloc,
          child: Scaffold(
            body: GroupActivityFeed(
              groupId: groupId,
            ),
          ),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('should display loading state initially', (tester) async {
        when(mockBloc.state).thenReturn(const GroupActivityLoading());

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should display activities when loaded', (tester) async {
        when(mockBloc.state).thenReturn(GroupActivityLoaded(
          activities: testActivities,
          hasMore: false,
        ));

        await tester.pumpWidget(createTestWidget());

        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('Jane Smith'), findsOneWidget);
        expect(find.text('Bob Wilson'), findsOneWidget);
      });

      testWidgets('should display empty state when no activities', (tester) async {
        when(mockBloc.state).thenReturn(const GroupActivityLoaded(
          activities: [],
          hasMore: false,
        ));

        await tester.pumpWidget(createTestWidget());

        expect(find.text('No activities yet'), findsOneWidget);
        expect(find.text('Be the first to share a workout!'), findsOneWidget);
      });

      testWidgets('should display error state', (tester) async {
        when(mockBloc.state).thenReturn(const GroupActivityError(
          message: 'Failed to load activities',
        ));

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Failed to load activities'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });
    });

    group('Activity Types', () {
      testWidgets('should display workout completion activity correctly', (tester) async {
        final workoutActivity = [testActivities[0]];
        when(mockBloc.state).thenReturn(GroupActivityLoaded(
          activities: workoutActivity,
          hasMore: false,
        ));

        await tester.pumpWidget(createTestWidget());

        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('completed a workout'), findsOneWidget);
        expect(find.text('Push Day'), findsOneWidget);
        expect(find.text('45 min'), findsOneWidget);
        expect(find.text('8 exercises'), findsOneWidget);
      });

      testWidgets('should display routine sharing activity correctly', (tester) async {
        final routineActivity = [testActivities[1]];
        when(mockBloc.state).thenReturn(GroupActivityLoaded(
          activities: routineActivity,
          hasMore: false,
        ));

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Jane Smith'), findsOneWidget);
        expect(find.text('shared a routine'), findsOneWidget);
        expect(find.text('Full Body Workout'), findsOneWidget);
        expect(find.text('Great for beginners'), findsOneWidget);
      });

      testWidgets('should display encouragement activity correctly', (tester) async {
        final encouragementActivity = [testActivities[2]];
        when(mockBloc.state).thenReturn(GroupActivityLoaded(
          activities: encouragementActivity,
          hasMore: false,
        ));

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Bob Wilson'), findsOneWidget);
        expect(find.text('sent encouragement'), findsOneWidget);
        expect(find.text('Keep up the great work!'), findsOneWidget);
      });
    });

    group('Infinite Scroll', () {
      testWidgets('should load more activities when scrolled to bottom', (tester) async {
        when(mockBloc.state).thenReturn(GroupActivityLoaded(
          activities: testActivities,
          hasMore: true,
        ));

        await tester.pumpWidget(createTestWidget());

        // Scroll to bottom
        await tester.drag(
          find.byType(ListView),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();

        // Should trigger load more
        verify(mockBloc.add(any)).called(greaterThan(1));
      });

      testWidgets('should show loading indicator when loading more', (tester) async {
        when(mockBloc.state).thenReturn(GroupActivityLoaded(
          activities: testActivities,
          hasMore: true,
          isLoadingMore: true,
        ));

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should not load more when hasMore is false', (tester) async {
        when(mockBloc.state).thenReturn(GroupActivityLoaded(
          activities: testActivities,
          hasMore: false,
        ));

        await tester.pumpWidget(createTestWidget());

        // Scroll to bottom
        await tester.drag(
          find.byType(ListView),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();

        // Should not show loading indicator
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    group('Pull to Refresh', () {
      testWidgets('should refresh activities when pulled down', (tester) async {
        when(mockBloc.state).thenReturn(GroupActivityLoaded(
          activities: testActivities,
          hasMore: false,
        ));

        await tester.pumpWidget(createTestWidget());

        // Pull to refresh
        await tester.drag(
          find.byType(RefreshIndicator),
          const Offset(0, 300),
        );
        await tester.pumpAndSettle();

        // Should trigger refresh
        verify(mockBloc.add(any)).called(greaterThan(1));
      });

      testWidgets('should show refresh indicator during refresh', (tester) async {
        when(mockBloc.state).thenReturn(const GroupActivityLoading());

        await tester.pumpWidget(createTestWidget());

        // Pull to refresh
        await tester.drag(
          find.byType(RefreshIndicator),
          const Offset(0, 300),
        );
        await tester.pump();

        expect(find.byType(RefreshIndicator), findsOneWidget);
      });
    });

    group('Responsive Design', () {
      testWidgets('should adapt to mobile screen size', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(400, 800);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        when(mockBloc.state).thenReturn(GroupActivityLoaded(
          activities: testActivities,
          hasMore: false,
        ));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(GroupActivityFeed), findsOneWidget);

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
      });

      testWidgets('should adapt to tablet screen size', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        when(mockBloc.state).thenReturn(GroupActivityLoaded(
          activities: testActivities,
          hasMore: false,
        ));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(GroupActivityFeed), findsOneWidget);

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
      });
    });

    group('Error Handling', () {
      testWidgets('should handle retry button tap', (tester) async {
        when(mockBloc.state).thenReturn(const GroupActivityError(
          message: 'Network error',
        ));

        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        verify(mockBloc.add(any)).called(greaterThan(0));
      });

      testWidgets('should handle network errors gracefully', (tester) async {
        when(mockBloc.state).thenReturn(const GroupActivityError(
          message: 'No internet connection',
        ));

        await tester.pumpWidget(createTestWidget());

        expect(find.text('No internet connection'), findsOneWidget);
        expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      });
    });

    group('Real-time Updates', () {
      testWidgets('should handle real-time activity updates', (tester) async {
        when(mockBloc.state).thenReturn(GroupActivityLoaded(
          activities: testActivities,
          hasMore: false,
        ));

        await tester.pumpWidget(createTestWidget());

        // Simulate new activity added
        final updatedActivities = [
          GroupActivity(
            id: 'activity-4',
            groupId: 'group-1',
            userId: 'user-4',
            userName: 'Alice Johnson',
            activityType: GroupActivityType.memberJoined,
            activityData: {'welcomeMessage': 'Welcome to the group!'},
            createdAt: DateTime.now(),
            mentionedUserIds: [],
          ),
          ...testActivities,
        ];

        when(mockBloc.state).thenReturn(GroupActivityLoaded(
          activities: updatedActivities,
          hasMore: false,
        ));

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Alice Johnson'), findsOneWidget);
        expect(find.text('joined the group'), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper accessibility labels', (tester) async {
        when(mockBloc.state).thenReturn(GroupActivityLoaded(
          activities: testActivities,
          hasMore: false,
        ));

        await tester.pumpWidget(createTestWidget());

        expect(
          find.bySemanticsLabel('Group activity feed'),
          findsOneWidget,
        );
        
        expect(
          find.bySemanticsLabel('Refresh activities'),
          findsOneWidget,
        );
      });

      testWidgets('should support keyboard navigation', (tester) async {
        when(mockBloc.state).thenReturn(GroupActivityLoaded(
          activities: testActivities,
          hasMore: false,
        ));

        await tester.pumpWidget(createTestWidget());

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        expect(find.byType(GroupActivityFeed), findsOneWidget);
      });
    });

    group('Performance', () {
      testWidgets('should handle large number of activities', (tester) async {
        final largeActivityList = List.generate(100, (index) => 
          GroupActivity(
            id: 'activity-$index',
            groupId: 'group-1',
            userId: 'user-$index',
            userName: 'User $index',
            activityType: GroupActivityType.workoutCompleted,
            activityData: {'workoutName': 'Workout $index'},
            createdAt: DateTime.now().subtract(Duration(days: index)),
            mentionedUserIds: [],
          ),
        );

        when(mockBloc.state).thenReturn(GroupActivityLoaded(
          activities: largeActivityList,
          hasMore: false,
        ));

        await tester.pumpWidget(createTestWidget());

        // Should render without performance issues
        expect(find.byType(GroupActivityFeed), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}