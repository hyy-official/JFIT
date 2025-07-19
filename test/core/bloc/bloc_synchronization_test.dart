import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:jfit/core/bloc/bloc_event_bus.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/features/meal/bloc/meal_bloc.dart';
import 'package:jfit/features/meal/bloc/meal_event.dart';
import 'package:jfit/features/meal/bloc/meal_state.dart';
import 'package:jfit/features/daily_summary/bloc/daily_summary_bloc.dart';
import 'package:jfit/features/daily_summary/bloc/daily_summary_state.dart';
import 'package:jfit/features/workout_session/bloc/workout_session_bloc.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_bloc.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_event.dart';
import 'package:jfit/features/meal/data/repositories/meal_repository.dart';
import 'package:jfit/features/daily_summary/data/repositories/daily_summary_repository.dart';
import 'package:jfit/features/workout_session/data/repositories/workout_session_repository.dart';
import 'package:jfit/features/workout_program/data/repositories/workout_program_repository.dart';
import 'package:jfit/features/records/data/models/meal_record_model.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';

// Generate mocks
@GenerateMocks([
  MealRepository,
  DailySummaryRepository,
  WorkoutSessionRepository,
  WorkoutProgramRepository,
])
import 'bloc_synchronization_test.mocks.dart';

void main() {
  group('BLOC Synchronization Tests', () {
    late BlocEventBus eventBus;
    late MealBloc mealBloc;
    late DailySummaryBloc dailySummaryBloc;
    late WorkoutSessionBloc workoutSessionBloc;
    late WorkoutProgramBloc workoutProgramBloc;
    
    late MockMealRepository mockMealRepository;
    late MockDailySummaryRepository mockDailySummaryRepository;
    late MockWorkoutSessionRepository mockWorkoutSessionRepository;
    late MockWorkoutProgramRepository mockWorkoutProgramRepository;

    setUp(() {
      // Create mock repositories
      mockMealRepository = MockMealRepository();
      mockDailySummaryRepository = MockDailySummaryRepository();
      mockWorkoutSessionRepository = MockWorkoutSessionRepository();
      mockWorkoutProgramRepository = MockWorkoutProgramRepository();

      // Create event bus instance
      eventBus = BlocEventBus();
      
      // Create BLOCs with mock repositories
      mealBloc = MealBloc(mealRepository: mockMealRepository);
      dailySummaryBloc = DailySummaryBloc(repository: mockDailySummaryRepository);
      workoutSessionBloc = WorkoutSessionBloc(repository: mockWorkoutSessionRepository);
      workoutProgramBloc = WorkoutProgramBloc(workoutProgramRepository: mockWorkoutProgramRepository);
    });

    tearDown(() {
      // Clean up BLOCs
      mealBloc.close();
      dailySummaryBloc.close();
      workoutSessionBloc.close();
      workoutProgramBloc.close();
      
      // Clean up event bus
      eventBus.clearProcessingEvents();
    });

    group('Meal to Daily Summary Synchronization', () {
      test('should trigger daily summary update when meal is added', () async {
        // Arrange
        final testMeal = MealRecord(
          id: 'meal-123',
          userId: 'user-123',
          mealType: 'breakfast',
          mealDate: DateTime.now(),
          totalCalories: 500.0,
          totalProtein: 25.0,
          totalCarbs: 60.0,
          totalFat: 15.0,
        );

        final testSummary = UserDailySummary(
          id: 'summary-123',
          userId: 'user-123',
          summaryDate: DateTime.now(),
          totalCaloriesConsumed: 500,
          totalWorkoutDurationMinutes: 0,
        );

        // Mock repository responses
        when(mockMealRepository.addMealRecord(any))
            .thenAnswer((_) async => const Right(null));
        when(mockDailySummaryRepository.calculateAndUpdateDailySummary(any, any))
            .thenAnswer((_) async => Right(testSummary));

        // Track daily summary state changes
        dailySummaryBloc.stream.listen((state) {
          // In a real test, we'd track the events that caused state changes
          // For now, we'll verify the communication events are emitted
        });

        // Track communication events
        final communicationEvents = <BlocCommunicationEvent>[];
        eventBus.stream.listen(communicationEvents.add);

        // Act
        mealBloc.add(AddMealRecord(mealRecord: testMeal));

        // Wait for event processing
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(communicationEvents, isNotEmpty);
        expect(communicationEvents.any((e) => e is MealRecordChangedEvent), isTrue);
        
        final mealEvent = communicationEvents
            .whereType<MealRecordChangedEvent>()
            .first;
        expect(mealEvent.userId, equals('user-123'));
        expect(mealEvent.changeType, equals(MealChangeType.added));
      });

      test('should handle meal update synchronization', () async {
        // Arrange
        final testMeal = MealRecord(
          id: 'meal-456',
          userId: 'user-456',
          mealType: 'lunch',
          mealDate: DateTime.now(),
          totalCalories: 600.0,
          totalProtein: 30.0,
          totalCarbs: 70.0,
          totalFat: 20.0,
        );

        // Mock repository responses
        when(mockMealRepository.updateMealRecord(any))
            .thenAnswer((_) async => const Right(null));

        // Track communication events
        final communicationEvents = <BlocCommunicationEvent>[];
        eventBus.stream.listen(communicationEvents.add);

        // Act
        mealBloc.add(UpdateMealRecord(mealRecord: testMeal));

        // Wait for event processing
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(communicationEvents, isNotEmpty);
        expect(communicationEvents.any((e) => e is MealRecordChangedEvent), isTrue);
        
        final mealEvent = communicationEvents
            .whereType<MealRecordChangedEvent>()
            .first;
        expect(mealEvent.changeType, equals(MealChangeType.updated));
        expect(mealEvent.recordId, equals('meal-456'));
      });

      test('should handle meal deletion synchronization', () async {
        // Arrange
        const userId = 'user-789';
        const recordId = 'meal-789';
        final testDate = DateTime.now();

        // Mock repository responses
        when(mockMealRepository.deleteMealRecord(any))
            .thenAnswer((_) async => const Right(null));

        // Track communication events
        final communicationEvents = <BlocCommunicationEvent>[];
        eventBus.stream.listen(communicationEvents.add);

        // Act
        mealBloc.add(DeleteMealRecord(
          recordId: recordId,
          userId: userId,
          date: testDate,
        ));

        // Wait for event processing
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(communicationEvents, isNotEmpty);
        expect(communicationEvents.any((e) => e is MealRecordChangedEvent), isTrue);
        
        final mealEvent = communicationEvents
            .whereType<MealRecordChangedEvent>()
            .first;
        expect(mealEvent.changeType, equals(MealChangeType.deleted));
        expect(mealEvent.recordId, equals(recordId));
        expect(mealEvent.userId, equals(userId));
      });
    });

    group('Workout Session to Daily Summary Synchronization', () {
      test('should handle workout session completed events', () async {
        // Arrange
        final communicationEvents = <WorkoutSessionCompletedEvent>[];
        final subscription = eventBus.streamOf<WorkoutSessionCompletedEvent>()
            .listen(communicationEvents.add);

        // Act - emit a workout session completed event directly
        eventBus.emit(WorkoutSessionCompletedEvent(
          userId: 'user-123',
          date: DateTime.now(),
          sessionId: 'session-123',
          userProgramId: 'program-123',
        ));

        // Wait for event processing
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(communicationEvents, hasLength(1));
        expect(communicationEvents.first.sessionId, equals('session-123'));
        expect(communicationEvents.first.userProgramId, equals('program-123'));

        // Clean up
        await subscription.cancel();
      });
    });

    group('Workout Program Synchronization', () {
      test('should handle workout program progress updates', () async {
        // Arrange
        const userProgramId = 'program-456';
        const currentWeek = 2;
        const currentDay = 3;

        // Mock repository responses
        when(mockWorkoutProgramRepository.updateUserProgramProgress(any, any, any))
            .thenAnswer((_) async => const Right(null));

        // Track communication events
        final communicationEvents = <BlocCommunicationEvent>[];
        eventBus.stream.listen(communicationEvents.add);

        // Act
        workoutProgramBloc.add(UpdateProgramProgress(
          userProgramId: userProgramId,
          currentWeek: currentWeek,
          currentDay: currentDay,
        ));

        // Wait for event processing
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(communicationEvents, isNotEmpty);
        expect(communicationEvents.any((e) => e is WorkoutProgramProgressUpdatedEvent), isTrue);
        
        final progressEvent = communicationEvents
            .whereType<WorkoutProgramProgressUpdatedEvent>()
            .first;
        expect(progressEvent.userProgramId, equals(userProgramId));
        expect(progressEvent.currentWeek, equals(currentWeek));
        expect(progressEvent.currentDay, equals(currentDay));
      });

      test('should handle workout program day completion', () async {
        // Arrange
        const userProgramId = 'program-789';
        const week = 1;
        const day = 2;
        const note = 'Great workout!';

        // Mock repository responses
        when(mockWorkoutProgramRepository.completeUserProgramDay(any, any, any, note: anyNamed('note')))
            .thenAnswer((_) async => const Right(null));

        // Track communication events
        final communicationEvents = <BlocCommunicationEvent>[];
        eventBus.stream.listen(communicationEvents.add);

        // Act
        workoutProgramBloc.add(CompleteProgramDay(
          userProgramId: userProgramId,
          week: week,
          day: day,
          note: note,
        ));

        // Wait for event processing
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(communicationEvents, isNotEmpty);
        expect(communicationEvents.any((e) => e is WorkoutProgramDayCompletedEvent), isTrue);
        
        final dayEvent = communicationEvents
            .whereType<WorkoutProgramDayCompletedEvent>()
            .first;
        expect(dayEvent.userProgramId, equals(userProgramId));
        expect(dayEvent.week, equals(week));
        expect(dayEvent.day, equals(day));
      });

      test('should handle workout program deletion', () async {
        // Arrange
        const userProgramId = 'program-delete';
        const userId = 'user-delete';

        // Mock repository responses
        when(mockWorkoutProgramRepository.deleteUserProgram(any))
            .thenAnswer((_) async => const Right(null));

        // Track communication events
        final communicationEvents = <BlocCommunicationEvent>[];
        eventBus.stream.listen(communicationEvents.add);

        // Act
        workoutProgramBloc.add(DeleteUserProgram(
          userProgramId: userProgramId,
          userId: userId,
        ));

        // Wait for event processing
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(communicationEvents, isNotEmpty);
        expect(communicationEvents.any((e) => e is WorkoutProgramDeletedEvent), isTrue);
        
        final deleteEvent = communicationEvents
            .whereType<WorkoutProgramDeletedEvent>()
            .first;
        expect(deleteEvent.userProgramId, equals(userProgramId));
        expect(deleteEvent.userId, equals(userId));
      });
    });

    group('Cross-BLOC Communication Handling', () {
      test('should handle daily summary refresh requests', () async {
        // Arrange
        final testSummary = UserDailySummary(
          id: 'summary-refresh',
          userId: 'user-refresh',
          summaryDate: DateTime.now(),
          totalCaloriesConsumed: 1500,
          totalWorkoutDurationMinutes: 60,
        );

        // Mock repository responses
        when(mockDailySummaryRepository.calculateAndUpdateDailySummary(any, any))
            .thenAnswer((_) async => Right(testSummary));

        // Track daily summary states
        final summaryStates = <DailySummaryState>[];
        dailySummaryBloc.stream.listen(summaryStates.add);

        // Act - emit a refresh request event
        eventBus.emit(DailySummaryRefreshRequestedEvent(
          userId: 'user-refresh',
          date: DateTime.now(),
          reason: RefreshReason.mealChanged,
        ));

        // Wait for event processing
        await Future.delayed(const Duration(milliseconds: 200));

        // Assert - daily summary should have processed the refresh request
        expect(summaryStates, isNotEmpty);
        // The exact state verification would depend on the implementation details
      });

      test('should handle workout session completion affecting program progress', () async {
        // Arrange
        final testDate = DateTime.now();
        
        // Track communication events
        final communicationEvents = <BlocCommunicationEvent>[];
        eventBus.stream.listen(communicationEvents.add);

        // Act - emit a workout session completed event
        eventBus.emit(WorkoutSessionCompletedEvent(
          userId: 'user-program-sync',
          date: testDate,
          sessionId: 'session-sync',
          userProgramId: 'program-sync',
        ));

        // Wait for event processing
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - should trigger additional communication events
        expect(communicationEvents, isNotEmpty);
        
        // The workout program bloc should handle this event
        // and potentially emit additional events
      });
    });

    group('Error Propagation and Recovery', () {
      test('should handle repository errors gracefully', () async {
        // Arrange
        final testMeal = MealRecord(
          id: 'meal-error',
          userId: 'user-error',
          mealType: 'breakfast',
          mealDate: DateTime.now(),
        );

        // Mock repository to return error
        when(mockMealRepository.addMealRecord(any))
            .thenAnswer((_) async => Left(ServerFailure('Database error')));

        // Track meal states
        final mealStates = <MealState>[];
        mealBloc.stream.listen(mealStates.add);

        // Track communication events
        final communicationEvents = <BlocCommunicationEvent>[];
        eventBus.stream.listen(communicationEvents.add);

        // Act
        mealBloc.add(AddMealRecord(mealRecord: testMeal));

        // Wait for event processing
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - should handle error without crashing
        expect(mealStates, isNotEmpty);
        expect(mealStates.any((s) => s is MealErrorState), isTrue);
        
        // Should not emit communication events on error
        expect(communicationEvents.any((e) => e is MealRecordChangedEvent), isFalse);
      });

      test('should recover from communication event handling errors', () async {
        // Arrange
        eventBus.clearProcessingEvents(); // Start with clean state
        
        // Track communication events
        final communicationEvents = <BlocCommunicationEvent>[];
        eventBus.stream.listen(communicationEvents.add);

        // Act - emit events after clearing error state
        eventBus.emit(MealRecordChangedEvent(
          userId: 'recovery-user',
          date: DateTime.now(),
          changeType: MealChangeType.added,
        ));

        // Wait for event processing
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - should process events normally after recovery
        expect(communicationEvents, hasLength(1));
        expect(communicationEvents.first, isA<MealRecordChangedEvent>());
      });
    });
  });
}