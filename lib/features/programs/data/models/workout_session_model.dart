import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'workout_session_model.g.dart';

@JsonSerializable()
class WorkoutSessionModel extends Equatable {
  final String id;
  final String userProgramId;
  final DateTime sessionDate;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final bool isCompleted;
  final Map<String, dynamic>? exercisesJson;

  const WorkoutSessionModel({
    required this.id,
    required this.userProgramId,
    required this.sessionDate,
    this.startedAt,
    this.endedAt,
    required this.isCompleted,
    this.exercisesJson,
  });

  factory WorkoutSessionModel.fromJson(Map<String, dynamic> json) => _$WorkoutSessionModelFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutSessionModelToJson(this);

  @override
  List<Object?> get props => [id, userProgramId, sessionDate, startedAt, endedAt, isCompleted, exercisesJson];
} 