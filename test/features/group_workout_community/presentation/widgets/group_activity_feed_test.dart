import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_activity.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/group_activity_feed.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group_activity/group_activity_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group_activity/group_activity_state.dart';
import 'package:jfit/core/error/bloc_errors.dart';

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
          activityType: GroupActivityType.workoutCompleted,
          activityData: {
            'workoutName': 'Push Day',
            'userName': 'John Doe',
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
          activityType: GroupActivityType.routineShared,
          activityData: {
            'routineName': 'Full Body Workout',
            'description': 'Great for beginners',
            'userName': 'Jane Smith',
          },
          createdAt: DateTime(2024, 1, 2),
          mentionedUserIds: [],
        ),
        GroupActivity(
          id: 'activity-3',
          groupId: 'group-1',
          userId: 'user-3',
          activityType: GroupActivityType.encouragementSent,
          activityData: {
            'message': 'Keep up the great work!',
            'targetUserId': 'user-1',
            'userName': 'Bob Wilson',
          },
          createdAt: DateTime(2024, 1, 3),
          mentionedUserIds: ['user-1'],
        ),
      ];

      when(mockBloc.state).thenReturn(const GroupActivityInitial());
      when(mockBloc.stream).thenAnswer((_) => const Stream.empty());
    });

    group('Basic Display', () {
      testWidgets('should display activities when loaded', (tester) async {
        when(mockBloc.state).thenReturn(GroupActivitiesLoaded(
          groupId: 'group-1',
          activities: testActivities,
          hasMore: false,
          loadedAt: DateTime.now(),
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<GroupActivityBloc>(
              create: (_) => mockBloc,
              child: const GroupActivityFeed(groupId: 'group-1'),
            ),
          ),
        );

        expect(find.byType(GroupActivityFeed), findsOneWidget);
      });

      testWidgets('should display empty state when no activities', (tester) async {
        when(mockBloc.state).thenReturn(GroupActivitiesLoaded(
          groupId: 'group-1',
          activities: const [],
          hasMore: false,
          loadedAt: DateTime.now(),
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<GroupActivityBloc>(
              create: (_) => mockBloc,
              child: const GroupActivityFeed(groupId: 'group-1'),
            ),
          ),
        );

        expect(find.byType(GroupActivityFeed), findsOneWidget);
      });

      testWidgets('should display loading state', (tester) async {
        when(mockBloc.state).thenReturn(const GroupActivityLoading());

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<GroupActivityBloc>(
              create: (_) => mockBloc,
              child: const GroupActivityFeed(groupId: 'group-1'),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should display error state', (tester) async {
        when(mockBloc.state).thenReturn(const GroupActivityErrorState(
          GroupActivityError('Test error'),
          isRetryable: true,
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<GroupActivityBloc>(
              create: (_) => mockBloc,
              child: const GroupActivityFeed(groupId: 'group-1'),
            ),
          ),
        );

        expect(find.byType(GroupActivityFeed), findsOneWidget);
      });
    });

    group('Activity Types', () {
      testWidgets('should display workout completion activity correctly', (tester) async {
        final workoutActivity = [testActivities[0]];
        when(mockBloc.state).thenReturn(GroupActivitiesLoaded(
          groupId: 'group-1',
          activities: workoutActivity,
          hasMore: false,
          loadedAt: DateTime.now(),
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<GroupActivityBloc>(
              create: (_) => mockBloc,
              child: const GroupActivityFeed(groupId: 'group-1'),
            ),
          ),
        );

        expect(find.byType(GroupActivityFeed), findsOneWidget);
      });

      testWidgets('should display routine sharing activity correctly', (tester) async {
        final routineActivity = [testActivities[1]];
        when(mockBloc.state).thenReturn(GroupActivitiesLoaded(
          groupId: 'group-1',
          activities: routineActivity,
          hasMore: false,
          loadedAt: DateTime.now(),
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<GroupActivityBloc>(
              create: (_) => mockBloc,
              child: const GroupActivityFeed(groupId: 'group-1'),
            ),
          ),
        );

        expect(find.byType(GroupActivityFeed), findsOneWidget);
      });

      testWidgets('should display encouragement activity correctly', (tester) async {
        final encouragementActivity = [testActivities[2]];
        when(mockBloc.state).thenReturn(GroupActivitiesLoaded(
          groupId: 'group-1',
          activities: encouragementActivity,
          hasMore: false,
          loadedAt: DateTime.now(),
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<GroupActivityBloc>(
              create: (_) => mockBloc,
              child: const GroupActivityFeed(groupId: 'group-1'),
            ),
          ),
        );

        expect(find.byType(GroupActivityFeed), findsOneWidget);
      });
    });
  });
}