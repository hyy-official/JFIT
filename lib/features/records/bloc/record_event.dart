import 'package:equatable/equatable.dart';
import 'package:jfit/features/records/data/models/meal_record_model.dart';

abstract class RecordEvent extends Equatable {
  const RecordEvent();

  @override
  List<Object?> get props => [];
}

class LoadMealRecords extends RecordEvent {
  final String userId;
  final DateTime? date;

  const LoadMealRecords({required this.userId, this.date});

  @override
  List<Object?> get props => [userId, date];
}

class AddMealRecord extends RecordEvent {
  final MealRecord mealRecord;

  const AddMealRecord({required this.mealRecord});

  @override
  List<Object> get props => [mealRecord];
}

class UpdateMealRecord extends RecordEvent {
  final MealRecord mealRecord;

  const UpdateMealRecord({required this.mealRecord});

  @override
  List<Object> get props => [mealRecord];
}

class DeleteMealRecord extends RecordEvent {
  final String recordId;

  const DeleteMealRecord({required this.recordId});

  @override
  List<Object> get props => [recordId];
}

class LoadDailySummary extends RecordEvent {
  final String userId;
  final DateTime date;

  const LoadDailySummary({required this.userId, required this.date});

  @override
  List<Object> get props => [userId, date];
}

// 운동 관련 이벤트들
class LoadUserPrograms extends RecordEvent {
  final String userId;

  const LoadUserPrograms({required this.userId});

  @override
  List<Object> get props => [userId];
}

class LoadWorkoutSessions extends RecordEvent {
  final String userId;
  final DateTime date;

  const LoadWorkoutSessions({required this.userId, required this.date});

  @override
  List<Object> get props => [userId, date];
}

class StartWorkoutSession extends RecordEvent {
  final String userProgramId;
  final DateTime date;

  const StartWorkoutSession({required this.userProgramId, required this.date});

  @override
  List<Object> get props => [userProgramId, date];
}

class CompleteWorkoutSession extends RecordEvent {
  final String sessionId;

  const CompleteWorkoutSession({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}

class UpdateProgramProgress extends RecordEvent {
  final String userProgramId;
  final int currentWeek;
  final int currentDay;

  const UpdateProgramProgress({
    required this.userProgramId,
    required this.currentWeek,
    required this.currentDay,
  });

  @override
  List<Object> get props => [userProgramId, currentWeek, currentDay];
}
