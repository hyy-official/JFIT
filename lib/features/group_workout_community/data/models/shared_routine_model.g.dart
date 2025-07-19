// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_routine_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharedRoutineModel _$SharedRoutineModelFromJson(Map<String, dynamic> json) =>
    SharedRoutineModel(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      sharedByUserId: json['sharedByUserId'] as String,
      userProgramId: json['userProgramId'] as String,
      routineName: json['routineName'] as String,
      description: json['description'] as String?,
      exerciseIds: (json['exerciseIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      sharedAt: DateTime.parse(json['sharedAt'] as String),
      likesCount: (json['likesCount'] as num).toInt(),
      copiesCount: (json['copiesCount'] as num).toInt(),
    );

Map<String, dynamic> _$SharedRoutineModelToJson(SharedRoutineModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'sharedByUserId': instance.sharedByUserId,
      'userProgramId': instance.userProgramId,
      'routineName': instance.routineName,
      'description': instance.description,
      'exerciseIds': instance.exerciseIds,
      'sharedAt': instance.sharedAt.toIso8601String(),
      'likesCount': instance.likesCount,
      'copiesCount': instance.copiesCount,
    };
