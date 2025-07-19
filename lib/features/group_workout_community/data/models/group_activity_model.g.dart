// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_activity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupActivityModel _$GroupActivityModelFromJson(Map<String, dynamic> json) =>
    GroupActivityModel(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      userId: json['userId'] as String,
      activityType:
          $enumDecode(_$GroupActivityTypeEnumMap, json['activityType']),
      activityData: json['activityData'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      mentionedUserIds: (json['mentionedUserIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$GroupActivityModelToJson(GroupActivityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'userId': instance.userId,
      'activityType': _$GroupActivityTypeEnumMap[instance.activityType]!,
      'activityData': instance.activityData,
      'createdAt': instance.createdAt.toIso8601String(),
      'mentionedUserIds': instance.mentionedUserIds,
    };

const _$GroupActivityTypeEnumMap = {
  GroupActivityType.workoutCompleted: 'workoutCompleted',
  GroupActivityType.routineShared: 'routineShared',
  GroupActivityType.memberJoined: 'memberJoined',
  GroupActivityType.memberLeft: 'memberLeft',
  GroupActivityType.encouragementSent: 'encouragementSent',
  GroupActivityType.achievementUnlocked: 'achievementUnlocked',
  GroupActivityType.programStarted: 'programStarted',
  GroupActivityType.milestoneReached: 'milestoneReached',
};
