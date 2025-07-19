import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_ranking.dart';
import 'package:jfit/features/group_workout_community/domain/entities/user_workout_score.dart';
import 'package:jfit/features/group_workout_community/domain/entities/body_part_mapping.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/ranking_repository.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/ranking/ranking_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/ranking/ranking_event.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/ranking/ranking_state.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ranking_bloc_test.mocks.dart';

@GenerateMocks([RankingRepository])
void main() {
  group('RankingBloc', () {
    late RankingBloc rankingBloc;
    late MockRankingRepository mockRepository;

    setUp(() {
      mockRepository = MockRankingRepository();
      rankingBloc = RankingBloc(mockRepository);
    });

    tearDown(() {
      rankingBloc.close();
    });

    test('initial state is RankingInitial', () {
      expect(rankingBloc.state, equals(const RankingInitial()));
    });

    group('LoadGroupRankings', () {
      final testRankings = [
        GroupRanking(
          id: 'ranking-1',
          groupId: 'group-1',
          groupName: 'Fitness Group 1',
          rankingPeriod: RankingPeriod.weekly,
          periodStartDate: DateTime(2024, 1, 1),
          periodEndDate: DateTime(2024, 1, 7),
          totalScore: 1500,
          memberCount: 10,
          averageScore: 150.0,
          rankPosition: 1,
          previousRank: 2,
          calculatedAt: DateTime(2024, 1, 1),
          scoreBreakdown: {
            'balance': 85.5,
            'volume': 92.0,
            'progress': 78.3,
            'consistency': 88.7,
          },
        ),
        GroupRanking(
          id: 'ranking-2',
          groupId: 'group-2',
          groupName: 'Fitness Group 2',
          rankingPeriod: RankingPeriod.weekly,
          periodStartDate: DateTime(2024, 1, 1),
          periodEndDate: DateTime(2024, 1, 7),
          totalScore: 1200,
          memberCount: 8,
          averageScore: 150.0,
          rankPosition: 2,
          previousRank: 1,
          calculatedAt: DateTime(2024, 1, 1),
          scoreBreakdown: {
            'balance': 80.0,
            'volume': 85.5,
            'progress': 82.1,
            'consistency': 90.2,
          },
        ),
      ];

      blocTest<RankingBloc, RankingState>(
        'emits [RankingLoading, RankingLoaded] when LoadGroupRankings succeeds',
        build: () {
          when(mockRepository.getGroupRankings(any, limit: 100, offset: 0))
              .thenAnswer((_) async => Right(testRankings));
          return rankingBloc;
        },
        act: (bloc) => bloc.add(const LoadGroupRankings(
          request: RankingPeriodRequest(period: RankingPeriod.weekly),
        )),
        expect: () => [
          const RankingLoading(),
          isA<RankingLoaded>()
              .having((state) => state.groupRankings, 'groupRankings', testRankings)
              .having((state) => state.currentPeriod, 'currentPeriod', RankingPeriod.weekly)
              .having((state) => state.groupRankings.length, 'rankings length', 2),
        ],
        verify: (_) {
          verify(mockRepository.getGroupRankings(
            argThat(isA<RankingPeriodRequest>()
                .having((req) => req.period, 'period', RankingPeriod.weekly)),
            limit: 100,
            offset: 0,
          )).called(1);
        },
      );

      blocTest<RankingBloc, RankingState>(
        'emits [RankingLoading, RankingLoaded] with monthly period',
        build: () {
          when(mockRepository.getGroupRankings(any, limit: 100, offset: 0))
              .thenAnswer((_) async => Right(testRankings));
          return rankingBloc;
        },
        act: (bloc) => bloc.add(const LoadGroupRankings(
          request: RankingPeriodRequest(period: RankingPeriod.monthly),
        )),
        expect: () => [
          const RankingLoading(),
          isA<RankingLoaded>()
              .having((state) => state.groupRankings, 'groupRankings', testRankings)
              .having((state) => state.currentPeriod, 'currentPeriod', RankingPeriod.monthly),
        ],
        verify: (_) {
          verify(mockRepository.getGroupRankings(
            argThat(isA<RankingPeriodRequest>()
                .having((req) => req.period, 'period', RankingPeriod.monthly)),
            limit: 100,
            offset: 0,
          )).called(1);
        },
      );

      blocTest<RankingBloc, RankingState>(
        'emits [RankingLoading, RankingError] when LoadGroupRankings fails',
        build: () {
          when(mockRepository.getGroupRankings(any, limit: 100, offset: 0))
              .thenAnswer((_) async => Left(ServerFailure('Server error')));
          return rankingBloc;
        },
        act: (bloc) => bloc.add(const LoadGroupRankings(
          request: RankingPeriodRequest(period: RankingPeriod.weekly),
        )),
        expect: () => [
          const RankingLoading(),
          isA<RankingError>()
              .having((state) => state.message, 'message', contains('Server error')),
        ],
        verify: (_) {
          verify(mockRepository.getGroupRankings(any, limit: 100, offset: 0)).called(1);
        },
      );

      blocTest<RankingBloc, RankingState>(
        'emits [RankingLoading, RankingLoaded] with empty list when no rankings exist',
        build: () {
          when(mockRepository.getGroupRankings(any, limit: 100, offset: 0))
              .thenAnswer((_) async => const Right([]));
          return rankingBloc;
        },
        act: (bloc) => bloc.add(const LoadGroupRankings(
          request: RankingPeriodRequest(period: RankingPeriod.weekly),
        )),
        expect: () => [
          const RankingLoading(),
          isA<RankingLoaded>()
              .having((state) => state.groupRankings, 'groupRankings', isEmpty),
        ],
        verify: (_) {
          verify(mockRepository.getGroupRankings(any, limit: 100, offset: 0)).called(1);
        },
      );
    });

    group('LoadUserScores', () {
      const userId = 'test-user-id';
      final testScores = [
        UserWorkoutScore(
          id: 'score-1',
          userId: userId,
          groupId: 'group-1',
          scoreDate: DateTime(2024, 1, 1),
          totalScore: 85.5,
          bodyBalanceScore: 88.0,
          volumeScore: 92.5,
          progressScore: 78.2,
          consistencyScore: 83.8,
          bodyPartScores: {
            BodyPart.chest: 85.0,
            BodyPart.back: 90.0,
            BodyPart.legs: 88.5,
            BodyPart.shoulders: 82.0,
            BodyPart.arms: 87.5,
            BodyPart.core: 89.0,
          },
          createdAt: DateTime(2024, 1, 1),
        ),
        UserWorkoutScore(
          id: 'score-2',
          userId: userId,
          groupId: 'group-1',
          scoreDate: DateTime(2024, 1, 2),
          totalScore: 87.2,
          bodyBalanceScore: 89.5,
          volumeScore: 94.0,
          progressScore: 80.1,
          consistencyScore: 85.2,
          bodyPartScores: {
            BodyPart.chest: 87.0,
            BodyPart.back: 92.0,
            BodyPart.legs: 90.0,
            BodyPart.shoulders: 84.0,
            BodyPart.arms: 89.0,
            BodyPart.core: 91.0,
          },
          createdAt: DateTime(2024, 1, 2),
        ),
      ];

      blocTest<RankingBloc, RankingState>(
        'emits [RankingLoading, RankingLoaded] when LoadUserScores succeeds',
        build: () {
          when(mockRepository.getUserScores(
            userId,
            groupId: anyNamed('groupId'),
            period: anyNamed('period'),
            limit: 30,
          )).thenAnswer((_) async => Right(testScores));
          return rankingBloc;
        },
        act: (bloc) => bloc.add(const LoadUserScores(userId: userId)),
        expect: () => [
          const RankingLoading(),
          isA<RankingLoaded>()
              .having((state) => state.userScores, 'userScores', testScores)
              .having((state) => state.userScores.length, 'scores length', 2),
        ],
        verify: (_) {
          verify(mockRepository.getUserScores(
            userId,
            groupId: anyNamed('groupId'),
            period: anyNamed('period'),
            limit: 30,
          )).called(1);
        },
      );

      blocTest<RankingBloc, RankingState>(
        'emits [RankingLoading, RankingLoaded] with monthly period',
        build: () {
          when(mockRepository.getUserScores(userId, groupId: anyNamed('groupId'), period: anyNamed('period'), limit: 30))
              .thenAnswer((_) async => Right(testScores));
          return rankingBloc;
        },
        act: (bloc) => bloc.add(LoadUserScores(
          userId: userId,
          period: const RankingPeriodRequest(period: RankingPeriod.monthly),
        )),
        expect: () => [
          const RankingLoading(),
          isA<RankingLoaded>()
              .having((state) => state.userScores, 'userScores', testScores)
              .having((state) => state.currentPeriod, 'currentPeriod', RankingPeriod.monthly),
        ],
        verify: (_) {
          verify(mockRepository.getUserScores(userId, groupId: anyNamed('groupId'), period: anyNamed('period'), limit: 30)).called(1);
        },
      );

      blocTest<RankingBloc, RankingState>(
        'emits [RankingLoading, RankingError] when LoadUserScores fails',
        build: () {
          when(mockRepository.getUserScores(userId, groupId: anyNamed('groupId'), period: anyNamed('period'), limit: 30))
              .thenAnswer((_) async => Left(DatabaseFailure('Database error')));
          return rankingBloc;
        },
        act: (bloc) => bloc.add(const LoadUserScores(userId: userId)),
        expect: () => [
          const RankingLoading(),
          isA<RankingError>()
              .having((state) => state.message, 'message', contains('Database error')),
        ],
        verify: (_) {
          verify(mockRepository.getUserScores(userId, groupId: anyNamed('groupId'), period: anyNamed('period'), limit: 30)).called(1);
        },
      );
    });

    group('CalculateUserScore', () {
      const userId = 'test-user-id';
      const groupId = 'test-group-id';
      final scoreDate = DateTime(2024, 1, 1);

      final calculatedScore = UserWorkoutScore(
        id: 'calculated-score-id',
        userId: userId,
        groupId: groupId,
        scoreDate: scoreDate,
        totalScore: 88.5,
        bodyBalanceScore: 90.0,
        volumeScore: 95.0,
        progressScore: 82.5,
        consistencyScore: 86.5,
        bodyPartScores: {
          BodyPart.chest: 88.0,
          BodyPart.back: 93.0,
          BodyPart.legs: 91.5,
          BodyPart.shoulders: 85.0,
          BodyPart.arms: 90.0,
          BodyPart.core: 92.0,
        },
        createdAt: DateTime.now(),
      );

      blocTest<RankingBloc, RankingState>(
        'emits [RankingCalculating, RankingOperationSuccess] when CalculateUserScore succeeds',
        build: () {
          when(mockRepository.calculateUserScore(any))
              .thenAnswer((_) async => Right(calculatedScore));
          when(mockRepository.getUserScores(userId, groupId: groupId, period: anyNamed('period'), limit: 30))
              .thenAnswer((_) async => Right([calculatedScore]));
          return rankingBloc;
        },
        act: (bloc) => bloc.add(CalculateUserScore(
          request: CalculateScoreRequest(
            userId: userId,
            groupId: groupId,
            scoreDate: scoreDate,
            sessionIds: ['session-1'],
          ),
        )),
        expect: () => [
          RankingCalculating(userId: userId, scoreDate: scoreDate),
          isA<RankingOperationSuccess>()
              .having((state) => state.operationType, 'operationType', 'calculate_score'),
          const RankingLoading(),
          isA<RankingLoaded>()
              .having((state) => state.userScores.length, 'user scores length', 1),
        ],
        verify: (_) {
          verify(mockRepository.calculateUserScore(any)).called(1);
        },
      );

      blocTest<RankingBloc, RankingState>(
        'emits [RankingCalculating, RankingError] when CalculateUserScore fails',
        build: () {
          when(mockRepository.calculateUserScore(any))
              .thenAnswer((_) async => Left(ValidationFailure('Invalid data')));
          return rankingBloc;
        },
        act: (bloc) => bloc.add(CalculateUserScore(
          request: CalculateScoreRequest(
            userId: userId,
            groupId: groupId,
            scoreDate: scoreDate,
            sessionIds: ['session-1'],
          ),
        )),
        expect: () => [
          RankingCalculating(userId: userId, scoreDate: scoreDate),
          isA<RankingError>()
              .having((state) => state.message, 'message', contains('Invalid data')),
        ],
        verify: (_) {
          verify(mockRepository.calculateUserScore(any)).called(1);
        },
      );
    });

    group('UpdateGroupRankings', () {
      blocTest<RankingBloc, RankingState>(
        'emits [RankingUpdating, RankingOperationSuccess] when UpdateGroupRankings succeeds',
        build: () {
          when(mockRepository.updateGroupRankings(any))
              .thenAnswer((_) async => const Right(null));
          when(mockRepository.getGroupRankings(any, limit: 100, offset: 0))
              .thenAnswer((_) async => const Right([]));
          return rankingBloc;
        },
        act: (bloc) => bloc.add(const UpdateGroupRankings(
          request: RankingPeriodRequest(period: RankingPeriod.weekly),
        )),
        expect: () => [
          const RankingUpdating(period: RankingPeriod.weekly),
          isA<RankingOperationSuccess>()
              .having((state) => state.operationType, 'operationType', 'update_rankings'),
          const RankingLoading(),
          isA<RankingLoaded>(),
        ],
        verify: (_) {
          verify(mockRepository.updateGroupRankings(any)).called(1);
        },
      );

      blocTest<RankingBloc, RankingState>(
        'emits [RankingUpdating, RankingError] when UpdateGroupRankings fails',
        build: () {
          when(mockRepository.updateGroupRankings(any))
              .thenAnswer((_) async => Left(ServerFailure('Update failed')));
          return rankingBloc;
        },
        act: (bloc) => bloc.add(const UpdateGroupRankings(
          request: RankingPeriodRequest(period: RankingPeriod.weekly),
        )),
        expect: () => [
          const RankingUpdating(period: RankingPeriod.weekly),
          isA<RankingError>()
              .having((state) => state.message, 'message', contains('Update failed')),
        ],
        verify: (_) {
          verify(mockRepository.updateGroupRankings(any)).called(1);
        },
      );
    });

    group('LoadScoreBreakdown', () {
      const userId = 'test-user-id';
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);

      final testBreakdown = {
        'balance': 85.5,
        'volume': 92.0,
        'progress': 78.3,
        'consistency': 88.7,
        'chest': 87.0,
        'back': 92.0,
        'legs': 89.5,
        'shoulders': 83.0,
        'arms': 88.0,
        'core': 90.5,
      };

      blocTest<RankingBloc, RankingState>(
        'emits [RankingPartialLoading, RankingLoaded] when LoadScoreBreakdown succeeds',
        build: () {
          when(mockRepository.getScoreBreakdown(userId, startDate, endDate))
              .thenAnswer((_) async => Right(testBreakdown));
          return rankingBloc;
        },
        act: (bloc) => bloc.add(LoadScoreBreakdown(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
        )),
        expect: () => [
          const RankingLoading(),
          isA<RankingLoaded>()
              .having((state) => state.scoreBreakdown, 'scoreBreakdown', testBreakdown),
        ],
        verify: (_) {
          verify(mockRepository.getScoreBreakdown(userId, startDate, endDate)).called(1);
        },
      );

      blocTest<RankingBloc, RankingState>(
        'emits [RankingLoading, RankingError] when LoadScoreBreakdown fails',
        build: () {
          when(mockRepository.getScoreBreakdown(userId, startDate, endDate))
              .thenAnswer((_) async => Left(NotFoundFailure('No data found')));
          return rankingBloc;
        },
        act: (bloc) => bloc.add(LoadScoreBreakdown(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
        )),
        expect: () => [
          const RankingLoading(),
          isA<RankingError>()
              .having((state) => state.message, 'message', contains('No data found')),
        ],
        verify: (_) {
          verify(mockRepository.getScoreBreakdown(userId, startDate, endDate)).called(1);
        },
      );
    });

    group('LoadGroupMemberScores', () {
      const groupId = 'test-group-id';
      final testMemberScores = [
        UserWorkoutScore(
          id: 'score-1',
          userId: 'user-1',
          groupId: groupId,
          scoreDate: DateTime(2024, 1, 1),
          totalScore: 88.5,
          bodyBalanceScore: 90.0,
          volumeScore: 95.0,
          progressScore: 82.5,
          consistencyScore: 86.5,
          bodyPartScores: {
            BodyPart.chest: 88.0,
            BodyPart.back: 93.0,
            BodyPart.legs: 91.5,
            BodyPart.shoulders: 85.0,
            BodyPart.arms: 90.0,
            BodyPart.core: 92.0,
          },
          createdAt: DateTime(2024, 1, 1),
        ),
        UserWorkoutScore(
          id: 'score-2',
          userId: 'user-2',
          groupId: groupId,
          scoreDate: DateTime(2024, 1, 1),
          totalScore: 85.2,
          bodyBalanceScore: 87.5,
          volumeScore: 91.0,
          progressScore: 79.8,
          consistencyScore: 83.5,
          bodyPartScores: {
            BodyPart.chest: 85.0,
            BodyPart.back: 90.0,
            BodyPart.legs: 88.5,
            BodyPart.shoulders: 82.0,
            BodyPart.arms: 87.0,
            BodyPart.core: 89.5,
          },
          createdAt: DateTime(2024, 1, 1),
        ),
      ];

      blocTest<RankingBloc, RankingState>(
        'emits [RankingLoading, RankingLoaded] when LoadGroupMemberScores succeeds',
        build: () {
          when(mockRepository.getGroupMemberScores(groupId, any, limit: 50))
              .thenAnswer((_) async => Right(testMemberScores));
          return rankingBloc;
        },
        act: (bloc) => bloc.add(LoadGroupMemberScores(
          groupId: groupId,
          request: const RankingPeriodRequest(period: RankingPeriod.weekly),
        )),
        expect: () => [
          const RankingLoading(),
          isA<RankingLoaded>()
              .having((state) => state.userScores, 'userScores', testMemberScores)
              .having((state) => state.currentPeriod, 'currentPeriod', RankingPeriod.weekly)
              .having((state) => state.userScores.length, 'scores length', 2),
        ],
        verify: (_) {
          verify(mockRepository.getGroupMemberScores(groupId, any, limit: 50)).called(1);
        },
      );

      blocTest<RankingBloc, RankingState>(
        'emits [RankingLoading, RankingLoaded] with monthly period',
        build: () {
          when(mockRepository.getGroupMemberScores(groupId, any, limit: 50))
              .thenAnswer((_) async => Right(testMemberScores));
          return rankingBloc;
        },
        act: (bloc) => bloc.add(LoadGroupMemberScores(
          groupId: groupId,
          request: const RankingPeriodRequest(period: RankingPeriod.monthly),
        )),
        expect: () => [
          const RankingLoading(),
          isA<RankingLoaded>()
              .having((state) => state.userScores, 'userScores', testMemberScores)
              .having((state) => state.currentPeriod, 'currentPeriod', RankingPeriod.monthly),
        ],
        verify: (_) {
          verify(mockRepository.getGroupMemberScores(groupId, any, limit: 50)).called(1);
        },
      );
    });

    group('Error Handling', () {
      const userId = 'test-user-id';

      blocTest<RankingBloc, RankingState>(
        'handles unexpected exceptions during LoadUserScores',
        setUp: () {
          reset(mockRepository);
        },
        build: () {
          when(mockRepository.getUserScores(userId, groupId: anyNamed('groupId'), period: anyNamed('period'), limit: 30))
              .thenThrow(Exception('Unexpected error'));
          return rankingBloc;
        },
        act: (bloc) => bloc.add(const LoadUserScores(userId: userId)),
        expect: () => [
          const RankingLoading(),
          isA<RankingError>()
              .having((state) => state.message, 'message', contains('Unexpected error')),
        ],
      );

      blocTest<RankingBloc, RankingState>(
        'handles network failures gracefully',
        build: () {
          when(mockRepository.getGroupRankings(any, limit: 100, offset: 0))
              .thenAnswer((_) async => Left(NetworkFailure('Network error')));
          return rankingBloc;
        },
        act: (bloc) => bloc.add(const LoadGroupRankings(
          request: RankingPeriodRequest(period: RankingPeriod.weekly),
        )),
        expect: () => [
          const RankingLoading(),
          isA<RankingError>()
              .having((state) => state.message, 'message', contains('Network error')),
        ],
      );
    });

    group('State Transitions', () {
      blocTest<RankingBloc, RankingState>(
        'should handle multiple consecutive events correctly',
        build: () {
          when(mockRepository.getGroupRankings(any, limit: 100, offset: 0))
              .thenAnswer((_) async => const Right([]));
          when(mockRepository.getUserScores('user-1', groupId: anyNamed('groupId'), period: anyNamed('period'), limit: 30))
              .thenAnswer((_) async => const Right([]));
          return rankingBloc;
        },
        act: (bloc) {
          bloc.add(const LoadGroupRankings(
            request: RankingPeriodRequest(period: RankingPeriod.weekly),
          ));
          bloc.add(const LoadUserScores(userId: 'user-1'));
        },
        expect: () => [
          const RankingLoading(),
          isA<RankingLoaded>(),
          isA<RankingPartialLoading>()
              .having((state) => state.loadingType, 'loadingType', 'user_scores'),
          isA<RankingLoaded>(),
        ],
      );
    });
  });
}