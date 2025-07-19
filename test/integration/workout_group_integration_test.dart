import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports
import 'package:jfit/core/di/injection_container.dart';
import 'package:jfit/core/navigation/app_router.dart';
import 'package:jfit/l10n/app_localizations.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:dartz/dartz.dart';

// Existing workout features
import 'package:jfit/features/workout_program/bloc/workout_program_bloc.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_state.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_event.dart';
import 'package:jfit/features/workout_session/bloc/workout_session_bloc.dart';
import 'package:jfit/features/workout_session/bloc/workout_session_state.dart';
import 'package:jfit/features/workout_session/bloc/workout_session_event.dart';
import 'package:jfit/features/programs/presentation/bloc/programs_bloc.dart';
import 'package:jfit/features/programs/presentation/bloc/programs_state.dart';
import 'package:jfit/features/programs/presentation/bloc/programs_event.dart';

// Group workout community features
import 'package:jfit/features/group_workout_community/presentation/bloc/group/group_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group/group_state.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group/group_event.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group_activity/group_activity_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group_activity/group_activity_state.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group_activity/group_activity_event.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_member.dart';
import 'package:jfit/features/group_workout_community/domain/entities/shared_routine.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_activity.dart';

// Repository interfaces
import 'package:jfit/features/workout_program/data/repositories/workout_program_repository.dart';
import 'package:jfit/features/workout_session/data/repositories/workout_session_repository.dart';
import 'package:jfit/features/programs/domain/repositories/program_repository.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/group_repository.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/group_activity_repository.dart';

// Models and entities
import 'package:jfit/features/workout_program/data/models/user_program_model.dart';
import 'package:jfit/features/workout_session/data/models/workout_session_model.dart';
import 'package:jfit/features/programs/data/models/workout_program_model.dart';

import 'workout_group_integration_test.mocks.dart';

