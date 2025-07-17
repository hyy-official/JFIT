import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/workout_program_failures.dart';
import '../../domain/entities/workout_program.dart';
import '../../data/models/user_program_day_model.dart';
import '../../data/models/workout_session_model.dart';
import '../../data/models/workout_log_model.dart';
import '../../data/models/exercise_model.dart';

abstract class ProgramsState extends Equatable {
  const ProgramsState();

  @override
  List<Object?> get props => [];
}

class ProgramsInitial extends ProgramsState {}

class ProgramsLoading extends ProgramsState {}

class ProgramsLoaded extends ProgramsState {
  final List<WorkoutProgram> popularPrograms;
  final List<WorkoutProgram> programs;
  final List<WorkoutProgram> userPrograms;
  final List<WorkoutProgram> searchResults;
  final bool isSearching;
  final String? searchQuery;

  const ProgramsLoaded({
    this.popularPrograms = const [],
    this.programs = const [],
    this.userPrograms = const [],
    this.searchResults = const [],
    this.isSearching = false,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [
        popularPrograms,
        programs,
        userPrograms,
        searchResults,
        isSearching,
        searchQuery,
      ];

  ProgramsLoaded copyWith({
    List<WorkoutProgram>? popularPrograms,
    List<WorkoutProgram>? programs,
    List<WorkoutProgram>? userPrograms,
    List<WorkoutProgram>? searchResults,
    bool? isSearching,
    String? searchQuery,
  }) {
    return ProgramsLoaded(
      popularPrograms: popularPrograms ?? this.popularPrograms,
      programs: programs ?? this.programs,
      userPrograms: userPrograms ?? this.userPrograms,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ProgramsError extends ProgramsState {
  final String message;

  const ProgramsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Enhanced error state with retry capability
class ProgramsErrorWithRetry extends ProgramsState {
  final String message;
  final VoidCallback retryAction;
  final String? recoverySuggestion;

  const ProgramsErrorWithRetry({
    required this.message,
    required this.retryAction,
    this.recoverySuggestion,
  });

  @override
  List<Object?> get props => [message, retryAction, recoverySuggestion];

  /// Get action button text for retry
  String get actionButtonText => '다시 시도';

  /// Get recovery suggestion message
  String get recoveryMessage {
    return recoverySuggestion ?? '문제가 지속되면 고객센터에 문의해주세요.';
  }
}

class ProgramDetailLoading extends ProgramsState {}

class ProgramDetailLoaded extends ProgramsState {
  final WorkoutProgram program;

  const ProgramDetailLoaded(this.program);

  @override
  List<Object?> get props => [program];
}

class ProgramDetailError extends ProgramsState {
  final String message;

  const ProgramDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProgramAddedToUser extends ProgramsState {
  final String message;

  const ProgramAddedToUser(this.message);

  @override
  List<Object?> get props => [message];
}

class RoutineSaved extends ProgramsState {
  final String message;

  const RoutineSaved(this.message);

  @override
  List<Object?> get props => [message];
}

class RoutineSaveError extends ProgramsState {
  final String message;

  const RoutineSaveError(this.message);

  @override
  List<Object?> get props => [message];
}

class RoutineDuplicateFound extends ProgramsState {
  final ProgramDuplicateInfo duplicateInfo;

  const RoutineDuplicateFound(this.duplicateInfo);

  @override
  List<Object?> get props => [duplicateInfo];
}

class ProgramAddError extends ProgramsState {
  final String message;

  const ProgramAddError(this.message);

  @override
  List<Object?> get props => [message];
}

// Day별 상태/운동 루틴 관련 상태
class UserProgramDaysLoading extends ProgramsState {}
class UserProgramDaysLoaded extends ProgramsState {
  final List<UserProgramDayModel> days;
  const UserProgramDaysLoaded(this.days);
  @override
  List<Object?> get props => [days];
}
class UserProgramDaysError extends ProgramsState {
  final String message;
  const UserProgramDaysError(this.message);
  @override
  List<Object?> get props => [message];
}

class WorkoutSessionsLoading extends ProgramsState {}
class WorkoutSessionsLoaded extends ProgramsState {
  final List<WorkoutSessionModel> sessions;
  const WorkoutSessionsLoaded(this.sessions);
  @override
  List<Object?> get props => [sessions];
}
class WorkoutSessionsError extends ProgramsState {
  final String message;
  const WorkoutSessionsError(this.message);
  @override
  List<Object?> get props => [message];
}

class WorkoutLogsLoading extends ProgramsState {}
class WorkoutLogsLoaded extends ProgramsState {
  final List<WorkoutLogModel> logs;
  const WorkoutLogsLoaded(this.logs);
  @override
  List<Object?> get props => [logs];
}
class WorkoutLogsError extends ProgramsState {
  final String message;
  const WorkoutLogsError(this.message);
  @override
  List<Object?> get props => [message];
}

class ExerciseLoading extends ProgramsState {}
class ExerciseLoaded extends ProgramsState {
  final ExerciseModel exercise;
  const ExerciseLoaded(this.exercise);
  @override
  List<Object?> get props => [exercise];
}
class ExerciseError extends ProgramsState {
  final String message;
  const ExerciseError(this.message);
  @override
  List<Object?> get props => [message];
}

// 프로그램 중복 및 진행 상황 관련 상태들
class ProgramDuplicateFound extends ProgramsState {
  final String programId;
  final String programName;
  final int currentWeek;
  final int currentDay;
  final int totalWeeks;
  final double progressPercent;
  final bool isCompleted;
  
  const ProgramDuplicateFound({
    required this.programId,
    required this.programName,
    required this.currentWeek,
    required this.currentDay,
    required this.totalWeeks,
    required this.progressPercent,
    required this.isCompleted,
  });
  
  @override
  List<Object?> get props => [
    programId, 
    programName, 
    currentWeek, 
    currentDay, 
    totalWeeks, 
    progressPercent, 
    isCompleted
  ];
}

class ProgramRestarted extends ProgramsState {
  final String message;
  const ProgramRestarted(this.message);
  @override
  List<Object?> get props => [message];
}

class ProgramContinued extends ProgramsState {
  final String message;
  const ProgramContinued(this.message);
  @override
  List<Object?> get props => [message];
}

// ProgramDetailSheet에서 사용할 복합 상태
class ProgramDetailData extends ProgramsState {
  final List<UserProgramDayModel> days;
  final List<WorkoutSessionModel> sessions;
  final List<WorkoutLogModel>? logs;
  final bool isLoading;
  final String? error;

  const ProgramDetailData({
    this.days = const [],
    this.sessions = const [],
    this.logs,
    this.isLoading = false,
    this.error,
  });

  @override
  List<Object?> get props => [days, sessions, logs, isLoading, error];

  ProgramDetailData copyWith({
    List<UserProgramDayModel>? days,
    List<WorkoutSessionModel>? sessions,
    List<WorkoutLogModel>? logs,
    bool? isLoading,
    String? error,
  }) {
    return ProgramDetailData(
      days: days ?? this.days,
      sessions: sessions ?? this.sessions,
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
} 