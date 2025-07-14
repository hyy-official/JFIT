// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutLogModel _$WorkoutLogModelFromJson(Map<String, dynamic> json) =>
    WorkoutLogModel(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      exerciseIndex: (json['exerciseIndex'] as num).toInt(),
      exerciseName: json['exerciseName'] as String?,
      setNumber: (json['setNumber'] as num).toInt(),
      weight: json['weight'] as num?,
      reps: (json['reps'] as num?)?.toInt(),
      completed: json['completed'] as bool,
      loggedAt: DateTime.parse(json['loggedAt'] as String),
      exerciseId: json['exerciseId'] as String?,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$WorkoutLogModelToJson(WorkoutLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'exerciseIndex': instance.exerciseIndex,
      'exerciseName': instance.exerciseName,
      'setNumber': instance.setNumber,
      'weight': instance.weight,
      'reps': instance.reps,
      'completed': instance.completed,
      'loggedAt': instance.loggedAt.toIso8601String(),
      'exerciseId': instance.exerciseId,
      'completedAt': instance.completedAt?.toIso8601String(),
    };