@GenerateMocks([
  WorkoutProgramRepository,
  WorkoutSessionRepository,
  ProgramRepository,
  GroupRepository,
  GroupActivityRepository,
])
void main() {
  group('Workout Group Integration Tests', () {
    late MockWorkoutProgramRepository mockWorkoutProgramRepository;
    late MockWorkoutSessionRepository mockWorkoutSessionRepository;
    late MockProgramRepository mockProgramRepository;
    late MockGroupRepository mockGroupRepository;
    late MockGroupActivityRepository mockGroupActivityRepository;

    late WorkoutProgramBloc workoutProgramBloc;
    late WorkoutSessionBloc workoutSessionBloc;
    late ProgramsBloc programsBloc;
    late GroupBloc groupBloc;
    late GroupActivityBloc groupActivityBloc;

    setUp(() {
      // Reset GetIt
      GetIt.instance.reset();

      // Create mocks
      mockWorkoutProgramRepository = MockWorkoutProgramRepository();
      mockWorkoutSessionRepository = MockWorkoutSessionRepository();
      mockProgramRepository = MockProgramRepository();
      mockGroupRepository = MockGroupRepository();
      mockGroupActivityRepository = MockGroupActivityRepository();

      // Register mocks in GetIt
      GetIt.instance.registerLazySingleton<WorkoutProgramRepository>(
        () => mockWorkoutProgramRepository,
      );
      GetIt.instance.registerLazySingleton<WorkoutSessionRepository>(
        () => mockWorkoutSessionRepository,
      );
      GetIt.instance.registerLazySingleton<ProgramRepository>(
        () => mockProgramRepository,
      );
      GetIt.instance.registerLazySingleton<GroupRepository>(
        () => mockGroupRepository,
      );
      GetIt.instance.registerLazySingleton<GroupActivityRepository>(
        () => mockGroupActivityRepository,
      );

      // Create BLoCs
      workoutProgramBloc = WorkoutProgramBloc(mockWorkoutProgramRepository);
      workoutSessionBloc = WorkoutSessionBloc(mockWorkoutSessionRepository);
      programsBloc = ProgramsBloc(mockProgramRepository);
      groupBloc = GroupBloc(mockGroupRepository);
      groupActivityBloc = GroupActivityBloc(mockGroupActivityRepository);
    });

    tearDown(() {
      workoutProgramBloc.close();
      workoutSessionBloc.close();
      programsBloc.close();
      groupBloc.close();
      groupActivityBloc.close();
      GetIt.instance.reset();
    });

    group('Workout Program and Group Integration', () {
      testWidgets('should share workout program with group successfully', (tester) async {
        // Arrange
        const userId = 'user123';
        const groupId = 'group123';
        const programId = 'program123';
        
        final mockProgram = WorkoutProgramModel(
          id: programId,
          name: 'Test Program',
          description: 'Test Description',
          createdBy: userId,
          difficultyLevel: 'intermediate',
          programType: 'strength',
          durationWeeks: 8,
          workoutDays: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final mockUserProgram = UserProgramModel(
          id: 'userProgram123',
          userId: userId,
          programId: programId,
          currentWeek: 1,
          currentDay: 1,
          startDate: DateTime.now(),
          isActive: true,
          exercisesJson: '[]',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final mockGroup = WorkoutGroup(
          id: groupId,
          name: 'Test Group',
          description: 'Test Group Description',
          adminId: userId,
          privacyType: GroupPrivacyType.public,
          maxMembers: 50,
          currentMemberCount: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        );

        // Mock repository responses
        when(mockProgramRepository.getProgram(programId))
            .thenAnswer((_) async => Right(mockProgram));
        
        when(mockWorkoutProgramRepository.getUserProgram(userId, programId))
            .thenAnswer((_) async => Right(mockUserProgram));
        
        when(mockGroupRepository.getUserGroups(userId))
            .thenAnswer((_) async => Right([mockGroup]));
        
        when(mockGroupActivityRepository.shareRoutine(any))
            .thenAnswer((_) async => const Right(null));

        // Build widget
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: AppRouter.router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: JFitTheme.lightTheme,
            builder: (context, child) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider<WorkoutProgramBloc>.value(value: workoutProgramBloc),
                  BlocProvider<WorkoutSessionBloc>.value(value: workoutSessionBloc),
                  BlocProvider<ProgramsBloc>.value(value: programsBloc),
                  BlocProvider<GroupBloc>.value(value: groupBloc),
                  BlocProvider<GroupActivityBloc>.value(value: groupActivityBloc),
                ],
                child: child ?? const SizedBox(),
              );
            },
          ),
        );

        await tester.pumpAndSettle();

        // Act - Load user programs and groups
        workoutProgramBloc.add(LoadUserPrograms(userId: userId));
        groupBloc.add(LoadUserGroups(userId: userId));
        
        await tester.pump();

        // Verify initial states
        expect(workoutProgramBloc.state, isA<WorkoutProgramLoading>());
        expect(groupBloc.state, isA<GroupLoading>());

        await tester.pump();

        // Simulate sharing routine
        groupActivityBloc.add(ShareRoutineEvent(
          groupId: groupId,
          userProgramId: mockUserProgram.id,
          routineName: mockProgram.name,
          description: 'Sharing my current program',
        ));

        await tester.pump();

        // Verify share routine was called
        verify(mockGroupActivityRepository.shareRoutine(any)).called(1);
      });

      testWidgets('should copy shared routine to user programs', (tester) async {
        // Arrange
        const userId = 'user123';
        const groupId = 'group123';
        const sharedRoutineId = 'routine123';
        
        final mockSharedRoutine = SharedRoutine(
          id: sharedRoutineId,
          groupId: groupId,
          sharedByUserId: 'otherUser',
          userProgramId: 'otherUserProgram',
          routineName: 'Shared Routine',
          description: 'Great routine for beginners',
          exerciseIds: const ['ex1', 'ex2', 'ex3'],
          sharedAt: DateTime.now(),
          likesCount: 5,
          copiesCount: 2,
        );

        // Mock repository responses
        when(mockGroupActivityRepository.getSharedRoutines(groupId))
            .thenAnswer((_) async => Right([mockSharedRoutine]));
        
        when(mockGroupActivityRepository.copySharedRoutine(sharedRoutineId, userId))
            .thenAnswer((_) async => const Right(null));

        // Build widget
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: AppRouter.router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: JFitTheme.lightTheme,
            builder: (context, child) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider<GroupActivityBloc>.value(value: groupActivityBloc),
                ],
                child: child ?? const SizedBox(),
              );
            },
          ),
        );

        await tester.pumpAndSettle();

        // Act - Load shared routines
        groupActivityBloc.add(LoadSharedRoutines(groupId: groupId));
        
        await tester.pump();

        // Act - Copy shared routine
        groupActivityBloc.add(CopySharedRoutineEvent(
          sharedRoutineId: sharedRoutineId,
          userId: userId,
        ));

        await tester.pump();

        // Verify copy routine was called
        verify(mockGroupActivityRepository.copySharedRoutine(sharedRoutineId, userId)).called(1);
      });
    });

    group('Workout Session and Group Activity Integration', () {
      testWidgets('should log workout completion to group activity', (tester) async {
        // Arrange
        const userId = 'user123';
        const groupId = 'group123';
        const sessionId = 'session123';
        
        final mockSession = WorkoutSessionModel(
          id: sessionId,
          userId: userId,
          userProgramId: 'program123',
          sessionDate: DateTime.now(),
          startedAt: DateTime.now().subtract(const Duration(hours: 1)),
          endedAt: DateTime.now(),
          isCompleted: true,
          totalDurationMinutes: 60,
          totalCaloriesBurned: 300,
          notes: 'Great workout!',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Mock repository responses
        when(mockWorkoutSessionRepository.getSession(sessionId))
            .thenAnswer((_) async => Right(mockSession));
        
        when(mockGroupActivityRepository.logWorkoutCompletion(any))
            .thenAnswer((_) async => const Right(null));

        // Build widget
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: AppRouter.router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: JFitTheme.lightTheme,
            builder: (context, child) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider<WorkoutSessionBloc>.value(value: workoutSessionBloc),
                  BlocProvider<GroupActivityBloc>.value(value: groupActivityBloc),
                ],
                child: child ?? const SizedBox(),
              );
            },
          ),
        );

        await tester.pumpAndSettle();

        // Act - Complete workout session
        workoutSessionBloc.add(CompleteWorkoutSession(sessionId: sessionId));
        
        await tester.pump();

        // Act - Log completion to group
        groupActivityBloc.add(LogWorkoutCompletionEvent(
          groupId: groupId,
          userId: userId,
          sessionId: sessionId,
          duration: 60,
          caloriesBurned: 300,
        ));

        await tester.pump();

        // Verify workout completion was logged
        verify(mockGroupActivityRepository.logWorkoutCompletion(any)).called(1);
      });

      testWidgets('should send encouragement message to group member', (tester) async {
        // Arrange
        const userId = 'user123';
        const groupId = 'group123';
        const targetUserId = 'target123';
        const message = 'Great job on your workout!';

        // Mock repository responses
        when(mockGroupActivityRepository.sendEncouragement(groupId, targetUserId, message))
            .thenAnswer((_) async => const Right(null));

        // Build widget
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: AppRouter.router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: JFitTheme.lightTheme,
            builder: (context, child) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider<GroupActivityBloc>.value(value: groupActivityBloc),
                ],
                child: child ?? const SizedBox(),
              );
            },
          ),
        );

        await tester.pumpAndSettle();

        // Act - Send encouragement
        groupActivityBloc.add(SendEncouragementEvent(
          groupId: groupId,
          targetUserId: targetUserId,
          message: message,
        ));

        await tester.pump();

        // Verify encouragement was sent
        verify(mockGroupActivityRepository.sendEncouragement(groupId, targetUserId, message)).called(1);
      });
    });

    group('Cross-Feature Data Flow Integration', () {
      testWidgets('should maintain data consistency across workout and group features', (tester) async {
        // Arrange
        const userId = 'user123';
        const groupId = 'group123';
        const programId = 'program123';
        
        final mockProgram = WorkoutProgramModel(
          id: programId,
          name: 'Integration Test Program',
          description: 'Testing cross-feature integration',
          createdBy: userId,
          difficultyLevel: 'intermediate',
          programType: 'strength',
          durationWeeks: 8,
          workoutDays: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final mockGroup = WorkoutGroup(
          id: groupId,
          name: 'Integration Test Group',
          description: 'Testing group integration',
          adminId: userId,
          privacyType: GroupPrivacyType.public,
          maxMembers: 50,
          currentMemberCount: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        );

        final mockActivity = GroupActivity(
          id: 'activity123',
          groupId: groupId,
          userId: userId,
          activityType: GroupActivityType.workoutCompleted,
          activityData: {
            'programName': mockProgram.name,
            'duration': 60,
            'calories': 300,
          },
          createdAt: DateTime.now(),
          mentionedUserIds: const [],
        );

        // Mock repository responses
        when(mockProgramRepository.getProgram(programId))
            .thenAnswer((_) async => Right(mockProgram));
        
        when(mockGroupRepository.getUserGroups(userId))
            .thenAnswer((_) async => Right([mockGroup]));
        
        when(mockGroupActivityRepository.getGroupActivities(groupId, limit: anyNamed('limit')))
            .thenAnswer((_) async => Right([mockActivity]));

        // Build widget
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: AppRouter.router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: JFitTheme.lightTheme,
            builder: (context, child) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider<ProgramsBloc>.value(value: programsBloc),
                  BlocProvider<GroupBloc>.value(value: groupBloc),
                  BlocProvider<GroupActivityBloc>.value(value: groupActivityBloc),
                ],
                child: child ?? const SizedBox(),
              );
            },
          ),
        );

        await tester.pumpAndSettle();

        // Act - Load data from multiple features
        programsBloc.add(LoadPrograms());
        groupBloc.add(LoadUserGroups(userId: userId));
        groupActivityBloc.add(LoadGroupActivities(groupId: groupId));

        await tester.pump();

        // Verify all repositories were called
        verify(mockProgramRepository.getPrograms(any)).called(1);
        verify(mockGroupRepository.getUserGroups(userId)).called(1);
        verify(mockGroupActivityRepository.getGroupActivities(groupId, limit: anyNamed('limit'))).called(1);

        // Verify states are consistent
        await tester.pump();
        
        expect(programsBloc.state, isA<ProgramsLoaded>());
        expect(groupBloc.state, isA<GroupLoaded>());
        expect(groupActivityBloc.state, isA<GroupActivityLoaded>());
      });
    });

    group('Error Handling Integration', () {
      testWidgets('should handle errors gracefully across features', (tester) async {
        // Arrange
        const userId = 'user123';
        const groupId = 'group123';
        
        // Mock repository failures
        when(mockGroupRepository.getUserGroups(userId))
            .thenAnswer((_) async => const Left(ServerFailure('Network error')));
        
        when(mockWorkoutProgramRepository.getUserPrograms(userId))
            .thenAnswer((_) async => const Left(ServerFailure('Database error')));

        // Build widget
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: AppRouter.router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: JFitTheme.lightTheme,
            builder: (context, child) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider<WorkoutProgramBloc>.value(value: workoutProgramBloc),
                  BlocProvider<GroupBloc>.value(value: groupBloc),
                ],
                child: child ?? const SizedBox(),
              );
            },
          ),
        );

        await tester.pumpAndSettle();

        // Act - Trigger errors
        workoutProgramBloc.add(LoadUserPrograms(userId: userId));
        groupBloc.add(LoadUserGroups(userId: userId));

        await tester.pump();

        // Verify error states
        expect(workoutProgramBloc.state, isA<WorkoutProgramError>());
        expect(groupBloc.state, isA<GroupError>());
      });
    });

    group('Performance Integration', () {
      testWidgets('should handle concurrent operations efficiently', (tester) async {
        // Arrange
        const userId = 'user123';
        const groupId = 'group123';
        
        // Mock multiple concurrent operations
        when(mockGroupRepository.getUserGroups(userId))
            .thenAnswer((_) async {
              await Future.delayed(const Duration(milliseconds: 100));
              return const Right([]);
            });
        
        when(mockWorkoutProgramRepository.getUserPrograms(userId))
            .thenAnswer((_) async {
              await Future.delayed(const Duration(milliseconds: 100));
              return const Right([]);
            });
        
        when(mockGroupActivityRepository.getGroupActivities(groupId, limit: anyNamed('limit')))
            .thenAnswer((_) async {
              await Future.delayed(const Duration(milliseconds: 100));
              return const Right([]);
            });

        // Build widget
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: AppRouter.router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: JFitTheme.lightTheme,
            builder: (context, child) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider<WorkoutProgramBloc>.value(value: workoutProgramBloc),
                  BlocProvider<GroupBloc>.value(value: groupBloc),
                  BlocProvider<GroupActivityBloc>.value(value: groupActivityBloc),
                ],
                child: child ?? const SizedBox(),
              );
            },
          ),
        );

        await tester.pumpAndSettle();

        // Act - Trigger concurrent operations
        final stopwatch = Stopwatch()..start();
        
        workoutProgramBloc.add(LoadUserPrograms(userId: userId));
        groupBloc.add(LoadUserGroups(userId: userId));
        groupActivityBloc.add(LoadGroupActivities(groupId: groupId));

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        
        stopwatch.stop();

        // Verify operations completed in reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(200));
        
        // Verify all operations completed
        verify(mockWorkoutProgramRepository.getUserPrograms(userId)).called(1);
        verify(mockGroupRepository.getUserGroups(userId)).called(1);
        verify(mockGroupActivityRepository.getGroupActivities(groupId, limit: anyNamed('limit'))).called(1);
      });
    });
  });
}