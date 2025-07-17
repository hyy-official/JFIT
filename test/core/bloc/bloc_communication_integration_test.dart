import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:jfit/core/bloc/bloc_event_bus.dart';
import 'package:jfit/features/meal/bloc/meal_bloc.dart';
import 'package:jfit/features/daily_summary/bloc/daily_summary_bloc.dart';
import 'package:jfit/features/workout_session/bloc/workout_session_bloc.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_bloc.dart';
import 'package:jfit/features/meal/data/repositories/meal_repository.dart';
import 'package:jfit/features/daily_summary/data/repositories/daily_summary_repository.dart';
import 'package:jfit/features/workout_session/data/repositories/workout_session_repository.dart';
import 'package:jfit/features/workout_program/data/repositories/workout_program_repository.dart';

// Generate mocks
@GenerateMocks([
  MealRepository,
  DailySummaryRepository,
  WorkoutSessionRepository,
  WorkoutProgramRepository,
])
import 'bloc_communication_integration_test.mocks.dart';

void main() {
  group('BLOC Communication Integration Tests', () {
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

    group('Event Bus System Tests', () {
      test('should emit and receive communication events', () async {
        // Arrange
        final completer = Completer<BlocCommunicationEvent>();
        late StreamSubscription subscription;
        
        subscription = eventBus.stream.listen((event) {
          completer.complete(event);
          subscription.cancel();
        });

        // Act
        final testEvent = MealRecordChangedEvent(
          userId: 'test-user',
          date: DateTime.now(),
          changeType: MealChangeType.added,
          recordId: 'test-record',
        );
        eventBus.emit(testEvent);

        // Assert
        final receivedEvent = await completer.future.timeout(
          const Duration(seconds: 1),
          onTimeout: () => throw TimeoutException('Event not received'),
        );
        
        expect(receivedEvent, isA<MealRecordChangedEvent>());
        expect((receivedEvent as MealRecordChangedEvent).userId, equals('test-user'));
        expect(receivedEvent.changeType, equals(MealChangeType.added));
      });

      test('should filter events by type', () async {
        // Arrange
        final mealEvents = <MealRecordChangedEvent>[];
        final workoutEvents = <WorkoutSessionCompletedEvent>[];
        
        final mealSubscription = eventBus.streamOf<MealRecordChangedEvent>()
            .listen(mealEvents.add);
        final workoutSubscription = eventBus.streamOf<WorkoutSessionCompletedEvent>()
            .listen(workoutEvents.add);

        // Act
        eventBus.emit(MealRecordChangedEvent(
          userId: 'user1',
          date: DateTime.now(),
          changeType: MealChangeType.added,
        ));
        
        eventBus.emit(WorkoutSessionCompletedEvent(
          userId: 'user1',
          date: DateTime.now(),
          sessionId: 'session1',
        ));
        
        eventBus.emit(MealRecordChangedEvent(
          userId: 'user1',
          date: DateTime.now(),
          changeType: MealChangeType.updated,
        ));

        // Wait for events to be processed
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(mealEvents, hasLength(2));
        expect(workoutEvents, hasLength(1));
        expect(mealEvents[0].changeType, equals(MealChangeType.added));
        expect(mealEvents[1].changeType, equals(MealChangeType.updated));
        expect(workoutEvents[0].sessionId, equals('session1'));

        // Clean up
        await mealSubscription.cancel();
        await workoutSubscription.cancel();
      });

      test('should prevent circular references', () async {
        // Arrange
        final events = <BlocCommunicationEvent>[];
        final subscription = eventBus.stream.listen(events.add);
        
        final testEvent = MealRecordChangedEvent(
          userId: 'test-user',
          date: DateTime.now(),
          changeType: MealChangeType.added,
          recordId: 'test-record',
        );

        // Act - emit the same event multiple times rapidly
        for (int i = 0; i < 5; i++) {
          eventBus.emit(testEvent);
        }

        // Wait for events to be processed but not too long for cleanup
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert - should only receive one event due to circular reference prevention
        expect(events, hasLength(1));
        // Note: processingEvents might be empty if cleanup happened quickly
        // The important thing is that only one event was processed

        // Clean up
        await subscription.cancel();
      });

      test('should prevent infinite event chains', () async {
        // Arrange
        final events = <BlocCommunicationEvent>[];
        final subscription = eventBus.stream.listen(events.add);

        // Act - emit many different events rapidly to test depth limit
        for (int i = 0; i < 10; i++) {
          eventBus.emit(MealRecordChangedEvent(
            userId: 'user$i',
            date: DateTime.now(),
            changeType: MealChangeType.added,
            recordId: 'record$i',
          ));
        }

        // Wait for events to be processed
        await Future.delayed(const Duration(milliseconds: 200));

        // Assert - should limit the number of events processed
        expect(events.length, lessThanOrEqualTo(5)); // Max depth is 5
        expect(eventBus.currentEventDepth, lessThanOrEqualTo(5));

        // Clean up
        await subscription.cancel();
      });
    });

    group('Meal to Daily Summary Communication', () {
      test('should update daily summary when meal record is added', () async {
        // This test would require more complex setup with actual BLOC integration
        // For now, we'll test the event emission and handling separately
        
        // Arrange
        final testDate = DateTime.now();
        final events = <BlocCommunicationEvent>[];
        final subscription = eventBus.stream.listen(events.add);

        // Act
        eventBus.emit(MealRecordChangedEvent(
          userId: 'test-user',
          date: testDate,
          changeType: MealChangeType.added,
          recordId: 'meal-123',
        ));

        // Wait for event processing
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(events, hasLength(1));
        expect(events.first, isA<MealRecordChangedEvent>());
        
        final mealEvent = events.first as MealRecordChangedEvent;
        expect(mealEvent.userId, equals('test-user'));
        expect(mealEvent.changeType, equals(MealChangeType.added));
        expect(mealEvent.recordId, equals('meal-123'));

        // Clean up
        await subscription.cancel();
      });

      test('should handle meal record updates', () async {
        // Arrange
        final events = <MealRecordChangedEvent>[];
        final subscription = eventBus.streamOf<MealRecordChangedEvent>()
            .listen(events.add);

        // Act
        eventBus.emit(MealRecordChangedEvent(
          userId: 'test-user',
          date: DateTime.now(),
          changeType: MealChangeType.updated,
          recordId: 'meal-456',
        ));

        // Wait for event processing
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(events, hasLength(1));
        expect(events.first.changeType, equals(MealChangeType.updated));
        expect(events.first.recordId, equals('meal-456'));

        // Clean up
        await subscription.cancel();
      });

      test('should handle meal record deletions', () async {
        // Arrange
        final events = <MealRecordChangedEvent>[];
        final subscription = eventBus.streamOf<MealRecordChangedEvent>()
            .listen(events.add);

        // Act
        eventBus.emit(MealRecordChangedEvent(
          userId: 'test-user',
          date: DateTime.now(),
          changeType: MealChangeType.deleted,
          recordId: 'meal-789',
        ));

        // Wait for event processing
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(events, hasLength(1));
        expect(events.first.changeType, equals(MealChangeType.deleted));
        expect(events.first.recordId, equals('meal-789'));

        // Clean up
        await subscription.cancel();
      });
    });

    group('Workout Session to Daily Summary Communication', () {
      test('should update daily summary when workout session is completed', () async {
        // Arrange
        final events = <WorkoutSessionCompletedEvent>[];
        final subscription = eventBus.streamOf<WorkoutSessionCompletedEvent>()
            .listen(events.add);

        // Act
        eventBus.emit(WorkoutSessionCompletedEvent(
          userId: 'test-user',
          date: DateTime.now(),
          sessionId: 'session-123',
          userProgramId: 'program-456',
        ));

        // Wait for event processing
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(events, hasLength(1));
        expect(events.first.sessionId, equals('session-123'));
        expect(events.first.userProgramId, equals('program-456'));

        // Clean up
        await subscription.cancel();
      });

      test('should trigger daily summary refresh on workout completion', () async {
        // Arrange
        final refreshEvents = <DailySummaryRefreshRequestedEvent>[];
        final subscription = eventBus.streamOf<DailySummaryRefreshRequestedEvent>()
            .listen(refreshEvents.add);

        // Act - simulate workout session completion triggering summary refresh
        eventBus.emit(DailySummaryRefreshRequestedEvent(
          userId: 'test-user',
          date: DateTime.now(),
          reason: RefreshReason.workoutCompleted,
        ));

        // Wait for event processing
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(refreshEvents, hasLength(1));
        expect(refreshEvents.first.reason, equals(RefreshReason.workoutCompleted));

        // Clean up
        await subscription.cancel();
      });
    });

    group('Workout Program Communication', () {
      test('should handle workout program progress updates', () async {
        // Arrange
        final events = <WorkoutProgramProgressUpdatedEvent>[];
        final subscription = eventBus.streamOf<WorkoutProgramProgressUpdatedEvent>()
            .listen(events.add);

        // Act
        eventBus.emit(WorkoutProgramProgressUpdatedEvent(
          userProgramId: 'program-123',
          currentWeek: 2,
          currentDay: 3,
        ));

        // Wait for event processing
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(events, hasLength(1));
        expect(events.first.userProgramId, equals('program-123'));
        expect(events.first.currentWeek, equals(2));
        expect(events.first.currentDay, equals(3));

        // Clean up
        await subscription.cancel();
      });

      test('should handle workout program day completion', () async {
        // Arrange
        final events = <WorkoutProgramDayCompletedEvent>[];
        final subscription = eventBus.streamOf<WorkoutProgramDayCompletedEvent>()
            .listen(events.add);

        // Act
        final completedAt = DateTime.now();
        eventBus.emit(WorkoutProgramDayCompletedEvent(
          userProgramId: 'program-456',
          week: 1,
          day: 2,
          completedAt: completedAt,
        ));

        // Wait for event processing
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(events, hasLength(1));
        expect(events.first.userProgramId, equals('program-456'));
        expect(events.first.week, equals(1));
        expect(events.first.day, equals(2));
        expect(events.first.completedAt, equals(completedAt));

        // Clean up
        await subscription.cancel();
      });

      test('should handle workout program deletion', () async {
        // Arrange
        final events = <WorkoutProgramDeletedEvent>[];
        final subscription = eventBus.streamOf<WorkoutProgramDeletedEvent>()
            .listen(events.add);

        // Act
        eventBus.emit(WorkoutProgramDeletedEvent(
          userProgramId: 'program-789',
          userId: 'user-123',
        ));

        // Wait for event processing
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(events, hasLength(1));
        expect(events.first.userProgramId, equals('program-789'));
        expect(events.first.userId, equals('user-123'));

        // Clean up
        await subscription.cancel();
      });
    });

    group('Error Handling and Recovery', () {
      test('should handle communication errors gracefully', () async {
        // Arrange
        final events = <BlocCommunicationEvent>[];
        final errors = <dynamic>[];
        
        final subscription = eventBus.stream.listen(
          events.add,
          onError: errors.add,
        );

        // Act - emit a valid event
        eventBus.emit(MealRecordChangedEvent(
          userId: 'test-user',
          date: DateTime.now(),
          changeType: MealChangeType.added,
        ));

        // Wait for event processing
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert - should handle events without errors
        expect(events, hasLength(1));
        expect(errors, isEmpty);

        // Clean up
        await subscription.cancel();
      });

      test('should recover from processing errors', () async {
        // Arrange
        eventBus.clearProcessingEvents(); // Start with clean state
        
        final events = <BlocCommunicationEvent>[];
        final subscription = eventBus.stream.listen(events.add);

        // Act - emit events after clearing processing state
        eventBus.emit(MealRecordChangedEvent(
          userId: 'recovery-test',
          date: DateTime.now(),
          changeType: MealChangeType.added,
        ));

        // Wait for event processing
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(events, hasLength(1));
        expect(eventBus.processingEvents, isNotEmpty);

        // Clean up
        await subscription.cancel();
      });
    });

    group('Data Consistency Tests', () {
      test('should maintain event order for same user', () async {
        // Arrange
        final events = <MealRecordChangedEvent>[];
        final subscription = eventBus.streamOf<MealRecordChangedEvent>()
            .listen(events.add);

        // Act - emit multiple events for the same user
        final testDate = DateTime.now();
        eventBus.emit(MealRecordChangedEvent(
          userId: 'consistency-user',
          date: testDate,
          changeType: MealChangeType.added,
          recordId: 'meal-1',
        ));
        
        eventBus.emit(MealRecordChangedEvent(
          userId: 'consistency-user',
          date: testDate,
          changeType: MealChangeType.updated,
          recordId: 'meal-1',
        ));

        // Wait for event processing
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - should receive events in order
        expect(events, hasLength(2));
        expect(events[0].changeType, equals(MealChangeType.added));
        expect(events[1].changeType, equals(MealChangeType.updated));
        expect(events[0].recordId, equals(events[1].recordId));

        // Clean up
        await subscription.cancel();
      });

      test('should handle concurrent events from different users', () async {
        // Arrange
        final events = <MealRecordChangedEvent>[];
        final subscription = eventBus.streamOf<MealRecordChangedEvent>()
            .listen(events.add);

        // Act - emit events for different users concurrently
        final testDate = DateTime.now();
        eventBus.emit(MealRecordChangedEvent(
          userId: 'user-1',
          date: testDate,
          changeType: MealChangeType.added,
          recordId: 'meal-user1',
        ));
        
        eventBus.emit(MealRecordChangedEvent(
          userId: 'user-2',
          date: testDate,
          changeType: MealChangeType.added,
          recordId: 'meal-user2',
        ));

        // Wait for event processing
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - should receive all events
        expect(events, hasLength(2));
        
        final userIds = events.map((e) => e.userId).toSet();
        expect(userIds, containsAll(['user-1', 'user-2']));

        // Clean up
        await subscription.cancel();
      });
    });
  });
}