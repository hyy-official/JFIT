import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:jfit/features/programs/presentation/bloc/programs_bloc.dart';
import 'package:jfit/features/programs/presentation/bloc/programs_state.dart';
import 'package:jfit/features/programs/presentation/bloc/programs_event.dart';
import 'package:jfit/features/programs/domain/repositories/program_repository.dart';
import 'package:jfit/core/error/workout_program_failures.dart';
import 'package:jfit/features/workout_program/data/models/duplicate_check_result_model.dart';

import 'programs_bloc_error_handling_test.mocks.dart';

@GenerateMocks([
  ProgramRepository,
])
void main() {
  group('ProgramsBloc Error Handling', () {
    late ProgramsBloc programsBloc;
    late MockProgramRepository mockRepository;

    setUp(() {
      mockRepository = MockProgramRepository();
      programsBloc = ProgramsBloc(repository: mockRepository);
    });

    tearDown(() {
      programsBloc.close();
    });

    group('SaveAsMyRoutine', () {
      const templateProgramId = 'template-123';

      blocTest<ProgramsBloc, ProgramsState>(
        'should emit duplicate state when program already exists',
        build: () => programsBloc,
        setUp: () {
          final duplicateInfo = ProgramDuplicateInfo(
            userProgramId: 'existing-program-id',
            programName: 'Existing Program',
            currentWeek: 2,
            currentDay: 3,
            totalWeeks: 4,
            progressPercent: 50.0,
            isCompleted: false,
            status: ProgramStatus.active,
            availableOptions: const [
              ResolutionOption.continueExisting,
              ResolutionOption.restartProgram,
              ResolutionOption.createNewInstance,
              ResolutionOption.cancel,
            ],
          );
          final duplicateResult = DuplicateCheckResult.duplicate(
            existingProgramId: 'existing-program-id',
            duplicateInfo: duplicateInfo,
          );
          when(mockRepository.saveAsMyRoutine(templateProgramId))
              .thenAnswer((_) async => Right(duplicateResult));
        },
        act: (bloc) => bloc.add(const SaveAsMyRoutine(templateProgramId)),
        expect: () => [
          isA<RoutineDuplicateFound>(),
        ],
      );

      blocTest<ProgramsBloc, ProgramsState>(
        'should emit success state when no duplicate exists',
        build: () => programsBloc,
        setUp: () {
          final noDuplicateResult = DuplicateCheckResult.noDuplicate();
          when(mockRepository.saveAsMyRoutine(templateProgramId))
              .thenAnswer((_) async => Right(noDuplicateResult));
        },
        act: (bloc) => bloc.add(const SaveAsMyRoutine(templateProgramId)),
        expect: () => [
          isA<RoutineSaved>(),
        ],
      );

      blocTest<ProgramsBloc, ProgramsState>(
        'should emit error state when network failure occurs',
        build: () => programsBloc,
        setUp: () {
          const networkFailure = WorkoutProgramNetworkFailure(
            technicalMessage: 'Connection timeout',
          );
          when(mockRepository.saveAsMyRoutine(templateProgramId))
              .thenAnswer((_) async => const Left(networkFailure));
        },
        act: (bloc) => bloc.add(const SaveAsMyRoutine(templateProgramId)),
        expect: () => [
          isA<RoutineSaveError>(),
        ],
      );

      blocTest<ProgramsBloc, ProgramsState>(
        'should emit error state when server failure occurs',
        build: () => programsBloc,
        setUp: () {
          final serverFailure = WorkoutProgramServerFailure(
            statusCode: 500,
            technicalMessage: 'Internal server error',
          );
          when(mockRepository.saveAsMyRoutine(templateProgramId))
              .thenAnswer((_) async => Left(serverFailure));
        },
        act: (bloc) => bloc.add(const SaveAsMyRoutine(templateProgramId)),
        expect: () => [
          isA<RoutineSaveError>(),
        ],
      );

      blocTest<ProgramsBloc, ProgramsState>(
        'should emit error state when permission failure occurs',
        build: () => programsBloc,
        setUp: () {
          const permissionFailure = WorkoutProgramPermissionFailure(
            technicalMessage: 'User not authenticated',
          );
          when(mockRepository.saveAsMyRoutine(templateProgramId))
              .thenAnswer((_) async => const Left(permissionFailure));
        },
        act: (bloc) => bloc.add(const SaveAsMyRoutine(templateProgramId)),
        expect: () => [
          isA<RoutineSaveError>(),
        ],
      );

      blocTest<ProgramsBloc, ProgramsState>(
        'should emit error state when validation failure occurs',
        build: () => programsBloc,
        setUp: () {
          final validationFailure = WorkoutProgramValidationFailure(
            validationErrors: ['Invalid program ID', 'Missing user ID'],
            technicalMessage: 'Validation failed',
          );
          when(mockRepository.saveAsMyRoutine(templateProgramId))
              .thenAnswer((_) async => Left(validationFailure));
        },
        act: (bloc) => bloc.add(const SaveAsMyRoutine(templateProgramId)),
        expect: () => [
          isA<RoutineSaveError>(),
        ],
      );
    });

    group('Program Management', () {
      const programId = 'program-123';

      blocTest<ProgramsBloc, ProgramsState>(
        'should emit success when continue program succeeds',
        build: () => programsBloc,
        setUp: () {
          when(mockRepository.continueProgram(programId))
              .thenAnswer((_) async => const Right(null));
        },
        act: (bloc) => bloc.add(const ContinueProgram(programId)),
        expect: () => [
          isA<ProgramContinued>(),
        ],
      );

      blocTest<ProgramsBloc, ProgramsState>(
        'should emit success when restart program succeeds',
        build: () => programsBloc,
        setUp: () {
          when(mockRepository.restartProgram(programId))
              .thenAnswer((_) async => const Right(null));
        },
        act: (bloc) => bloc.add(const RestartProgram(programId)),
        expect: () => [
          isA<ProgramRestarted>(),
        ],
      );

      blocTest<ProgramsBloc, ProgramsState>(
        'should emit error when continue program fails',
        build: () => programsBloc,
        setUp: () {
          const networkFailure = WorkoutProgramNetworkFailure(
            technicalMessage: 'Connection timeout',
          );
          when(mockRepository.continueProgram(programId))
              .thenAnswer((_) async => const Left(networkFailure));
        },
        act: (bloc) => bloc.add(const ContinueProgram(programId)),
        expect: () => [
          isA<ProgramAddError>(),
        ],
      );

      blocTest<ProgramsBloc, ProgramsState>(
        'should emit initial state when cancel is selected',
        build: () => programsBloc,
        act: (bloc) => bloc.add(const CancelDuplicateResolution()),
        expect: () => [
          ProgramsInitial(),
        ],
      );
    });

    group('Error Recovery', () {
      const templateProgramId = 'template-123';

      blocTest<ProgramsBloc, ProgramsState>(
        'should allow retry after network error',
        build: () => programsBloc,
        setUp: () {
          // First call fails, second call succeeds
          const networkFailure = WorkoutProgramNetworkFailure(
            technicalMessage: 'Connection timeout',
          );
          final noDuplicateResult = DuplicateCheckResult.noDuplicate();
          var callCount = 0;
          when(mockRepository.saveAsMyRoutine(templateProgramId))
              .thenAnswer((_) async {
                callCount++;
                if (callCount == 1) {
                  return const Left(networkFailure);
                } else {
                  return Right(noDuplicateResult);
                }
              });
        },
        act: (bloc) async {
          bloc.add(const SaveAsMyRoutine(templateProgramId));
          await Future.delayed(const Duration(milliseconds: 100));
          
          // Retry the same operation
          bloc.add(const SaveAsMyRoutine(templateProgramId));
        },
        expect: () => [
          isA<RoutineSaveError>(),
          isA<RoutineSaved>(),
        ],
      );

      blocTest<ProgramsBloc, ProgramsState>(
        'should handle multiple consecutive errors gracefully',
        build: () => programsBloc,
        setUp: () {
          const networkFailure = WorkoutProgramNetworkFailure(
            technicalMessage: 'Connection timeout',
          );
          final serverFailure = WorkoutProgramServerFailure(
            statusCode: 500,
            technicalMessage: 'Internal server error',
          );
          final noDuplicateResult = DuplicateCheckResult.noDuplicate();
          var callCount = 0;
          when(mockRepository.saveAsMyRoutine(templateProgramId))
              .thenAnswer((_) async {
                callCount++;
                if (callCount == 1) {
                  return const Left(networkFailure);
                } else if (callCount == 2) {
                  return Left(serverFailure);
                } else {
                  return Right(noDuplicateResult);
                }
              });
        },
        act: (bloc) async {
          // First attempt - network error
          bloc.add(const SaveAsMyRoutine(templateProgramId));
          await Future.delayed(const Duration(milliseconds: 50));
          
          // Second attempt - server error
          bloc.add(const SaveAsMyRoutine(templateProgramId));
          await Future.delayed(const Duration(milliseconds: 50));
          
          // Third attempt - success
          bloc.add(const SaveAsMyRoutine(templateProgramId));
        },
        expect: () => [
          isA<RoutineSaveError>(),
          isA<RoutineSaveError>(),
          isA<RoutineSaved>(),
        ],
      );
    });

    group('State Transitions', () {
      test('should create error state correctly', () {
        // arrange
        const errorState = ProgramsError('Network connection failed');

        // assert
        expect(errorState.message, 'Network connection failed');
        expect(errorState, isA<ProgramsError>());
      });

      test('should create duplicate found state correctly', () {
        // arrange
        const duplicateState = ProgramDuplicateFound(
          programId: 'test-id',
          programName: 'Test Program',
          currentWeek: 1,
          currentDay: 1,
          totalWeeks: 4,
          progressPercent: 0.0,
          isCompleted: false,
        );

        // assert
        expect(duplicateState.programId, 'test-id');
        expect(duplicateState.programName, 'Test Program');
        expect(duplicateState.currentWeek, 1);
        expect(duplicateState.currentDay, 1);
        expect(duplicateState.totalWeeks, 4);
        expect(duplicateState.progressPercent, 0.0);
        expect(duplicateState.isCompleted, false);
      });
    });
  });
}