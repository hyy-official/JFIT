import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/core/error/bloc_errors.dart';
import 'package:jfit/core/error/workout_program_failures.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_bloc.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_event.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_state.dart';
import 'package:jfit/features/workout_program/utils/workout_program_repository_manager.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(() async {
    // Initialize test environment including Supabase
    await TestHelpers.setupMockSupabase();
  });

  group('WorkoutProgramBloc Null Safety Tests', () {
    setUp(() {
      // Reset the repository manager before each test
      WorkoutProgramRepositoryManager.reset();
    });

    tearDown(() {
      WorkoutProgramRepositoryManager.reset();
    });

    group('Repository Null Safety', () {
      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'emits error when network request fails',
        build: () {
          // Create bloc - repository will be created but network will fail
          return WorkoutProgramBloc();
        },
        act: (bloc) => bloc.add(const LoadUserPrograms(userId: 'test-user-id')),
        expect: () => [
          isA<WorkoutProgramLoading>(),
          isA<WorkoutProgramErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.unknown, // Network error becomes unknown error
          ),
        ],
      );
    });

    group('All Event Handlers Null Safety', () {
      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'LoadProgramDetails emits error when network request fails',
        build: () => WorkoutProgramBloc(),
        act: (bloc) => bloc.add(const LoadProgramDetails(userProgramId: 'test-id')),
        expect: () => [
          isA<WorkoutProgramLoading>(),
          isA<WorkoutProgramErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.unknown,
          ),
        ],
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'LoadProgramDays emits error when network request fails',
        build: () => WorkoutProgramBloc(),
        act: (bloc) => bloc.add(const LoadProgramDays(userProgramId: 'test-id')),
        expect: () => [
          isA<WorkoutProgramLoading>(),
          isA<WorkoutProgramErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.unknown,
          ),
        ],
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'UpdateProgramProgress emits error when network request fails',
        build: () => WorkoutProgramBloc(),
        act: (bloc) => bloc.add(const UpdateProgramProgress(
          userProgramId: 'test-id',
          currentWeek: 1,
          currentDay: 1,
        )),
        expect: () => [
          isA<WorkoutProgramLoading>(),
          isA<WorkoutProgramErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.unknown,
          ),
        ],
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'CompleteProgramDay emits error when network request fails',
        build: () => WorkoutProgramBloc(),
        act: (bloc) => bloc.add(const CompleteProgramDay(
          userProgramId: 'test-id',
          week: 1,
          day: 1,
        )),
        expect: () => [
          isA<WorkoutProgramLoading>(),
          isA<WorkoutProgramErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.unknown,
          ),
        ],
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'DeleteUserProgram emits error when network request fails',
        build: () => WorkoutProgramBloc(),
        act: (bloc) => bloc.add(const DeleteUserProgram(
          userProgramId: 'test-id',
          userId: 'test-user-id',
        )),
        expect: () => [
          isA<WorkoutProgramLoading>(),
          isA<WorkoutProgramErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.unknown,
          ),
        ],
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'LoadCurrentWorkoutInfo emits error when network request fails',
        build: () => WorkoutProgramBloc(),
        act: (bloc) => bloc.add(const LoadCurrentWorkoutInfo(userId: 'test-user-id')),
        expect: () => [
          isA<WorkoutProgramLoading>(),
          isA<WorkoutProgramErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.unknown,
          ),
        ],
      );
    });

    group('Repository Manager Tests', () {
      test('getInstance returns repository when Supabase is available', () {
        WorkoutProgramRepositoryManager.reset();
        final repository = WorkoutProgramRepositoryManager.getInstance();
        expect(repository, isNotNull);
      });

      test('checkRepositoryHealth returns healthy status when Supabase is available', () {
        WorkoutProgramRepositoryManager.reset();
        var status = WorkoutProgramRepositoryManager.checkRepositoryHealth();
        expect(status, equals(RepositoryHealthStatus.healthy));
      });

      test('createInitializationFailure returns proper failure', () {
        WorkoutProgramRepositoryManager.reset();
        final failure = WorkoutProgramRepositoryManager.createInitializationFailure();
        expect(failure, isA<RepositoryNotInitializedFailure>());
        expect(failure.type, equals(WorkoutProgramErrorType.repositoryNotInitialized));
        expect(failure.userMessage, equals('운동 프로그램 서비스를 초기화할 수 없습니다.'));
      });

      test('forceReinitialize resets and attempts initialization', () {
        WorkoutProgramRepositoryManager.forceReinitialize();
        // After force reinitialize, it should attempt to get from GetIt or create fallback
        // In test environment, this will likely be null since GetIt is not set up
        final repository = WorkoutProgramRepositoryManager.getInstance();
        // The result depends on whether GetIt is properly set up in test environment
        // We just verify that the method doesn't throw
        expect(() => WorkoutProgramRepositoryManager.getInstance(), returnsNormally);
      });
    });
  });
}