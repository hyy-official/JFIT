import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/workout_group.dart';

part 'workout_group_model.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkoutGroupModel extends WorkoutGroup {
  const WorkoutGroupModel({
    required super.id,
    required super.name,
    required super.description,
    required super.adminId,
    required super.privacyType,
    required super.maxMembers,
    required super.currentMemberCount,
    required super.createdAt,
    required super.updatedAt,
    super.inviteCode,
    required super.isActive,
    super.groupType,
  });

  factory WorkoutGroupModel.fromJson(Map<String, dynamic> json) {
    return WorkoutGroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      adminId: json['admin_id'] as String,
      privacyType: _parsePrivacyType(json['privacy_type'] as String?),
      maxMembers: json['max_members'] as int? ?? 50,
      currentMemberCount: json['current_member_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      inviteCode: json['invite_code'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      groupType: json['group_type'] as String?,
    );
  }

  static GroupPrivacyType _parsePrivacyType(String? value) {
    switch (value) {
      case 'private':
        return GroupPrivacyType.private;
      case 'public':
      default:
        return GroupPrivacyType.public;
    }
  }

  static String _privacyTypeToString(GroupPrivacyType type) {
    switch (type) {
      case GroupPrivacyType.private:
        return 'private';
      case GroupPrivacyType.public:
        return 'public';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'admin_id': adminId,
      'privacy_type': _privacyTypeToString(privacyType),
      'max_members': maxMembers,
      'current_member_count': currentMemberCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'invite_code': inviteCode,
      'is_active': isActive,
      'group_type': groupType,
    };
  }

  WorkoutGroup toEntity() {
    return WorkoutGroup(
      id: id,
      name: name,
      description: description,
      adminId: adminId,
      privacyType: privacyType,
      maxMembers: maxMembers,
      currentMemberCount: currentMemberCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      inviteCode: inviteCode,
      isActive: isActive,
      groupType: groupType,
    );
  }

  factory WorkoutGroupModel.fromEntity(WorkoutGroup entity) {
    return WorkoutGroupModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      adminId: entity.adminId,
      privacyType: entity.privacyType,
      maxMembers: entity.maxMembers,
      currentMemberCount: entity.currentMemberCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      inviteCode: entity.inviteCode,
      isActive: entity.isActive,
      groupType: entity.groupType,
    );
  }
}