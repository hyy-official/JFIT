import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/core/error/bloc_errors.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_bloc.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_event.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_state.dart';
import 'package:jfit/features/workout_program/data/repositories/workout_program_repository.dart';
import 'package:jfit/features/workout_program/data/models/user_program_model.dart';
import 'package:jfit/features/workout_program/data/models/current_workout_info_model.dart';
import 'package:jfit/features/programs/data/models/user_program_day_model.dart';
import 'package:jfit/features/programs/domain/entities/workout_program.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'workout_program_bloc_test.mocks.dart';

@GenerateMocks([WorkoutProgramRepository])
void main() {
  group('WorkoutProgramBloc', () {
    late WorkoutProgramBloc workoutProgramBloc;
    late MockWorkoutProgramRepository mockWorkoutProgramRepository;

    setUp(() {
      mockWorkoutProgramRepository = MockWorkoutProgramRepository();
      workoutProgramBloc = WorkoutProgramBloc(
        workoutProgramRepository: mockWorkoutProgramRepository,
      );
    });

    tearDown(() {
      workoutProgramBloc.close();
    });

    test('initial state is WorkoutProgramInitial', () {
      expect(workoutProgramBloc.state, equals(const WorkoutProgramInitial()));
    });

    group('LoadUserPrograms', () {
      const userId = 'test-user-id';
      final testWorkoutProgram = WorkoutProgram(
        id: 'program-1',
        name: 'Test Program',
        creator: 'Test Creator',
        description: 'Test Description',
        durationWeeks: 4,
        difficultyLevel: 'beginner',
        programType: 'strength',
        workoutsPerWeek: 3,
        rating: 4.5,
        totalRatings: 100,
        isPopular: true,
        isPublic: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
        isSample: false,
      );

      final userPrograms = [
        UserProgramModel(
          id: 'user-program-1',
          userId: userId,
          programId: 'program-1',
          currentWeek: 2,
          currentDay: 3,
          isActive: true,
          startedAt: DateTime.now().subtract(const Duration(days: 10)),
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now(),
          workoutProgram: testWorkoutProgram,
        ),
      ];

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'emits [WorkoutProgramLoading, UserProgramsLoaded] when LoadUserPrograms succeeds',
        build: () {
          when(mockWorkoutProgramRepository.getUserPrograms(userId))
              .thenAnswer((_) async => Right(userPrograms));
          return workoutProgramBloc;
        },
        act: (bloc) => bloc.add(const LoadUserPrograms(userId: userId)),
        expect: () => [
          const WorkoutProgramLoading(message: 'Loading user programs...'),
          UserProgramsLoaded(userPrograms: userPrograms),
        ],
        verify: (_) {
          verify(mockWorkoutProgramRepository.getUserPrograms(userId)).called(1);
        },
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'emits [WorkoutProgramLoading, WorkoutProgramErrorState] when LoadUserPrograms fails',
        build: () {
          when(mockWorkoutProgramRepository.getUserPrograms(userId))
              .thenAnswer((_) async => const Left(ServerFailure('Server error')));
          return workoutProgramBloc;
        },
        act: (bloc) => bloc.add(const LoadUserPrograms(userId: userId)),
        expect: () => [
          const WorkoutProgramLoading(message: 'Loading user programs...'),
          isA<WorkoutProgramErrorState>(),
        ],
        verify: (_) {
          verify(mockWorkoutProgramRepository.getUserPrograms(userId)).called(1);
        },
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'emits [WorkoutProgramErrorState] when userId is empty',
        build: () => workoutProgramBloc,
        act: (bloc) => bloc.add(const LoadUserPrograms(userId: '')),
        expect: () => [
          isA<WorkoutProgramErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.validationError,
          ),
        ],
        verify: (_) {
          verifyZeroInteractions(mockWorkoutProgramRepository);
        },
      );
    });

    group('LoadProgramDetails', () {
      const userProgramId = 'user-program-1';
      final testWorkoutProgram = WorkoutProgram(
        id: 'program-1',
        name: 'Test Program',
        creator: 'Test Creator',
        description: 'Test Description',
        durationWeeks: 4,
        difficultyLevel: 'beginner',
        programType: 'strength',
        workoutsPerWeek: 3,
        rating: 4.5,
        totalRatings: 100,
        isPopular: true,
        isPublic: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
        isSample: false,
      );

      final userProgram = UserProgramModel(
        id: userProgramId,
        userId: 'test-user-id',
        programId: 'program-1',
        currentWeek: 2,
        currentDay: 3,
        isActive: true,
        startedAt: DateTime.now().subtract(const Duration(days: 10)),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
        workoutProgram: testWorkoutProgram,
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'emits [WorkoutProgramLoading, ProgramDetailsLoaded] when LoadProgramDetails succeeds',
        build: () {
          when(mockWorkoutProgramRepository.getUserProgramDetails(userProgramId))
              .thenAnswer((_) async => Right(userProgram));
          return workoutProgramBloc;
        },
        act: (bloc) => bloc.add(const LoadProgramDetails(userProgramId: userProgramId)),
        expect: () => [
          const WorkoutProgramLoading(message: 'Loading program details...'),
          ProgramDetailsLoaded(userProgram: userProgram),
        ],
        verify: (_) {
          verify(mockWorkoutProgramRepository.getUserProgramDetails(userProgramId)).called(1);
        },
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'emits [WorkoutProgramLoading, WorkoutProgramErrorState] when program not found',
        build: () {
          when(mockWorkoutProgramRepository.getUserProgramDetails(userProgramId))
              .thenAnswer((_) async => const Right(null));
          return workoutProgramBloc;
        },
        act: (bloc) => bloc.add(const LoadProgramDetails(userProgramId: userProgramId)),
        expect: () => [
          const WorkoutProgramLoading(message: 'Loading program details...'),
          isA<WorkoutProgramErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.dataNotFound,
          ),
        ],
        verify: (_) {
          verify(mockWorkoutProgramRepository.getUserProgramDetails(userProgramId)).called(1);
        },
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'emits [WorkoutProgramErrorState] when userProgramId is empty',
        build: () => workoutProgramBloc,
        act: (bloc) => bloc.add(const LoadProgramDetails(userProgramId: '')),
        expect: () => [
          isA<WorkoutProgramErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.validationError,
          ),
        ],
        verify: (_) {
          verifyZeroInteractions(mockWorkoutProgramRepository);
        },
      );
    });

    group('LoadProgramDays', () {
      const userProgramId = 'user-program-1';
      final programDays = [
        UserProgramDayModel(
          id: 'day-1',
          userProgramId: userProgramId,
          week: 1,
          day: 1,
          completedAt: DateTime.now().subtract(const Duration(days: 5)),
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        UserProgramDayModel(
          id: 'day-2',
          userProgramId: userProgramId,
          week: 1,
          day: 2,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ];

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'emits [WorkoutProgramLoading, ProgramDaysLoaded] when LoadProgramDays succeeds',
        build: () {
          when(mockWorkoutProgramRepository.getUserProgramDays(userProgramId))
              .thenAnswer((_) async => Right(programDays));
          return workoutProgramBloc;
        },
        act: (bloc) => bloc.add(const LoadProgramDays(userProgramId: userProgramId)),
        expect: () => [
          const WorkoutProgramLoading(message: 'Loading program days...'),
          ProgramDaysLoaded(programDays: programDays, userProgramId: userProgramId),
        ],
        verify: (_) {
          verify(mockWorkoutProgramRepository.getUserProgramDays(userProgramId)).called(1);
        },
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'emits [WorkoutProgramErrorState] when userProgramId is empty',
        build: () => workoutProgramBloc,
        act: (bloc) => bloc.add(const LoadProgramDays(userProgramId: '')),
        expect: () => [
          isA<WorkoutProgramErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.validationError,
          ),
        ],
        verify: (_) {
          verifyZeroInteractions(mockWorkoutProgramRepository);
        },
      );
    });

    group('UpdateProgramProgress', () {
      const userProgramId = 'user-program-1';
      const currentWeek = 2;
      const currentDay = 3;

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'emits [WorkoutProgramLoading, ProgramProgressUpdated] when UpdateProgramProgress succeeds',
        build: () {
          when(mockWorkoutProgramRepository.updateUserProgramProgress(
            userProgramId,
            currentWeek,
            currentDay,
          )).thenAnswer((_) async => const Right(null));
          return workoutProgramBloc;
        },
        act: (bloc) => bloc.add(const UpdateProgramProgress(
          userProgramId: userProgramId,
          currentWeek: currentWeek,
          currentDay: currentDay,
        )),
        expect: () => [
          const WorkoutProgramLoading(message: 'Updating program progress...'),
          const ProgramProgressUpdated(
            userProgramId: userProgramId,
            currentWeek: currentWeek,
            currentDay: currentDay,
          ),
        ],
        verify: (_) {
          verify(mockWorkoutProgramRepository.updateUserProgramProgress(
            userProgramId,
            currentWeek,
            currentDay,
          )).called(1);
        },
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'emits [WorkoutProgramErrorState] when userProgramId is empty',
        build: () => workoutProgramBloc,
        act: (bloc) => bloc.add(const UpdateProgramProgress(
          userProgramId: '',
          currentWeek: currentWeek,
          currentDay: currentDay,
        )),
        expect: () => [
          isA<WorkoutProgramErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.validationError,
          ),
        ],
        verify: (_) {
          verifyZeroInteractions(mockWorkoutProgramRepository);
        },
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'emits [WorkoutProgramErrorState] when week is invalid',
        build: () => workoutProgramBloc,
        act: (bloc) => bloc.add(const UpdateProgramProgress(
          userProgramId: userProgramId,
          currentWeek: 0,
          currentDay: currentDay,
        )),
        expect: () => [
          isA<WorkoutProgramErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.validationError,
          ),
        ],
        verify: (_) {
          verifyZeroInteractions(mockWorkoutProgramRepository);
        },
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'emits [WorkoutProgramErrorState] when day is invalid',
        build: () => workoutProgramBloc,
        act: (bloc) => bloc.add(const UpdateProgramProgress(
          userProgramId: userProgramId,
          currentWeek: currentWeek,
          currentDay: 0,
        )),
        expect: () => [
          isA<WorkoutProgramErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.validationError,
          ),
        ],
        verify: (_) {
          verifyZeroInteractions(mockWorkoutProgramRepository);
        },
      );
    });

    group('CompleteProgramDay', () {
      const userProgramId = 'user-program-1';
      const week = 2;
      const day = 3;
      const note = 'Great workout!';

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'emits [WorkoutProgramLoading, ProgramDayCompleted] when CompleteProgramDay succeeds',
        build: () {
          when(mockWorkoutProgramRepository.completeUserProgramDay(
            userProgramId,
            week,
            day,
            note: note,
          )).thenAnswer((_) async => const Right(null));
          return workoutProgramBloc;
        },
        act: (bloc) => bloc.add(const CompleteProgramDay(
          userProgramId: userProgramId,
          week: week,
          day: day,
          note: note,
        )),
        expect: () => [
          const WorkoutProgramLoading(message: 'Completing program day...'),
          const ProgramDayCompleted(
            userProgramId: userProgramId,
            week: week,
            day: day,
            note: note,
          ),
        ],
        verify: (_) {
          verify(mockWorkoutProgramRepository.completeUserProgramDay(
            userProgramId,
            week,
            day,
            note: note,
          )).called(1);
        },
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'emits [WorkoutProgramLoading, ProgramDayCompleted] when CompleteProgramDay succeeds without note',
        build: () {
          when(mockWorkoutProgramRepository.completeUserProgramDay(
            userProgramId,
            week,
            day,
            note: null,
          )).thenAnswer((_) async => const Right(null));
          return workoutProgramBloc;
        },
        act: (bloc) => bloc.add(const CompleteProgramDay(
          userProgramId: userProgramId,
          week: week,
          day: day,
        )),
        expect: () => [
          const WorkoutProgramLoading(message: 'Completing program day...'),
          const ProgramDayCompleted(
            userProgramId: userProgramId,
            week: week,
            day: day,
            note: null,
          ),
        ],
        verify: (_) {
          verify(mockWorkoutProgramRepository.completeUserProgramDay(
            userProgramId,
            week,
            day,
            note: null,
          )).called(1);
        },
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'emits [WorkoutProgramErrorState] when userProgramId is empty',
        build: () => workoutProgramBloc,
        act: (bloc) => bloc.add(const CompleteProgramDay(
          userProgramId: '',
          week: week,
          day: day,
        )),
        expect: () => [
          isA<WorkoutProgramErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.validationError,
          ),
        ],
        verify: (_) {
          verifyZeroInteractions(mockWorkoutProgramRepository);
        },
      );
    });

    group('DeleteUserProgram', () {
      const userProgramId = 'user-program-1';
      const userId = 'test-user-id';

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'emits [WorkoutProgramLoading, UserProgramDeleted] when DeleteUserProgram succeeds',
        build: () {
          when(mockWorkoutProgramRepository.deleteUserProgram(userProgramId))
              .thenAnswer((_) async => const Right(null));
          return workoutProgramBloc;
        },
        act: (bloc) => bloc.add(const DeleteUserProgram(
          userProgramId: userProgramId,
          userId: userId,
        )),
        expect: () => [
          const WorkoutProgramLoading(message: 'Deleting user program...'),
          const UserProgramDeleted(userProgramId: userProgramId),
        ],
        verify: (_) {
          verify(mockWorkoutProgramRepository.deleteUserProgram(userProgramId)).called(1);
        },
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'emits [WorkoutProgramErrorState] when userProgramId is empty',
        build: () => workoutProgramBloc,
        act: (bloc) => bloc.add(const DeleteUserProgram(
          userProgramId: '',
          userId: userId,
        )),
        expect: () => [
          isA<WorkoutProgramErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.validationError,
          ),
        ],
        verify: (_) {
          verifyZeroInteractions(mockWorkoutProgramRepository);
        },
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'emits [WorkoutProgramErrorState] when userId is empty',
        build: () => workoutProgramBloc,
        act: (bloc) => bloc.add(const DeleteUserProgram(
          userProgramId: userProgramId,
          userId: '',
        )),
        expect: () => [
          isA<WorkoutProgramErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.validationError,
          ),
        ],
        verify: (_) {
          verifyZeroInteractions(mockWorkoutProgramRepository);
        },
      );
    });

    group('LoadCurrentWorkoutInfo', () {
      const userId = 'test-user-id';
      final currentWorkoutInfo = CurrentWorkoutInfoModel.empty();

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'emits [WorkoutProgramLoading, CurrentWorkoutInfoLoaded] when LoadCurrentWorkoutInfo succeeds',
        build: () {
          when(mockWorkoutProgramRepository.getCurrentWorkoutInfo(userId))
              .thenAnswer((_) async => Right(currentWorkoutInfo));
          return workoutProgramBloc;
        },
        act: (bloc) => bloc.add(const LoadCurrentWorkoutInfo(userId: userId)),
        expect: () => [
          const WorkoutProgramLoading(message: 'Loading current workout info...'),
          CurrentWorkoutInfoLoaded(currentWorkoutInfo: currentWorkoutInfo),
        ],
        verify: (_) {
          verify(mockWorkoutProgramRepository.getCurrentWorkoutInfo(userId)).called(1);
        },
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'emits [WorkoutProgramErrorState] when userId is empty',
        build: () => workoutProgramBloc,
        act: (bloc) => bloc.add(const LoadCurrentWorkoutInfo(userId: '')),
        expect: () => [
          isA<WorkoutProgramErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.validationError,
          ),
        ],
        verify: (_) {
          verifyZeroInteractions(mockWorkoutProgramRepository);
        },
      );
    });

    group('Error Handling', () {
      const userId = 'test-user-id';
      const userProgramId = 'user-program-1';

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'handles unexpected exceptions during LoadUserPrograms',
        setUp: () {
          reset(mockWorkoutProgramRepository);
        },
        build: () {
          when(mockWorkoutProgramRepository.getUserPrograms(userId))
              .thenThrow(Exception('Unexpected error'));
          return workoutProgramBloc;
        },
        act: (bloc) => bloc.add(const LoadUserPrograms(userId: userId)),
        expect: () => [
          const WorkoutProgramLoading(message: 'Loading user programs...'),
          isA<WorkoutProgramErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.unknown,
          ),
        ],
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'handles unexpected exceptions during UpdateProgramProgress',
        setUp: () {
          reset(mockWorkoutProgramRepository);
        },
        build: () {
          when(mockWorkoutProgramRepository.updateUserProgramProgress(
            userProgramId,
            2,
            3,
          )).thenThrow(Exception('Unexpected error'));
          return workoutProgramBloc;
        },
        act: (bloc) => bloc.add(const UpdateProgramProgress(
          userProgramId: userProgramId,
          currentWeek: 2,
          currentDay: 3,
        )),
        expect: () => [
          const WorkoutProgramLoading(message: 'Updating program progress...'),
          isA<WorkoutProgramErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.workoutProgramUpdateFailed,
          ),
        ],
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'handles unexpected exceptions during DeleteUserProgram',
        setUp: () {
          reset(mockWorkoutProgramRepository);
        },
        build: () {
          when(mockWorkoutProgramRepository.deleteUserProgram(userProgramId))
              .thenThrow(Exception('Unexpected error'));
          return workoutProgramBloc;
        },
        act: (bloc) => bloc.add(const DeleteUserProgram(
          userProgramId: userProgramId,
          userId: userId,
        )),
        expect: () => [
          const WorkoutProgramLoading(message: 'Deleting user program...'),
          isA<WorkoutProgramErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.workoutProgramDeleteFailed,
          ),
        ],
      );
    });

    group('Complex Program Progress Logic', () {
      const userId = 'test-user-id';
      const userProgramId = 'user-program-1';
      
      final testWorkoutProgram = WorkoutProgram(
        id: 'program-1',
        name: 'Advanced Program',
        creator: 'Test Creator',
        description: 'Complex program for testing',
        durationWeeks: 8,
        difficultyLevel: 'advanced',
        programType: 'hypertrophy',
        workoutsPerWeek: 5,
        rating: 4.8,
        totalRatings: 200,
        isPopular: true,
        isPublic: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
        isSample: false,
      );

      final userProgram = UserProgramModel(
        id: userProgramId,
        userId: userId,
        programId: 'program-1',
        currentWeek: 4,
        currentDay: 2,
        isActive: true,
        startedAt: DateTime.now().subtract(const Duration(days: 20)),
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
        workoutProgram: testWorkoutProgram,
      );

      final currentWorkoutInfo = CurrentWorkoutInfoModel.fromUserProgram(
        userProgram,
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 1)),
        totalCompletedDays: 15,
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'handles complex program progress calculation correctly',
        build: () {
          when(mockWorkoutProgramRepository.getCurrentWorkoutInfo(userId))
              .thenAnswer((_) async => Right(currentWorkoutInfo));
          return workoutProgramBloc;
        },
        act: (bloc) => bloc.add(const LoadCurrentWorkoutInfo(userId: userId)),
        expect: () => [
          const WorkoutProgramLoading(message: 'Loading current workout info...'),
          CurrentWorkoutInfoLoaded(currentWorkoutInfo: currentWorkoutInfo),
        ],
        verify: (_) {
          verify(mockWorkoutProgramRepository.getCurrentWorkoutInfo(userId)).called(1);
        },
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'handles program completion edge case',
        build: () {
          when(mockWorkoutProgramRepository.updateUserProgramProgress(
            userProgramId,
            8, // Final week
            5, // Final day
          )).thenAnswer((_) async => const Right(null));
          return workoutProgramBloc;
        },
        act: (bloc) => bloc.add(const UpdateProgramProgress(
          userProgramId: userProgramId,
          currentWeek: 8,
          currentDay: 5,
        )),
        expect: () => [
          const WorkoutProgramLoading(message: 'Updating program progress...'),
          const ProgramProgressUpdated(
            userProgramId: userProgramId,
            currentWeek: 8,
            currentDay: 5,
          ),
        ],
        verify: (_) {
          verify(mockWorkoutProgramRepository.updateUserProgramProgress(
            userProgramId,
            8,
            5,
          )).called(1);
        },
      );
    });

    group('Edge Cases', () {
      const userId = 'test-user-id';
      const userProgramId = 'user-program-1';

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'handles empty user programs list',
        build: () {
          when(mockWorkoutProgramRepository.getUserPrograms(userId))
              .thenAnswer((_) async => const Right([]));
          return workoutProgramBloc;
        },
        act: (bloc) => bloc.add(const LoadUserPrograms(userId: userId)),
        expect: () => [
          const WorkoutProgramLoading(message: 'Loading user programs...'),
          const UserProgramsLoaded(userPrograms: []),
        ],
        verify: (_) {
          verify(mockWorkoutProgramRepository.getUserPrograms(userId)).called(1);
        },
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'handles empty program days list',
        build: () {
          when(mockWorkoutProgramRepository.getUserProgramDays(userProgramId))
              .thenAnswer((_) async => const Right([]));
          return workoutProgramBloc;
        },
        act: (bloc) => bloc.add(const LoadProgramDays(userProgramId: userProgramId)),
        expect: () => [
          const WorkoutProgramLoading(message: 'Loading program days...'),
          const ProgramDaysLoaded(programDays: [], userProgramId: userProgramId),
        ],
        verify: (_) {
          verify(mockWorkoutProgramRepository.getUserProgramDays(userProgramId)).called(1);
        },
      );

      blocTest<WorkoutProgramBloc, WorkoutProgramState>(
        'handles network failure gracefully',
        build: () {
          when(mockWorkoutProgramRepository.getUserPrograms(userId))
              .thenAnswer((_) async => const Left(NetworkFailure('Network connection failed')));
          return workoutProgramBloc;
        },
        act: (bloc) => bloc.add(const LoadUserPrograms(userId: userId)),
        expect: () => [
          const WorkoutProgramLoading(message: 'Loading user programs...'),
          isA<WorkoutProgramErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.networkError,
          ),
        ],
        verify: (_) {
          verify(mockWorkoutProgramRepository.getUserPrograms(userId)).called(1);
        },
      );
    });
  });
}