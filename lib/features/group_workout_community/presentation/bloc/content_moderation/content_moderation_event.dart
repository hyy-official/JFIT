import 'package:equatable/equatable.dart';
import '../../../domain/entities/content_report.dart';
import '../../../domain/entities/moderation_action.dart';

abstract class ContentModerationEvent extends Equatable {
  const ContentModerationEvent();

  @override
  List<Object?> get props => [];
}

// Content Report Events
class SubmitContentReportEvent extends ContentModerationEvent {
  final ReportedContentType contentType;
  final String contentId;
  final String? reportedUserId;
  final String? groupId;
  final ReportReason reportReason;
  final String? reportDescription;

  const SubmitContentReportEvent({
    required this.contentType,
    required this.contentId,
    this.reportedUserId,
    this.groupId,
    required this.reportReason,
    this.reportDescription,
  });

  @override
  List<Object?> get props => [
        contentType,
        contentId,
        reportedUserId,
        groupId,
        reportReason,
        reportDescription,
      ];
}

class LoadUserReportsEvent extends ContentModerationEvent {
  final String userId;
  final int limit;
  final int offset;

  const LoadUserReportsEvent({
    required this.userId,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [userId, limit, offset];
}

class LoadReportsForModerationEvent extends ContentModerationEvent {
  final String? groupId;
  final ReportStatus? status;
  final ReportPriority? priority;
  final int limit;
  final int offset;

  const LoadReportsForModerationEvent({
    this.groupId,
    this.status,
    this.priority,
    this.limit = 50,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [groupId, status, priority, limit, offset];
}

class UpdateReportStatusEvent extends ContentModerationEvent {
  final String reportId;
  final ReportStatus status;
  final ReportPriority? priority;

  const UpdateReportStatusEvent({
    required this.reportId,
    required this.status,
    this.priority,
  });

  @override
  List<Object?> get props => [reportId, status, priority];
}

// Moderation Action Events
class CreateModerationActionEvent extends ContentModerationEvent {
  final String? reportId;
  final ModerationTargetType targetContentType;
  final String targetContentId;
  final String targetUserId;
  final ModerationActionType actionType;
  final String actionReason;
  final Map<String, dynamic> actionDetails;
  final int? durationHours;

  const CreateModerationActionEvent({
    this.reportId,
    required this.targetContentType,
    required this.targetContentId,
    required this.targetUserId,
    required this.actionType,
    required this.actionReason,
    this.actionDetails = const {},
    this.durationHours,
  });

  @override
  List<Object?> get props => [
        reportId,
        targetContentType,
        targetContentId,
        targetUserId,
        actionType,
        actionReason,
        actionDetails,
        durationHours,
      ];
}

class LoadModerationActionsForUserEvent extends ContentModerationEvent {
  final String userId;
  final bool activeOnly;
  final int limit;
  final int offset;

  const LoadModerationActionsForUserEvent({
    required this.userId,
    this.activeOnly = false,
    this.limit = 50,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [userId, activeOnly, limit, offset];
}

class CheckUserBanStatusEvent extends ContentModerationEvent {
  final String userId;
  final String? groupId;

  const CheckUserBanStatusEvent({
    required this.userId,
    this.groupId,
  });

  @override
  List<Object?> get props => [userId, groupId];
}

// Content Filtering Events
class ModerateContentEvent extends ContentModerationEvent {
  final String content;

  const ModerateContentEvent({
    required this.content,
  });

  @override
  List<Object?> get props => [content];
}

class LoadReportStatisticsEvent extends ContentModerationEvent {
  final String? groupId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadReportStatisticsEvent({
    this.groupId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [groupId, startDate, endDate];
}

class LoadModerationStatisticsEvent extends ContentModerationEvent {
  final String? moderatorId;
  final String? groupId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadModerationStatisticsEvent({
    this.moderatorId,
    this.groupId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [moderatorId, groupId, startDate, endDate];
}