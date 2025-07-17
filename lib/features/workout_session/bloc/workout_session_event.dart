import 'package:equatable/equatable.dart';
import 'package:jfit/core/bloc/base_bloc.dart';

/// Base class for all WorkoutSession events
abstract class WorkoutSessionEvent extends BaseEvent {
  const WorkoutSessionEvent();
}

/// Event to create a new workout session
class CreateWorkoutSession extends WorkoutSessionEvent {
  final String userProgramId;
  final Map<String, dynamic> exercisesJson;

  const CreateWorkoutSession({
    required this.userProgramId,
    required this.exercisesJson,
  });

  @override
  List<Object?> get props => [userProgramId, exercisesJson];
}

/// Event to start a workout session with exercise data validation
class StartWorkoutSessionWithValidation extends WorkoutSessionEvent {
  final String userProgramId;
  final int? targetWeek;
  final int? targetDay;
  final dynamic exercisesData;

  const StartWorkoutSessionWithValidation({
    required this.userProgramId,
    this.targetWeek,
    this.targetDay,
    this.exercisesData,
  });

  @override
  List<Object?> get props => [userProgramId, targetWeek, targetDay, exercisesData];
}

/// Event to load a specific workout session
class LoadWorkoutSession extends WorkoutSessionEvent {
  final String sessionId;

  const LoadWorkoutSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Event to update workout session information
class UpdateWorkoutSession extends WorkoutSessionEvent {
  final String sessionId;
  final Map<String, dynamic> updates;

  const UpdateWorkoutSession({
    required this.sessionId,
    required this.updates,
  });

  @override
  List<Object?> get props => [sessionId, updates];
}

/// Event to log a workout set
class LogWorkoutSet extends WorkoutSessionEvent {
  final String sessionId;
  final String exerciseId;
  final int setNumber;
  final int reps;
  final double weight;

  const LogWorkoutSet({
    required this.sessionId,
    required this.exerciseId,
    required this.setNumber,
    required this.reps,
    required this.weight,
  });

  @override
  List<Object?> get props => [sessionId, exerciseId, setNumber, reps, weight];
}

/// Event to complete a workout session
class CompleteWorkoutSession extends WorkoutSessionEvent {
  final String sessionId;

  const CompleteWorkoutSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Event to load active (incomplete) workout sessions for a user
class LoadActiveSession extends WorkoutSessionEvent {
  final String userId;

  const LoadActiveSession(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to load all workout sessions for a user
class LoadWorkoutSessions extends WorkoutSessionEvent {
  final String userId;

  const LoadWorkoutSessions(this.userId);

  @override
  List<Object?> get props => [userId];
}