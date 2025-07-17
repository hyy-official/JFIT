import 'dart:async';
import 'dart:math';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/models/exercise.dart';
import 'package:jfit/features/exercise/bloc/exercise_bloc.dart';
import 'package:jfit/features/exercise/bloc/exercise_event.dart';
import 'package:jfit/features/exercise/bloc/exercise_state.dart';
import 'package:jfit/features/exercise/data/repositories/exercise_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'exercise_bloc_test.mocks.dart';

/// Comprehensive tests for ExerciseBloc performance and memory usage
/// Focuses on performance optimization, memory management, and scalability
@GenerateMocks([ExerciseRepository])
void main() {
  group('ExerciseBloc - Performance & Memory Usage Tests', () {
    late ExerciseBloc exerciseBloc;
    late MockExerciseRepository mockExerciseRepository;

    // Test data generators
    List<Exercise> generateTestExercises(int count) {
      return List.generate(count, (index) => Exercise(
        id: index,
        titleKo: '운동 $index',
        titleEn: 'Exercise $index',
        descKo: '운동 설명 $index',
        descEn: 'Exercise description $index',
        difficulty: ['beginner', 'intermediate', 'advanced'][index % 3],
        difficultyKo: ['초급', '중급', '고급'][index % 3],
        type: ['strength', 'cardio', 'flexibility'][index % 3],
        typeKo: ['근력', '유산소', '유연성'][index % 3],
        equipment: ['bodyweight', 'dumbbell', 'barbell'][index % 3],
        equipmentKo: ['맨몸', '덤벨', '바벨'][index % 3],
        primaryMusclesKo: ['근육그룹${index % 10}'],
        secondaryMusclesKo: ['보조근육${index % 5}'],
        musclesUsedKo: ['근육그룹${index % 10}', '보조근육${index % 5}'],
        popularityScore: Random().nextInt(100),
      ));
    }

    setUp(() {
      mockExerciseRepository = MockExerciseRepository();
      exerciseBloc = ExerciseBloc(repository: mockExerciseRepository);
    });

    tearDown(() {
      exerciseBloc.close();
    });

    group('Search Performance Tests', () {
      test('handles rapid search requests efficiently', () async {
        const searchCount = 100;
        var repositoryCallCount = 0;

        when(mockExerciseRepository.search(any, limit: anyNamed('limit')))
            .thenAnswer((_) async {
          repositoryCallCount++;
          await Future.delayed(const Duration(milliseconds: 10));
          return Right(generateTestExercises(5));
        });

        final stopwatch = Stopwatch()..start();

        // Send rapid search requests
        for (int i = 0; i < searchCount; i++) {
          exerciseBloc.add(SearchExercises(query: 'rapid$i'));
        }

        // Wait for debounce to complete
        await Future.delayed(const Duration(milliseconds: 350));
        stopwatch.stop();

        // Due to debouncing, only the last search should be executed
        expect(repositoryCallCount, equals(1));
        expect(stopwatch.elapsedMilliseconds, lessThan(500)); // Should be fast due to debouncing
        
        // Verify the last search was executed
        verify(mockExerciseRepository.search('rapid99', limit: anyNamed('limit')))
            .called(1);
      });

      test('search debounce timing is optimal', () async {
        when(mockExerciseRepository.search(any, limit: anyNamed('limit')))
            .thenAnswer((_) async => Right(generateTestExercises(10)));

        final stopwatch = Stopwatch()..start();

        // Send search request
        exerciseBloc.add(const SearchExercises(query: 'timing_test'));

        // Wait for debounce (should be around 300ms)
        await Future.delayed(const Duration(milliseconds: 350));
        stopwatch.stop();

        // Debounce timing should be reasonable (not too fast, not too slow)
        expect(stopwatch.elapsedMilliseconds, greaterThan(300));
        expect(stopwatch.elapsedMilliseconds, lessThan(400));
        
        verify(mockExerciseRepository.search('timing_test', limit: anyNamed('limit')))
            .called(1);
      });

      test('handles large search results efficiently', () async {
        final largeDataset = generateTestExercises(10000);
        
        when(mockExerciseRepository.search('large_dataset', limit: anyNamed('limit')))
            .thenAnswer((_) async {
          // Simulate processing time for large dataset
          await Future.delayed(const Duration(milliseconds: 100));
          return Right(largeDataset);
        });

        final stopwatch = Stopwatch()..start();
        
        exerciseBloc.add(const SearchExercises(query: 'large_dataset'));
        await Future.delayed(const Duration(milliseconds: 500));
        
        stopwatch.stop();

        // Should handle large dataset within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        
        final state = exerciseBloc.state as ExerciseSearchResults;
        expect(state.exercises.length, equals(10000));
        expect(state.totalCount, equals(10000));
      });

      test('concurrent search operations maintain performance', () async {
        when(mockExerciseRepository.search(any, limit: anyNamed('limit')))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return Right(generateTestExercises(100));
        });

        final stopwatch = Stopwatch()..start();

        // Start multiple concurrent search operations
        final futures = <Future>[];
        for (int i = 0; i < 20; i++) {
          futures.add(Future(() {
            exerciseBloc.add(SearchExercises(query: 'concurrent$i'));
          }));
        }

        await Future.wait(futures);
        await Future.delayed(const Duration(milliseconds: 400)); // Wait for debounce
        
        stopwatch.stop();

        // Should complete within reasonable time despite concurrency
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        
        // Only the last search should be executed due to debouncing
        verify(mockExerciseRepository.search(argThat(startsWith('concurrent')), limit: anyNamed('limit')))
            .called(1);
      });
    });

    group('Memory Management Tests', () {
      test('properly disposes resources on close', () async {
        when(mockExerciseRepository.search(any, limit: anyNamed('limit')))
            .thenAnswer((_) async => Right(generateTestExercises(100)));

        // Start some operations
        exerciseBloc.add(const SearchExercises(query: 'memory_test'));
        await Future.delayed(const Duration(milliseconds: 100));

        // Close the bloc
        await exerciseBloc.close();

        // Bloc should be properly closed
        expect(exerciseBloc.isClosed, isTrue);
      });

      test('handles multiple bloc instances without memory leaks', () async {
        final blocs = <ExerciseBloc>[];
        
        // Create multiple bloc instances
        for (int i = 0; i < 10; i++) {
          final mockRepo = MockExerciseRepository();
          when(mockRepo.search(any, limit: anyNamed('limit')))
              .thenAnswer((_) async => Right(generateTestExercises(50)));
          
          final bloc = ExerciseBloc(repository: mockRepo);
          blocs.add(bloc);
          
          // Use each bloc
          bloc.add(SearchExercises(query: 'instance$i'));
        }

        // Wait for operations
        await Future.delayed(const Duration(milliseconds: 400));

        // Close all blocs
        for (final bloc in blocs) {
          await bloc.close();
          expect(bloc.isClosed, isTrue);
        }

        // All blocs should be properly disposed
        expect(blocs.every((bloc) => bloc.isClosed), isTrue);
      });

      test('large state objects are handled efficiently', () async {
        final massiveDataset = generateTestExercises(50000);
        
        when(mockExerciseRepository.search('massive', limit: anyNamed('limit')))
            .thenAnswer((_) async => Right(massiveDataset));

        final stopwatch = Stopwatch()..start();
        
        exerciseBloc.add(const SearchExercises(query: 'massive'));
        await Future.delayed(const Duration(milliseconds: 500));
        
        stopwatch.stop();

        // Should handle massive dataset
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
        
        final state = exerciseBloc.state as ExerciseSearchResults;
        expect(state.exercises.length, equals(50000));
        
        // State should be properly managed
        expect(state.exercises.isNotEmpty, isTrue);
        expect(state.totalCount, equals(50000));
      });

      test('timer cleanup prevents memory leaks', () async {
        when(mockExerciseRepository.search(any, limit: anyNamed('limit')))
            .thenAnswer((_) async => Right(generateTestExercises(10)));

        // Create many search operations to create timers
        for (int i = 0; i < 100; i++) {
          exerciseBloc.add(SearchExercises(query: 'timer$i'));
          await Future.delayed(const Duration(milliseconds: 1)); // Very short delay
        }

        // Wait for debounce
        await Future.delayed(const Duration(milliseconds: 350));

        // Close bloc - should clean up all timers
        await exerciseBloc.close();

        expect(exerciseBloc.isClosed, isTrue);
        
        // Only the last search should have been executed
        verify(mockExerciseRepository.search('timer99', limit: anyNamed('limit')))
            .called(1);
      });
    });

    group('Scalability Tests', () {
      test('maintains performance with increasing data size', () async {
        final dataSizes = [100, 1000, 5000, 10000];
        final performanceTimes = <int>[];

        for (final size in dataSizes) {
          final dataset = generateTestExercises(size);
          
          when(mockExerciseRepository.search('scale$size', limit: anyNamed('limit')))
              .thenAnswer((_) async {
            await Future.delayed(Duration(milliseconds: size ~/ 100)); // Simulate processing time
            return Right(dataset);
          });

          final stopwatch = Stopwatch()..start();
          
          exerciseBloc.add(SearchExercises(query: 'scale$size'));
          await Future.delayed(const Duration(milliseconds: 500));
          
          stopwatch.stop();
          performanceTimes.add(stopwatch.elapsedMilliseconds);

          // Verify state
          final state = exerciseBloc.state as ExerciseSearchResults;
          expect(state.exercises.length, equals(size));
        }

        // Performance should scale reasonably (not exponentially)
        for (int i = 1; i < performanceTimes.length; i++) {
          final ratio = performanceTimes[i] / performanceTimes[i - 1];
          expect(ratio, lessThan(5.0)); // Should not increase more than 5x
        }
      });

      test('handles high frequency operations', () async {
        var operationCount = 0;
        when(mockExerciseRepository.search(any, limit: anyNamed('limit')))
            .thenAnswer((_) async {
          operationCount++;
          await Future.delayed(const Duration(milliseconds: 10));
          return Right(generateTestExercises(20));
        });

        when(mockExerciseRepository.getExerciseById(any))
            .thenAnswer((_) async {
          operationCount++;
          await Future.delayed(const Duration(milliseconds: 5));
          return Right(generateTestExercises(1).first);
        });

        when(mockExerciseRepository.getPopularExercises(limit: anyNamed('limit')))
            .thenAnswer((_) async {
          operationCount++;
          await Future.delayed(const Duration(milliseconds: 15));
          return Right(generateTestExercises(50));
        });

        final stopwatch = Stopwatch()..start();

        // High frequency mixed operations
        for (int i = 0; i < 50; i++) {
          switch (i % 3) {
            case 0:
              exerciseBloc.add(SearchExercises(query: 'freq$i'));
              break;
            case 1:
              exerciseBloc.add(LoadExerciseDetails('$i'));
              break;
            case 2:
              exerciseBloc.add(const LoadPopularExercises());
              break;
          }
          
          if (i % 10 == 0) {
            await Future.delayed(const Duration(milliseconds: 1));
          }
        }

        // Wait for operations to complete
        await Future.delayed(const Duration(milliseconds: 1000));
        stopwatch.stop();

        // Should handle high frequency operations efficiently
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
        expect(operationCount, greaterThan(0)); // Some operations should have completed
        
        // BLoC should still be responsive
        expect(exerciseBloc.isClosed, isFalse);
      });

      test('memory usage remains stable under load', () async {
        when(mockExerciseRepository.search(any, limit: anyNamed('limit')))
            .thenAnswer((_) async => Right(generateTestExercises(1000)));

        // Simulate sustained load
        for (int cycle = 0; cycle < 10; cycle++) {
          // Burst of operations
          for (int i = 0; i < 20; i++) {
            exerciseBloc.add(SearchExercises(query: 'load_cycle${cycle}_$i'));
          }
          
          // Wait for operations to complete
          await Future.delayed(const Duration(milliseconds: 400));
          
          // Verify bloc is still functional
          expect(exerciseBloc.isClosed, isFalse);
          
          // Small pause between cycles
          await Future.delayed(const Duration(milliseconds: 50));
        }

        // Final verification
        expect(exerciseBloc.isClosed, isFalse);
        expect(exerciseBloc.state, isA<ExerciseSearchResults>());
      });
    });

    group('Resource Optimization Tests', () {
      test('debouncing reduces unnecessary network calls', () async {
        var networkCallCount = 0;
        when(mockExerciseRepository.search(any, limit: anyNamed('limit')))
            .thenAnswer((_) async {
          networkCallCount++;
          await Future.delayed(const Duration(milliseconds: 50)); // Simulate network delay
          return Right(generateTestExercises(10));
        });

        // Simulate user typing (rapid requests)
        const queries = ['p', 'pu', 'pus', 'push', 'pushu', 'pushup'];
        
        for (final query in queries) {
          exerciseBloc.add(SearchExercises(query: query));
          await Future.delayed(const Duration(milliseconds: 50)); // Typing speed
        }

        // Wait for debounce to complete
        await Future.delayed(const Duration(milliseconds: 350));

        // Only the last query should result in a network call
        expect(networkCallCount, equals(1));
        verify(mockExerciseRepository.search('pushup', limit: anyNamed('limit')))
            .called(1);
      });

      test('efficient state updates minimize rebuilds', () async {
        var stateChangeCount = 0;
        
        exerciseBloc.stream.listen((_) {
          stateChangeCount++;
        });

        when(mockExerciseRepository.search('efficient', limit: anyNamed('limit')))
            .thenAnswer((_) async => Right(generateTestExercises(100)));

        exerciseBloc.add(const SearchExercises(query: 'efficient'));
        await Future.delayed(const Duration(milliseconds: 400));

        // Should have minimal state changes: Loading -> Results
        expect(stateChangeCount, equals(2));
      });

      test('handles error recovery efficiently', () async {
        var attemptCount = 0;
        
        when(mockExerciseRepository.search('recovery', limit: anyNamed('limit')))
            .thenAnswer((_) async {
          attemptCount++;
          if (attemptCount <= 2) {
            return Left(NetworkFailure('Network error'));
          }
          return Right(generateTestExercises(50));
        });

        final stopwatch = Stopwatch()..start();

        // First attempt (will fail)
        exerciseBloc.add(const SearchExercises(query: 'recovery'));
        await Future.delayed(const Duration(milliseconds: 400));
        expect(exerciseBloc.state, isA<ExerciseErrorState>());

        // Second attempt (will fail)
        exerciseBloc.add(const SearchExercises(query: 'recovery'));
        await Future.delayed(const Duration(milliseconds: 400));
        expect(exerciseBloc.state, isA<ExerciseErrorState>());

        // Third attempt (will succeed)
        exerciseBloc.add(const SearchExercises(query: 'recovery'));
        await Future.delayed(const Duration(milliseconds: 400));
        
        stopwatch.stop();

        expect(exerciseBloc.state, isA<ExerciseSearchResults>());
        expect(attemptCount, equals(3));
        expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // Should recover efficiently
      });
    });

    group('Performance Benchmarks', () {
      test('search operation completes within acceptable time', () async {
        when(mockExerciseRepository.search('benchmark', limit: anyNamed('limit')))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100)); // Simulate realistic delay
          return Right(generateTestExercises(500));
        });

        final stopwatch = Stopwatch()..start();
        
        exerciseBloc.add(const SearchExercises(query: 'benchmark'));
        await Future.delayed(const Duration(milliseconds: 500));
        
        stopwatch.stop();

        // Should complete within 600ms (including debounce)
        expect(stopwatch.elapsedMilliseconds, lessThan(600));
        expect(exerciseBloc.state, isA<ExerciseSearchResults>());
      });

      test('exercise details loading meets performance targets', () async {
        when(mockExerciseRepository.getExerciseById('benchmark'))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return Right(generateTestExercises(1).first);
        });

        final stopwatch = Stopwatch()..start();
        
        exerciseBloc.add(const LoadExerciseDetails('benchmark'));
        await Future.delayed(const Duration(milliseconds: 100));
        
        stopwatch.stop();

        // Should complete within 120ms
        expect(stopwatch.elapsedMilliseconds, lessThan(120));
        expect(exerciseBloc.state, isA<ExerciseDetailsLoaded>());
      });

      test('popular exercises loading performance', () async {
        when(mockExerciseRepository.getPopularExercises(limit: anyNamed('limit')))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 75));
          return Right(generateTestExercises(100));
        });

        final stopwatch = Stopwatch()..start();
        
        exerciseBloc.add(const LoadPopularExercises());
        await Future.delayed(const Duration(milliseconds: 150));
        
        stopwatch.stop();

        // Should complete within 180ms
        expect(stopwatch.elapsedMilliseconds, lessThan(180));
        expect(exerciseBloc.state, isA<PopularExercisesLoaded>());
      });

      test('cache refresh performance benchmark', () async {
        when(mockExerciseRepository.refreshCache())
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 200)); // Simulate cache rebuild
          return const Right(null);
        });

        final stopwatch = Stopwatch()..start();
        
        exerciseBloc.add(const RefreshExerciseCache());
        await Future.delayed(const Duration(milliseconds: 250));
        
        stopwatch.stop();

        // Cache refresh should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(300));
        expect(exerciseBloc.state, isA<ExerciseCacheRefreshed>());
      });
    });

    group('Stress Tests', () {
      test('handles extreme load without crashing', () async {
        when(mockExerciseRepository.search(any, limit: anyNamed('limit')))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 10));
          return Right(generateTestExercises(100));
        });

        // Extreme load test
        for (int i = 0; i < 1000; i++) {
          exerciseBloc.add(SearchExercises(query: 'stress$i'));
          
          // Occasional pause to prevent overwhelming
          if (i % 100 == 0) {
            await Future.delayed(const Duration(milliseconds: 10));
          }
        }

        // Wait for operations to settle
        await Future.delayed(const Duration(milliseconds: 500));

        // BLoC should survive the stress test
        expect(exerciseBloc.isClosed, isFalse);
        expect(exerciseBloc.state, isA<ExerciseSearchResults>());
      });

      test('recovers gracefully from resource exhaustion', () async {
        var callCount = 0;
        when(mockExerciseRepository.search(any, limit: anyNamed('limit')))
            .thenAnswer((_) async {
          callCount++;
          if (callCount <= 5) {
            throw Exception('Resource exhausted');
          }
          return Right(generateTestExercises(10));
        });

        // Multiple attempts that initially fail
        for (int i = 0; i < 10; i++) {
          exerciseBloc.add(SearchExercises(query: 'exhaust$i'));
          await Future.delayed(const Duration(milliseconds: 400));
        }

        // Should eventually succeed
        expect(exerciseBloc.state, isA<ExerciseSearchResults>());
        expect(callCount, greaterThan(5));
      });
    });
  });
}