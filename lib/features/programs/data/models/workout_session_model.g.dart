// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutSessionModel _$WorkoutSessionModelFromJson(Map<String, dynamic> json) =>
    WorkoutSessionModel(
      id: json['id'] as String,
      userProgramId: json['user_program_id'] as String,
      sessionDate: json['session_date'] == null
          ? null
          : DateTime.parse(json['session_date'] as String),
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] == null
          ? null
          : DateTime.parse(json['ended_at'] as String),
      isCompleted: json['is_completed'] as bool,
      exercisesJson: json['exercises_json'] as List<dynamic>?,
    );

Map<String, dynamic> _$WorkoutSessionModelToJson(
        WorkoutSessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_program_id': instance.userProgramId,
      'session_date': instance.sessionDate?.toIso8601String(),
      'started_at': instance.startedAt?.toIso8601String(),
      'ended_at': instance.endedAt?.toIso8601String(),
      'is_completed': instance.isCompleted,
      'exercises_json': instance.exercisesJson,
    };
