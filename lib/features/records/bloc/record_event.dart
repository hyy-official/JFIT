import 'package:equatable/equatable.dart';

abstract class RecordEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// 사용자 프로그램 관련 이벤트
class LoadUserPrograms extends RecordEvent {}

// 운동 세션 관련 이벤트
class LoadWorkoutSessions extends RecordEvent {
  final String userProgramId;

  LoadWorkoutSessions(this.userProgramId);

  @override
  List<Object?> get props => [userProgramId];
}

class StartWorkoutSession extends RecordEvent {
  final String userProgramId;
  final DateTime sessionDate;
  final Map<String, dynamic> exercisesJson;

  StartWorkoutSession(this.userProgramId, this.sessionDate, this.exercisesJson);

  @override
  List<Object?> get props => [userProgramId, sessionDate, exercisesJson];
}

class CompleteWorkoutSession extends RecordEvent {
  final String sessionId;

  CompleteWorkoutSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class UpdateProgramProgress extends RecordEvent {
  final String userProgramId;
  final int currentWeek;
  final int currentDay;

  UpdateProgramProgress(this.userProgramId, this.currentWeek, this.currentDay);

  @override
  List<Object?> get props => [userProgramId, currentWeek, currentDay];
}
