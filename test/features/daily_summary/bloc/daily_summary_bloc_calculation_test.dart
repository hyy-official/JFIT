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
  group('DailySummaryBloc Calculation Logic', () {
    late DailySummaryBloc bloc;
    late MockDailySummaryRepository mockRepository;

    setUp(() {
      mockRepository = MockDailySummaryRepository();
      bloc = DailySummaryBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    group('Summary Data Calculation', () {
      test('should calculate correct totals when all data is present', () async {
        // Arrange
        const userId = 'test-user-id';
        final date = DateTime(2024, 1, 15);
        final expectedSummary = UserDailySummary(
          id: 'test-id',
          userId: userId,
          summaryDate: date,
          totalCaloriesConsumed: 2500.0,
          totalProteinConsumed: 180.0,
          totalCarbsConsumed: 300.0,
          totalFatConsumed: 95.0,
          totalWorkoutDurationMinutes: 90,
          totalCaloriesBurned: 600,
        );

        when(mockRepository.calculateAndUpdateDailySummary(userId, date))
            .thenAnswer((_) async => Right(expectedSummary));

        // Act
        bloc.add(RefreshDailySummary(userId: userId, date: date));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(bloc.state, isA<DailySummaryUpdated>());
        final state = bloc.state as DailySummaryUpdated;
        expect(state.summary.totalCaloriesConsumed, equals(2500.0));
        expect(state.summary.totalProteinConsumed, equals(180.0));
        expect(state.summary.totalCarbsConsumed, equals(300.0));
        expect(state.summary.totalFatConsumed, equals(95.0));
        expect(state.summary.totalWorkoutDurationMinutes, equals(90));
        expect(state.summary.totalCaloriesBurned, equals(600));
      });

      test('should handle zero values correctly', () async {
        // Arrange
        const userId = 'test-user-id';
        final date = DateTime(2024, 1, 15);
        final expectedSummary = UserDailySummary(
          id: 'test-id',
          userId: userId,
          summaryDate: date,
          totalCaloriesConsumed: 0.0,
          totalProteinConsumed: 0.0,
          totalCarbsConsumed: 0.0,
          totalFatConsumed: 0.0,
          totalWorkoutDurationMinutes: 0,
          totalCaloriesBurned: 0,
        );

        when(mockRepository.calculateAndUpdateDailySummary(userId, date))
            .thenAnswer((_) async => Right(expectedSummary));

        // Act
        bloc.add(RefreshDailySummary(userId: userId, date: date));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(bloc.state, isA<DailySummaryUpdated>());
        final state = bloc.state as DailySummaryUpdated;
        expect(state.summary.totalCaloriesConsumed, equals(0.0));
        expect(state.summary.totalProteinConsumed, equals(0.0));
        expect(state.summary.totalCarbsConsumed, equals(0.0));
        expect(state.summary.totalFatConsumed, equals(0.0));
        expect(state.summary.totalWorkoutDurationMinutes, equals(0));
        expect(state.summary.totalCaloriesBurned, equals(0));
      });

      test('should handle very large values correctly', () async {
        // Arrange
        const userId = 'test-user-id';
        final date = DateTime(2024, 1, 15);
        final expectedSummary = UserDailySummary(
          id: 'test-id',
          userId: userId,
          summaryDate: date,
          totalCaloriesConsumed: 10000.0,
          totalProteinConsumed: 500.0,
          totalCarbsConsumed: 1200.0,
          totalFatConsumed: 400.0,
          totalWorkoutDurationMinutes: 480, // 8 hours
          totalCaloriesBurned: 2000,
        );

        when(mockRepository.calculateAndUpdateDailySummary(userId, date))
            .thenAnswer((_) async => Right(expectedSummary));

        // Act
        bloc.add(RefreshDailySummary(userId: userId, date: date));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(bloc.state, isA<DailySummaryUpdated>());
        final state = bloc.state as DailySummaryUpdated;
        expect(state.summary.totalCaloriesConsumed, equals(10000.0));
        expect(state.summary.totalProteinConsumed, equals(500.0));
        expect(state.summary.totalCarbsConsumed, equals(1200.0));
        expect(state.summary.totalFatConsumed, equals(400.0));
        expect(state.summary.totalWorkoutDurationMinutes, equals(480));
        expect(state.summary.totalCaloriesBurned, equals(2000));
      });

      test('should handle decimal precision correctly', () async {
        // Arrange
        const userId = 'test-user-id';
        final date = DateTime(2024, 1, 15);
        final expectedSummary = UserDailySummary(
          id: 'test-id',
          userId: userId,
          summaryDate: date,
          totalCaloriesConsumed: 2000.5,
          totalProteinConsumed: 150.25,
          totalCarbsConsumed: 250.75,
          totalFatConsumed: 80.125,
          totalWorkoutDurationMinutes: 65,
          totalCaloriesBurned: 425,
        );

        when(mockRepository.calculateAndUpdateDailySummary(userId, date))
            .thenAnswer((_) async => Right(expectedSummary));

        // Act
        bloc.add(RefreshDailySummary(userId: userId, date: date));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(bloc.state, isA<DailySummaryUpdated>());
        final state = bloc.state as DailySummaryUpdated;
        expect(state.summary.totalCaloriesConsumed, equals(2000.5));
        expect(state.summary.totalProteinConsumed, equals(150.25));
        expect(state.summary.totalCarbsConsumed, equals(250.75));
        expect(state.summary.totalFatConsumed, equals(80.125));
      });
    });

    group('Calculation Error Handling', () {
      blocTest<DailySummaryBloc, DailySummaryState>(
        'should emit error when calculation fails due to database error',
        build: () {
          when(mockRepository.calculateAndUpdateDailySummary(any, any))
              .thenAnswer((_) async => Left(DatabaseFailure('Database connection failed')));
          return bloc;
        },
        act: (bloc) => bloc.add(RefreshDailySummary(
          userId: 'test-user-id',
          date: DateTime(2024, 1, 15),
        )),
        expect: () => [
          isA<DailySummaryRefreshing>(),
          isA<DailySummaryError>()
              .having((state) => state.message, 'message', 'Database connection failed')
              .having((state) => state.operation, 'operation', 'refresh'),
        ],
      );

      blocTest<DailySummaryBloc, DailySummaryState>(
        'should emit error when calculation fails due to server error',
        build: () {
          when(mockRepository.calculateAndUpdateDailySummary(any, any))
              .thenAnswer((_) async => Left(ServerFailure('Server unavailable')));
          return bloc;
        },
        act: (bloc) => bloc.add(RefreshDailySummary(
          userId: 'test-user-id',
          date: DateTime(2024, 1, 15),
        )),
        expect: () => [
          isA<DailySummaryRefreshing>(),
          isA<DailySummaryError>()
              .having((state) => state.message, 'message', 'Server unavailable')
              .having((state) => state.operation, 'operation', 'refresh'),
        ],
      );

      blocTest<DailySummaryBloc, DailySummaryState>(
        'should emit error when calculation fails due to general error',
        build: () {
          when(mockRepository.calculateAndUpdateDailySummary(any, any))
              .thenAnswer((_) async => Left(GeneralFailure('Invalid date range')));
          return bloc;
        },
        act: (bloc) => bloc.add(RefreshDailySummary(
          userId: 'test-user-id',
          date: DateTime(2024, 1, 15),
        )),
        expect: () => [
          isA<DailySummaryRefreshing>(),
          isA<DailySummaryError>()
              .having((state) => state.message, 'message', 'Invalid date range')
              .having((state) => state.operation, 'operation', 'refresh'),
        ],
      );
    });

    group('Incremental Calculation Updates', () {
      test('should update summary incrementally when meal data changes', () async {
        // Arrange
        const userId = 'test-user-id';
        final date = DateTime(2024, 1, 15);
        
        // Initial summary
        final initialSummary = UserDailySummary(
          id: 'test-id',
          userId: userId,
          summaryDate: date,
          totalCaloriesConsumed: 1500.0,
          totalProteinConsumed: 120.0,
          totalCarbsConsumed: 200.0,
          totalFatConsumed: 60.0,
          totalWorkoutDurationMinutes: 60,
          totalCaloriesBurned: 400,
        );

        // Updated summary after meal change
        final updatedSummary = UserDailySummary(
          id: 'test-id',
          userId: userId,
          summaryDate: date,
          totalCaloriesConsumed: 1800.0, // +300 calories
          totalProteinConsumed: 140.0,   // +20g protein
          totalCarbsConsumed: 230.0,     // +30g carbs
          totalFatConsumed: 70.0,        // +10g fat
          totalWorkoutDurationMinutes: 60, // unchanged
          totalCaloriesBurned: 400,        // unchanged
        );

        when(mockRepository.getDailySummary(userId, date))
            .thenAnswer((_) async => Right(initialSummary));
        when(mockRepository.calculateAndUpdateDailySummary(userId, date))
            .thenAnswer((_) async => Right(updatedSummary));

        // Act - Load initial summary
        bloc.add(LoadDailySummary(userId: userId, date: date));
        await Future.delayed(const Duration(milliseconds: 100));

        // Act - Update from meal change
        bloc.add(UpdateSummaryFromMeal(
          userId: userId,
          date: date,
          mealRecordId: 'meal-123',
        ));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(bloc.state, isA<DailySummaryUpdated>());
        final state = bloc.state as DailySummaryUpdated;
        expect(state.summary.totalCaloriesConsumed, equals(1800.0));
        expect(state.summary.totalProteinConsumed, equals(140.0));
        expect(state.summary.totalCarbsConsumed, equals(230.0));
        expect(state.summary.totalFatConsumed, equals(70.0));
        // Workout data should remain unchanged
        expect(state.summary.totalWorkoutDurationMinutes, equals(60));
        expect(state.summary.totalCaloriesBurned, equals(400));
      });

      test('should update summary incrementally when workout data changes', () async {
        // Arrange
        const userId = 'test-user-id';
        final date = DateTime(2024, 1, 15);
        
        // Initial summary
        final initialSummary = UserDailySummary(
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

        // Updated summary after workout change
        final updatedSummary = UserDailySummary(
          id: 'test-id',
          userId: userId,
          summaryDate: date,
          totalCaloriesConsumed: 2000.0, // unchanged
          totalProteinConsumed: 150.0,   // unchanged
          totalCarbsConsumed: 250.0,     // unchanged
          totalFatConsumed: 80.0,        // unchanged
          totalWorkoutDurationMinutes: 90, // +30 minutes
          totalCaloriesBurned: 600,        // +200 calories burned
        );

        when(mockRepository.getDailySummary(userId, date))
            .thenAnswer((_) async => Right(initialSummary));
        when(mockRepository.calculateAndUpdateDailySummary(userId, date))
            .thenAnswer((_) async => Right(updatedSummary));

        // Act - Load initial summary
        bloc.add(LoadDailySummary(userId: userId, date: date));
        await Future.delayed(const Duration(milliseconds: 100));

        // Act - Update from workout change
        bloc.add(UpdateSummaryFromWorkout(
          userId: userId,
          date: date,
          sessionId: 'session-123',
        ));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(bloc.state, isA<DailySummaryUpdated>());
        final state = bloc.state as DailySummaryUpdated;
        // Nutrition data should remain unchanged
        expect(state.summary.totalCaloriesConsumed, equals(2000.0));
        expect(state.summary.totalProteinConsumed, equals(150.0));
        expect(state.summary.totalCarbsConsumed, equals(250.0));
        expect(state.summary.totalFatConsumed, equals(80.0));
        // Workout data should be updated
        expect(state.summary.totalWorkoutDurationMinutes, equals(90));
        expect(state.summary.totalCaloriesBurned, equals(600));
      });
    });

    group('Date Range Calculations', () {
      test('should calculate summaries for multiple dates correctly', () async {
        // Arrange
        const userId = 'test-user-id';
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 3);
        
        final summaries = [
          UserDailySummary(
            id: 'test-id-1',
            userId: userId,
            summaryDate: DateTime(2024, 1, 1),
            totalCaloriesConsumed: 2000.0,
            totalWorkoutDurationMinutes: 60,
          ),
          UserDailySummary(
            id: 'test-id-2',
            userId: userId,
            summaryDate: DateTime(2024, 1, 2),
            totalCaloriesConsumed: 2200.0,
            totalWorkoutDurationMinutes: 75,
          ),
          UserDailySummary(
            id: 'test-id-3',
            userId: userId,
            summaryDate: DateTime(2024, 1, 3),
            totalCaloriesConsumed: 1800.0,
            totalWorkoutDurationMinutes: 45,
          ),
        ];

        when(mockRepository.getDailySummariesForRange(userId, startDate, endDate))
            .thenAnswer((_) async => Right(summaries));

        // Act
        bloc.add(LoadDailySummariesForRange(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
        ));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(bloc.state, isA<DailySummariesLoaded>());
        final state = bloc.state as DailySummariesLoaded;
        expect(state.summaries.length, equals(3));
        expect(state.summaries[0].totalCaloriesConsumed, equals(2000.0));
        expect(state.summaries[1].totalCaloriesConsumed, equals(2200.0));
        expect(state.summaries[2].totalCaloriesConsumed, equals(1800.0));
        expect(state.startDate, equals(startDate));
        expect(state.endDate, equals(endDate));
      });

      test('should handle empty date range correctly', () async {
        // Arrange
        const userId = 'test-user-id';
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 3);

        when(mockRepository.getDailySummariesForRange(userId, startDate, endDate))
            .thenAnswer((_) async => const Right([]));

        // Act
        bloc.add(LoadDailySummariesForRange(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
        ));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(bloc.state, isA<DailySummariesLoaded>());
        final state = bloc.state as DailySummariesLoaded;
        expect(state.summaries.isEmpty, isTrue);
        expect(state.startDate, equals(startDate));
        expect(state.endDate, equals(endDate));
      });
    });
  });
}