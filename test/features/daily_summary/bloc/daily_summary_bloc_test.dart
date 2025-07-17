import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/features/daily_summary/bloc/daily_summary_bloc.dart';
import 'package:jfit/features/daily_summary/bloc/daily_summary_event.dart';
import 'package:jfit/features/daily_summary/bloc/daily_summary_state.dart';
import 'package:jfit/features/daily_summary/data/repositories/daily_summary_repository.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'daily_summary_bloc_test.mocks.dart';

@GenerateMocks([DailySummaryRepository])
void main() {
  group('DailySummaryBloc', () {
    late DailySummaryBloc bloc;
    late MockDailySummaryRepository mockRepository;

    setUp(() {
      mockRepository = MockDailySummaryRepository();
      bloc = DailySummaryBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is DailySummaryInitial', () {
      expect(bloc.state, equals(const DailySummaryInitial()));
    });

    group('LoadDailySummary', () {
      const userId = 'test-user-id';
      final date = DateTime(2024, 1, 15);
      final summary = UserDailySummary(
        id: 'test-id',
        userId: userId,
        summaryDate: date,
        totalCaloriesConsumed: 2000.0,
        totalProteinConsumed: 150.0,
        totalCarbsConsumed: 250.0,
        totalFatConsumed: 80.0,
        totalWorkoutDurationMinutes: 60,
        totalCaloriesBurned: 400,
      );

      blocTest<DailySummaryBloc, DailySummaryState>(
        'emits [DailySummaryLoading, DailySummaryLoaded] when summary is found',
        build: () {
          when(mockRepository.getDailySummary(userId, date))
              .thenAnswer((_) async => Right(summary));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadDailySummary(userId: userId, date: date)),
        expect: () => [
          DailySummaryLoading(message: 'Loading daily summary...', date: date),
          isA<DailySummaryLoaded>()
              .having((state) => state.summary, 'summary', summary),
        ],
      );

      blocTest<DailySummaryBloc, DailySummaryState>(
        'emits [DailySummaryLoading, DailySummaryEmpty] when no summary is found',
        build: () {
          when(mockRepository.getDailySummary(userId, date))
              .thenAnswer((_) async => const Right(null));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadDailySummary(userId: userId, date: date)),
        expect: () => [
          DailySummaryLoading(message: 'Loading daily summary...', date: date),
          DailySummaryEmpty(userId: userId, date: date),
        ],
      );

      blocTest<DailySummaryBloc, DailySummaryState>(
        'emits [DailySummaryLoading, DailySummaryError] when repository fails',
        build: () {
          when(mockRepository.getDailySummary(userId, date))
              .thenAnswer((_) async => Left(ServerFailure('Server error')));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadDailySummary(userId: userId, date: date)),
        expect: () => [
          DailySummaryLoading(message: 'Loading daily summary...', date: date),
          isA<DailySummaryError>()
              .having((state) => state.message, 'message', 'Server error')
              .having((state) => state.date, 'date', date)
              .having((state) => state.operation, 'operation', 'load'),
        ],
      );
    });

    group('RefreshDailySummary', () {
      const userId = 'test-user-id';
      final date = DateTime(2024, 1, 15);
      final summary = UserDailySummary(
        id: 'test-id',
        userId: userId,
        summaryDate: date,
        totalCaloriesConsumed: 2100.0,
        totalProteinConsumed: 160.0,
        totalCarbsConsumed: 260.0,
        totalFatConsumed: 85.0,
        totalWorkoutDurationMinutes: 75,
        totalCaloriesBurned: 450,
      );

      blocTest<DailySummaryBloc, DailySummaryState>(
        'emits [DailySummaryRefreshing, DailySummaryUpdated] when refresh succeeds',
        build: () {
          when(mockRepository.calculateAndUpdateDailySummary(userId, date))
              .thenAnswer((_) async => Right(summary));
          return bloc;
        },
        act: (bloc) => bloc.add(RefreshDailySummary(userId: userId, date: date)),
        expect: () => [
          DailySummaryRefreshing(userId: userId, date: date),
          isA<DailySummaryUpdated>()
              .having((state) => state.summary, 'summary', summary)
              .having((state) => state.updateReason, 'updateReason', 'Manual refresh'),
        ],
      );

      blocTest<DailySummaryBloc, DailySummaryState>(
        'emits [DailySummaryRefreshing, DailySummaryError] when refresh fails',
        build: () {
          when(mockRepository.calculateAndUpdateDailySummary(userId, date))
              .thenAnswer((_) async => Left(DatabaseFailure('Database error')));
          return bloc;
        },
        act: (bloc) => bloc.add(RefreshDailySummary(userId: userId, date: date)),
        expect: () => [
          DailySummaryRefreshing(userId: userId, date: date),
          isA<DailySummaryError>()
              .having((state) => state.message, 'message', 'Database error')
              .having((state) => state.date, 'date', date)
              .having((state) => state.operation, 'operation', 'refresh'),
        ],
      );
    });

    group('UpdateSummaryFromMeal', () {
      const userId = 'test-user-id';
      final date = DateTime(2024, 1, 15);
      final summary = UserDailySummary(
        id: 'test-id',
        userId: userId,
        summaryDate: date,
        totalCaloriesConsumed: 2200.0,
        totalProteinConsumed: 170.0,
        totalCarbsConsumed: 270.0,
        totalFatConsumed: 90.0,
        totalWorkoutDurationMinutes: 60,
        totalCaloriesBurned: 400,
      );

      blocTest<DailySummaryBloc, DailySummaryState>(
        'emits [DailySummaryUpdated] when meal update succeeds',
        build: () {
          when(mockRepository.calculateAndUpdateDailySummary(userId, date))
              .thenAnswer((_) async => Right(summary));
          return bloc;
        },
        act: (bloc) => bloc.add(UpdateSummaryFromMeal(
          userId: userId,
          date: date,
          mealRecordId: 'meal-123',
        )),
        expect: () => [
          isA<DailySummaryUpdated>()
              .having((state) => state.summary, 'summary', summary)
              .having((state) => state.updateReason, 'updateReason', 'Meal data changed'),
        ],
      );
    });

    group('UpdateSummaryFromWorkout', () {
      const userId = 'test-user-id';
      final date = DateTime(2024, 1, 15);
      final summary = UserDailySummary(
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

      blocTest<DailySummaryBloc, DailySummaryState>(
        'emits [DailySummaryUpdated] when workout update succeeds',
        build: () {
          when(mockRepository.calculateAndUpdateDailySummary(userId, date))
              .thenAnswer((_) async => Right(summary));
          return bloc;
        },
        act: (bloc) => bloc.add(UpdateSummaryFromWorkout(
          userId: userId,
          date: date,
          sessionId: 'session-123',
        )),
        expect: () => [
          isA<DailySummaryUpdated>()
              .having((state) => state.summary, 'summary', summary)
              .having((state) => state.updateReason, 'updateReason', 'Workout data changed'),
        ],
      );
    });

    group('LoadDailySummariesForRange', () {
      const userId = 'test-user-id';
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);
      final summaries = [
        UserDailySummary(
          id: 'test-id-1',
          userId: userId,
          summaryDate: DateTime(2024, 1, 1),
          totalCaloriesConsumed: 2000.0,
        ),
        UserDailySummary(
          id: 'test-id-2',
          userId: userId,
          summaryDate: DateTime(2024, 1, 2),
          totalCaloriesConsumed: 2100.0,
        ),
      ];

      blocTest<DailySummaryBloc, DailySummaryState>(
        'emits [DailySummaryLoading, DailySummariesLoaded] when range load succeeds',
        build: () {
          when(mockRepository.getDailySummariesForRange(userId, startDate, endDate))
              .thenAnswer((_) async => Right(summaries));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadDailySummariesForRange(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
        )),
        expect: () => [
          const DailySummaryLoading(message: 'Loading summaries for date range...'),
          isA<DailySummariesLoaded>()
              .having((state) => state.summaries, 'summaries', summaries)
              .having((state) => state.startDate, 'startDate', startDate)
              .having((state) => state.endDate, 'endDate', endDate),
        ],
      );
    });

    group('DeleteDailySummary', () {
      const userId = 'test-user-id';
      final date = DateTime(2024, 1, 15);

      blocTest<DailySummaryBloc, DailySummaryState>(
        'emits [DailySummaryLoading, DailySummaryDeleted] when delete succeeds',
        build: () {
          when(mockRepository.deleteDailySummary(userId, date))
              .thenAnswer((_) async => const Right(null));
          return bloc;
        },
        act: (bloc) => bloc.add(DeleteDailySummary(userId: userId, date: date)),
        expect: () => [
          DailySummaryLoading(message: 'Deleting daily summary...', date: date),
          isA<DailySummaryDeleted>()
              .having((state) => state.userId, 'userId', userId)
              .having((state) => state.date, 'date', date),
        ],
      );
    });

    group('ClearDailySummaryCache', () {
      blocTest<DailySummaryBloc, DailySummaryState>(
        'emits [DailySummaryCacheCleared] when cache is cleared',
        build: () => bloc,
        act: (bloc) => bloc.add(const ClearDailySummaryCache()),
        expect: () => [
          isA<DailySummaryCacheCleared>(),
        ],
      );
    });
  });
}