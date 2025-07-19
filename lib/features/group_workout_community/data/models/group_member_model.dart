import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/entities/workout_group.dart';

part 'group_member_model.g.dart';

@JsonSerializable(explicitToJson: true)
class GroupMemberModel extends GroupMember {
  const GroupMemberModel({
    required super.id,
    required super.groupId,
    required super.userId,
    required super.username,
    super.profileImageUrl,
    required super.role,
    required super.joinedAt,
    required super.isActive,
    super.lastActiveAt,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String,
      username: json['username'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
      role: _parseRole(json['role'] as String?),
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : DateTime.now(),
      isActive: json['is_active'] as bool? ?? true,
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
    );
  }

  static GroupRole _parseRole(String? value) {
    switch (value) {
      case 'admin':
        return GroupRole.admin;
      case 'moderator':
        return GroupRole.moderator;
      case 'member':
      default:
        return GroupRole.member;
    }
  }

  static String _roleToString(GroupRole role) {
    switch (role) {
      case GroupRole.admin:
        return 'admin';
      case GroupRole.moderator:
        return 'moderator';
      case GroupRole.member:
        return 'member';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'username': username,
      'profile_image_url': profileImageUrl,
      'role': _roleToString(role),
      'joined_at': joinedAt.toIso8601String(),
      'is_active': isActive,
      'last_active_at': lastActiveAt?.toIso8601String(),
    };
  }

  GroupMember toEntity() {
    return GroupMember(
      id: id,
      groupId: groupId,
      userId: userId,
      username: username,
      profileImageUrl: profileImageUrl,
      role: role,
      joinedAt: joinedAt,
      isActive: isActive,
      lastActiveAt: lastActiveAt,
    );
  }

  factory GroupMemberModel.fromEntity(GroupMember entity) {
    return GroupMemberModel(
      id: entity.id,
      groupId: entity.groupId,
      userId: entity.userId,
      username: entity.username,
      profileImageUrl: entity.profileImageUrl,
      role: entity.role,
      joinedAt: entity.joinedAt,
      isActive: entity.isActive,
      lastActiveAt: entity.lastActiveAt,
    );
  }
}