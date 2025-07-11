import 'package:equatable/equatable.dart';

abstract class RecordState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RecordInitial extends RecordState {}

class RecordLoading extends RecordState {}

class RecordError extends RecordState {
  final String message;

  RecordError(this.message);

  @override
  List<Object?> get props => [message];
}

// 사용자 프로그램 관련 상태
class UserProgramsLoaded extends RecordState {
  final List<UserProgram> userPrograms;

  UserProgramsLoaded(this.userPrograms);

  @override
  List<Object?> get props => [userPrograms];
}

// 운동 세션 관련 상태
class WorkoutSessionsLoaded extends RecordState {
  final List<WorkoutSession> sessions;

  WorkoutSessionsLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

class WorkoutSessionStarted extends RecordState {
  final WorkoutSession session;

  WorkoutSessionStarted(this.session);

  @override
  List<Object?> get props => [session];
}

class WorkoutSessionCompleted extends RecordState {
  final String sessionId;

  WorkoutSessionCompleted(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class ProgramProgressUpdated extends RecordState {
  final String userProgramId;
  final int currentWeek;
  final int currentDay;

  ProgramProgressUpdated(this.userProgramId, this.currentWeek, this.currentDay);

  @override
  List<Object?> get props => [userProgramId, currentWeek, currentDay];
}

// 데이터 모델 클래스들
class UserProgram extends Equatable {
  final String id;
  final String? programId;
  final String name;
  final String creator;
  final String description;
  final int currentWeek;
  final int currentDay;
  final int totalWeeks;
  final String difficulty;
  final String programType;
  final int workoutsPerWeek;
  final Map<String, dynamic> exercisesJson;
  final String? imageUrl;
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool isActive;
  final List<dynamic> weeklySchedule;

  const UserProgram({
    required this.id,
    this.programId,
    required this.name,
    required this.creator,
    required this.description,
    required this.currentWeek,
    required this.currentDay,
    required this.totalWeeks,
    required this.difficulty,
    required this.programType,
    required this.workoutsPerWeek,
    required this.exercisesJson,
    this.imageUrl,
    required this.startedAt,
    this.completedAt,
    required this.isActive,
    required this.weeklySchedule,
  });

  @override
  List<Object?> get props => [
        id,
        programId,
        name,
        creator,
        description,
        currentWeek,
        currentDay,
        totalWeeks,
        difficulty,
        programType,
        workoutsPerWeek,
        exercisesJson,
        imageUrl,
        startedAt,
        completedAt,
        isActive,
        weeklySchedule,
      ];
}

class WorkoutSession extends Equatable {
  final String id;
  final String userProgramId;
  final DateTime sessionDate;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final bool isCompleted;
  final Map<String, dynamic> exercisesJson;

  const WorkoutSession({
    required this.id,
    required this.userProgramId,
    required this.sessionDate,
    this.startedAt,
    this.endedAt,
    required this.isCompleted,
    required this.exercisesJson,
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
