import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
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
  group('DailySummaryBloc Caching', () {
    late DailySummaryBloc bloc;
    late MockDailySummaryRepository mockRepository;

    setUp(() {
      mockRepository = MockDailySummaryRepository();
      bloc = DailySummaryBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('should cache loaded summaries and return from cache on subsequent requests', () async {
      // Arrange
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

      when(mockRepository.getDailySummary(userId, date))
          .thenAnswer((_) async => Right(summary));

      // Act - First request should call repository
      bloc.add(LoadDailySummary(userId: userId, date: date));
      await Future.delayed(const Duration(milliseconds: 100));

      // Act - Second request should use cache
      bloc.add(LoadDailySummary(userId: userId, date: date));
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Repository should only be called once due to caching
      verify(mockRepository.getDailySummary(userId, date)).called(1);
    });

    test('should clear cache when ClearDailySummaryCache event is added', () async {
      // Arrange
      const userId = 'test-user-id';
      final date = DateTime(2024, 1, 15);
      final summary = UserDailySummary(
        id: 'test-id',
        userId: userId,
        summaryDate: date,
        totalCaloriesConsumed: 2000.0,
      );

      when(mockRepository.getDailySummary(userId, date))
          .thenAnswer((_) async => Right(summary));

      // Act - Load summary to cache it
      bloc.add(LoadDailySummary(userId: userId, date: date));
      await Future.delayed(const Duration(milliseconds: 100));

      // Act - Clear cache
      bloc.add(const ClearDailySummaryCache());
      await Future.delayed(const Duration(milliseconds: 100));

      // Act - Load summary again (should call repository again)
      bloc.add(LoadDailySummary(userId: userId, date: date));
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Repository should be called twice (once before cache clear, once after)
      verify(mockRepository.getDailySummary(userId, date)).called(2);
    });

    test('should update cache when summary is refreshed', () async {
      // Arrange
      const userId = 'test-user-id';
      final date = DateTime(2024, 1, 15);
      final originalSummary = UserDailySummary(
        id: 'test-id',
        userId: userId,
        summaryDate: date,
        totalCaloriesConsumed: 2000.0,
      );
      final updatedSummary = UserDailySummary(
        id: 'test-id',
        userId: userId,
        summaryDate: date,
        totalCaloriesConsumed: 2200.0,
      );

      when(mockRepository.getDailySummary(userId, date))
          .thenAnswer((_) async => Right(originalSummary));
      when(mockRepository.calculateAndUpdateDailySummary(userId, date))
          .thenAnswer((_) async => Right(updatedSummary));

      // Act - Load original summary
      bloc.add(LoadDailySummary(userId: userId, date: date));
      await Future.delayed(const Duration(milliseconds: 100));

      // Act - Refresh summary (should update cache)
      bloc.add(RefreshDailySummary(userId: userId, date: date));
      await Future.delayed(const Duration(milliseconds: 100));

      // Act - Load summary again (should return updated summary from cache)
      bloc.add(LoadDailySummary(userId: userId, date: date));
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - getDailySummary should only be called once (initial load)
      // The second load should use the cached updated summary
      verify(mockRepository.getDailySummary(userId, date)).called(1);
      verify(mockRepository.calculateAndUpdateDailySummary(userId, date)).called(1);
    });

    blocTest<DailySummaryBloc, DailySummaryState>(
      'should cache summaries loaded from range requests',
      build: () {
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

        when(mockRepository.getDailySummariesForRange(userId, startDate, endDate))
            .thenAnswer((_) async => Right(summaries));
        when(mockRepository.getDailySummary(userId, DateTime(2024, 1, 1)))
            .thenAnswer((_) async => Right(summaries[0]));

        return bloc;
      },
      act: (bloc) async {
        // Load range first (should cache individual summaries)
        bloc.add(LoadDailySummariesForRange(
          userId: 'test-user-id',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 7),
        ));
        await Future.delayed(const Duration(milliseconds: 100));

        // Load individual summary (should use cache)
        bloc.add(LoadDailySummary(
          userId: 'test-user-id',
          date: DateTime(2024, 1, 1),
        ));
      },
      verify: (bloc) {
        // Should not call getDailySummary because it's cached from range request
        verifyNever(mockRepository.getDailySummary('test-user-id', DateTime(2024, 1, 1)));
      },
    );
  });
}