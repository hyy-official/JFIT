import 'package:equatable/equatable.dart';

enum ReportReason {
  spam,
  harassment,
  inappropriateContent,
  hateSpeech,
  violence,
  misinformation,
  copyright,
  other,
}

enum ReportStatus {
  pending,
  underReview,
  resolved,
  dismissed,
}

enum ReportPriority {
  low,
  medium,
  high,
  urgent,
}

enum ReportedContentType {
  post,
  comment,
  message,
  user,
}

class ContentReport extends Equatable {
  final String id;
  final String reporterId;
  final ReportedContentType reportedContentType;
  final String reportedContentId;
  final String? reportedUserId;
  final String? groupId;
  final ReportReason reportReason;
  final String? reportDescription;
  final ReportStatus status;
  final ReportPriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ContentReport({
    required this.id,
    required this.reporterId,
    required this.reportedContentType,
    required this.reportedContentId,
    this.reportedUserId,
    this.groupId,
    required this.reportReason,
    this.reportDescription,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  ContentReport copyWith({
    String? id,
    String? reporterId,
    ReportedContentType? reportedContentType,
    String? reportedContentId,
    String? reportedUserId,
    String? groupId,
    ReportReason? reportReason,
    String? reportDescription,
    ReportStatus? status,
    ReportPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContentReport(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      reportedContentType: reportedContentType ?? this.reportedContentType,
      reportedContentId: reportedContentId ?? this.reportedContentId,
      reportedUserId: reportedUserId ?? this.reportedUserId,
      groupId: groupId ?? this.groupId,
      reportReason: reportReason ?? this.reportReason,
      reportDescription: reportDescription ?? this.reportDescription,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        reporterId,
        reportedContentType,
        reportedContentId,
        reportedUserId,
        groupId,
        reportReason,
        reportDescription,
        status,
        priority,
        createdAt,
        updatedAt,
      ];
}

extension ReportReasonExtension on ReportReason {
  String get displayName {
    switch (this) {
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.harassment:
        return 'Harassment';
      case ReportReason.inappropriateContent:
        return 'Inappropriate Content';
      case ReportReason.hateSpeech:
        return 'Hate Speech';
      case ReportReason.violence:
        return 'Violence';
      case ReportReason.misinformation:
        return 'Misinformation';
      case ReportReason.copyright:
        return 'Copyright Violation';
      case ReportReason.other:
        return 'Other';
    }
  }

  String get value {
    switch (this) {
      case ReportReason.spam:
        return 'spam';
      case ReportReason.harassment:
        return 'harassment';
      case ReportReason.inappropriateContent:
        return 'inappropriate_content';
      case ReportReason.hateSpeech:
        return 'hate_speech';
      case ReportReason.violence:
        return 'violence';
      case ReportReason.misinformation:
        return 'misinformation';
      case ReportReason.copyright:
        return 'copyright';
      case ReportReason.other:
        return 'other';
    }
  }

  static ReportReason fromString(String value) {
    switch (value) {
      case 'spam':
        return ReportReason.spam;
      case 'harassment':
        return ReportReason.harassment;
      case 'inappropriate_content':
        return ReportReason.inappropriateContent;
      case 'hate_speech':
        return ReportReason.hateSpeech;
      case 'violence':
        return ReportReason.violence;
      case 'misinformation':
        return ReportReason.misinformation;
      case 'copyright':
        return ReportReason.copyright;
      case 'other':
        return ReportReason.other;
      default:
        return ReportReason.other;
    }
  }
}

extension ReportStatusExtension on ReportStatus {
  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.underReview:
        return 'Under Review';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.dismissed:
        return 'Dismissed';
    }
  }

  String get value {
    switch (this) {
      case ReportStatus.pending:
        return 'pending';
      case ReportStatus.underReview:
        return 'under_review';
      case ReportStatus.resolved:
        return 'resolved';
      case ReportStatus.dismissed:
        return 'dismissed';
    }
  }

  static ReportStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return ReportStatus.pending;
      case 'under_review':
        return ReportStatus.underReview;
      case 'resolved':
        return ReportStatus.resolved;
      case 'dismissed':
        return ReportStatus.dismissed;
      default:
        return ReportStatus.pending;
    }
  }
}

extension ReportPriorityExtension on ReportPriority {
  String get displayName {
    switch (this) {
      case ReportPriority.low:
        return 'Low';
      case ReportPriority.medium:
        return 'Medium';
      case ReportPriority.high:
        return 'High';
      case ReportPriority.urgent:
        return 'Urgent';
    }
  }

  String get value {
    switch (this) {
      case ReportPriority.low:
        return 'low';
      case ReportPriority.medium:
        return 'medium';
      case ReportPriority.high:
        return 'high';
      case ReportPriority.urgent:
        return 'urgent';
    }
  }

  static ReportPriority fromString(String value) {
    switch (value) {
      case 'low':
        return ReportPriority.low;
      case 'medium':
        return ReportPriority.medium;
      case 'high':
        return ReportPriority.high;
      case 'urgent':
        return ReportPriority.urgent;
      default:
        return ReportPriority.medium;
    }
  }
}

extension ReportedContentTypeExtension on ReportedContentType {
  String get value {
    switch (this) {
      case ReportedContentType.post:
        return 'post';
      case ReportedContentType.comment:
        return 'comment';
      case ReportedContentType.message:
        return 'message';
      case ReportedContentType.user:
        return 'user';
    }
  }

  static ReportedContentType fromString(String value) {
    switch (value) {
      case 'post':
        return ReportedContentType.post;
      case 'comment':
        return ReportedContentType.comment;
      case 'message':
        return ReportedContentType.message;
      case 'user':
        return ReportedContentType.user;
      default:
        return ReportedContentType.post;
    }
  }
}