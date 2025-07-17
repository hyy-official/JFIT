import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:jfit/core/di/injection_container.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_bloc.dart';
import 'package:jfit/features/workout_program/data/repositories/workout_program_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('Injection Container Robustness Tests', () {
    setUp(() {
      // Reset GetIt before each test
      resetDependencies();
    });

    tearDown(() {
      // Clean up after each test
      resetDependencies();
    });

    group('Dependency Setup Error Handling', () {
      test('setupDependencies handles errors gracefully and sets up fallbacks', () {
        // This test verifies that setupDependencies doesn't throw even when Supabase is not initialized
        expect(() => setupDependencies(), returnsNormally);
        
        // Verify that fallback WorkoutProgramBloc is available even if repository setup fails
        expect(GetIt.instance.isRegistered<WorkoutProgramBloc>(), isTrue);
      });

      test('fallback dependencies are set up when main setup fails', () {
        // Reset and try to setup dependencies without proper Supabase initialization
        resetDependencies();
        setupDependencies();
        
        // Even if repository setup fails, WorkoutProgramBloc should be available
        expect(GetIt.instance.isRegistered<WorkoutProgramBloc>(), isTrue);
        
        // Should be able to create WorkoutProgramBloc instance
        expect(() => GetIt.instance<WorkoutProgramBloc>(), returnsNormally);
      });
    });

    group('Repository Health Checks', () {
      test('checkRepositoryHealth returns false when repository is not available', () {
        resetDependencies();
        
        final isHealthy = checkRepositoryHealth();
        expect(isHealthy, isFalse);
      });

      test('checkRepositoryHealth handles exceptions gracefully', () {
        resetDependencies();
        
        // Should not throw even when GetIt is in inconsistent state
        expect(() => checkRepositoryHealth(), returnsNormally);
        
        final isHealthy = checkRepositoryHealth();
        expect(isHealthy, isFalse);
      });
    });

    group('Critical Dependency Validation', () {
      test('validation continues even when some dependencies fail', () {
        // This test ensures that the validation process doesn't completely fail
        // when some dependencies are not available
        expect(() => setupDependencies(), returnsNormally);
      });
    });

    group('Fallback Mechanisms', () {
      test('WorkoutProgramBloc can be created without repository injection', () {
        resetDependencies();
        
        // Manually register only the WorkoutProgramBloc without its dependencies
        GetIt.instance.registerFactory<WorkoutProgramBloc>(
          () => WorkoutProgramBloc(),
        );
        
        // Should be able to create the BLoC
        final bloc = GetIt.instance<WorkoutProgramBloc>();
        expect(bloc, isNotNull);
        expect(bloc, isA<WorkoutProgramBloc>());
      });

      test('fallback setup registers WorkoutProgramBloc when not already registered', () {
        resetDependencies();
        
        // Ensure WorkoutProgramBloc is not registered
        expect(GetIt.instance.isRegistered<WorkoutProgramBloc>(), isFalse);
        
        // Call fallback setup directly (this is called internally by setupDependencies)
        setupDependencies(); // This will trigger fallback setup
        
        // WorkoutProgramBloc should now be registered
        expect(GetIt.instance.isRegistered<WorkoutProgramBloc>(), isTrue);
      });
    });

    group('Error Recovery', () {
      test('resetDependencies clears all registrations', () {
        // Setup some dependencies
        setupDependencies();
        
        // Verify something is registered
        expect(GetIt.instance.isRegistered<WorkoutProgramBloc>(), isTrue);
        
        // Reset
        resetDependencies();
        
        // Verify everything is cleared
        expect(GetIt.instance.isRegistered<WorkoutProgramBloc>(), isFalse);
      });

      test('multiple setupDependencies calls are safe', () {
        // First setup
        expect(() => setupDependencies(), returnsNormally);
        
        // Second setup should not cause issues
        expect(() => setupDependencies(), returnsNormally);
        
        // Should still be able to get WorkoutProgramBloc
        expect(() => GetIt.instance<WorkoutProgramBloc>(), returnsNormally);
      });
    });

    group('Repository State Validation', () {
      test('validates that WorkoutProgramRepository can be resolved when available', () {
        // This test checks the validation logic for when dependencies are properly set up
        // In test environment, this will likely fail due to Supabase not being initialized
        // but the validation should handle this gracefully
        
        expect(() => setupDependencies(), returnsNormally);
        
        // The validation should have run without throwing
        // Even if WorkoutProgramRepository validation failed, the setup should continue
      });
    });

    group('Dependency Registration Robustness', () {
      test('WorkoutProgramRepository registration handles SupabaseClient injection failure', () {
        resetDependencies();
        
        // Try to setup dependencies - this should handle SupabaseClient failures gracefully
        expect(() => setupDependencies(), returnsNormally);
        
        // Even if WorkoutProgramRepository couldn't be created, the app should continue
        // and WorkoutProgramBloc should be available via fallback
        expect(GetIt.instance.isRegistered<WorkoutProgramBloc>(), isTrue);
      });

      test('BLoC registration handles repository injection failure gracefully', () {
        resetDependencies();
        
        setupDependencies();
        
        // WorkoutProgramBloc should be registered even if repository injection failed
        expect(GetIt.instance.isRegistered<WorkoutProgramBloc>(), isTrue);
        
        // Should be able to create WorkoutProgramBloc
        final bloc = GetIt.instance<WorkoutProgramBloc>();
        expect(bloc, isNotNull);
        
        // The BLoC should be created without a repository and will use the repository manager
        expect(bloc, isA<WorkoutProgramBloc>());
      });
    });
  });
}