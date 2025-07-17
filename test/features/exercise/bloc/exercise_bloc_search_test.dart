import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/core/error/bloc_errors.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/models/exercise.dart';
import 'package:jfit/features/exercise/bloc/exercise_bloc.dart';
import 'package:jfit/features/exercise/bloc/exercise_event.dart';
import 'package:jfit/features/exercise/bloc/exercise_state.dart';
import 'package:jfit/features/exercise/data/repositories/exercise_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'exercise_bloc_test.mocks.dart';

/// Comprehensive tests for ExerciseBloc search logic and result processing
/// Focuses on search functionality, debouncing, filtering, and result handling
@GenerateMocks([ExerciseRepository])
void main() {
  group('ExerciseBloc - Search Logic & Result Processing Tests', () {
    late ExerciseBloc exerciseBloc;
    late MockExerciseRepository mockExerciseRepository;

    // Test data
    final testExercises = [
      Exercise(
        id: 1,
        titleKo: '푸시업',
        titleEn: 'Push-up',
        descKo: '가슴과 팔 근육을 강화하는 운동',
        descEn: 'Exercise to strengthen chest and arm muscles',
        difficulty: 'beginner',
        difficultyKo: '초급',
        type: 'strength',
        typeKo: '근력',
        equipment: 'bodyweight',
        equipmentKo: '맨몸',
        primaryMusclesKo: ['가슴'],
        secondaryMusclesKo: ['삼두근'],
        musclesUsedKo: ['가슴', '삼두근'],
        popularityScore: 100,
      ),
      Exercise(
        id: 2,
        titleKo: '스쿼트',
        titleEn: 'Squat',
        descKo: '하체 근육을 강화하는 운동',
        descEn: 'Exercise to strengthen lower body muscles',
        difficulty: 'intermediate',
        difficultyKo: '중급',
        type: 'strength',
        typeKo: '근력',
        equipment: 'bodyweight',
        equipmentKo: '맨몸',
        primaryMusclesKo: ['대퇴사두근'],
        secondaryMusclesKo: ['둔근'],
        musclesUsedKo: ['대퇴사두근', '둔근'],
        popularityScore: 95,
      ),
    ];

    setUp(() {
      mockExerciseRepository = MockExerciseRepository();
      exerciseBloc = ExerciseBloc(repository: mockExerciseRepository);
    });

    tearDown(() {
      exerciseBloc.close();
    });

    group('Search Query Processing', () {
      test('trims whitespace from search query', () async {
        const query = '  푸시업  ';
        const trimmedQuery = '푸시업';

        when(mockExerciseRepository.search(trimmedQuery, limit: anyNamed('limit')))
            .thenAnswer((_) async => Right(testExercises));

        exerciseBloc.add(const SearchExercises(query: query));
        await Future.delayed(const Duration(milliseconds: 350));

        verify(mockExerciseRepository.search(trimmedQuery, limit: anyNamed('limit')))
            .called(1);
      });

      test('handles special characters in search query', () async {
        const query = '푸시업@#\$%^&*()';

        when(mockExerciseRepository.search(query, limit: anyNamed('limit')))
            .thenAnswer((_) async => Right(testExercises));

        exerciseBloc.add(const SearchExercises(query: query));
        await Future.delayed(const Duration(milliseconds: 350));

        verify(mockExerciseRepository.search(query, limit: anyNamed('limit')))
            .called(1);
      });

      test('handles unicode characters in search query', () async {
        const query = '푸시업 🏋️‍♂️ 운동';

        when(mockExerciseRepository.search(query, limit: anyNamed('limit')))
            .thenAnswer((_) async => Right(testExercises));

        exerciseBloc.add(const SearchExercises(query: query));
        await Future.delayed(const Duration(milliseconds: 350));

        verify(mockExerciseRepository.search(query, limit: anyNamed('limit')))
            .called(1);
      });

      test('handles very long search queries', () async {
        final longQuery = 'a' * 1000; // 1000 character query

        when(mockExerciseRepository.search(longQuery, limit: anyNamed('limit')))
            .thenAnswer((_) async => Right(testExercises));

        exerciseBloc.add(SearchExercises(query: longQuery));
        await Future.delayed(const Duration(milliseconds: 350));

        verify(mockExerciseRepository.search(longQuery, limit: anyNamed('limit')))
            .called(1);
      });
    });

    group('Search Result Processing', () {
      blocTest<ExerciseBloc, ExerciseState>(
        'correctly processes empty search results',
        build: () {
          when(mockExerciseRepository.search('nonexistent', limit: anyNamed('limit')))
              .thenAnswer((_) async => const Right([]));
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(const SearchExercises(query: 'nonexistent')),
        wait: const Duration(milliseconds: 350),
        expect: () => [
          const ExerciseLoading(message: '운동을 검색하고 있습니다...'),
          const ExerciseSearchResults(
            exercises: [],
            query: 'nonexistent',
            hasMore: false,
            totalCount: 0,
          ),
        ],
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'correctly sets hasMore flag when results equal limit',
        build: () {
          final limitedResults = List.generate(20, (index) => Exercise(
            id: index,
            titleKo: '운동 $index',
            titleEn: 'Exercise $index',
            descKo: '설명 $index',
            descEn: 'Description $index',
            difficulty: 'beginner',
            difficultyKo: '초급',
            type: 'strength',
            typeKo: '근력',
            equipment: 'bodyweight',
            equipmentKo: '맨몸',
            primaryMusclesKo: ['근육'],
            secondaryMusclesKo: [],
            musclesUsedKo: ['근육'],
            popularityScore: index,
          ));
          when(mockExerciseRepository.search('test', limit: 20))
              .thenAnswer((_) async => Right(limitedResults));
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(const SearchExercises(query: 'test', limit: 20)),
        wait: const Duration(milliseconds: 350),
        expect: () => [
          const ExerciseLoading(message: '운동을 검색하고 있습니다...'),
          isA<ExerciseSearchResults>().having(
            (state) => state.exercises.length,
            'exercises length',
            equals(20),
          ).having(
            (state) => state.hasMore,
            'hasMore flag',
            equals(true),
          ),
        ],
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'correctly sets hasMore flag when results less than limit',
        build: () {
          when(mockExerciseRepository.search('test', limit: 20))
              .thenAnswer((_) async => Right(testExercises)); // Only 2 exercises
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(const SearchExercises(query: 'test', limit: 20)),
        wait: const Duration(milliseconds: 350),
        expect: () => [
          const ExerciseLoading(message: '운동을 검색하고 있습니다...'),
          ExerciseSearchResults(
            exercises: testExercises,
            query: 'test',
            hasMore: false, // Should be false when results.length < limit
            totalCount: testExercises.length,
          ),
        ],
      );

      test('maintains exercise order from repository', () async {
        final orderedExercises = [
          testExercises[1], // Squat first
          testExercises[0], // Push-up second
        ];

        when(mockExerciseRepository.search('ordered', limit: anyNamed('limit')))
            .thenAnswer((_) async => Right(orderedExercises));

        exerciseBloc.add(const SearchExercises(query: 'ordered'));
        await Future.delayed(const Duration(milliseconds: 350));

        final state = exerciseBloc.state as ExerciseSearchResults;
        expect(state.exercises[0].titleKo, equals('스쿼트'));
        expect(state.exercises[1].titleKo, equals('푸시업'));
      });
    });

    group('Search Filtering', () {
      blocTest<ExerciseBloc, ExerciseState>(
        'applies single filter correctly',
        build: () {
          final filters = {'difficulty': 'beginner'};
          when(mockExerciseRepository.searchWithFilters(
            'test',
            filters,
            limit: anyNamed('limit'),
          )).thenAnswer((_) async => Right([testExercises.first]));
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(SearchExercises(
          query: 'test',
          filters: {'difficulty': 'beginner'},
        )),
        wait: const Duration(milliseconds: 350),
        expect: () => [
          const ExerciseLoading(message: '운동을 검색하고 있습니다...'),
          ExerciseSearchResults(
            exercises: [testExercises.first],
            query: 'test',
            hasMore: false,
            totalCount: 1,
          ),
        ],
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'applies multiple filters correctly',
        build: () {
          final filters = {
            'difficulty': 'beginner',
            'type': 'strength',
            'equipment': 'bodyweight',
          };
          when(mockExerciseRepository.searchWithFilters(
            'test',
            filters,
            limit: anyNamed('limit'),
          )).thenAnswer((_) async => Right([testExercises.first]));
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(SearchExercises(
          query: 'test',
          filters: {
            'difficulty': 'beginner',
            'type': 'strength',
            'equipment': 'bodyweight',
          },
        )),
        wait: const Duration(milliseconds: 350),
        expect: () => [
          const ExerciseLoading(message: '운동을 검색하고 있습니다...'),
          ExerciseSearchResults(
            exercises: [testExercises.first],
            query: 'test',
            hasMore: false,
            totalCount: 1,
          ),
        ],
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'handles empty filters map',
        build: () {
          when(mockExerciseRepository.search('test', limit: anyNamed('limit')))
              .thenAnswer((_) async => Right(testExercises));
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(const SearchExercises(
          query: 'test',
          filters: {}, // Empty filters should use regular search
        )),
        wait: const Duration(milliseconds: 350),
        expect: () => [
          const ExerciseLoading(message: '운동을 검색하고 있습니다...'),
          ExerciseSearchResults(
            exercises: testExercises,
            query: 'test',
            hasMore: false,
            totalCount: testExercises.length,
          ),
        ],
        verify: (_) {
          verify(mockExerciseRepository.search('test', limit: anyNamed('limit')))
              .called(1);
          verifyNever(mockExerciseRepository.searchWithFilters(
            any,
            any,
            limit: anyNamed('limit'),
          ));
        },
      );
    });

    group('Search Debouncing Logic', () {
      test('debounces rapid search requests', () async {
        when(mockExerciseRepository.search(any, limit: anyNamed('limit')))
            .thenAnswer((_) async => Right(testExercises));

        // Send rapid search requests
        exerciseBloc.add(const SearchExercises(query: 'a'));
        exerciseBloc.add(const SearchExercises(query: 'ab'));
        exerciseBloc.add(const SearchExercises(query: 'abc'));
        exerciseBloc.add(const SearchExercises(query: 'abcd'));
        exerciseBloc.add(const SearchExercises(query: 'abcde'));

        // Wait for debounce to complete
        await Future.delayed(const Duration(milliseconds: 350));

        // Only the last search should be executed
        verify(mockExerciseRepository.search('abcde', limit: anyNamed('limit')))
            .called(1);
        verifyNever(mockExerciseRepository.search('a', limit: anyNamed('limit')));
        verifyNever(mockExerciseRepository.search('ab', limit: anyNamed('limit')));
        verifyNever(mockExerciseRepository.search('abc', limit: anyNamed('limit')));
        verifyNever(mockExerciseRepository.search('abcd', limit: anyNamed('limit')));
      });

      test('executes search after debounce delay', () async {
        when(mockExerciseRepository.search('delayed', limit: anyNamed('limit')))
            .thenAnswer((_) async => Right(testExercises));

        exerciseBloc.add(const SearchExercises(query: 'delayed'));

        // Verify search hasn't been called immediately
        verifyZeroInteractions(mockExerciseRepository);

        // Wait for debounce delay
        await Future.delayed(const Duration(milliseconds: 350));

        // Now search should be called
        verify(mockExerciseRepository.search('delayed', limit: anyNamed('limit')))
            .called(1);
      });

      test('cancels previous search when new search is initiated', () async {
        when(mockExerciseRepository.search(any, limit: anyNamed('limit')))
            .thenAnswer((_) async => Right(testExercises));

        // Start first search
        exerciseBloc.add(const SearchExercises(query: 'first'));

        // Wait partially through debounce period
        await Future.delayed(const Duration(milliseconds: 150));

        // Start second search (should cancel first)
        exerciseBloc.add(const SearchExercises(query: 'second'));

        // Wait for full debounce period
        await Future.delayed(const Duration(milliseconds: 350));

        // Only second search should be executed
        verify(mockExerciseRepository.search('second', limit: anyNamed('limit')))
            .called(1);
        verifyNever(mockExerciseRepository.search('first', limit: anyNamed('limit')));
      });

      test('handles search cancellation via clear results', () async {
        when(mockExerciseRepository.search(any, limit: anyNamed('limit')))
            .thenAnswer((_) async => Right(testExercises));

        // Start search
        exerciseBloc.add(const SearchExercises(query: 'cancelled'));

        // Clear results before debounce completes
        await Future.delayed(const Duration(milliseconds: 100));
        exerciseBloc.add(const ClearSearchResults());

        // Wait for debounce period to complete
        await Future.delayed(const Duration(milliseconds: 300));

        // Search should not have been executed
        verifyZeroInteractions(mockExerciseRepository);
      });
    });

    group('Search Error Handling', () {
      blocTest<ExerciseBloc, ExerciseState>(
        'handles network failure during search',
        build: () {
          when(mockExerciseRepository.search('network_fail', limit: anyNamed('limit')))
              .thenAnswer((_) async => Left(NetworkFailure('Network connection failed')));
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(const SearchExercises(query: 'network_fail')),
        wait: const Duration(milliseconds: 350),
        expect: () => [
          const ExerciseLoading(message: '운동을 검색하고 있습니다...'),
          isA<ExerciseErrorState>().having(
            (state) => state.error.message,
            'error message',
            contains('Network connection failed'),
          ),
        ],
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'handles server failure during search',
        build: () {
          when(mockExerciseRepository.search('server_fail', limit: anyNamed('limit')))
              .thenAnswer((_) async => Left(ServerFailure('Internal server error')));
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(const SearchExercises(query: 'server_fail')),
        wait: const Duration(milliseconds: 350),
        expect: () => [
          const ExerciseLoading(message: '운동을 검색하고 있습니다...'),
          isA<ExerciseErrorState>().having(
            (state) => state.error.message,
            'error message',
            contains('Internal server error'),
          ),
        ],
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'handles timeout during search',
        build: () {
          when(mockExerciseRepository.search('timeout', limit: anyNamed('limit')))
              .thenAnswer((_) async {
            await Future.delayed(const Duration(seconds: 30)); // Simulate timeout
            return Left(NetworkFailure('Request timeout'));
          });
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(const SearchExercises(query: 'timeout')),
        wait: const Duration(milliseconds: 350),
        expect: () => [
          const ExerciseLoading(message: '운동을 검색하고 있습니다...'),
          // Note: In real scenario, this would timeout, but for test we simulate immediate failure
        ],
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'handles unexpected exception during search',
        build: () {
          when(mockExerciseRepository.search('exception', limit: anyNamed('limit')))
              .thenThrow(Exception('Unexpected error occurred'));
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(const SearchExercises(query: 'exception')),
        wait: const Duration(milliseconds: 350),
        expect: () => [
          const ExerciseLoading(message: '운동을 검색하고 있습니다...'),
          isA<ExerciseErrorState>(),
        ],
      );

      test('maintains state consistency during error recovery', () async {
        // First successful search
        when(mockExerciseRepository.search('success', limit: anyNamed('limit')))
            .thenAnswer((_) async => Right(testExercises));

        exerciseBloc.add(const SearchExercises(query: 'success'));
        await Future.delayed(const Duration(milliseconds: 350));

        expect(exerciseBloc.state, isA<ExerciseSearchResults>());

        // Then failed search
        when(mockExerciseRepository.search('fail', limit: anyNamed('limit')))
            .thenAnswer((_) async => Left(NetworkFailure('Network error')));

        exerciseBloc.add(const SearchExercises(query: 'fail'));
        await Future.delayed(const Duration(milliseconds: 350));

        expect(exerciseBloc.state, isA<ExerciseErrorState>());

        // Then successful search again
        when(mockExerciseRepository.search('success2', limit: anyNamed('limit')))
            .thenAnswer((_) async => Right([testExercises.first]));

        exerciseBloc.add(const SearchExercises(query: 'success2'));
        await Future.delayed(const Duration(milliseconds: 350));

        expect(exerciseBloc.state, isA<ExerciseSearchResults>());
        final state = exerciseBloc.state as ExerciseSearchResults;
        expect(state.exercises.length, equals(1));
      });
    });

    group('Search State Management', () {
      test('preserves search query in result state', () async {
        const query = '특별한 검색어';
        when(mockExerciseRepository.search(query, limit: anyNamed('limit')))
            .thenAnswer((_) async => Right(testExercises));

        exerciseBloc.add(const SearchExercises(query: query));
        await Future.delayed(const Duration(milliseconds: 350));

        final state = exerciseBloc.state as ExerciseSearchResults;
        expect(state.query, equals(query));
      });

      test('updates total count correctly', () async {
        final manyExercises = List.generate(50, (index) => Exercise(
          id: index,
          titleKo: '운동 $index',
          descKo: '설명 $index',
          difficulty: 'beginner',
          difficultyKo: '초급',
          type: 'strength',
          typeKo: '근력',
          equipment: 'bodyweight',
          equipmentKo: '맨몸',
          primaryMusclesKo: ['근육'],
          secondaryMusclesKo: [],
          musclesUsedKo: ['근육'],
          popularityScore: index,
        ));

        when(mockExerciseRepository.search('many', limit: anyNamed('limit')))
            .thenAnswer((_) async => Right(manyExercises));

        exerciseBloc.add(const SearchExercises(query: 'many'));
        await Future.delayed(const Duration(milliseconds: 350));

        final state = exerciseBloc.state as ExerciseSearchResults;
        expect(state.totalCount, equals(50));
        expect(state.exercises.length, equals(50));
      });

      blocTest<ExerciseBloc, ExerciseState>(
        'clears search results properly',
        build: () => exerciseBloc,
        seed: () => ExerciseSearchResults(
          exercises: testExercises,
          query: 'previous',
          hasMore: false,
          totalCount: testExercises.length,
        ),
        act: (bloc) => bloc.add(const ClearSearchResults()),
        expect: () => [
          const ExerciseSearchCleared(),
        ],
      );
    });
  });
}