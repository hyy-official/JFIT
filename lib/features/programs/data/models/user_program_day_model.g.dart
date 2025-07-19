// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_program_day_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProgramDayModel _$UserProgramDayModelFromJson(Map<String, dynamic> json) =>
    UserProgramDayModel(
      id: json['id'] as String,
      userProgramId: json['user_program_id'] as String,
      week: (json['week'] as num).toInt(),
      day: (json['day'] as num).toInt(),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UserProgramDayModelToJson(
        UserProgramDayModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_program_id': instance.userProgramId,
      'week': instance.week,
      'day': instance.day,
      'completed_at': instance.completedAt?.toIso8601String(),
      'note': instance.note,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
