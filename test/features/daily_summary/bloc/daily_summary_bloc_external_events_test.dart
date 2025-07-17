import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/core/bloc/bloc_event_bus.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/features/daily_summary/bloc/daily_summary_bloc.dart';
import 'package:jfit/features/daily_summary/bloc/daily_summary_state.dart';
import 'package:jfit/features/daily_summary/data/repositories/daily_summary_repository.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'daily_summary_bloc_test.mocks.dart';

@GenerateMocks([DailySummaryRepository])
void main() {
  group('DailySummaryBloc External Events', () {
    late DailySummaryBloc bloc;
    late MockDailySummaryRepository mockRepository;

    setUp(() {
      mockRepository = MockDailySummaryRepository();
      bloc = DailySummaryBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    group('Meal Record Change Events', () {
      blocTest<DailySummaryBloc, DailySummaryState>(
        'should handle MealRecordChangedEvent with added meal',
        build: () {
          const userId = 'test-user-id';
          final date = DateTime(2024, 1, 15);
          final updatedSummary = UserDailySummary(
            id: 'test-id',
            userId: userId,
            summaryDate: date,
            totalCaloriesConsumed: 2200.0,
            totalProteinConsumed: 160.0,
            totalCarbsConsumed: 260.0,
            totalFatConsumed: 85.0,
            totalWorkoutDurationMinutes: 60,
            totalCaloriesBurned: 400,
          );

          when(mockRepository.calculateAndUpdateDailySummary(userId, date))
              .thenAnswer((_) async => Right(updatedSummary));

          return bloc;
        },
        act: (bloc) {
          final event = MealRecordChangedEvent(
            userId: 'test-user-id',
            date: DateTime(2024, 1, 15),
            changeType: MealChangeType.added,
            recordId: 'meal-123',
          );
          bloc.handleCommunicationEvent(event);
        },
        expect: () => [
          isA<DailySummaryUpdated>()
              .having((state) => state.summary.totalCaloriesConsumed, 'calories', 2200.0)
              .having((state) => state.updateReason, 'reason', 'Meal data changed'),
        ],
      );

      blocTest<DailySummaryBloc, DailySummaryState>(
        'should handle MealRecordChangedEvent with updated meal',
        build: () {
          const userId = 'test-user-id';
          final date = DateTime(2024, 1, 15);
          final updatedSummary = UserDailySummary(
            id: 'test-id',
            userId: userId,
            summaryDate: date,
            totalCaloriesConsumed: 1950.0, // Reduced calories
            totalProteinConsumed: 145.0,
            totalCarbsConsumed: 240.0,
            totalFatConsumed: 75.0,
            totalWorkoutDurationMinutes: 60,
            totalCaloriesBurned: 400,
          );

          when(mockRepository.calculateAndUpdateDailySummary(userId, date))
              .thenAnswer((_) async => Right(updatedSummary));

          return bloc;
        },
        act: (bloc) {
          final event = MealRecordChangedEvent(
            userId: 'test-user-id',
            date: DateTime(2024, 1, 15),
            changeType: MealChangeType.updated,
            recordId: 'meal-123',
          );
          bloc.handleCommunicationEvent(event);
        },
        expect: () => [
          isA<DailySummaryUpdated>()
              .having((state) => state.summary.totalCaloriesConsumed, 'calories', 1950.0)
              .having((state) => state.updateReason, 'reason', 'Meal data changed'),
        ],
      );

      blocTest<DailySummaryBloc, DailySummaryState>(
        'should handle MealRecordChangedEvent with deleted meal',
        build: () {
          const userId = 'test-user-id';
          final date = DateTime(2024, 1, 15);
          final updatedSummary = UserDailySummary(
            id: 'test-id',
            userId: userId,
            summaryDate: date,
            totalCaloriesConsumed: 1800.0, // Reduced calories after deletion
            totalProteinConsumed: 130.0,
            totalCarbsConsumed: 220.0,
            totalFatConsumed: 70.0,
            totalWorkoutDurationMinutes: 60,
            totalCaloriesBurned: 400,
          );

          when(mockRepository.calculateAndUpdateDailySummary(userId, date))
              .thenAnswer((_) async => Right(updatedSummary));

          return bloc;
        },
        act: (bloc) {
          final event = MealRecordChangedEvent(
            userId: 'test-user-id',
            date: DateTime(2024, 1, 15),
            changeType: MealChangeType.deleted,
            recordId: 'meal-123',
          );
          bloc.handleCommunicationEvent(event);
        },
        expect: () => [
          isA<DailySummaryUpdated>()
              .having((state) => state.summary.totalCaloriesConsumed, 'calories', 1800.0)
              .having((state) => state.updateReason, 'reason', 'Meal data changed'),
        ],
      );

      blocTest<DailySummaryBloc, DailySummaryState>(
        'should handle meal change event error gracefully',
        build: () {
          when(mockRepository.calculateAndUpdateDailySummary(any, any))
              .thenAnswer((_) async => Left(DatabaseFailure('Database error')));
          return bloc;
        },
        act: (bloc) {
          final event = MealRecordChangedEvent(
            userId: 'test-user-id',
            date: DateTime(2024, 1, 15),
            changeType: MealChangeType.added,
            recordId: 'meal-123',
          );
          bloc.handleCommunicationEvent(event);
        },
        expect: () => [
          isA<DailySummaryError>()
              .having((state) => state.message, 'message', 'Database error')
              .having((state) => state.operation, 'operation', 'auto_update'),
        ],
      );
    });

    group('Workout Session Completed Events', () {
      blocTest<DailySummaryBloc, DailySummaryState>(
        'should handle WorkoutSessionCompletedEvent',
        build: () {
          const userId = 'test-user-id';
          final date = DateTime(2024, 1, 15);
          final updatedSummary = UserDailySummary(
            id: 'test-id',
            userId: userId,
            summaryDate: date,
            totalCaloriesConsumed: 2000.0,
            totalProteinConsumed: 150.0,
            totalCarbsConsumed: 250.0,
            totalFatConsumed: 80.0,
            totalWorkoutDurationMinutes: 90, // Increased workout time
            totalCaloriesBurned: 500, // Increased calories burned
          );

          when(mockRepository.calculateAndUpdateDailySummary(userId, date))
              .thenAnswer((_) async => Right(updatedSummary));

          return bloc;
        },
        act: (bloc) {
          final event = WorkoutSessionCompletedEvent(
            userId: 'test-user-id',
            date: DateTime(2024, 1, 15),
            sessionId: 'session-123',
            userProgramId: 'program-456',
          );
          bloc.handleCommunicationEvent(event);
        },
        expect: () => [
          isA<DailySummaryUpdated>()
              .having((state) => state.summary.totalWorkoutDurationMinutes, 'duration', 90)
              .having((state) => state.summary.totalCaloriesBurned, 'burned', 500)
              .having((state) => state.updateReason, 'reason', 'Workout data changed'),
        ],
      );

      blocTest<DailySummaryBloc, DailySummaryState>(
        'should handle workout session completed event error gracefully',
        build: () {
          when(mockRepository.calculateAndUpdateDailySummary(any, any))
              .thenAnswer((_) async => Left(ServerFailure('Server error')));
          return bloc;
        },
        act: (bloc) {
          final event = WorkoutSessionCompletedEvent(
            userId: 'test-user-id',
            date: DateTime(2024, 1, 15),
            sessionId: 'session-123',
          );
          bloc.handleCommunicationEvent(event);
        },
        expect: () => [
          isA<DailySummaryError>()
              .having((state) => state.message, 'message', 'Server error')
              .having((state) => state.operation, 'operation', 'auto_update'),
        ],
      );
    });

    group('Daily Summary Refresh Requested Events', () {
      blocTest<DailySummaryBloc, DailySummaryState>(
        'should handle DailySummaryRefreshRequestedEvent with manual refresh',
        build: () {
          const userId = 'test-user-id';
          final date = DateTime(2024, 1, 15);
          final refreshedSummary = UserDailySummary(
            id: 'test-id',
            userId: userId,
            summaryDate: date,
            totalCaloriesConsumed: 2300.0,
            totalProteinConsumed: 170.0,
            totalCarbsConsumed: 270.0,
            totalFatConsumed: 90.0,
            totalWorkoutDurationMinutes: 75,
            totalCaloriesBurned: 450,
          );

          when(mockRepository.calculateAndUpdateDailySummary(userId, date))
              .thenAnswer((_) async => Right(refreshedSummary));

          return bloc;
        },
        act: (bloc) {
          final event = DailySummaryRefreshRequestedEvent(
            userId: 'test-user-id',
            date: DateTime(2024, 1, 15),
            reason: RefreshReason.manualRefresh,
          );
          bloc.handleCommunicationEvent(event);
        },
        expect: () => [
          isA<DailySummaryRefreshing>(),
          isA<DailySummaryUpdated>()
              .having((state) => state.summary.totalCaloriesConsumed, 'calories', 2300.0)
              .having((state) => state.updateReason, 'reason', 'Manual refresh'),
        ],
      );

      blocTest<DailySummaryBloc, DailySummaryState>(
        'should handle DailySummaryRefreshRequestedEvent with meal changed reason',
        build: () {
          const userId = 'test-user-id';
          final date = DateTime(2024, 1, 15);
          final refreshedSummary = UserDailySummary(
            id: 'test-id',
            userId: userId,
            summaryDate: date,
            totalCaloriesConsumed: 2100.0,
            totalProteinConsumed: 155.0,
            totalCarbsConsumed: 255.0,
            totalFatConsumed: 82.0,
            totalWorkoutDurationMinutes: 60,
            totalCaloriesBurned: 400,
          );

          when(mockRepository.calculateAndUpdateDailySummary(userId, date))
              .thenAnswer((_) async => Right(refreshedSummary));

          return bloc;
        },
        act: (bloc) {
          final event = DailySummaryRefreshRequestedEvent(
            userId: 'test-user-id',
            date: DateTime(2024, 1, 15),
            reason: RefreshReason.mealChanged,
          );
          bloc.handleCommunicationEvent(event);
        },
        expect: () => [
          isA<DailySummaryRefreshing>(),
          isA<DailySummaryUpdated>()
              .having((state) => state.updateReason, 'reason', 'Manual refresh'),
        ],
      );
    });

    group('Unrelated Events', () {
      test('should ignore WorkoutProgramProgressUpdatedEvent', () async {
        // Arrange
        const userId = 'test-user-id';
        final date = DateTime(2024, 1, 15);

        final unrelatedEvent = WorkoutProgramProgressUpdatedEvent(
          userProgramId: 'program-123',
          currentWeek: 2,
          currentDay: 3,
        );

        // Act
        bloc.handleCommunicationEvent(unrelatedEvent);
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - Repository should not be called for unrelated events
        verifyNever(mockRepository.calculateAndUpdateDailySummary(userId, date));
        verifyNever(mockRepository.getDailySummary(userId, date));
      });

      test('should ignore WorkoutProgramDayCompletedEvent', () async {
        // Arrange
        const userId = 'test-user-id';
        final date = DateTime(2024, 1, 15);

        final unrelatedEvent = WorkoutProgramDayCompletedEvent(
          userProgramId: 'program-123',
          week: 2,
          day: 3,
          completedAt: DateTime.now(),
        );

        // Act
        bloc.handleCommunicationEvent(unrelatedEvent);
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - Repository should not be called for unrelated events
        verifyNever(mockRepository.calculateAndUpdateDailySummary(userId, date));
        verifyNever(mockRepository.getDailySummary(userId, date));
      });

      test('should ignore WorkoutProgramDeletedEvent', () async {
        // Arrange
        const userId = 'test-user-id';
        final date = DateTime(2024, 1, 15);

        final unrelatedEvent = WorkoutProgramDeletedEvent(
          userProgramId: 'program-123',
          userId: userId,
        );

        // Act
        bloc.handleCommunicationEvent(unrelatedEvent);
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - Repository should not be called for unrelated events
        verifyNever(mockRepository.calculateAndUpdateDailySummary(userId, date));
        verifyNever(mockRepository.getDailySummary(userId, date));
      });
    });

    group('Multiple External Events', () {
      test('should handle multiple meal change events for same date', () async {
        // Arrange
        const userId = 'test-user-id';
        final date = DateTime(2024, 1, 15);
        
        final summary1 = UserDailySummary(
          id: 'test-id',
          userId: userId,
          summaryDate: date,
          totalCaloriesConsumed: 2100.0,
        );
        
        final summary2 = UserDailySummary(
          id: 'test-id',
          userId: userId,
          summaryDate: date,
          totalCaloriesConsumed: 2300.0,
        );

        when(mockRepository.calculateAndUpdateDailySummary(userId, date))
            .thenAnswer((_) async => Right(summary1));
        when(mockRepository.calculateAndUpdateDailySummary(userId, date))
            .thenAnswer((_) async => Right(summary2));

        // Act - Multiple meal change events
        final event1 = MealRecordChangedEvent(
          userId: userId,
          date: date,
          changeType: MealChangeType.added,
          recordId: 'meal-123',
        );
        
        final event2 = MealRecordChangedEvent(
          userId: userId,
          date: date,
          changeType: MealChangeType.updated,
          recordId: 'meal-456',
        );

        bloc.handleCommunicationEvent(event1);
        await Future.delayed(const Duration(milliseconds: 100));
        
        bloc.handleCommunicationEvent(event2);
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - Both events should trigger updates
        verify(mockRepository.calculateAndUpdateDailySummary(userId, date)).called(2);
      });

      test('should handle meal and workout events for same date', () async {
        // Arrange
        const userId = 'test-user-id';
        final date = DateTime(2024, 1, 15);
        
        final mealUpdatedSummary = UserDailySummary(
          id: 'test-id',
          userId: userId,
          summaryDate: date,
          totalCaloriesConsumed: 2200.0,
          totalWorkoutDurationMinutes: 60,
        );
        
        final workoutUpdatedSummary = UserDailySummary(
          id: 'test-id',
          userId: userId,
          summaryDate: date,
          totalCaloriesConsumed: 2200.0,
          totalWorkoutDurationMinutes: 90,
        );

        when(mockRepository.calculateAndUpdateDailySummary(userId, date))
            .thenAnswer((_) async => Right(mealUpdatedSummary));
        when(mockRepository.calculateAndUpdateDailySummary(userId, date))
            .thenAnswer((_) async => Right(workoutUpdatedSummary));

        // Act - Meal change followed by workout completion
        final mealEvent = MealRecordChangedEvent(
          userId: userId,
          date: date,
          changeType: MealChangeType.added,
          recordId: 'meal-123',
        );
        
        final workoutEvent = WorkoutSessionCompletedEvent(
          userId: userId,
          date: date,
          sessionId: 'session-456',
        );

        bloc.handleCommunicationEvent(mealEvent);
        await Future.delayed(const Duration(milliseconds: 100));
        
        bloc.handleCommunicationEvent(workoutEvent);
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - Both events should trigger updates
        verify(mockRepository.calculateAndUpdateDailySummary(userId, date)).called(2);
      });

      test('should handle events for different dates independently', () async {
        // Arrange
        const userId = 'test-user-id';
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 1, 16);
        
        final summary1 = UserDailySummary(
          id: 'test-id-1',
          userId: userId,
          summaryDate: date1,
          totalCaloriesConsumed: 2000.0,
        );
        
        final summary2 = UserDailySummary(
          id: 'test-id-2',
          userId: userId,
          summaryDate: date2,
          totalCaloriesConsumed: 2200.0,
        );

        when(mockRepository.calculateAndUpdateDailySummary(userId, date1))
            .thenAnswer((_) async => Right(summary1));
        when(mockRepository.calculateAndUpdateDailySummary(userId, date2))
            .thenAnswer((_) async => Right(summary2));

        // Act - Events for different dates
        final event1 = MealRecordChangedEvent(
          userId: userId,
          date: date1,
          changeType: MealChangeType.added,
          recordId: 'meal-123',
        );
        
        final event2 = WorkoutSessionCompletedEvent(
          userId: userId,
          date: date2,
          sessionId: 'session-456',
        );

        bloc.handleCommunicationEvent(event1);
        await Future.delayed(const Duration(milliseconds: 100));
        
        bloc.handleCommunicationEvent(event2);
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - Each date should be updated independently
        verify(mockRepository.calculateAndUpdateDailySummary(userId, date1)).called(1);
        verify(mockRepository.calculateAndUpdateDailySummary(userId, date2)).called(1);
      });
    });

    group('Event Timing and Order', () {
      test('should process events in the order they are received', () async {
        // Arrange
        const userId = 'test-user-id';
        final date = DateTime(2024, 1, 15);
        final callOrder = <String>[];
        
        when(mockRepository.calculateAndUpdateDailySummary(userId, date))
            .thenAnswer((_) async {
          callOrder.add('update_${callOrder.length + 1}');
          return Right(UserDailySummary(
            id: 'test-id',
            userId: userId,
            summaryDate: date,
            totalCaloriesConsumed: 2000.0 + callOrder.length * 100,
          ));
        });

        // Act - Send events in specific order
        final events = [
          MealRecordChangedEvent(
            userId: userId,
            date: date,
            changeType: MealChangeType.added,
            recordId: 'meal-1',
          ),
          MealRecordChangedEvent(
            userId: userId,
            date: date,
            changeType: MealChangeType.updated,
            recordId: 'meal-2',
          ),
          WorkoutSessionCompletedEvent(
            userId: userId,
            date: date,
            sessionId: 'session-1',
          ),
        ];

        for (final event in events) {
          bloc.handleCommunicationEvent(event);
          await Future.delayed(const Duration(milliseconds: 100));
        }

        // Assert - Events should be processed in order
        expect(callOrder, equals(['update_1', 'update_2', 'update_3']));
        verify(mockRepository.calculateAndUpdateDailySummary(userId, date)).called(3);
      });
    });
  });
}