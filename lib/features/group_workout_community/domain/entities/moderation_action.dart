import 'package:equatable/equatable.dart';

enum ModerationActionType {
  warning,
  contentRemoval,
  contentEdit,
  temporaryBan,
  permanentBan,
  groupRemoval,
  dismissReport,
}

enum ModerationTargetType {
  post,
  comment,
  message,
  user,
}

class ModerationAction extends Equatable {
  final String id;
  final String moderatorId;
  final String? reportId;
  final ModerationTargetType targetContentType;
  final String targetContentId;
  final String targetUserId;
  final ModerationActionType actionType;
  final String actionReason;
  final Map<String, dynamic> actionDetails;
  final int? durationHours;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const ModerationAction({
    required this.id,
    required this.moderatorId,
    this.reportId,
    required this.targetContentType,
    required this.targetContentId,
    required this.targetUserId,
    required this.actionType,
    required this.actionReason,
    this.actionDetails = const {},
    this.durationHours,
    required this.isActive,
    required this.createdAt,
    this.expiresAt,
  });

  ModerationAction copyWith({
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
    return ModerationAction(
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

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isTemporary {
    return actionType == ModerationActionType.temporaryBan && expiresAt != null;
  }

  @override
  List<Object?> get props => [
        id,
        moderatorId,
        reportId,
        targetContentType,
        targetContentId,
        targetUserId,
        actionType,
        actionReason,
        actionDetails,
        durationHours,
        isActive,
        createdAt,
        expiresAt,
      ];
}

extension ModerationActionTypeExtension on ModerationActionType {
  String get displayName {
    switch (this) {
      case ModerationActionType.warning:
        return 'Warning';
      case ModerationActionType.contentRemoval:
        return 'Content Removal';
      case ModerationActionType.contentEdit:
        return 'Content Edit';
      case ModerationActionType.temporaryBan:
        return 'Temporary Ban';
      case ModerationActionType.permanentBan:
        return 'Permanent Ban';
      case ModerationActionType.groupRemoval:
        return 'Group Removal';
      case ModerationActionType.dismissReport:
        return 'Dismiss Report';
    }
  }

  String get value {
    switch (this) {
      case ModerationActionType.warning:
        return 'warning';
      case ModerationActionType.contentRemoval:
        return 'content_removal';
      case ModerationActionType.contentEdit:
        return 'content_edit';
      case ModerationActionType.temporaryBan:
        return 'temporary_ban';
      case ModerationActionType.permanentBan:
        return 'permanent_ban';
      case ModerationActionType.groupRemoval:
        return 'group_removal';
      case ModerationActionType.dismissReport:
        return 'dismiss_report';
    }
  }

  static ModerationActionType fromString(String value) {
    switch (value) {
      case 'warning':
        return ModerationActionType.warning;
      case 'content_removal':
        return ModerationActionType.contentRemoval;
      case 'content_edit':
        return ModerationActionType.contentEdit;
      case 'temporary_ban':
        return ModerationActionType.temporaryBan;
      case 'permanent_ban':
        return ModerationActionType.permanentBan;
      case 'group_removal':
        return ModerationActionType.groupRemoval;
      case 'dismiss_report':
        return ModerationActionType.dismissReport;
      default:
        return ModerationActionType.warning;
    }
  }
}

extension ModerationTargetTypeExtension on ModerationTargetType {
  String get value {
    switch (this) {
      case ModerationTargetType.post:
        return 'post';
      case ModerationTargetType.comment:
        return 'comment';
      case ModerationTargetType.message:
        return 'message';
      case ModerationTargetType.user:
        return 'user';
    }
  }

  static ModerationTargetType fromString(String value) {
    switch (value) {
      case 'post':
        return ModerationTargetType.post;
      case 'comment':
        return ModerationTargetType.comment;
      case 'message':
        return ModerationTargetType.message;
      case 'user':
        return ModerationTargetType.user;
      default:
        return ModerationTargetType.post;
    }
  }
}