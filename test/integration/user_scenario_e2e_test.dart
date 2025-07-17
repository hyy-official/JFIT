import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get_it/get_it.dart';

import 'package:jfit/features/meal/bloc/meal_bloc.dart';
import 'package:jfit/features/meal/bloc/meal_event.dart';
import 'package:jfit/features/meal/bloc/meal_state.dart';
import 'package:jfit/features/meal/data/repositories/meal_repository.dart';

import 'package:jfit/features/workout_program/bloc/workout_program_bloc.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_event.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_state.dart';
import 'package:jfit/features/workout_program/data/repositories/workout_program_repository.dart';

import 'package:jfit/features/workout_session/bloc/workout_session_bloc.dart';
import 'package:jfit/features/workout_session/bloc/workout_session_event.dart';
import 'package:jfit/features/workout_session/bloc/workout_session_state.dart';
import 'package:jfit/features/workout_session/data/repositories/workout_session_repository.dart';

import 'package:jfit/features/daily_summary/bloc/daily_summary_bloc.dart';
import 'package:jfit/features/daily_summary/bloc/daily_summary_event.dart';
import 'package:jfit/features/daily_summary/bloc/daily_summary_state.dart';
import 'package:jfit/features/daily_summary/data/repositories/daily_summary_repository.dart';

import 'package:jfit/features/exercise/bloc/exercise_bloc.dart';
import 'package:jfit/features/exercise/bloc/exercise_event.dart';
import 'package:jfit/features/exercise/bloc/exercise_state.dart';
import 'package:jfit/features/exercise/data/repositories/exercise_repository.dart';

import 'package:jfit/core/models/exercise.dart';
import 'package:jfit/core/navigation/main_navigation_page.dart';
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_state.dart';

