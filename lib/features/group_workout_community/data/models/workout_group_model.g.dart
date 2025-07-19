// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutGroupModel _$WorkoutGroupModelFromJson(Map<String, dynamic> json) =>
    WorkoutGroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      adminId: json['adminId'] as String,
      privacyType: $enumDecode(_$GroupPrivacyTypeEnumMap, json['privacyType']),
      maxMembers: (json['maxMembers'] as num).toInt(),
      currentMemberCount: (json['currentMemberCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      inviteCode: json['inviteCode'] as String?,
      isActive: json['isActive'] as bool,
      groupType: json['groupType'] as String?,
    );

Map<String, dynamic> _$WorkoutGroupModelToJson(WorkoutGroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'adminId': instance.adminId,
      'privacyType': _$GroupPrivacyTypeEnumMap[instance.privacyType]!,
      'maxMembers': instance.maxMembers,
      'currentMemberCount': instance.currentMemberCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'inviteCode': instance.inviteCode,
      'isActive': instance.isActive,
      'groupType': instance.groupType,
    };

const _$GroupPrivacyTypeEnumMap = {
  GroupPrivacyType.public: 'public',
  GroupPrivacyType.private: 'private',
};
