import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'workout_log_model.g.dart';

@JsonSerializable()
class WorkoutLogModel extends Equatable {
  final String id;
  final String sessionId;
  final int exerciseIndex;
  final String? exerciseName;
  final int setNumber;
  final num? weight;
  final int? reps;
  final bool completed;
  final DateTime loggedAt;
  final String? exerciseId;
  final DateTime? completedAt;

  const WorkoutLogModel({
    required this.id,
    required this.sessionId,
    required this.exerciseIndex,
    this.exerciseName,
    required this.setNumber,
    this.weight,
    this.reps,
    required this.completed,
    required this.loggedAt,
    this.exerciseId,
    this.completedAt,
  });

  factory WorkoutLogModel.fromJson(Map<String, dynamic> json) => _$WorkoutLogModelFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutLogModelToJson(this);

  @override
  List<Object?> get props => [id, sessionId, exerciseIndex, exerciseName, setNumber, weight, reps, completed, loggedAt, exerciseId, completedAt];
} 