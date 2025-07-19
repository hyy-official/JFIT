import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/content_report.dart';

abstract class ContentReportRepository {
  /// Submit a new content report
  Future<Either<Failure, ContentReport>> submitReport({
    required String reporterId,
    required ReportedContentType reportedContentType,
    required String reportedContentId,
    String? reportedUserId,
    String? groupId,
    required ReportReason reportReason,
    String? reportDescription,
  });

  /// Get reports submitted by a user
  Future<Either<Failure, List<ContentReport>>> getUserReports(
    String userId, {
    int limit = 20,
    int offset = 0,
  });

  /// Get reports for moderation (admin/moderator only)
  Future<Either<Failure, List<ContentReport>>> getReportsForModeration({
    String? groupId,
    ReportStatus? status,
    ReportPriority? priority,
    int limit = 50,
    int offset = 0,
  });

  /// Get report by ID
  Future<Either<Failure, ContentReport>> getReportById(String reportId);

  /// Update report status (moderator only)
  Future<Either<Failure, ContentReport>> updateReportStatus({
    required String reportId,
    required ReportStatus status,
    ReportPriority? priority,
  });

  /// Get reports for specific content
  Future<Either<Failure, List<ContentReport>>> getReportsForContent({
    required ReportedContentType contentType,
    required String contentId,
  });

  /// Check if user has already reported specific content
  Future<Either<Failure, bool>> hasUserReportedContent({
    required String userId,
    required ReportedContentType contentType,
    required String contentId,
  });

  /// Get report statistics for admin dashboard
  Future<Either<Failure, Map<String, dynamic>>> getReportStatistics({
    String? groupId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Delete report (admin only)
  Future<Either<Failure, void>> deleteReport(String reportId);
}