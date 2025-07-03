import 'package:equatable/equatable.dart';

class ExerciseRecord extends Equatable {
  final String id;
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

  const ExerciseRecord({
    required this.id,
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
        id,
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

  factory ExerciseRecord.fromJson(Map<String, dynamic> json) {
    return ExerciseRecord(
      id: json['id'] as String,
      userId: json['user_id'] as int,
      exerciseName: json['exercise_name'] as String,
      exerciseType: json['exercise_type'] as String,
      durationMinutes: json['duration_minutes'] as int,
      caloriesBurned: json['calories_burned'] as int,
      exerciseDate: DateTime.parse(json['exercise_date'] as String),
      weightKg: json['weight_kg'] as double?,
      sets: json['sets'] as int?,
      reps: json['reps'] as int?,
      distanceKm: json['distance_km'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'exercise_name': exerciseName,
      'exercise_type': exerciseType,
      'duration_minutes': durationMinutes,
      'calories_burned': caloriesBurned,
      'exercise_date': exerciseDate.toIso8601String(),
      'weight_kg': weightKg,
      'sets': sets,
      'reps': reps,
      'distance_km': distanceKm,
    };
  }
}
