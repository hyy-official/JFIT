import 'package:jfit/core/bloc/base_bloc.dart';

/// Base class for all WorkoutProgram events
abstract class WorkoutProgramEvent extends BaseEvent {
  const WorkoutProgramEvent();
}

/// Event to load user's active workout programs
class LoadUserPrograms extends WorkoutProgramEvent {
  final String userId;

  const LoadUserPrograms({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event to load specific program details
class LoadProgramDetails extends WorkoutProgramEvent {
  final String userProgramId;

  const LoadProgramDetails({required this.userProgramId});

  @override
  List<Object?> get props => [userProgramId];
}

/// Event to load program days for a specific user program
class LoadProgramDays extends WorkoutProgramEvent {
  final String userProgramId;

  const LoadProgramDays({required this.userProgramId});

  @override
  List<Object?> get props => [userProgramId];
}

/// Event to update program progress
class UpdateProgramProgress extends WorkoutProgramEvent {
  final String userProgramId;
  final int currentWeek;
  final int currentDay;

  const UpdateProgramProgress({
    required this.userProgramId,
    required this.currentWeek,
    required this.currentDay,
  });

  @override
  List<Object?> get props => [userProgramId, currentWeek, currentDay];
}

/// Event to complete a program day
class CompleteProgramDay extends WorkoutProgramEvent {
  final String userProgramId;
  final int week;
  final int day;
  final String? note;

  const CompleteProgramDay({
    required this.userProgramId,
    required this.week,
    required this.day,
    this.note,
  });

  @override
  List<Object?> get props => [userProgramId, week, day, note];
}

/// Event to delete/deactivate a user program
class DeleteUserProgram extends WorkoutProgramEvent {
  final String userProgramId;
  final String userId;

  const DeleteUserProgram({
    required this.userProgramId,
    required this.userId,
  });

  @override
  List<Object?> get props => [userProgramId, userId];
}

/// Event to load current workout info for a user
class LoadCurrentWorkoutInfo extends WorkoutProgramEvent {
  final String userId;

  const LoadCurrentWorkoutInfo({required this.userId});

  @override
  List<Object?> get props => [userId];
}