import 'user_scenario_e2e_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  MealRepository,
  WorkoutProgramRepository,
  WorkoutSessionRepository,
  DailySummaryRepository,
  ExerciseRepository,
  AuthBloc,
])
void main() {
  group('User Scenario E2E Tests', () {
    late MockMealRepository mockMealRepository;
    late MockWorkoutProgramRepository mockWorkoutProgramRepository;
    late MockWorkoutSessionRepository mockWorkoutSessionRepository;
    late MockDailySummaryRepository mockDailySummaryRepository;
    late MockExerciseRepository mockExerciseRepository;
    late MockAuthBloc mockAuthBloc;

    late MealBloc mealBloc;
    late WorkoutProgramBloc workoutProgramBloc;
    late WorkoutSessionBloc workoutSessionBloc;
    late DailySummaryBloc dailySummaryBloc;
    late ExerciseBloc exerciseBloc;

    setUp(() {
      mockMealRepository = MockMealRepository();
      mockWorkoutProgramRepository = MockWorkoutProgramRepository();
      mockWorkoutSessionRepository = MockWorkoutSessionRepository();
      mockDailySummaryRepository = MockDailySummaryRepository();
      mockExerciseRepository = MockExerciseRepository();
      mockAuthBloc = MockAuthBloc();

      mealBloc = MealBloc(mealRepository: mockMealRepository);
      workoutProgramBloc = WorkoutProgramBloc(workoutProgramRepository: mockWorkoutProgramRepository);
      workoutSessionBloc = WorkoutSessionBloc(repository: mockWorkoutSessionRepository);
      dailySummaryBloc = DailySummaryBloc(repository: mockDailySummaryRepository);
      exerciseBloc = ExerciseBloc(repository: mockExerciseRepository);

      // Setup GetIt
      GetIt.instance.reset();
      GetIt.instance.registerFactory<MealBloc>(() => mealBloc);
      GetIt.instance.registerFactory<WorkoutProgramBloc>(() => workoutProgramBloc);
      GetIt.instance.registerFactory<WorkoutSessionBloc>(() => workoutSessionBloc);
      GetIt.instance.registerFactory<DailySummaryBloc>(() => dailySummaryBloc);
      GetIt.instance.registerFactory<ExerciseBloc>(() => exerciseBloc);

      when(mockAuthBloc.state).thenReturn(const AuthInitial());
      when(mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

      // Setup default responses
      _setupDefaultMockResponses();
    });

    tearDown(() {
      mealBloc.close();
      workoutProgramBloc.close();
      workoutSessionBloc.close();
      dailySummaryBloc.close();
      exerciseBloc.close();
      GetIt.instance.reset();
    });

    void _setupDefaultMockResponses() {
      when(mockMealRepository.getMealRecords(any, date: anyNamed('date')))
          .thenAnswer((_) async => []);
      when(mockMealRepository.addMealRecord(any))
          .thenAnswer((_) async {});
      when(mockMealRepository.updateMealRecord(any))
          .thenAnswer((_) async {});
      when(mockMealRepository.deleteMealRecord(any))
          .thenAnswer((_) async {});

      when(mockWorkoutProgramRepository.getUserPrograms(any))
          .thenAnswer((_) async => []);
      when(mockWorkoutProgramRepository.getProgramDetails(any))
          .thenAnswer((_) async => null);
      when(mockWorkoutProgramRepository.updateProgramProgress(any, any, any))
          .thenAnswer((_) async {});

      when(mockWorkoutSessionRepository.createWorkoutSession(any))
          .thenAnswer((_) async => 'session-123');
      when(mockWorkoutSessionRepository.getActiveSessions(any))
          .thenAnswer((_) async => []);
      when(mockWorkoutSessionRepository.logWorkoutSet(any))
          .thenAnswer((_) async {});
      when(mockWorkoutSessionRepository.completeWorkoutSession(any, any))
          .thenAnswer((_) async {});

      when(mockDailySummaryRepository.getDailySummary(any, any))
          .thenAnswer((_) async => null);
      when(mockDailySummaryRepository.updateDailySummary(any))
          .thenAnswer((_) async {});

      when(mockExerciseRepository.searchExercises(any))
          .thenAnswer((_) async => []);
      when(mockExerciseRepository.getExerciseDetails(any))
          .thenAnswer((_) async => null);
    }

    group('Complete Daily Fitness Journey', () {
      testWidgets('Morning routine: Check daily summary and plan meals', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: mockAuthBloc),
                BlocProvider<MealBloc>.value(value: mealBloc),
                BlocProvider<DailySummaryBloc>.value(value: dailySummaryBloc),
                BlocProvider<ExerciseBloc>.value(value: exerciseBloc),
              ],
              child: const MainNavigationPage(),
            ),
          ),
        );

        // Step 1: User opens app and checks daily summary
        dailySummaryBloc.add(const LoadDailySummary(
          userId: 'test-user',
          date: '2024-01-01',
        ));
        await tester.pump();

        expect(dailySummaryBloc.state, isA<DailySummaryState>());

        // Step 2: User searches for breakfast foods
        when(mockExerciseRepository.searchExercises('oatmeal'))
            .thenAnswer((_) async => [
              Exercise(
                id: 'food-oatmeal',
                titleKo: '오트밀',
                titleEn: 'Oatmeal',
                difficulty: 'Easy',
                type: 'Food',
                equipment: '',
                met: 0,
              ),
            ]);

        exerciseBloc.add(const SearchExercises(query: 'oatmeal'));
        await tester.pump();

        expect(exerciseBloc.state, isA<ExerciseSearchResults>());

        // Step 3: User adds breakfast meal
        mealBloc.add(const AddMealRecord(
          userId: 'test-user',
          foodItemId: 'food-oatmeal',
          quantity: 50,
          mealType: 'breakfast',
        ));
        await tester.pump();

        expect(mealBloc.state, isA<MealRecordAdded>());

        // Step 4: Daily summary should be updated
        dailySummaryBloc.add(const RefreshDailySummary(
          userId: 'test-user',
          date: '2024-01-01',
        ));
        await tester.pump();

        expect(dailySummaryBloc.state, isA<DailySummaryState>());
      });

      testWidgets('Workout session: Complete full workout flow', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: mockAuthBloc),
                BlocProvider<WorkoutProgramBloc>.value(value: workoutProgramBloc),
                BlocProvider<WorkoutSessionBloc>.value(value: workoutSessionBloc),
                BlocProvider<ExerciseBloc>.value(value: exerciseBloc),
                BlocProvider<DailySummaryBloc>.value(value: dailySummaryBloc),
              ],
              child: const MainNavigationPage(),
            ),
          ),
        );

        // Step 1: Load user's workout programs
        workoutProgramBloc.add(const LoadUserPrograms(userId: 'test-user'));
        await tester.pump();

        expect(workoutProgramBloc.state, isA<UserProgramsLoaded>());

        // Step 2: Start a workout session
        workoutSessionBloc.add(const CreateWorkoutSession(
          userId: 'test-user',
          userProgramId: 'program-1',
          sessionDate: '2024-01-01',
        ));
        await tester.pump();

        expect(workoutSessionBloc.state, isA<WorkoutSessionCreated>());

        // Step 3: Search for exercises to add to session
        when(mockExerciseRepository.searchExercises('push up'))
            .thenAnswer((_) async => [
              Exercise(
                id: 'exercise-pushup',
                titleKo: '푸시업',
                titleEn: 'Push Up',
                difficulty: 'Medium',
                type: 'Strength',
                equipment: 'Bodyweight',
                met: 8.0,
              ),
            ]);

        exerciseBloc.add(const SearchExercises(query: 'push up'));
        await tester.pump();

        expect(exerciseBloc.state, isA<ExerciseSearchResults>());

        // Step 4: Log workout sets
        for (int set = 1; set <= 3; set++) {
          workoutSessionBloc.add(LogWorkoutSet(
            sessionId: 'session-123',
            exerciseId: 'exercise-pushup',
            setNumber: set,
            weight: 0.0, // Bodyweight
            reps: 10 + set, // Progressive reps
          ));
          await tester.pump();
        }

        expect(workoutSessionBloc.state, isA<WorkoutSetLogged>());

        // Step 5: Complete workout session
        workoutSessionBloc.add(const CompleteWorkoutSession(
          sessionId: 'session-123',
          userId: 'test-user',
        ));
        await tester.pump();

        expect(workoutSessionBloc.state, isA<WorkoutSessionCompleted>());

        // Step 6: Update program progress
        workoutProgramBloc.add(const UpdateProgramProgress(
          userProgramId: 'program-1',
          currentWeek: 1,
          currentDay: 2,
        ));
        await tester.pump();

        expect(workoutProgramBloc.state, isA<ProgramProgressUpdated>());

        // Step 7: Daily summary should reflect workout completion
        dailySummaryBloc.add(const RefreshDailySummary(
          userId: 'test-user',
          date: '2024-01-01',
        ));
        await tester.pump();

        expect(dailySummaryBloc.state, isA<DailySummaryState>());
      });

      testWidgets('Evening routine: Log dinner and review daily progress', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: mockAuthBloc),
                BlocProvider<MealBloc>.value(value: mealBloc),
                BlocProvider<ExerciseBloc>.value(value: exerciseBloc),
                BlocProvider<DailySummaryBloc>.value(value: dailySummaryBloc),
              ],
              child: const MainNavigationPage(),
            ),
          ),
        );

        // Step 1: Search for dinner foods
        when(mockExerciseRepository.searchExercises('chicken'))
            .thenAnswer((_) async => [
              Exercise(
                id: 'food-chicken',
                titleKo: '닭가슴살',
                titleEn: 'Chicken Breast',
                difficulty: 'Easy',
                type: 'Food',
                equipment: '',
                met: 0,
              ),
            ]);

        exerciseBloc.add(const SearchExercises(query: 'chicken'));
        await tester.pump();

        expect(exerciseBloc.state, isA<ExerciseSearchResults>());

        // Step 2: Add multiple dinner items
        final dinnerItems = [
          ('food-chicken', 150, 'dinner'),
          ('food-rice', 100, 'dinner'),
          ('food-vegetables', 200, 'dinner'),
        ];

        for (final (foodId, quantity, mealType) in dinnerItems) {
          mealBloc.add(AddMealRecord(
            userId: 'test-user',
            foodItemId: foodId,
            quantity: quantity,
            mealType: mealType,
          ));
          await tester.pump();
        }

        expect(mealBloc.state, isA<MealRecordAdded>());

        // Step 3: Load all meals for the day
        mealBloc.add(const LoadMealRecords(
          userId: 'test-user',
          date: '2024-01-01',
        ));
        await tester.pump();

        expect(mealBloc.state, isA<MealRecordsLoaded>());

        // Step 4: Get final daily summary
        dailySummaryBloc.add(const LoadDailySummary(
          userId: 'test-user',
          date: '2024-01-01',
        ));
        await tester.pump();

        expect(dailySummaryBloc.state, isA<DailySummaryState>());
      });
    });

    group('Multi-Day Fitness Program', () {
      testWidgets('Week-long workout program progression', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: mockAuthBloc),
                BlocProvider<WorkoutProgramBloc>.value(value: workoutProgramBloc),
                BlocProvider<WorkoutSessionBloc>.value(value: workoutSessionBloc),
                BlocProvider<DailySummaryBloc>.value(value: dailySummaryBloc),
              ],
              child: const MainNavigationPage(),
            ),
          ),
        );

        // Simulate 7 days of workout progression
        for (int day = 1; day <= 7; day++) {
          final date = '2024-01-0${day.toString().padLeft(2, '0')}';

          // Load programs for the day
          workoutProgramBloc.add(const LoadUserPrograms(userId: 'test-user'));
          await tester.pump();

          // Create workout session
          workoutSessionBloc.add(CreateWorkoutSession(
            userId: 'test-user',
            userProgramId: 'program-1',
            sessionDate: date,
          ));
          await tester.pump();

          // Complete workout
          workoutSessionBloc.add(const CompleteWorkoutSession(
            sessionId: 'session-123',
            userId: 'test-user',
          ));
          await tester.pump();

          // Update program progress
          workoutProgramBloc.add(UpdateProgramProgress(
            userProgramId: 'program-1',
            currentWeek: 1,
            currentDay: day,
          ));
          await tester.pump();

          // Check daily summary
          dailySummaryBloc.add(LoadDailySummary(
            userId: 'test-user',
            date: date,
          ));
          await tester.pump();

          expect(workoutProgramBloc.state, isA<WorkoutProgramState>());
          expect(workoutSessionBloc.state, isA<WorkoutSessionState>());
          expect(dailySummaryBloc.state, isA<DailySummaryState>());
        }
      });
    });

    group('Error Recovery Scenarios', () {
      testWidgets('Network failure during meal logging with recovery', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: mockAuthBloc),
                BlocProvider<MealBloc>.value(value: mealBloc),
                BlocProvider<ExerciseBloc>.value(value: exerciseBloc),
              ],
              child: const MainNavigationPage(),
            ),
          ),
        );

        // Step 1: Simulate network failure
        when(mockMealRepository.addMealRecord(any))
            .thenThrow(Exception('Network error'));

        mealBloc.add(const AddMealRecord(
          userId: 'test-user',
          foodItemId: 'food-1',
          quantity: 100,
          mealType: 'lunch',
        ));
        await tester.pump();

        expect(mealBloc.state, isA<MealError>());

        // Step 2: Network recovery
        when(mockMealRepository.addMealRecord(any))
            .thenAnswer((_) async {});

        // Step 3: User retries the operation
        mealBloc.add(const AddMealRecord(
          userId: 'test-user',
          foodItemId: 'food-1',
          quantity: 100,
          mealType: 'lunch',
        ));
        await tester.pump();

        expect(mealBloc.state, isA<MealRecordAdded>());
      });

      testWidgets('Workout session interruption and recovery', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: mockAuthBloc),
                BlocProvider<WorkoutSessionBloc>.value(value: workoutSessionBloc),
              ],
              child: const MainNavigationPage(),
            ),
          ),
        );

        // Step 1: Start workout session
        workoutSessionBloc.add(const CreateWorkoutSession(
          userId: 'test-user',
          userProgramId: 'program-1',
          sessionDate: '2024-01-01',
        ));
        await tester.pump();

        // Step 2: Simulate app crash/interruption
        when(mockWorkoutSessionRepository.logWorkoutSet(any))
            .thenThrow(Exception('Connection lost'));

        workoutSessionBloc.add(const LogWorkoutSet(
          sessionId: 'session-123',
          exerciseId: 'exercise-1',
          setNumber: 1,
          weight: 50.0,
          reps: 10,
        ));
        await tester.pump();

        expect(workoutSessionBloc.state, isA<WorkoutSessionError>());

        // Step 3: Recovery - load active sessions
        when(mockWorkoutSessionRepository.getActiveSessions(any))
            .thenAnswer((_) async => ['session-123']);
        when(mockWorkoutSessionRepository.logWorkoutSet(any))
            .thenAnswer((_) async {});

        workoutSessionBloc.add(const LoadActiveSessions(userId: 'test-user'));
        await tester.pump();

        // Step 4: Continue workout
        workoutSessionBloc.add(const LogWorkoutSet(
          sessionId: 'session-123',
          exerciseId: 'exercise-1',
          setNumber: 1,
          weight: 50.0,
          reps: 10,
        ));
        await tester.pump();

        expect(workoutSessionBloc.state, isA<WorkoutSetLogged>());
      });
    });

    group('Concurrent User Actions', () {
      testWidgets('Simultaneous meal logging and workout tracking', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: mockAuthBloc),
                BlocProvider<MealBloc>.value(value: mealBloc),
                BlocProvider<WorkoutSessionBloc>.value(value: workoutSessionBloc),
                BlocProvider<DailySummaryBloc>.value(value: dailySummaryBloc),
              ],
              child: const MainNavigationPage(),
            ),
          ),
        );

        // Simulate user doing multiple actions simultaneously
        // (e.g., logging pre-workout meal while starting workout)

        // Action 1: Log pre-workout meal
        mealBloc.add(const AddMealRecord(
          userId: 'test-user',
          foodItemId: 'food-preworkout',
          quantity: 30,
          mealType: 'snack',
        ));

        // Action 2: Start workout session (almost simultaneously)
        workoutSessionBloc.add(const CreateWorkoutSession(
          userId: 'test-user',
          userProgramId: 'program-1',
          sessionDate: '2024-01-01',
        ));

        // Action 3: Check daily summary
        dailySummaryBloc.add(const LoadDailySummary(
          userId: 'test-user',
          date: '2024-01-01',
        ));

        await tester.pump();

        // All actions should complete successfully without conflicts
        expect(mealBloc.state, isA<MealState>());
        expect(workoutSessionBloc.state, isA<WorkoutSessionState>());
        expect(dailySummaryBloc.state, isA<DailySummaryState>());
      });
    });
  });
}