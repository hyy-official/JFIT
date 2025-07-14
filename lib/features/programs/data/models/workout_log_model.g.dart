// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log_model.dart';

WorkoutLogModel _$WorkoutLogModelFromJson(Map<String, dynamic> json) => WorkoutLogModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      exerciseIndex: json['exercise_index'] as int,
      exerciseName: json['exercise_name'] as String?,
      setNumber: json['set_number'] as int,
      weight: json['weight'] as num?,
      reps: json['reps'] as int?,
      completed: json['completed'] as bool,
      loggedAt: DateTime.parse(json['logged_at'] as String),
      exerciseId: json['exercise_id'] as String?,
      completedAt: json['completed_at'] == null ? null : DateTime.parse(json['completed_at'] as String),
    );

Map<String, dynamic> _$WorkoutLogModelToJson(WorkoutLogModel instance) => <String, dynamic>{
      'id': instance.id,
      'session_id': instance.sessionId,
      'exercise_index': instance.exerciseIndex,
      'exercise_name': instance.exerciseName,
      'set_number': instance.setNumber,
      'weight': instance.weight,
      'reps': instance.reps,
      'completed': instance.completed,
      'logged_at': instance.loggedAt.toIso8601String(),
      'exercise_id': instance.exerciseId,
      'completed_at': instance.completedAt?.toIso8601String(),
    }; 