import '../../domain/entities/content_report.dart';

class ContentReportModel extends ContentReport {
  const ContentReportModel({
    required super.id,
    required super.reporterId,
    required super.reportedContentType,
    required super.reportedContentId,
    super.reportedUserId,
    super.groupId,
    required super.reportReason,
    super.reportDescription,
    required super.status,
    required super.priority,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ContentReportModel.fromJson(Map<String, dynamic> json) {
    return ContentReportModel(
      id: json['id'] as String,
      reporterId: json['reporter_id'] as String,
      reportedContentType: ReportedContentTypeExtension.fromString(
        json['reported_content_type'] as String,
      ),
      reportedContentId: json['reported_content_id'] as String,
      reportedUserId: json['reported_user_id'] as String?,
      groupId: json['group_id'] as String?,
      reportReason: ReportReasonExtension.fromString(
        json['report_reason'] as String,
      ),
      reportDescription: json['report_description'] as String?,
      status: ReportStatusExtension.fromString(
        json['status'] as String,
      ),
      priority: ReportPriorityExtension.fromString(
        json['priority'] as String,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'reported_content_type': reportedContentType.value,
      'reported_content_id': reportedContentId,
      'reported_user_id': reportedUserId,
      'group_id': groupId,
      'report_reason': reportReason.value,
      'report_description': reportDescription,
      'status': status.value,
      'priority': priority.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id'); // Remove ID for insert operations
    json.remove('created_at'); // Let database handle timestamps
    json.remove('updated_at');
    return json;
  }

  ContentReportModel copyWith({
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
    return ContentReportModel(
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
}