import 'package:equatable/equatable.dart';
import 'package:jfit/features/records/data/models/meal_record_model.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';

abstract class RecordState extends Equatable {
  const RecordState();

  @override
  List<Object> get props => [];
}

class RecordInitial extends RecordState {}

class RecordLoading extends RecordState {}

class MealRecordsLoaded extends RecordState {
  final List<MealRecord> mealRecords;

  const MealRecordsLoaded({this.mealRecords = const []});

  @override
  List<Object> get props => [mealRecords];
}

class DailySummaryLoaded extends RecordState {
  final UserDailySummary dailySummary;

  const DailySummaryLoaded({required this.dailySummary});

  @override
  List<Object> get props => [dailySummary];
}

class RecordError extends RecordState {
  final String message;

  const RecordError({required this.message});

  @override
  List<Object> get props => [message];
}

// 운동 관련 상태들
class UserProgramsLoaded extends RecordState {
  final List<UserProgram> userPrograms;

  const UserProgramsLoaded({required this.userPrograms});

  @override
  List<Object> get props => [userPrograms];
}

class WorkoutSessionsLoaded extends RecordState {
  final List<WorkoutSession> workoutSessions;

  const WorkoutSessionsLoaded({required this.workoutSessions});

  @override
  List<Object> get props => [workoutSessions];
}

class WorkoutSessionStarted extends RecordState {
  final WorkoutSession session;

  const WorkoutSessionStarted({required this.session});

  @override
  List<Object> get props => [session];
}

class WorkoutSessionCompleted extends RecordState {
  final String sessionId;

  const WorkoutSessionCompleted({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}

class ProgramProgressUpdated extends RecordState {
  final String userProgramId;
  final int currentWeek;
  final int currentDay;

  const ProgramProgressUpdated({
    required this.userProgramId,
    required this.currentWeek,
    required this.currentDay,
  });

  @override
  List<Object> get props => [userProgramId, currentWeek, currentDay];
}

// 데이터 모델들 (임시로 여기에 정의, 나중에 별도 파일로 이동)
class UserProgram extends Equatable {
  final String id;
  final String userId;
  final String programId;
  final String programName;
  final DateTime startedAt;
  final int currentWeek;
  final int currentDay;
  final bool isActive;
  final Map<String, dynamic> exercisesJson;

  const UserProgram({
    required this.id,
    required this.userId,
    required this.programId,
    required this.programName,
    required this.startedAt,
    required this.currentWeek,
    required this.currentDay,
    required this.isActive,
    required this.exercisesJson,
  });

  @override
  List<Object> get props => [
    id,
    userId,
    programId,
    programName,
    startedAt,
    currentWeek,
    currentDay,
    isActive,
    exercisesJson,
  ];
}

class WorkoutSession extends Equatable {
  final String id;
  final String userProgramId;
  final DateTime sessionDate;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final bool isCompleted;
  final Map<String, dynamic>? exercisesJson;

  const WorkoutSession({
    required this.id,
    required this.userProgramId,
    required this.sessionDate,
    this.startedAt,
    this.endedAt,
    required this.isCompleted,
    this.exercisesJson,
  });

  @override
  List<Object?> get props => [
    id,
    userProgramId,
    sessionDate,
    startedAt,
    endedAt,
    isCompleted,
    exercisesJson,
  ];
}
