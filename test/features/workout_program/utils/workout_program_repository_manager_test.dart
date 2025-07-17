import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jfit/features/workout_program/utils/workout_program_repository_manager.dart';
import 'package:jfit/features/workout_program/data/repositories/workout_program_repository.dart';
import 'package:jfit/core/error/workout_program_failures.dart';

import 'workout_program_repository_manager_test.mocks.dart';

@GenerateMocks([
  WorkoutProgramRepository,
  SupabaseClient,
])
void main() {
  group('WorkoutProgramRepositoryManager', () {
    late MockWorkoutProgramRepository mockRepository;
    late MockSupabaseClient mockSupabaseClient;

    setUp(() {
      mockRepository = MockWorkoutProgramRepository();
      mockSupabaseClient = MockSupabaseClient();
      
      // Reset manager state before each test
      WorkoutProgramRepositoryManager.reset();
      
      // Clear GetIt registrations
      if (GetIt.instance.isRegistered<WorkoutProgramRepository>()) {
        GetIt.instance.unregister<WorkoutProgramRepository>();
      }
      if (GetIt.instance.isRegistered<SupabaseClient>()) {
        GetIt.instance.unregister<SupabaseClient>();
      }
    });

    tearDown(() {
      // Clean up after each test
      WorkoutProgramRepositoryManager.reset();
      GetIt.instance.reset();
    });

    group('getInstance', () {
      test('should return null when repository cannot be initialized', () {
        // arrange - no registrations in GetIt

        // act
        final result = WorkoutProgramRepositoryManager.getInstance();

        // assert
        expect(result, isNull);
      });

      test('should return repository from GetIt when registered', () {
        // arrange
        GetIt.instance.registerSingleton<WorkoutProgramRepository>(mockRepository);

        // act
        final result = WorkoutProgramRepositoryManager.getInstance();

        // assert
        expect(result, equals(mockRepository));
      });

      test('should return same instance on multiple calls', () {
        // arrange
        GetIt.instance.registerSingleton<WorkoutProgramRepository>(mockRepository);

        // act
        final result1 = WorkoutProgramRepositoryManager.getInstance();
        final result2 = WorkoutProgramRepositoryManager.getInstance();

        // assert
        expect(result1, equals(result2));
        expect(result1, equals(mockRepository));
      });

      test('should create fallback instance when GetIt fails but Supabase is available', () {
        // arrange
        GetIt.instance.registerSingleton<SupabaseClient>(mockSupabaseClient);

        // act
        final result = WorkoutProgramRepositoryManager.getInstance();

        // assert
        expect(result, isNotNull);
        expect(result, isA<WorkoutProgramRepository>());
      });

      test('should handle GetIt exception gracefully', () {
        // arrange
        GetIt.instance.registerSingleton<WorkoutProgramRepository>(mockRepository);
        // Simulate GetIt exception by unregistering after registration check
        GetIt.instance.unregister<WorkoutProgramRepository>();

        // act
        final result = WorkoutProgramRepositoryManager.getInstance();

        // assert
        expect(result, isNull); // Should not throw, just return null
      });
    });

    group('checkRepositoryHealth', () {
      test('should return notInitialized when repository is null', () {
        // arrange - no repository setup

        // act
        final status = WorkoutProgramRepositoryManager.checkRepositoryHealth();

        // assert
        expect(status, RepositoryHealthStatus.notInitialized);
      });

      test('should return clientUnavailable when repository exists but client is null', () {
        // arrange
        WorkoutProgramRepositoryManager.setInstance(mockRepository);
        // No Supabase client registered

        // act
        final status = WorkoutProgramRepositoryManager.checkRepositoryHealth();

        // assert
        expect(status, RepositoryHealthStatus.clientUnavailable);
      });

      test('should return healthy when both repository and client are available', () {
        // arrange
        WorkoutProgramRepositoryManager.setInstance(mockRepository);
        GetIt.instance.registerSingleton<SupabaseClient>(mockSupabaseClient);

        // act
        final status = WorkoutProgramRepositoryManager.checkRepositoryHealth();

        // assert
        expect(status, RepositoryHealthStatus.healthy);
      });
    });

    group('forceReinitialize', () {
      test('should reset and reinitialize repository', () {
        // arrange
        WorkoutProgramRepositoryManager.setInstance(mockRepository);
        final initialInstance = WorkoutProgramRepositoryManager.getInstance();
        expect(initialInstance, equals(mockRepository));

        // Register new repository in GetIt
        final newMockRepository = MockWorkoutProgramRepository();
        GetIt.instance.registerSingleton<WorkoutProgramRepository>(newMockRepository);

        // act
        WorkoutProgramRepositoryManager.forceReinitialize();

        // assert
        final newInstance = WorkoutProgramRepositoryManager.getInstance();
        expect(newInstance, equals(newMockRepository));
        expect(newInstance, isNot(equals(mockRepository)));
      });
    });

    group('setInstance', () {
      test('should set repository instance manually', () {
        // arrange & act
        WorkoutProgramRepositoryManager.setInstance(mockRepository);

        // assert
        final result = WorkoutProgramRepositoryManager.getInstance();
        expect(result, equals(mockRepository));
      });
    });

    group('reset', () {
      test('should clear repository instance and initialization flag', () {
        // arrange
        WorkoutProgramRepositoryManager.setInstance(mockRepository);
        expect(WorkoutProgramRepositoryManager.getInstance(), isNotNull);

        // act
        WorkoutProgramRepositoryManager.reset();

        // assert
        final result = WorkoutProgramRepositoryManager.getInstance();
        expect(result, isNull); // Should be null since no registrations
      });
    });

    group('createInitializationFailure', () {
      test('should create failure with notInitialized status', () {
        // arrange - no repository setup

        // act
        final failure = WorkoutProgramRepositoryManager.createInitializationFailure();

        // assert
        expect(failure, isA<RepositoryNotInitializedFailure>());
        expect(failure.technicalMessage, contains('Repository instance could not be created'));
      });

      test('should create failure with clientUnavailable status', () {
        // arrange
        WorkoutProgramRepositoryManager.setInstance(mockRepository);
        // No Supabase client

        // act
        final failure = WorkoutProgramRepositoryManager.createInitializationFailure();

        // assert
        expect(failure, isA<RepositoryNotInitializedFailure>());
        expect(failure.technicalMessage, contains('Supabase client is not available'));
      });

      test('should create failure with healthy status when repository appears healthy', () {
        // arrange
        WorkoutProgramRepositoryManager.setInstance(mockRepository);
        GetIt.instance.registerSingleton<SupabaseClient>(mockSupabaseClient);

        // act
        final failure = WorkoutProgramRepositoryManager.createInitializationFailure();

        // assert
        expect(failure, isA<RepositoryNotInitializedFailure>());
        expect(failure.technicalMessage, contains('Repository appears healthy but initialization failed'));
      });
    });

    group('null safety mechanisms', () {
      test('should handle null repository gracefully in getInstance', () {
        // arrange - ensure no repository is available

        // act & assert - should not throw
        expect(() => WorkoutProgramRepositoryManager.getInstance(), returnsNormally);
        expect(WorkoutProgramRepositoryManager.getInstance(), isNull);
      });

      test('should handle multiple initialization attempts', () {
        // arrange - first call will attempt initialization

        // act
        final result1 = WorkoutProgramRepositoryManager.getInstance();
        final result2 = WorkoutProgramRepositoryManager.getInstance();

        // assert
        expect(result1, equals(result2)); // Should be consistent
      });

      test('should handle Supabase client initialization failure', () {
        // arrange - no Supabase setup

        // act & assert - should not throw
        expect(() => WorkoutProgramRepositoryManager.getInstance(), returnsNormally);
      });
    });

    group('error scenarios', () {
      test('should handle GetIt registration check exception', () {
        // This test simulates internal GetIt exceptions
        // In practice, this would be hard to trigger, but we test the error handling path

        // act & assert - should not throw even if internal errors occur
        expect(() => WorkoutProgramRepositoryManager.getInstance(), returnsNormally);
      });

      test('should handle repository creation exception', () {
        // arrange - register a client that might cause creation issues
        GetIt.instance.registerSingleton<SupabaseClient>(mockSupabaseClient);

        // act & assert - should handle any repository creation errors gracefully
        expect(() => WorkoutProgramRepositoryManager.getInstance(), returnsNormally);
      });
    });
  });
}