import '../../domain/entities/moderation_action.dart';

class ModerationActionModel extends ModerationAction {
  const ModerationActionModel({
    required super.id,
    required super.moderatorId,
    super.reportId,
    required super.targetContentType,
    required super.targetContentId,
    required super.targetUserId,
    required super.actionType,
    required super.actionReason,
    super.actionDetails = const {},
    super.durationHours,
    required super.isActive,
    required super.createdAt,
    super.expiresAt,
  });

  factory ModerationActionModel.fromJson(Map<String, dynamic> json) {
    return ModerationActionModel(
      id: json['id'] as String,
      moderatorId: json['moderator_id'] as String,
      reportId: json['report_id'] as String?,
      targetContentType: ModerationTargetTypeExtension.fromString(
        json['target_content_type'] as String,
      ),
      targetContentId: json['target_content_id'] as String,
      targetUserId: json['target_user_id'] as String,
      actionType: ModerationActionTypeExtension.fromString(
        json['action_type'] as String,
      ),
      actionReason: json['action_reason'] as String,
      actionDetails: Map<String, dynamic>.from(
        json['action_details'] as Map<String, dynamic>? ?? {},
      ),
      durationHours: json['duration_hours'] as int?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moderator_id': moderatorId,
      'report_id': reportId,
      'target_content_type': targetContentType.value,
      'target_content_id': targetContentId,
      'target_user_id': targetUserId,
      'action_type': actionType.value,
      'action_reason': actionReason,
      'action_details': actionDetails,
      'duration_hours': durationHours,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id'); // Remove ID for insert operations
    json.remove('created_at'); // Let database handle timestamps
    return json;
  }

  ModerationActionModel copyWith({
    String? id,
    String? moderatorId,
    String? reportId,
    ModerationTargetType? targetContentType,
    String? targetContentId,
    String? targetUserId,
    ModerationActionType? actionType,
    String? actionReason,
    Map<String, dynamic>? actionDetails,
    int? durationHours,
    bool? isActive,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return ModerationActionModel(
      id: id ?? this.id,
      moderatorId: moderatorId ?? this.moderatorId,
      reportId: reportId ?? this.reportId,
      targetContentType: targetContentType ?? this.targetContentType,
      targetContentId: targetContentId ?? this.targetContentId,
      targetUserId: targetUserId ?? this.targetUserId,
      actionType: actionType ?? this.actionType,
      actionReason: actionReason ?? this.actionReason,
      actionDetails: actionDetails ?? this.actionDetails,
      durationHours: durationHours ?? this.durationHours,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}