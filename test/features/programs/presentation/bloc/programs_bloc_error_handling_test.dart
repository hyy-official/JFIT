import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:jfit/features/programs/presentation/bloc/programs_bloc.dart';
import 'package:jfit/features/programs/data/datasources/program_remote_datasource.dart';
import 'package:jfit/features/workout_program/data/models/duplicate_check_result_model.dart';
import 'package:jfit/core/error/workout_program_failures.dart';

import 'programs_bloc_error_handling_test.mocks.dart';

@GenerateMocks([
  ProgramRemoteDataSource,
])
void main() {
  group('ProgramsBloc Error Handling', () {
    late ProgramsBloc programsBloc;
    late MockProgramRemoteDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockProgramRemoteDataSource();
      programsBloc = ProgramsBloc(dataSource: mockDataSource);
    });

    tearDown(() {
      programsBloc.close();
    });

    group('SaveAsMyRoutineEvent', () {
      const templateProgramId = 'template-123';
      const userId = 'user-456';

      blocTest<ProgramsBloc, ProgramsState>(
        'should emit duplicate state when program already exists',
        build: () => programsBloc,
        setUp: () {
          const duplicateInfo = ProgramDuplicateInfo(
            userProgramId: 'existing-program-id',
            programName: 'Existing Program',
            currentWeek: 2,
            currentDay: 3,
            totalWeeks: 4,
            progressPercent: 50.0,
            isCompleted: false,
            status: ProgramStatus.active,
            availableOptions: [
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

          when(mockDataSource.saveAsMyRoutine(templateProgramId, userId))
              .thenAnswer((_) async => Right(duplicateResult));
        },
        act: (bloc) => bloc.add(SaveAsMyRoutineEvent(
          templateProgramId: templateProgramId,
          userId: userId,
        )),
        expect: () => [
          const ProgramsState(status: ProgramsStatus.loading),
          isA<ProgramsState>()
              .having((s) => s.status, 'status', ProgramsStatus.duplicateFound)
              .having((s) => s.duplicateCheckResult?.isDuplicate, 'isDuplicate', true)
              .having((s) => s.duplicateCheckResult?.duplicateInfo?.programName, 'programName', 'Existing Program'),
        ],
      );

      blocTest<ProgramsBloc, ProgramsState>(
        'should emit success state when no duplicate exists',
        build: () => programsBloc,
        setUp: () {
          const noDuplicateResult = DuplicateCheckResult.noDuplicate();
          when(mockDataSource.saveAsMyRoutine(templateProgramId, userId))
              .thenAnswer((_) async => const Right(noDuplicateResult));
        },
        act: (bloc) => bloc.add(SaveAsMyRoutineEvent(
          templateProgramId: templateProgramId,
          userId: userId,
        )),
        expect: () => [
          const ProgramsState(status: ProgramsStatus.loading),
          const ProgramsState(status: ProgramsStatus.success),
        ],
      );

      blocTest<ProgramsBloc, ProgramsState>(
        'should emit error state when network failure occurs',
        build: () => programsBloc,
        setUp: () {
          const networkFailure = WorkoutProgramNetworkFailure(
            technicalMessage: 'Connection timeout',
          );
          when(mockDataSource.saveAsMyRoutine(templateProgramId, userId))
              .thenAnswer((_) async => const Left(networkFailure));
        },
        act: (bloc) => bloc.add(SaveAsMyRoutineEvent(
          templateProgramId: templateProgramId,
          userId: userId,
        )),
        expect: () => [
          const ProgramsState(status: ProgramsStatus.loading),
          isA<ProgramsState>()
              .having((s) => s.status, 'status', ProgramsStatus.error)
              .having((s) => s.failure?.type, 'errorType', WorkoutProgramErrorType.networkError)
              .having((s) => s.failure?.userMessage, 'userMessage', '네트워크 연결을 확인해주세요.'),
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
          when(mockDataSource.saveAsMyRoutine(templateProgramId, userId))
              .thenAnswer((_) async => Left(serverFailure));
        },
        act: (bloc) => bloc.add(SaveAsMyRoutineEvent(
          templateProgramId: templateProgramId,
          userId: userId,
        )),
        expect: () => [
          const ProgramsState(status: ProgramsStatus.loading),
          isA<ProgramsState>()
              .having((s) => s.status, 'status', ProgramsStatus.error)
              .having((s) => s.failure?.type, 'errorType', WorkoutProgramErrorType.serverError)
              .having((s) => s.failure?.userMessage, 'userMessage', '서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.'),
        ],
      );

      blocTest<ProgramsBloc, ProgramsState>(
        'should emit error state when permission failure occurs',
        build: () => programsBloc,
        setUp: () {
          const permissionFailure = WorkoutProgramPermissionFailure(
            technicalMessage: 'User not authenticated',
          );
          when(mockDataSource.saveAsMyRoutine(templateProgramId, userId))
              .thenAnswer((_) async => const Left(permissionFailure));
        },
        act: (bloc) => bloc.add(SaveAsMyRoutineEvent(
          templateProgramId: templateProgramId,
          userId: userId,
        )),
        expect: () => [
          const ProgramsState(status: ProgramsStatus.loading),
          isA<ProgramsState>()
              .having((s) => s.status, 'status', ProgramsStatus.error)
              .having((s) => s.failure?.type, 'errorType', WorkoutProgramErrorType.permissionDenied)
              .having((s) => s.failure?.userMessage, 'userMessage', '해당 작업을 수행할 권한이 없습니다.'),
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
          when(mockDataSource.saveAsMyRoutine(templateProgramId, userId))
              .thenAnswer((_) async => Left(validationFailure));
        },
        act: (bloc) => bloc.add(SaveAsMyRoutineEvent(
          templateProgramId: templateProgramId,
          userId: userId,
        )),
        expect: () => [
          const ProgramsState(status: ProgramsStatus.loading),
          isA<ProgramsState>()
              .having((s) => s.status, 'status', ProgramsStatus.error)
              .having((s) => s.failure?.type, 'errorType', WorkoutProgramErrorType.validationError)
              .having((s) => s.failure?.userMessage, 'userMessage', '입력한 정보를 다시 확인해주세요.'),
        ],
      );
    });

    group('ResolveDuplicateEvent', () {
      const templateProgramId = 'template-123';
      const userId = 'user-456';
      const existingProgramId = 'existing-program-id';

      blocTest<ProgramsBloc, ProgramsState>(
        'should emit success when continue existing is selected',
        build: () => programsBloc,
        setUp: () {
          const noDuplicateResult = DuplicateCheckResult.noDuplicate();
          when(mockDataSource.saveAsMyRoutineWithOption(
            templateProgramId,
            userId,
            ResolutionOption.continueExisting,
            existingProgramId: existingProgramId,
          )).thenAnswer((_) async => const Right(noDuplicateResult));
        },
        act: (bloc) => bloc.add(ResolveDuplicateEvent(
          templateProgramId: templateProgramId,
          userId: userId,
          resolution: ResolutionOption.continueExisting,
          existingProgramId: existingProgramId,
        )),
        expect: () => [
          const ProgramsState(status: ProgramsStatus.loading),
          const ProgramsState(status: ProgramsStatus.success),
        ],
      );

      blocTest<ProgramsBloc, ProgramsState>(
        'should emit success when restart program is selected',
        build: () => programsBloc,
        setUp: () {
          const noDuplicateResult = DuplicateCheckResult.noDuplicate();
          when(mockDataSource.saveAsMyRoutineWithOption(
            templateProgramId,
            userId,
            ResolutionOption.restartProgram,
            existingProgramId: existingProgramId,
          )).thenAnswer((_) async => const Right(noDuplicateResult));
        },
        act: (bloc) => bloc.add(ResolveDuplicateEvent(
          templateProgramId: templateProgramId,
          userId: userId,
          resolution: ResolutionOption.restartProgram,
          existingProgramId: existingProgramId,
        )),
        expect: () => [
          const ProgramsState(status: ProgramsStatus.loading),
          const ProgramsState(status: ProgramsStatus.success),
        ],
      );

      blocTest<ProgramsBloc, ProgramsState>(
        'should emit success when create new instance is selected',
        build: () => programsBloc,
        setUp: () {
          const noDuplicateResult = DuplicateCheckResult.noDuplicate();
          when(mockDataSource.saveAsMyRoutineWithOption(
            templateProgramId,
            userId,
            ResolutionOption.createNewInstance,
            existingProgramId: existingProgramId,
          )).thenAnswer((_) async => const Right(noDuplicateResult));
        },
        act: (bloc) => bloc.add(ResolveDuplicateEvent(
          templateProgramId: templateProgramId,
          userId: userId,
          resolution: ResolutionOption.createNewInstance,
          existingProgramId: existingProgramId,
        )),
        expect: () => [
          const ProgramsState(status: ProgramsStatus.loading),
          const ProgramsState(status: ProgramsStatus.success),
        ],
      );

      blocTest<ProgramsBloc, ProgramsState>(
        'should emit initial state when cancel is selected',
        build: () => programsBloc,
        act: (bloc) => bloc.add(ResolveDuplicateEvent(
          templateProgramId: templateProgramId,
          userId: userId,
          resolution: ResolutionOption.cancel,
        )),
        expect: () => [
          const ProgramsState(), // Back to initial state
        ],
      );

      blocTest<ProgramsBloc, ProgramsState>(
        'should emit error state when resolution fails',
        build: () => programsBloc,
        setUp: () {
          const networkFailure = WorkoutProgramNetworkFailure(
            technicalMessage: 'Connection timeout during resolution',
          );
          when(mockDataSource.saveAsMyRoutineWithOption(
            templateProgramId,
            userId,
            ResolutionOption.continueExisting,
            existingProgramId: existingProgramId,
          )).thenAnswer((_) async => const Left(networkFailure));
        },
        act: (bloc) => bloc.add(ResolveDuplicateEvent(
          templateProgramId: templateProgramId,
          userId: userId,
          resolution: ResolutionOption.continueExisting,
          existingProgramId: existingProgramId,
        )),
        expect: () => [
          const ProgramsState(status: ProgramsStatus.loading),
          isA<ProgramsState>()
              .having((s) => s.status, 'status', ProgramsStatus.error)
              .having((s) => s.failure?.type, 'errorType', WorkoutProgramErrorType.networkError),
        ],
      );
    });

    group('Error Recovery', () {
      const templateProgramId = 'template-123';
      const userId = 'user-456';

      blocTest<ProgramsBloc, ProgramsState>(
        'should allow retry after network error',
        build: () => programsBloc,
        setUp: () {
          // First call fails, second call succeeds
          when(mockDataSource.saveAsMyRoutine(templateProgramId, userId))
              .thenAnswer((_) async => const Left(WorkoutProgramNetworkFailure()))
              .thenAnswer((_) async => const Right(DuplicateCheckResult.noDuplicate()));
        },
        act: (bloc) async {
          bloc.add(SaveAsMyRoutineEvent(
            templateProgramId: templateProgramId,
            userId: userId,
          ));
          await Future.delayed(const Duration(milliseconds: 100));
          
          // Retry the same operation
          bloc.add(SaveAsMyRoutineEvent(
            templateProgramId: templateProgramId,
            userId: userId,
          ));
        },
        expect: () => [
          const ProgramsState(status: ProgramsStatus.loading),
          isA<ProgramsState>().having((s) => s.status, 'status', ProgramsStatus.error),
          const ProgramsState(status: ProgramsStatus.loading),
          const ProgramsState(status: ProgramsStatus.success),
        ],
      );

      blocTest<ProgramsBloc, ProgramsState>(
        'should handle multiple consecutive errors gracefully',
        build: () => programsBloc,
        setUp: () {
          when(mockDataSource.saveAsMyRoutine(templateProgramId, userId))
              .thenAnswer((_) async => const Left(WorkoutProgramNetworkFailure()))
              .thenAnswer((_) async => const Left(WorkoutProgramServerFailure()))
              .thenAnswer((_) async => const Right(DuplicateCheckResult.noDuplicate()));
        },
        act: (bloc) async {
          // First attempt - network error
          bloc.add(SaveAsMyRoutineEvent(
            templateProgramId: templateProgramId,
            userId: userId,
          ));
          await Future.delayed(const Duration(milliseconds: 50));
          
          // Second attempt - server error
          bloc.add(SaveAsMyRoutineEvent(
            templateProgramId: templateProgramId,
            userId: userId,
          ));
          await Future.delayed(const Duration(milliseconds: 50));
          
          // Third attempt - success
          bloc.add(SaveAsMyRoutineEvent(
            templateProgramId: templateProgramId,
            userId: userId,
          ));
        },
        expect: () => [
          const ProgramsState(status: ProgramsStatus.loading),
          isA<ProgramsState>()
              .having((s) => s.status, 'status', ProgramsStatus.error)
              .having((s) => s.failure?.type, 'errorType', WorkoutProgramErrorType.networkError),
          const ProgramsState(status: ProgramsStatus.loading),
          isA<ProgramsState>()
              .having((s) => s.status, 'status', ProgramsStatus.error)
              .having((s) => s.failure?.type, 'errorType', WorkoutProgramErrorType.serverError),
          const ProgramsState(status: ProgramsStatus.loading),
          const ProgramsState(status: ProgramsStatus.success),
        ],
      );
    });

    group('State Transitions', () {
      test('should maintain error information in state', () {
        // arrange
        const failure = WorkoutProgramNetworkFailure(
          technicalMessage: 'Connection timeout',
        );
        const errorState = ProgramsState(
          status: ProgramsStatus.error,
          failure: failure,
        );

        // assert
        expect(errorState.status, ProgramsStatus.error);
        expect(errorState.failure, failure);
        expect(errorState.failure?.type, WorkoutProgramErrorType.networkError);
        expect(errorState.failure?.userMessage, '네트워크 연결을 확인해주세요.');
      });

      test('should maintain duplicate information in state', () {
        // arrange
        const duplicateInfo = ProgramDuplicateInfo(
          userProgramId: 'test-id',
          programName: 'Test Program',
          currentWeek: 1,
          currentDay: 1,
          totalWeeks: 4,
          progressPercent: 0.0,
          isCompleted: false,
          status: ProgramStatus.active,
          availableOptions: [ResolutionOption.continueExisting],
        );
        final duplicateResult = DuplicateCheckResult.duplicate(
          existingProgramId: 'test-id',
          duplicateInfo: duplicateInfo,
        );
        final duplicateState = ProgramsState(
          status: ProgramsStatus.duplicateFound,
          duplicateCheckResult: duplicateResult,
        );

        // assert
        expect(duplicateState.status, ProgramsStatus.duplicateFound);
        expect(duplicateState.duplicateCheckResult?.isDuplicate, true);
        expect(duplicateState.duplicateCheckResult?.duplicateInfo, duplicateInfo);
      });
    });
  });
}