import 'dart:async';

/// Event bus system for BLOC-to-BLOC communication
/// Provides a centralized way for BLOCs to communicate with each other
/// without creating direct dependencies
class BlocEventBus {
  static final BlocEventBus _instance = BlocEventBus._internal();
  factory BlocEventBus() => _instance;
  BlocEventBus._internal();

  final StreamController<BlocCommunicationEvent> _controller =
      StreamController<BlocCommunicationEvent>.broadcast();

  // Circular reference prevention
  final Set<String> _processingEvents = <String>{};
  static const int _maxEventDepth = 5;
  int _currentEventDepth = 0;

  /// Stream of all communication events
  Stream<BlocCommunicationEvent> get stream => _controller.stream;

  /// Emit a communication event to all listening BLOCs
  /// Includes circular reference prevention to avoid infinite loops
  void emit(BlocCommunicationEvent event) {
    if (_controller.isClosed) return;

    // Generate a unique key for this event to detect circular references
    final eventKey = _generateEventKey(event);
    
    // Prevent circular references
    if (_processingEvents.contains(eventKey)) {
      // Log circular reference attempt but don't emit
      return;
    }

    // Prevent infinite event chains
    if (_currentEventDepth >= _maxEventDepth) {
      // Log max depth reached but don't emit
      return;
    }

    try {
      _processingEvents.add(eventKey);
      _currentEventDepth++;
      
      _controller.add(event);
    } finally {
      // Clean up tracking after a short delay to allow event processing
      Future.delayed(const Duration(milliseconds: 100), () {
        _processingEvents.remove(eventKey);
        _currentEventDepth = (_currentEventDepth - 1).clamp(0, _maxEventDepth);
      });
    }
  }

  /// Generate a unique key for an event to detect circular references
  String _generateEventKey(BlocCommunicationEvent event) {
    if (event is MealRecordChangedEvent) {
      return 'meal_${event.userId}_${event.date.toIso8601String().split('T')[0]}_${event.changeType.name}';
    } else if (event is WorkoutSessionCompletedEvent) {
      return 'workout_session_${event.userId}_${event.sessionId}';
    } else if (event is WorkoutSessionCreatedEvent) {
      return 'workout_session_created_${event.sessionId}_${event.userProgramId}';
    } else if (event is WorkoutProgramProgressUpdatedEvent) {
      return 'program_progress_${event.userProgramId}_${event.currentWeek}_${event.currentDay}';
    } else if (event is WorkoutProgramDayCompletedEvent) {
      return 'program_day_${event.userProgramId}_${event.week}_${event.day}';
    } else if (event is WorkoutProgramDeletedEvent) {
      return 'program_deleted_${event.userProgramId}';
    } else if (event is WorkoutProgramDataSyncRequestedEvent) {
      return 'program_sync_${event.reason}_${event.timestamp.millisecondsSinceEpoch}';
    } else if (event is DailySummaryRefreshRequestedEvent) {
      return 'summary_refresh_${event.userId}_${event.date.toIso8601String().split('T')[0]}_${event.reason.name}';
    }
    
    // Fallback for unknown event types
    return '${event.runtimeType}_${event.timestamp.millisecondsSinceEpoch}';
  }

  /// Filter stream by event type
  Stream<T> streamOf<T extends BlocCommunicationEvent>() {
    return stream.where((event) => event is T).cast<T>();
  }

  /// Get current processing events (for debugging)
  Set<String> get processingEvents => Set.unmodifiable(_processingEvents);

  /// Get current event depth (for debugging)
  int get currentEventDepth => _currentEventDepth;

  /// Clear processing events (for testing or error recovery)
  void clearProcessingEvents() {
    _processingEvents.clear();
    _currentEventDepth = 0;
  }

  /// Dispose the event bus (should be called when app is closing)
  void dispose() {
    _processingEvents.clear();
    _currentEventDepth = 0;
    _controller.close();
  }
}

/// Base class for all BLOC communication events
abstract class BlocCommunicationEvent {
  final DateTime timestamp;
  
  BlocCommunicationEvent() : timestamp = DateTime.now();
}

/// Event emitted when meal records are changed
class MealRecordChangedEvent extends BlocCommunicationEvent {
  final String userId;
  final DateTime date;
  final MealChangeType changeType;
  final String? recordId;

  MealRecordChangedEvent({
    required this.userId,
    required this.date,
    required this.changeType,
    this.recordId,
  });
}

/// Event emitted when a workout session is completed
class WorkoutSessionCompletedEvent extends BlocCommunicationEvent {
  final String userId;
  final DateTime date;
  final String sessionId;
  final String? userProgramId;

  WorkoutSessionCompletedEvent({
    required this.userId,
    required this.date,
    required this.sessionId,
    this.userProgramId,
  });
}

/// Event emitted when workout program progress is updated
class WorkoutProgramProgressUpdatedEvent extends BlocCommunicationEvent {
  final String userProgramId;
  final int currentWeek;
  final int currentDay;

  WorkoutProgramProgressUpdatedEvent({
    required this.userProgramId,
    required this.currentWeek,
    required this.currentDay,
  });
}

/// Event emitted when a workout program day is completed
class WorkoutProgramDayCompletedEvent extends BlocCommunicationEvent {
  final String userProgramId;
  final int week;
  final int day;
  final DateTime completedAt;

  WorkoutProgramDayCompletedEvent({
    required this.userProgramId,
    required this.week,
    required this.day,
    required this.completedAt,
  });
}

/// Event emitted when a user program is deleted
class WorkoutProgramDeletedEvent extends BlocCommunicationEvent {
  final String userProgramId;
  final String userId;

  WorkoutProgramDeletedEvent({
    required this.userProgramId,
    required this.userId,
  });
}

/// Event emitted when daily summary needs to be refreshed
class DailySummaryRefreshRequestedEvent extends BlocCommunicationEvent {
  final String userId;
  final DateTime date;
  final RefreshReason reason;

  DailySummaryRefreshRequestedEvent({
    required this.userId,
    required this.date,
    required this.reason,
  });
}

/// Event emitted when a workout session is created
class WorkoutSessionCreatedEvent extends BlocCommunicationEvent {
  final String sessionId;
  final String userProgramId;
  final DateTime sessionDate;

  WorkoutSessionCreatedEvent({
    required this.sessionId,
    required this.userProgramId,
    required this.sessionDate,
  });
}

/// Event emitted when workout program data synchronization is requested
class WorkoutProgramDataSyncRequestedEvent extends BlocCommunicationEvent {
  final String reason;

  WorkoutProgramDataSyncRequestedEvent({
    required this.reason,
  });
}

/// Types of meal record changes
enum MealChangeType {
  added,
  updated,
  deleted,
}

/// Reasons for daily summary refresh
enum RefreshReason {
  mealChanged,
  workoutCompleted,
  programProgressUpdated,
  manualRefresh,
}