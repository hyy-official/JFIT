import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'workout_session_model.g.dart';

@JsonSerializable()
class WorkoutSessionModel extends Equatable {
  final String id;
  
  @JsonKey(name: 'user_program_id')
  final String userProgramId;
  
  @JsonKey(name: 'session_date')
  final DateTime? sessionDate;
  
  @JsonKey(name: 'started_at')
  final DateTime? startedAt;
  
  @JsonKey(name: 'ended_at')
  final DateTime? endedAt;
  
  @JsonKey(name: 'is_completed')
  final bool isCompleted;
  
  @JsonKey(name: 'exercises_json')
  final List<dynamic>? exercisesJson;

  const WorkoutSessionModel({
    required this.id,
    required this.userProgramId,
    this.sessionDate,
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