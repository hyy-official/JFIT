import 'package:equatable/equatable.dart';

abstract class ExerciseEvent extends Equatable {
  const ExerciseEvent();

  @override
  List<Object> get props => [];
}

class LoadExerciseRecords extends ExerciseEvent {
  final int userId;

  const LoadExerciseRecords({required this.userId});

  @override
  List<Object> get props => [userId];
}

class AddExerciseRecord extends ExerciseEvent {
  final int userId;
  final String exerciseName;
  final String exerciseType;
  final int durationMinutes;
  final int caloriesBurned;
  final DateTime exerciseDate;
  final double? weightKg;
  final int? sets;
  final int? reps;
  final double? distanceKm;

  const AddExerciseRecord({
    required this.userId,
    required this.exerciseName,
    required this.exerciseType,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.exerciseDate,
    this.weightKg,
    this.sets,
    this.reps,
    this.distanceKm,
  });

  @override
  List<Object?> get props => [
        userId,
        exerciseName,
        exerciseType,
        durationMinutes,
        caloriesBurned,
        exerciseDate,
        weightKg,
        sets,
        reps,
        distanceKm,
      ];
}

class UpdateExerciseRecord extends ExerciseEvent {
  final String recordId;
  final int userId;
  final String exerciseName;
  final String exerciseType;
  final int durationMinutes;
  final int caloriesBurned;
  final DateTime exerciseDate;
  final double? weightKg;
  final int? sets;
  final int? reps;
  final double? distanceKm;

  const UpdateExerciseRecord({
    required this.recordId,
    required this.userId,
    required this.exerciseName,
    required this.exerciseType,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.exerciseDate,
    this.weightKg,
    this.sets,
    this.reps,
    this.distanceKm,
  });

  @override
  List<Object?> get props => [
        recordId,
        userId,
        exerciseName,
        exerciseType,
        durationMinutes,
        caloriesBurned,
        exerciseDate,
        weightKg,
        sets,
        reps,
        distanceKm,
      ];
}

class DeleteExerciseRecord extends ExerciseEvent {
  final String recordId;

  const DeleteExerciseRecord({required this.recordId});

  @override
  List<Object> get props => [recordId];
}
