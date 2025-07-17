import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/core/error/bloc_errors.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/features/workout_session/bloc/workout_session_bloc.dart';
import 'package:jfit/features/workout_session/bloc/workout_session_event.dart';
import 'package:jfit/features/workout_session/bloc/workout_session_state.dart';
import 'package:jfit/features/workout_session/data/repositories/workout_session_repository.dart';
import 'package:jfit/features/programs/data/models/workout_session_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'workout_session_bloc_test.mocks.dart';

@GenerateMocks([WorkoutSessionRepository])
void main() {
  group('WorkoutSessionBloc', () {
    late WorkoutSessionBloc workoutSessionBloc;
    late MockWorkoutSessionRepository mockWorkoutSessionRepository;

    setUp(() {
      mockWorkoutSessionRepository = MockWorkoutSessionRepository();
      workoutSessionBloc = WorkoutSessionBloc(
        repository: mockWorkoutSessionRepository,
      );
    });

    tearDown(() {
      workoutSessionBloc.close();
    });

    test('initial state is WorkoutSessionInitial', () {
      expect(workoutSessionBloc.state, equals(const WorkoutSessionInitial()));
    });

    group('CreateWorkoutSession', () {
      const userProgramId = 'user-program-1';
      const sessionId = 'session-1';
      final exercisesJson = {
        'exercises': [
          {'id': 'exercise-1', 'name': 'Push-ups', 'sets': 3, 'reps': 10}
        ]
      };

      final workoutSession = WorkoutSessionModel(
        id: sessionId,
        userProgramId: userProgramId,
        sessionDate: DateTime.now(),
        startedAt: DateTime.now(),
        isCompleted: false,
        exercisesJson: [exercisesJson],
      );

      blocTest<WorkoutSessionBloc, WorkoutSessionState>(
        'emits [WorkoutSessionLoading, WorkoutSessionCreated] when CreateWorkoutSession succeeds',
        build: () {
          when(mockWorkoutSessionRepository.createWorkoutSession(
            userProgramId: userProgramId,
            exercisesJson: exercisesJson,
          )).thenAnswer((_) async => const Right(sessionId));
          
          when(mockWorkoutSessionRepository.getWorkoutSession(sessionId))
              .thenAnswer((_) async => Right(workoutSession));
          
          return workoutSessionBloc;
        },
        act: (bloc) => bloc.add(CreateWorkoutSession(
          userProgramId: userProgramId,
          exercisesJson: exercisesJson,
        )),
        expect: () => [
          const WorkoutSessionLoading(message: '운동 세션을 생성하고 있습니다...'),
          WorkoutSessionCreated(sessionId: sessionId, session: workoutSession),
        ],
        verify: (_) {
          verify(mockWorkoutSessionRepository.createWorkoutSession(
            userProgramId: userProgramId,
            exercisesJson: exercisesJson,
          )).called(1);
          verify(mockWorkoutSessionRepository.getWorkoutSession(sessionId)).called(1);
        },
      );

      blocTest<WorkoutSessionBloc, WorkoutSessionState>(
        'emits [WorkoutSessionErrorState] when exercises data is empty',
        build: () => workoutSessionBloc,
        act: (bloc) => bloc.add(const CreateWorkoutSession(
          userProgramId: userProgramId,
          exercisesJson: {},
        )),
        expect: () => [
          const WorkoutSessionLoading(message: '운동 세션을 생성하고 있습니다...'),
          isA<WorkoutSessionErrorState>().having(
            (state) => state.error.code,
            'error code',
            BlocErrorCodes.validationError,
          ),
        ],
        verify: (_) {
          verifyZeroInteractions(mockWorkoutSessionRepository);
        },
      );

      blocTest<WorkoutSessionBloc, WorkoutSessionState>(
        'emits [WorkoutSessionLoading, WorkoutSessionErrorState] when CreateWorkoutSession fails',
        build: () {
          when(mockWorkoutSessionRepository.createWorkoutSession(
            userProgramId: userProgramId,
            exercisesJson: exercisesJson,
          )).thenAnswer((_) async => const Left(ServerFailure('Server error')));
          return workoutSessionBloc;
        },
        act: (bloc) => bloc.add(CreateWorkoutSession(
          userProgramId: userProgramId,
          exercisesJson: exercisesJson,
        )),
        expect: () => [
          const WorkoutSessionLoading(message: '운동 세션을 생성하고 있습니다...'),
          isA<WorkoutSessionErrorState>(),
        ],
        verify: (_) {
          verify(mockWorkoutSessionRepository.createWorkoutSession(
            userProgramId: userProgramId,
            exercisesJson: exercisesJson,
          )).called(1);
        },
      );

      blocTest<WorkoutSessionBloc, WorkoutSessionState>(
        'emits [WorkoutSessionErrorState] when created session cannot be found',
        build: () {
          when(mockWorkoutSessionRepository.createWorkoutSession(
            userProgramId: userProgramId,
            exercisesJson: exercisesJson,
          )).thenAnswer((_) async => const Right(sessionId));
          
          when(mockWorkoutSessionRepository.getWorkoutSession(sessionId))
              .thenAnswer((_) async => const Right(null));
          
          return workoutSessionBloc;
        },
        act: (bloc) => bloc.add(CreateWorkoutSession(
          userProgramId: userProgramId,
          exercisesJson: exercisesJson,
        )),
        expect: () => [
          const WorkoutSessionLoading(message: '운동 세션을 생성하고 있습니다...'),
          isA<WorkoutSessionErrorState>().having(
            (state) => state.error.code,
            'error code',
            BlocErrorCodes.sessionNotFound,
          ),
        ],
      );
    });

    group('LoadWorkoutSession', () {
      const sessionId = 'session-1';
      final workoutSession = WorkoutSessionModel(
        id: sessionId,
        userProgramId: 'user-program-1',
        sessionDate: DateTime.now(),
        startedAt: DateTime.now(),
        isCompleted: false,
      );

      blocTest<WorkoutSessionBloc, WorkoutSessionState>(
        'emits [WorkoutSessionLoading, WorkoutSessionLoaded] when LoadWorkoutSession succeeds',
        build: () {
          when(mockWorkoutSessionRepository.getWorkoutSession(sessionId))
              .thenAnswer((_) async => Right(workoutSession));
          return workoutSessionBloc;
        },
        act: (bloc) => bloc.add(const LoadWorkoutSession(sessionId)),
        expect: () => [
          const WorkoutSessionLoading(message: '운동 세션을 불러오고 있습니다...'),
          WorkoutSessionLoaded(workoutSession),
        ],
        verify: (_) {
          verify(mockWorkoutSessionRepository.getWorkoutSession(sessionId)).called(1);
        },
      );

      blocTest<WorkoutSessionBloc, WorkoutSessionState>(
        'emits [WorkoutSessionLoading, WorkoutSessionErrorState] when session not found',
        build: () {
          when(mockWorkoutSessionRepository.getWorkoutSession(sessionId))
              .thenAnswer((_) async => const Right(null));
          return workoutSessionBloc;
        },
        act: (bloc) => bloc.add(const LoadWorkoutSession(sessionId)),
        expect: () => [
          const WorkoutSessionLoading(message: '운동 세션을 불러오고 있습니다...'),
          isA<WorkoutSessionErrorState>().having(
            (state) => state.error.code,
            'error code',
            BlocErrorCodes.sessionNotFound,
          ),
        ],
        verify: (_) {
          verify(mockWorkoutSessionRepository.getWorkoutSession(sessionId)).called(1);
        },
      );

      blocTest<WorkoutSessionBloc, WorkoutSessionState>(
        'emits [WorkoutSessionLoading, WorkoutSessionErrorState] when LoadWorkoutSession fails',
        build: () {
          when(mockWorkoutSessionRepository.getWorkoutSession(sessionId))
              .thenAnswer((_) async => const Left(DatabaseFailure('Database error')));
          return workoutSessionBloc;
        },
        act: (bloc) => bloc.add(const LoadWorkoutSession(sessionId)),
        expect: () => [
          const WorkoutSessionLoading(message: '운동 세션을 불러오고 있습니다...'),
          isA<WorkoutSessionErrorState>(),
        ],
        verify: (_) {
          verify(mockWorkoutSessionRepository.getWorkoutSession(sessionId)).called(1);
        },
      );
    });

    group('LoadWorkoutSessions', () {
      const userId = 'user-1';
      final workoutSessions = [
        WorkoutSessionModel(
          id: 'session-1',
          userProgramId: 'user-program-1',
          sessionDate: DateTime.now(),
          startedAt: DateTime.now(),
          isCompleted: true,
        ),
        WorkoutSessionModel(
          id: 'session-2',
          userProgramId: 'user-program-1',
          sessionDate: DateTime.now().subtract(const Duration(days: 1)),
          startedAt: DateTime.now().subtract(const Duration(days: 1)),
          isCompleted: false,
        ),
      ];

      blocTest<WorkoutSessionBloc, WorkoutSessionState>(
        'emits [WorkoutSessionLoading, WorkoutSessionsLoaded] when LoadWorkoutSessions succeeds',
        build: () {
          when(mockWorkoutSessionRepository.getWorkoutSessions(userId))
              .thenAnswer((_) async => Right(workoutSessions));
          return workoutSessionBloc;
        },
        act: (bloc) => bloc.add(const LoadWorkoutSessions(userId)),
        expect: () => [
          const WorkoutSessionLoading(message: '운동 세션 목록을 불러오고 있습니다...'),
          WorkoutSessionsLoaded(workoutSessions),
        ],
        verify: (_) {
          verify(mockWorkoutSessionRepository.getWorkoutSessions(userId)).called(1);
        },
      );

      blocTest<WorkoutSessionBloc, WorkoutSessionState>(
        'emits [WorkoutSessionLoading, WorkoutSessionsLoaded] with empty list when no sessions found',
        build: () {
          when(mockWorkoutSessionRepository.getWorkoutSessions(userId))
              .thenAnswer((_) async => const Right([]));
          return workoutSessionBloc;
        },
        act: (bloc) => bloc.add(const LoadWorkoutSessions(userId)),
        expect: () => [
          const WorkoutSessionLoading(message: '운동 세션 목록을 불러오고 있습니다...'),
          const WorkoutSessionsLoaded([]),
        ],
        verify: (_) {
          verify(mockWorkoutSessionRepository.getWorkoutSessions(userId)).called(1);
        },
      );
    });

    group('LoadActiveSession', () {
      const userId = 'user-1';
      final activeSessions = [
        WorkoutSessionModel(
          id: 'session-1',
          userProgramId: 'user-program-1',
          sessionDate: DateTime.now(),
          startedAt: DateTime.now(),
          isCompleted: false,
        ),
      ];

      blocTest<WorkoutSessionBloc, WorkoutSessionState>(
        'emits [WorkoutSessionLoading, ActiveSessionLoaded] when LoadActiveSession succeeds',
        build: () {
          when(mockWorkoutSessionRepository.getActiveWorkoutSessions(userId))
              .thenAnswer((_) async => Right(activeSessions));
          return workoutSessionBloc;
        },
        act: (bloc) => bloc.add(const LoadActiveSession(userId)),
        expect: () => [
          const WorkoutSessionLoading(message: '진행 중인 운동 세션을 불러오고 있습니다...'),
          ActiveSessionLoaded(activeSessions),
        ],
        verify: (_) {
          verify(mockWorkoutSessionRepository.getActiveWorkoutSessions(userId)).called(1);
        },
      );
    });

    group('UpdateWorkoutSession', () {
      const sessionId = 'session-1';
      final updates = {'note': 'Great workout!'};
      final updatedSession = WorkoutSessionModel(
        id: sessionId,
        userProgramId: 'user-program-1',
        sessionDate: DateTime.now(),
        startedAt: DateTime.now(),
        isCompleted: false,
      );

      blocTest<WorkoutSessionBloc, WorkoutSessionState>(
        'emits [WorkoutSessionLoading, WorkoutSessionUpdated] when UpdateWorkoutSession succeeds',
        build: () {
          when(mockWorkoutSessionRepository.updateWorkoutSession(
            sessionId: sessionId,
            updates: updates,
          )).thenAnswer((_) async => Right(updatedSession));
          return workoutSessionBloc;
        },
        act: (bloc) => bloc.add(UpdateWorkoutSession(
          sessionId: sessionId,
          updates: updates,
        )),
        expect: () => [
          const WorkoutSessionLoading(message: '운동 세션을 업데이트하고 있습니다...'),
          WorkoutSessionUpdated(updatedSession),
        ],
        verify: (_) {
          verify(mockWorkoutSessionRepository.updateWorkoutSession(
            sessionId: sessionId,
            updates: updates,
          )).called(1);
        },
      );

      blocTest<WorkoutSessionBloc, WorkoutSessionState>(
        'emits [WorkoutSessionLoading, WorkoutSessionErrorState] when UpdateWorkoutSession fails',
        build: () {
          when(mockWorkoutSessionRepository.updateWorkoutSession(
            sessionId: sessionId,
            updates: updates,
          )).thenAnswer((_) async => const Left(ServerFailure('Update failed')));
          return workoutSessionBloc;
        },
        act: (bloc) => bloc.add(UpdateWorkoutSession(
          sessionId: sessionId,
          updates: updates,
        )),
        expect: () => [
          const WorkoutSessionLoading(message: '운동 세션을 업데이트하고 있습니다...'),
          isA<WorkoutSessionErrorState>(),
        ],
        verify: (_) {
          verify(mockWorkoutSessionRepository.updateWorkoutSession(
            sessionId: sessionId,
            updates: updates,
          )).called(1);
        },
      );
    });

    group('LogWorkoutSet', () {
      const sessionId = 'session-1';
      const exerciseId = 'exercise-1';
      const setNumber = 1;
      const reps = 10;
      const weight = 50.0;

      final activeSession = WorkoutSessionModel(
        id: sessionId,
        userProgramId: 'user-program-1',
        sessionDate: DateTime.now(),
        startedAt: DateTime.now(),
        isCompleted: false,
      );

      blocTest<WorkoutSessionBloc, WorkoutSessionState>(
        'emits [WorkoutSessionLoading, WorkoutSetLogged] when LogWorkoutSet succeeds',
        build: () {
          when(mockWorkoutSessionRepository.getWorkoutSession(sessionId))
              .thenAnswer((_) async => Right(activeSession));
          when(mockWorkoutSessionRepository.logWorkoutSet(
            sessionId: sessionId,
            exerciseId: exerciseId,
            setNumber: setNumber,
            reps: reps,
            weight: weight,
          )).thenAnswer((_) async => const Right(null));
          return workoutSessionBloc;
        },
        act: (bloc) => bloc.add(const LogWorkoutSet(
          sessionId: sessionId,
          exerciseId: exerciseId,
          setNumber: setNumber,
          reps: reps,
          weight: weight,
        )),
        expect: () => [
          const WorkoutSessionLoading(message: '운동 세트를 기록하고 있습니다...'),
          const WorkoutSetLogged(
            sessionId: sessionId,
            exerciseId: exerciseId,
            setNumber: setNumber,
            reps: reps,
            weight: weight,
          ),
        ],
        verify: (_) {
          verify(mockWorkoutSessionRepository.getWorkoutSession(sessionId)).called(1);
          verify(mockWorkoutSessionRepository.logWorkoutSet(
            sessionId: sessionId,
            exerciseId: exerciseId,
            setNumber: setNumber,
            reps: reps,
            weight: weight,
          )).called(1);
        },
      );

      blocTest<WorkoutSessionBloc, WorkoutSessionState>(
        'emits [WorkoutSessionErrorState] when reps is invalid',
        build: () => workoutSessionBloc,
        act: (bloc) => bloc.add(const LogWorkoutSet(
          sessionId: sessionId,
          exerciseId: exerciseId,
          setNumber: setNumber,
          reps: 0, // Invalid reps
          weight: weight,
        )),
        expect: () => [
          const WorkoutSessionLoading(message: '운동 세트를 기록하고 있습니다...'),
          isA<WorkoutSessionErrorState>().having(
            (state) => state.error.code,
            'error code',
            BlocErrorCodes.validationError,
          ),
        ],
        verify: (_) {
          verifyZeroInteractions(mockWorkoutSessionRepository);
        },
      );

      blocTest<WorkoutSessionBloc, WorkoutSessionState>(
        'emits [WorkoutSessionErrorState] when weight is negative',
        build: () => workoutSessionBloc,
        act: (bloc) => bloc.add(const LogWorkoutSet(
          sessionId: sessionId,
          exerciseId: exerciseId,
          setNumber: setNumber,
          reps: reps,
          weight: -10.0, // Invalid weight
        )),
        expect: () => [
          const WorkoutSessionLoading(message: '운동 세트를 기록하고 있습니다...'),
          isA<WorkoutSessionErrorState>().having(
            (state) => state.error.code,
            'error code',
            BlocErrorCodes.validationError,
          ),
        ],
        verify: (_) {
          verifyZeroInteractions(mockWorkoutSessionRepository);
        },
      );

      blocTest<WorkoutSessionBloc, WorkoutSessionState>(
        'emits [WorkoutSessionErrorState] when session not found',
        build: () {
          when(mockWorkoutSessionRepository.getWorkoutSession(sessionId))
              .thenAnswer((_) async => const Right(null));
          return workoutSessionBloc;
        },
        act: (bloc) => bloc.add(const LogWorkoutSet(
          sessionId: sessionId,
          exerciseId: exerciseId,
          setNumber: setNumber,
          reps: reps,
          weight: weight,
        )),
        expect: () => [
          const WorkoutSessionLoading(message: '운동 세트를 기록하고 있습니다...'),
          isA<WorkoutSessionErrorState>().having(
            (state) => state.error.code,
            'error code',
            BlocErrorCodes.sessionNotFound,
          ),
        ],
        verify: (_) {
          verify(mockWorkoutSessionRepository.getWorkoutSession(sessionId)).called(1);
          verifyNever(mockWorkoutSessionRepository.logWorkoutSet(
            sessionId: sessionId,
            exerciseId: exerciseId,
            setNumber: setNumber,
            reps: reps,
            weight: weight,
          ));
        },
      );

      blocTest<WorkoutSessionBloc, WorkoutSessionState>(
        'emits [WorkoutSessionErrorState] when session is already completed',
        build: () {
          final completedSession = WorkoutSessionModel(
            id: sessionId,
            userProgramId: 'user-program-1',
            sessionDate: DateTime.now(),
            startedAt: DateTime.now(),
            endedAt: DateTime.now(),
            isCompleted: true,
          );
          when(mockWorkoutSessionRepository.getWorkoutSession(sessionId))
              .thenAnswer((_) async => Right(completedSession));
          return workoutSessionBloc;
        },
        act: (bloc) => bloc.add(const LogWorkoutSet(
          sessionId: sessionId,
          exerciseId: exerciseId,
          setNumber: setNumber,
          reps: reps,
          weight: weight,
        )),
        expect: () => [
          const WorkoutSessionLoading(message: '운동 세트를 기록하고 있습니다...'),
          isA<WorkoutSessionErrorState>().having(
            (state) => state.error.code,
            'error code',
            BlocErrorCodes.sessionUpdateFailed,
          ),
        ],
        verify: (_) {
          verify(mockWorkoutSessionRepository.getWorkoutSession(sessionId)).called(1);
          verifyNever(mockWorkoutSessionRepository.logWorkoutSet(
            sessionId: sessionId,
            exerciseId: exerciseId,
            setNumber: setNumber,
            reps: reps,
            weight: weight,
          ));
        },
      );
    });

    group('CompleteWorkoutSession', () {
      const sessionId = 'session-1';
      final activeSession = WorkoutSessionModel(
        id: sessionId,
        userProgramId: 'user-program-1',
        sessionDate: DateTime.now(),
        startedAt: DateTime.now(),
        isCompleted: false,
      );

      final completedSession = WorkoutSessionModel(
        id: sessionId,
        userProgramId: 'user-program-1',
        sessionDate: DateTime.now(),
        startedAt: DateTime.now(),
        endedAt: DateTime.now(),
        isCompleted: true,
      );

      blocTest<WorkoutSessionBloc, WorkoutSessionState>(
        'emits [WorkoutSessionLoading, WorkoutSessionCompleted] when CompleteWorkoutSession succeeds',
        build: () {
          when(mockWorkoutSessionRepository.getWorkoutSession(sessionId))
              .thenAnswer((_) async => Right(activeSession));
          when(mockWorkoutSessionRepository.completeWorkoutSession(sessionId))
              .thenAnswer((_) async => Right(completedSession));
          return workoutSessionBloc;
        },
        act: (bloc) => bloc.add(const CompleteWorkoutSession(sessionId)),
        expect: () => [
          const WorkoutSessionLoading(message: '운동 세션을 완료하고 있습니다...'),
          WorkoutSessionCompleted(sessionId: sessionId, session: completedSession),
        ],
        verify: (_) {
          verify(mockWorkoutSessionRepository.getWorkoutSession(sessionId)).called(1);
          verify(mockWorkoutSessionRepository.completeWorkoutSession(sessionId)).called(1);
        },
      );

      blocTest<WorkoutSessionBloc, WorkoutSessionState>(
        'emits [WorkoutSessionErrorState] when session not found',
        build: () {
          when(mockWorkoutSessionRepository.getWorkoutSession(sessionId))
              .thenAnswer((_) async => const Right(null));
          return workoutSessionBloc;
        },
        act: (bloc) => bloc.add(const CompleteWorkoutSession(sessionId)),
        expect: () => [
          const WorkoutSessionLoading(message: '운동 세션을 완료하고 있습니다...'),
          isA<WorkoutSessionErrorState>().having(
            (state) => state.error.code,
            'error code',
            BlocErrorCodes.sessionNotFound,
          ),
        ],
        verify: (_) {
          verify(mockWorkoutSessionRepository.getWorkoutSession(sessionId)).called(1);
          verifyNever(mockWorkoutSessionRepository.completeWorkoutSession(sessionId));
        },
      );

      blocTest<WorkoutSessionBloc, WorkoutSessionState>(
        'emits [WorkoutSessionErrorState] when session is already completed',
        build: () {
          when(mockWorkoutSessionRepository.getWorkoutSession(sessionId))
              .thenAnswer((_) async => Right(completedSession));
          return workoutSessionBloc;
        },
        act: (bloc) => bloc.add(const CompleteWorkoutSession(sessionId)),
        expect: () => [
          const WorkoutSessionLoading(message: '운동 세션을 완료하고 있습니다...'),
          isA<WorkoutSessionErrorState>().having(
            (state) => state.error.code,
            'error code',
            BlocErrorCodes.sessionUpdateFailed,
          ),
        ],
        verify: (_) {
          verify(mockWorkoutSessionRepository.getWorkoutSession(sessionId)).called(1);
          verifyNever(mockWorkoutSessionRepository.completeWorkoutSession(sessionId));
        },
      );

      blocTest<WorkoutSessionBloc, WorkoutSessionState>(
        'emits [WorkoutSessionLoading, WorkoutSessionErrorState] when CompleteWorkoutSession fails',
        build: () {
          when(mockWorkoutSessionRepository.getWorkoutSession(sessionId))
              .thenAnswer((_) async => Right(activeSession));
          when(mockWorkoutSessionRepository.completeWorkoutSession(sessionId))
              .thenAnswer((_) async => const Left(ServerFailure('Completion failed')));
          return workoutSessionBloc;
        },
        act: (bloc) => bloc.add(const CompleteWorkoutSession(sessionId)),
        expect: () => [
          const WorkoutSessionLoading(message: '운동 세션을 완료하고 있습니다...'),
          isA<WorkoutSessionErrorState>(),
        ],
        verify: (_) {
          verify(mockWorkoutSessionRepository.getWorkoutSession(sessionId)).called(1);
          verify(mockWorkoutSessionRepository.completeWorkoutSession(sessionId)).called(1);
        },
      );
    });

    group('Real-time State Management', () {
      const userProgramId = 'user-program-1';
      const sessionId = 'session-1';
      final exercisesJson = {
        'exercises': [
          {'id': 'exercise-1', 'name': 'Push-ups', 'sets': 3, 'reps': 10}
        ]
      };

      final workoutSession = WorkoutSessionModel(
        id: sessionId,
        userProgramId: userProgramId,
        sessionDate: DateTime.now(),
        startedAt: DateTime.now(),
        isCompleted: false,
        exercisesJson: [exercisesJson],
      );

      test('tracks active session correctly during session lifecycle', () async {
        when(mockWorkoutSessionRepository.createWorkoutSession(
          userProgramId: userProgramId,
          exercisesJson: exercisesJson,
        )).thenAnswer((_) async => const Right(sessionId));
        
        when(mockWorkoutSessionRepository.getWorkoutSession(sessionId))
            .thenAnswer((_) async => Right(workoutSession));

        // Create session
        workoutSessionBloc.add(CreateWorkoutSession(
          userProgramId: userProgramId,
          exercisesJson: exercisesJson,
        ));

        // Wait for the event to be processed
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify that the active session is tracked
        expect(workoutSessionBloc.currentActiveSessionId, equals(sessionId));
        expect(workoutSessionBloc.getSessionWorkoutLogs(sessionId), isNotNull);
        expect(workoutSessionBloc.getSessionWorkoutLogs(sessionId), isEmpty);
      });

      test('tracks workout logs in real-time during session', () async {
        // Mock session creation
        when(mockWorkoutSessionRepository.createWorkoutSession(
          userProgramId: userProgramId,
          exercisesJson: exercisesJson,
        )).thenAnswer((_) async => const Right(sessionId));
        
        when(mockWorkoutSessionRepository.getWorkoutSession(sessionId))
            .thenAnswer((_) async => Right(workoutSession));
        
        when(mockWorkoutSessionRepository.logWorkoutSet(
          sessionId: sessionId,
          exerciseId: 'exercise-1',
          setNumber: 1,
          reps: 10,
          weight: 50.0,
        )).thenAnswer((_) async => const Right(null));

        // First initialize session logs by creating a session
        workoutSessionBloc.add(CreateWorkoutSession(
          userProgramId: userProgramId,
          exercisesJson: exercisesJson,
        ));
        await Future.delayed(const Duration(milliseconds: 100));

        // Then log a workout set
        workoutSessionBloc.add(const LogWorkoutSet(
          sessionId: sessionId,
          exerciseId: 'exercise-1',
          setNumber: 1,
          reps: 10,
          weight: 50.0,
        ));

        // Wait for the event to be processed
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify that workout logs are tracked
        expect(workoutSessionBloc.hasLoggedSets(sessionId), isTrue);
        expect(workoutSessionBloc.getTotalSetsLogged(sessionId), equals(1));
        expect(workoutSessionBloc.getExerciseLoggedSets(sessionId, 'exercise-1'), hasLength(1));
      });
    });

    group('Concurrency and State Consistency', () {
      const sessionId = 'session-1';
      const exerciseId = 'exercise-1';
      
      final activeSession = WorkoutSessionModel(
        id: sessionId,
        userProgramId: 'user-program-1',
        sessionDate: DateTime.now(),
        startedAt: DateTime.now(),
        isCompleted: false,
      );

      test('handles concurrent workout set logging correctly', () async {
        when(mockWorkoutSessionRepository.getWorkoutSession(sessionId))
            .thenAnswer((_) async => Right(activeSession));
        when(mockWorkoutSessionRepository.logWorkoutSet(
          sessionId: sessionId,
          exerciseId: exerciseId,
          setNumber: anyNamed('setNumber'),
          reps: anyNamed('reps'),
          weight: anyNamed('weight'),
        )).thenAnswer((_) async => const Right(null));

        // Simulate concurrent set logging
        workoutSessionBloc.add(const LogWorkoutSet(
          sessionId: sessionId,
          exerciseId: exerciseId,
          setNumber: 1,
          reps: 10,
          weight: 50.0,
        ));
        workoutSessionBloc.add(const LogWorkoutSet(
          sessionId: sessionId,
          exerciseId: exerciseId,
          setNumber: 2,
          reps: 12,
          weight: 55.0,
        ));

        // Wait for both events to be processed
        await Future.delayed(const Duration(milliseconds: 200));

        // Verify that both calls were made
        verify(mockWorkoutSessionRepository.getWorkoutSession(sessionId)).called(2);
        verify(mockWorkoutSessionRepository.logWorkoutSet(
          sessionId: sessionId,
          exerciseId: exerciseId,
          setNumber: anyNamed('setNumber'),
          reps: anyNamed('reps'),
          weight: anyNamed('weight'),
        )).called(2);
      });
    });

    group('Error Handling', () {
      const sessionId = 'session-1';
      const userId = 'user-1';

      blocTest<WorkoutSessionBloc, WorkoutSessionState>(
        'handles unexpected exceptions during CreateWorkoutSession',
        setUp: () {
          reset(mockWorkoutSessionRepository);
        },
        build: () {
          when(mockWorkoutSessionRepository.createWorkoutSession(
            userProgramId: anyNamed('userProgramId'),
            exercisesJson: anyNamed('exercisesJson'),
          )).thenThrow(Exception('Unexpected error'));
          return workoutSessionBloc;
        },
        act: (bloc) => bloc.add(const CreateWorkoutSession(
          userProgramId: 'user-program-1',
          exercisesJson: {'test': 'data'},
        )),
        expect: () => [
          const WorkoutSessionLoading(message: '운동 세션을 생성하고 있습니다...'),
          isA<WorkoutSessionErrorState>(),
        ],
      );

      blocTest<WorkoutSessionBloc, WorkoutSessionState>(
        'handles network failure gracefully',
        build: () {
          when(mockWorkoutSessionRepository.getWorkoutSessions(userId))
              .thenAnswer((_) async => const Left(NetworkFailure('Network connection failed')));
          return workoutSessionBloc;
        },
        act: (bloc) => bloc.add(const LoadWorkoutSessions(userId)),
        expect: () => [
          const WorkoutSessionLoading(message: '운동 세션 목록을 불러오고 있습니다...'),
          isA<WorkoutSessionErrorState>(),
        ],
        verify: (_) {
          verify(mockWorkoutSessionRepository.getWorkoutSessions(userId)).called(1);
        },
      );
    });

    group('Resource Management', () {
      test('cleans up resources on close', () async {
        const userProgramId = 'user-program-1';
        const sessionId = 'session-1';
        final exercisesJson = {'test': 'data'};

        final workoutSession = WorkoutSessionModel(
          id: sessionId,
          userProgramId: userProgramId,
          sessionDate: DateTime.now(),
          startedAt: DateTime.now(),
          isCompleted: false,
        );

        when(mockWorkoutSessionRepository.createWorkoutSession(
          userProgramId: userProgramId,
          exercisesJson: exercisesJson,
        )).thenAnswer((_) async => const Right(sessionId));
        
        when(mockWorkoutSessionRepository.getWorkoutSession(sessionId))
            .thenAnswer((_) async => Right(workoutSession));

        // Create session to set up state
        workoutSessionBloc.add(CreateWorkoutSession(
          userProgramId: userProgramId,
          exercisesJson: exercisesJson,
        ));

        await Future.delayed(const Duration(milliseconds: 100));

        // Verify state is set up
        expect(workoutSessionBloc.currentActiveSessionId, isNotNull);
        expect(workoutSessionBloc.getSessionWorkoutLogs(sessionId), isNotNull);

        // Close the bloc
        await workoutSessionBloc.close();

        // Verify resources are cleaned up
        expect(workoutSessionBloc.currentActiveSessionId, isNull);
        expect(workoutSessionBloc.getSessionWorkoutLogs(sessionId), isNull);
      });
    });
  });
}