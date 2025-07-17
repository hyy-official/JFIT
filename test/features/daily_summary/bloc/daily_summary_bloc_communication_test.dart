import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/core/bloc/bloc_event_bus.dart';
import 'package:jfit/features/daily_summary/bloc/daily_summary_bloc.dart';
import 'package:jfit/features/daily_summary/bloc/daily_summary_state.dart';
import 'package:jfit/features/daily_summary/data/repositories/daily_summary_repository.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'daily_summary_bloc_test.mocks.dart';

@GenerateMocks([DailySummaryRepository])
void main() {
  group('DailySummaryBloc Communication', () {
    late DailySummaryBloc bloc;
    late MockDailySummaryRepository mockRepository;
    late BlocEventBus eventBus;

    setUp(() {
      mockRepository = MockDailySummaryRepository();
      bloc = DailySummaryBloc(repository: mockRepository);
      eventBus = BlocEventBus();
    });

    tearDown(() {
      bloc.close();
    });

    blocTest<DailySummaryBloc, DailySummaryState>(
      'should handle MealRecordChangedEvent and update summary',
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
        // Simulate a meal record change event
        final event = MealRecordChangedEvent(
          userId: 'test-user-id',
          date: DateTime(2024, 1, 15),
          changeType: MealChangeType.added,
          recordId: 'meal-123',
        );
        
        // Manually trigger the communication event handler
        bloc.handleCommunicationEvent(event);
      },
      expect: () => [
        isA<DailySummaryUpdated>()
            .having((state) => state.updateReason, 'updateReason', 'Meal data changed'),
      ],
    );

    blocTest<DailySummaryBloc, DailySummaryState>(
      'should handle WorkoutSessionCompletedEvent and update summary',
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
          totalWorkoutDurationMinutes: 90,
          totalCaloriesBurned: 500,
        );

        when(mockRepository.calculateAndUpdateDailySummary(userId, date))
            .thenAnswer((_) async => Right(updatedSummary));

        return bloc;
      },
      act: (bloc) {
        // Simulate a workout session completed event
        final event = WorkoutSessionCompletedEvent(
          userId: 'test-user-id',
          date: DateTime(2024, 1, 15),
          sessionId: 'session-123',
          userProgramId: 'program-456',
        );
        
        // Manually trigger the communication event handler
        bloc.handleCommunicationEvent(event);
      },
      expect: () => [
        isA<DailySummaryUpdated>()
            .having((state) => state.updateReason, 'updateReason', 'Workout data changed'),
      ],
    );

    blocTest<DailySummaryBloc, DailySummaryState>(
      'should handle DailySummaryRefreshRequestedEvent and refresh summary',
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
        // Simulate a daily summary refresh requested event
        final event = DailySummaryRefreshRequestedEvent(
          userId: 'test-user-id',
          date: DateTime(2024, 1, 15),
          reason: RefreshReason.manualRefresh,
        );
        
        // Manually trigger the communication event handler
        bloc.handleCommunicationEvent(event);
      },
      expect: () => [
        isA<DailySummaryRefreshing>(),
        isA<DailySummaryUpdated>()
            .having((state) => state.updateReason, 'updateReason', 'Manual refresh'),
      ],
    );

    test('should ignore unrelated communication events', () async {
      // Arrange
      const userId = 'test-user-id';
      final date = DateTime(2024, 1, 15);

      // Create an unrelated event (not handled by DailySummaryBloc)
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
    });
  });
}