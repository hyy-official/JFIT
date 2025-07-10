// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_program_day_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProgramDayModel _$UserProgramDayModelFromJson(Map<String, dynamic> json) =>
    UserProgramDayModel(
      id: json['id'] as String,
      userProgramId: json['userProgramId'] as String,
      week: (json['week'] as num).toInt(),
      day: (json['day'] as num).toInt(),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserProgramDayModelToJson(
  UserProgramDayModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'userProgramId': instance.userProgramId,
  'week': instance.week,
  'day': instance.day,
  'completedAt': instance.completedAt?.toIso8601String(),
  'note': instance.note,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
