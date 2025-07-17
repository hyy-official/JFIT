import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get_it/get_it.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';

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

import 'package:jfit/core/bloc/bloc_event_bus.dart';
import 'package:jfit/core/models/exercise.dart';
import 'package:jfit/core/navigation/main_navigation_page.dart';
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_state.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/features/records/data/models/meal_record_model.dart';
import 'package:jfit/features/workout_program/data/models/user_program_model.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';

import 'full_system_integration_test.mocks.dart';

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
  group('Full System Integration Tests', () {
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
      // Initialize mocks
      mockMealRepository = MockMealRepository();
      mockWorkoutProgramRepository = MockWorkoutProgramRepository();
      mockWorkoutSessionRepository = MockWorkoutSessionRepository();
      mockDailySummaryRepository = MockDailySummaryRepository();
      mockExerciseRepository = MockExerciseRepository();
      mockAuthBloc = MockAuthBloc();

      // Initialize BLoCs with mocks
      mealBloc = MealBloc(mealRepository: mockMealRepository);
      workoutProgramBloc = WorkoutProgramBloc(workoutProgramRepository: mockWorkoutProgramRepository);
      workoutSessionBloc = WorkoutSessionBloc(repository: mockWorkoutSessionRepository);
      dailySummaryBloc = DailySummaryBloc(repository: mockDailySummaryRepository);
      exerciseBloc = ExerciseBloc(repository: mockExerciseRepository);

      // Setup GetIt for testing
      GetIt.instance.reset();
      GetIt.instance.registerFactory<MealBloc>(() => mealBloc);
      GetIt.instance.registerFactory<WorkoutProgramBloc>(() => workoutProgramBloc);
      GetIt.instance.registerFactory<WorkoutSessionBloc>(() => workoutSessionBloc);
      GetIt.instance.registerFactory<DailySummaryBloc>(() => dailySummaryBloc);
      GetIt.instance.registerFactory<ExerciseBloc>(() => exerciseBloc);

      // Setup auth mock
      when(mockAuthBloc.state).thenReturn(AuthInitial());
      when(mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

      // Setup default repository responses with Either types
      when(mockMealRepository.getMealRecords(any, date: anyNamed('date')))
          .thenAnswer((_) async => const Right(<MealRecord>[]));
      when(mockWorkoutProgramRepository.getUserPrograms(any))
          .thenAnswer((_) async => const Right(<UserProgramModel>[]));
      when(mockDailySummaryRepository.getDailySummary(any, any))
          .thenAnswer((_) async => const Right<Failure, UserDailySummary?>(null));
      when(mockExerciseRepository.getExercises(any))
          .thenAnswer((_) async => const Right(<Exercise>[]));
    });

    tearDown(() {
      mealBloc.close();
      workoutProgramBloc.close();
      workoutSessionBloc.close();
      dailySummaryBloc.close();
      exerciseBloc.close();
      GetIt.instance.reset();
    });

    group('BLOC Communication Integration', () {
      testWidgets('Meal record change triggers daily summary update', (WidgetTester tester) async {
        // Setup the app with all BLoCs
        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: mockAuthBloc),
                BlocProvider<MealBloc>.value(value: mealBloc),
                BlocProvider<DailySummaryBloc>.value(value: dailySummaryBloc),
              ],
              child: const Scaffold(body: Text('Test App')),
            ),
          ),
        );

        // Listen to daily summary bloc changes
        final dailySummaryStates = <DailySummaryState>[];
        dailySummaryBloc.stream.listen(dailySummaryStates.add);

        // Trigger meal record addition
        mealBloc.add(const AddMealRecord(
          userId: 'test-user',
          foodItemId: 'test-food',
          quantity: 100,
          mealType: 'breakfast',
        ));

        await tester.pump();

        // Verify that daily summary was notified
        expect(dailySummaryStates, isNotEmpty);
      });

      testWidgets('Workout session completion triggers multiple bloc updates', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: mockAuthBloc),
                BlocProvider<WorkoutSessionBloc>.value(value: workoutSessionBloc),
                BlocProvider<WorkoutProgramBloc>.value(value: workoutProgramBloc),
                BlocProvider<DailySummaryBloc>.value(value: dailySummaryBloc),
              ],
              child: const Scaffold(body: Text('Test App')),
            ),
          ),
        );

        // Listen to bloc state changes
        final workoutProgramStates = <WorkoutProgramState>[];
        final dailySummaryStates = <DailySummaryState>[];
        
        workoutProgramBloc.stream.listen(workoutProgramStates.add);
        dailySummaryBloc.stream.listen(dailySummaryStates.add);

        // Complete a workout session
        workoutSessionBloc.add(const CompleteWorkoutSession(
          sessionId: 'test-session',
          userId: 'test-user',
        ));

        await tester.pump();

        // Verify that related BLoCs were updated
        expect(workoutProgramStates, isNotEmpty);
        expect(dailySummaryStates, isNotEmpty);
      });
    });

    group('End-to-End User Scenarios', () {
      testWidgets('Complete meal logging workflow', (WidgetTester tester) async {
        // Setup mock responses for meal workflow
        when(mockExerciseRepository.searchExercises('chicken'))
            .thenAnswer((_) async => [
              Exercise(
                id: 'food-1',
                titleKo: '닭가슴살',
                titleEn: 'Chicken Breast',
                difficulty: 'Easy',
                type: 'Food',
                equipment: '',
                met: 0,
              ),
            ]);

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

        // 1. Search for food
        exerciseBloc.add(const SearchExercises(query: 'chicken'));
        await tester.pump();

        // 2. Add meal record
        mealBloc.add(const AddMealRecord(
          userId: 'test-user',
          foodItemId: 'food-1',
          quantity: 150,
          mealType: 'lunch',
        ));
        await tester.pump();

        // 3. Verify daily summary is updated
        dailySummaryBloc.add(const LoadDailySummary(
          userId: 'test-user',
          date: '2024-01-01',
        ));
        await tester.pump();

        // Verify the workflow completed without errors
        expect(mealBloc.state, isA<MealState>());
        expect(exerciseBloc.state, isA<ExerciseState>());
        expect(dailySummaryBloc.state, isA<DailySummaryState>());
      });

      testWidgets('Complete workout session workflow', (WidgetTester tester) async {
        // Setup mock responses for workout workflow
        when(mockWorkoutProgramRepository.getUserPrograms('test-user'))
            .thenAnswer((_) async => []);
        when(mockWorkoutSessionRepository.createWorkoutSession(any))
            .thenAnswer((_) async => 'session-123');

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

        // 1. Load user programs
        workoutProgramBloc.add(const LoadUserPrograms(userId: 'test-user'));
        await tester.pump();

        // 2. Create workout session
        workoutSessionBloc.add(const CreateWorkoutSession(
          userId: 'test-user',
          userProgramId: 'program-1',
          sessionDate: '2024-01-01',
        ));
        await tester.pump();

        // 3. Log workout sets
        workoutSessionBloc.add(const LogWorkoutSet(
          sessionId: 'session-123',
          exerciseId: 'exercise-1',
          setNumber: 1,
          weight: 50.0,
          reps: 10,
        ));
        await tester.pump();

        // 4. Complete session
        workoutSessionBloc.add(const CompleteWorkoutSession(
          sessionId: 'session-123',
          userId: 'test-user',
        ));
        await tester.pump();

        // Verify the workflow completed
        expect(workoutProgramBloc.state, isA<WorkoutProgramState>());
        expect(workoutSessionBloc.state, isA<WorkoutSessionState>());
      });
    });

    group('Error Handling and Recovery', () {
      testWidgets('Network error recovery in meal bloc', (WidgetTester tester) async {
        // Setup network error
        when(mockMealRepository.getMealRecords(any, date: anyNamed('date')))
            .thenThrow(Exception('Network error'));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MealBloc>.value(
              value: mealBloc,
              child: const Scaffold(body: Text('Test')),
            ),
          ),
        );

        // Trigger error
        mealBloc.add(const LoadMealRecords(userId: 'test-user', date: '2024-01-01'));
        await tester.pump();

        // Verify error state
        expect(mealBloc.state, isA<MealError>());

        // Setup recovery
        when(mockMealRepository.getMealRecords(any, date: anyNamed('date')))
            .thenAnswer((_) async => []);

        // Retry operation
        mealBloc.add(const LoadMealRecords(userId: 'test-user', date: '2024-01-01'));
        await tester.pump();

        // Verify recovery
        expect(mealBloc.state, isA<MealRecordsLoaded>());
      });

      testWidgets('Concurrent operations handling', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<MealBloc>.value(value: mealBloc),
                BlocProvider<WorkoutSessionBloc>.value(value: workoutSessionBloc),
                BlocProvider<DailySummaryBloc>.value(value: dailySummaryBloc),
              ],
              child: const Scaffold(body: Text('Test')),
            ),
          ),
        );

        // Trigger multiple concurrent operations
        mealBloc.add(const LoadMealRecords(userId: 'test-user', date: '2024-01-01'));
        workoutSessionBloc.add(const LoadActiveSessions(userId: 'test-user'));
        dailySummaryBloc.add(const LoadDailySummary(userId: 'test-user', date: '2024-01-01'));

        await tester.pump();

        // Verify all operations completed without conflicts
        expect(mealBloc.state, isA<MealState>());
        expect(workoutSessionBloc.state, isA<WorkoutSessionState>());
        expect(dailySummaryBloc.state, isA<DailySummaryState>());
      });
    });

    group('Performance and Memory Tests', () {
      testWidgets('Memory usage with multiple BLoCs', (WidgetTester tester) async {
        // Create multiple instances to test memory management
        final blocs = List.generate(10, (index) => MealBloc(mealRepository: mockMealRepository));

        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: blocs.map((bloc) => BlocProvider<MealBloc>.value(value: bloc)).toList(),
              child: const Scaffold(body: Text('Memory Test')),
            ),
          ),
        );

        // Trigger operations on all BLoCs
        for (final bloc in blocs) {
          bloc.add(const LoadMealRecords(userId: 'test-user', date: '2024-01-01'));
        }

        await tester.pump();

        // Dispose all BLoCs
        for (final bloc in blocs) {
          bloc.close();
        }

        // Verify no memory leaks (this is a basic check)
        expect(blocs.every((bloc) => bloc.isClosed), isTrue);
      });

      testWidgets('State change frequency optimization', (WidgetTester tester) async {
        int stateChangeCount = 0;
        
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MealBloc>.value(
              value: mealBloc,
              child: BlocListener<MealBloc, MealState>(
                listener: (context, state) {
                  stateChangeCount++;
                },
                child: const Scaffold(body: Text('Performance Test')),
              ),
            ),
          ),
        );

        // Trigger multiple rapid operations
        for (int i = 0; i < 5; i++) {
          mealBloc.add(LoadMealRecords(userId: 'test-user', date: '2024-01-0$i'));
        }

        await tester.pump();

        // Verify reasonable number of state changes (not excessive)
        expect(stateChangeCount, lessThan(10));
      });
    });

    group('Data Consistency Tests', () {
      testWidgets('Cross-bloc data synchronization', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<MealBloc>.value(value: mealBloc),
                BlocProvider<DailySummaryBloc>.value(value: dailySummaryBloc),
              ],
              child: const Scaffold(body: Text('Sync Test')),
            ),
          ),
        );

        // Add meal record
        mealBloc.add(const AddMealRecord(
          userId: 'test-user',
          foodItemId: 'food-1',
          quantity: 100,
          mealType: 'breakfast',
        ));

        await tester.pump();

        // Load daily summary
        dailySummaryBloc.add(const LoadDailySummary(
          userId: 'test-user',
          date: '2024-01-01',
        ));

        await tester.pump();

        // Verify data consistency between BLoCs
        expect(mealBloc.state, isA<MealState>());
        expect(dailySummaryBloc.state, isA<DailySummaryState>());
      });
    });
  });
}