// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupMemberModel _$GroupMemberModelFromJson(Map<String, dynamic> json) =>
    GroupMemberModel(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      role: $enumDecode(_$GroupRoleEnumMap, json['role']),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      isActive: json['isActive'] as bool,
      lastActiveAt: json['lastActiveAt'] == null
          ? null
          : DateTime.parse(json['lastActiveAt'] as String),
    );

Map<String, dynamic> _$GroupMemberModelToJson(GroupMemberModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'userId': instance.userId,
      'username': instance.username,
      'profileImageUrl': instance.profileImageUrl,
      'role': _$GroupRoleEnumMap[instance.role]!,
      'joinedAt': instance.joinedAt.toIso8601String(),
      'isActive': instance.isActive,
      'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
    };

const _$GroupRoleEnumMap = {
  GroupRole.admin: 'admin',
  GroupRole.moderator: 'moderator',
  GroupRole.member: 'member',
};
