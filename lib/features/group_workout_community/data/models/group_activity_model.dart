import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/group_activity.dart';
import '../../domain/entities/workout_group.dart';

part 'group_activity_model.g.dart';

@JsonSerializable(explicitToJson: true)
class GroupActivityModel extends GroupActivity {
  const GroupActivityModel({
    required super.id,
    required super.groupId,
    required super.userId,
    required super.activityType,
    required super.activityData,
    required super.createdAt,
    required super.mentionedUserIds,
  });

  factory GroupActivityModel.fromJson(Map<String, dynamic> json) {
    return GroupActivityModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String,
      activityType: _parseActivityType(json['activity_type'] as String?),
      activityData: json['activity_data'] != null
          ? Map<String, dynamic>.from(json['activity_data'] as Map)
          : <String, dynamic>{},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      mentionedUserIds: json['mentioned_user_ids'] != null
          ? List<String>.from(json['mentioned_user_ids'] as List)
          : <String>[],
    );
  }

  static GroupActivityType _parseActivityType(String? value) {
    switch (value) {
      case 'workout_completed':
        return GroupActivityType.workoutCompleted;
      case 'routine_shared':
        return GroupActivityType.routineShared;
      case 'member_joined':
        return GroupActivityType.memberJoined;
      case 'member_left':
        return GroupActivityType.memberLeft;
      case 'encouragement_sent':
        return GroupActivityType.encouragementSent;
      case 'achievement_unlocked':
        return GroupActivityType.achievementUnlocked;
      case 'program_started':
        return GroupActivityType.programStarted;
      case 'milestone_reached':
        return GroupActivityType.milestoneReached;
      default:
        return GroupActivityType.workoutCompleted;
    }
  }

  static String _activityTypeToString(GroupActivityType type) {
    switch (type) {
      case GroupActivityType.workoutCompleted:
        return 'workout_completed';
      case GroupActivityType.routineShared:
        return 'routine_shared';
      case GroupActivityType.memberJoined:
        return 'member_joined';
      case GroupActivityType.memberLeft:
        return 'member_left';
      case GroupActivityType.encouragementSent:
        return 'encouragement_sent';
      case GroupActivityType.achievementUnlocked:
        return 'achievement_unlocked';
      case GroupActivityType.programStarted:
        return 'program_started';
      case GroupActivityType.milestoneReached:
        return 'milestone_reached';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'activity_type': _activityTypeToString(activityType),
      'activity_data': activityData,
      'created_at': createdAt.toIso8601String(),
      'mentioned_user_ids': mentionedUserIds,
    };
  }

  GroupActivity toEntity() {
    return GroupActivity(
      id: id,
      groupId: groupId,
      userId: userId,
      activityType: activityType,
      activityData: activityData,
      createdAt: createdAt,
      mentionedUserIds: mentionedUserIds,
    );
  }

  factory GroupActivityModel.fromEntity(GroupActivity entity) {
    return GroupActivityModel(
      id: entity.id,
      groupId: entity.groupId,
      userId: entity.userId,
      activityType: entity.activityType,
      activityData: entity.activityData,
      createdAt: entity.createdAt,
      mentionedUserIds: entity.mentionedUserIds,
    );
  }
}