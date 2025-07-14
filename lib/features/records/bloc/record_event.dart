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
  List<Object?> get props => [mealRecord];
}

class UpdateMealRecord extends RecordEvent {
  final MealRecord mealRecord;

  const UpdateMealRecord({required this.mealRecord});

  @override
  List<Object?> get props => [mealRecord];
}

class DeleteMealRecord extends RecordEvent {
  final String recordId;

  const DeleteMealRecord({required this.recordId});

  @override
  List<Object?> get props => [recordId];
}

class LoadDailySummary extends RecordEvent {
  final String userId;
  final DateTime date;

  const LoadDailySummary({required this.userId, required this.date});

  @override
  List<Object?> get props => [userId, date];
}

// 운동 프로그램 관련 이벤트들
class LoadUserPrograms extends RecordEvent {
  final String userId;

  const LoadUserPrograms({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadUserProgramDetails extends RecordEvent {
  final String userProgramId;

  const LoadUserProgramDetails({required this.userProgramId});

  @override
  List<Object?> get props => [userProgramId];
}

class LoadUserProgramDays extends RecordEvent {
  final String userProgramId;

  const LoadUserProgramDays({required this.userProgramId});

  @override
  List<Object?> get props => [userProgramId];
}

class CompleteUserProgramDay extends RecordEvent {
  final String userProgramId;
  final int week;
  final int day;
  final String? note;

  const CompleteUserProgramDay({
    required this.userProgramId,
    required this.week,
    required this.day,
    this.note,
  });

  @override
  List<Object?> get props => [userProgramId, week, day, note];
}

class UpdateUserProgramProgress extends RecordEvent {
  final String userProgramId;
  final int currentWeek;
  final int currentDay;

  const UpdateUserProgramProgress({
    required this.userProgramId,
    required this.currentWeek,
    required this.currentDay,
  });

  @override
  List<Object?> get props => [userProgramId, currentWeek, currentDay];
}

class CreateWorkoutSession extends RecordEvent {
  final String userProgramId;
  final Map<String, dynamic> exercisesJson;

  const CreateWorkoutSession({
    required this.userProgramId,
    required this.exercisesJson,
  });

  @override
  List<Object?> get props => [userProgramId, exercisesJson];
}

class CompleteWorkoutSession extends RecordEvent {
  final String sessionId;

  const CompleteWorkoutSession({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class LoadExerciseDetails extends RecordEvent {
  final List<String> exerciseIds;

  const LoadExerciseDetails({required this.exerciseIds});

  @override
  List<Object?> get props => [exerciseIds];
}

class SearchExercises extends RecordEvent {
  final String query;

  const SearchExercises({required this.query});

  @override
  List<Object?> get props => [query];
}

class DeleteUserProgram extends RecordEvent {
  final String userProgramId;

  const DeleteUserProgram({required this.userProgramId});

  @override
  List<Object?> get props => [userProgramId];
}

// 워크아웃 세션 관련 이벤트들
class LoadWorkoutSession extends RecordEvent {
  final String sessionId;

  const LoadWorkoutSession({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class UpdateWorkoutSession extends RecordEvent {
  final String sessionId;
  final Map<String, dynamic> sessionData;

  const UpdateWorkoutSession({
    required this.sessionId,
    required this.sessionData,
  });

  @override
  List<Object?> get props => [sessionId, sessionData];
}

class LogWorkoutSet extends RecordEvent {
  final String exerciseId;
  final String sessionId;
  final int setNumber;
  final int reps;
  final double weight;

  const LogWorkoutSet({
    required this.exerciseId,
    required this.sessionId,
    required this.setNumber,
    required this.reps,
    required this.weight,
  });

  @override
  List<Object?> get props => [exerciseId, sessionId, setNumber, reps, weight];
}
