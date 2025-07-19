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
    } else if (event is GroupMemberJoinedEvent) {
      return 'group_member_joined_${event.groupId}_${event.userId}';
    } else if (event is GroupMemberLeftEvent) {
      return 'group_member_left_${event.groupId}_${event.userId}';
    } else if (event is RoutineSharedEvent) {
      return 'routine_shared_${event.groupId}_${event.sharedRoutineId}';
    } else if (event is GroupWorkoutCompletedEvent) {
      return 'group_workout_completed_${event.groupId}_${event.userId}_${event.sessionId}';
    } else if (event is CommunityPostCreatedEvent) {
      return 'post_created_${event.postId}_${event.authorId}';
    } else if (event is PostCommentAddedEvent) {
      return 'comment_added_${event.postId}_${event.commentId}';
    } else if (event is PostInteractionEvent) {
      return 'post_interaction_${event.postId}_${event.userId}_${event.interactionType}';
    } else if (event is GroupRankingUpdatedEvent) {
      return 'ranking_updated_${event.groupId}_${event.newRank}';
    } else if (event is UserWorkoutScoreCalculatedEvent) {
      return 'score_calculated_${event.userId}_${event.groupId}_${event.scoreDate.toIso8601String().split('T')[0]}';
    } else if (event is DietFeedbackProvidedEvent) {
      return 'diet_feedback_${event.groupId}_${event.memberId}_${event.feedbackId}';
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

// Group Workout Community Events

/// Event emitted when a user joins a group
class GroupMemberJoinedEvent extends BlocCommunicationEvent {
  final String groupId;
  final String userId;
  final String username;

  GroupMemberJoinedEvent({
    required this.groupId,
    required this.userId,
    required this.username,
  });
}

/// Event emitted when a user leaves a group
class GroupMemberLeftEvent extends BlocCommunicationEvent {
  final String groupId;
  final String userId;
  final String username;

  GroupMemberLeftEvent({
    required this.groupId,
    required this.userId,
    required this.username,
  });
}

/// Event emitted when a routine is shared in a group
class RoutineSharedEvent extends BlocCommunicationEvent {
  final String groupId;
  final String sharedByUserId;
  final String routineName;
  final String sharedRoutineId;

  RoutineSharedEvent({
    required this.groupId,
    required this.sharedByUserId,
    required this.routineName,
    required this.sharedRoutineId,
  });
}

/// Event emitted when a workout is completed and shared with group
class GroupWorkoutCompletedEvent extends BlocCommunicationEvent {
  final String groupId;
  final String userId;
  final String sessionId;
  final DateTime completedAt;

  GroupWorkoutCompletedEvent({
    required this.groupId,
    required this.userId,
    required this.sessionId,
    required this.completedAt,
  });
}

/// Event emitted when a new community post is created
class CommunityPostCreatedEvent extends BlocCommunicationEvent {
  final String postId;
  final String authorId;
  final String? groupId;
  final String title;

  CommunityPostCreatedEvent({
    required this.postId,
    required this.authorId,
    this.groupId,
    required this.title,
  });
}

/// Event emitted when a post receives a new comment
class PostCommentAddedEvent extends BlocCommunicationEvent {
  final String postId;
  final String commentId;
  final String authorId;
  final String? groupId;

  PostCommentAddedEvent({
    required this.postId,
    required this.commentId,
    required this.authorId,
    this.groupId,
  });
}

/// Event emitted when a post is liked/disliked
class PostInteractionEvent extends BlocCommunicationEvent {
  final String postId;
  final String userId;
  final String interactionType; // 'like', 'dislike', 'bookmark'
  final String? groupId;

  PostInteractionEvent({
    required this.postId,
    required this.userId,
    required this.interactionType,
    this.groupId,
  });
}

/// Event emitted when group rankings are updated
class GroupRankingUpdatedEvent extends BlocCommunicationEvent {
  final String groupId;
  final int newRank;
  final int previousRank;
  final double totalScore;

  GroupRankingUpdatedEvent({
    required this.groupId,
    required this.newRank,
    required this.previousRank,
    required this.totalScore,
  });
}

/// Event emitted when a user's workout score is calculated
class UserWorkoutScoreCalculatedEvent extends BlocCommunicationEvent {
  final String userId;
  final String groupId;
  final double totalScore;
  final DateTime scoreDate;

  UserWorkoutScoreCalculatedEvent({
    required this.userId,
    required this.groupId,
    required this.totalScore,
    required this.scoreDate,
  });
}

/// Event emitted when diet feedback is provided in PT groups
class DietFeedbackProvidedEvent extends BlocCommunicationEvent {
  final String groupId;
  final String memberId;
  final String trainerId;
  final String feedbackId;
  final String feedbackType;

  DietFeedbackProvidedEvent({
    required this.groupId,
    required this.memberId,
    required this.trainerId,
    required this.feedbackId,
    required this.feedbackType,
  });
}

/// Generic communication event for custom events
class GenericBlocCommunicationEvent extends BlocCommunicationEvent {
  final String type;
  final Map<String, dynamic> data;

  GenericBlocCommunicationEvent({
    required this.type,
    required this.data,
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