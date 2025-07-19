import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/content_report.dart';
import '../../domain/repositories/content_report_repository.dart';
import '../models/content_report_model.dart';

class ContentReportRepositoryImpl implements ContentReportRepository {
  final SupabaseClient _supabaseClient;

  ContentReportRepositoryImpl(this._supabaseClient);

  @override
  Future<Either<Failure, ContentReport>> submitReport({
    required String reporterId,
    required ReportedContentType reportedContentType,
    required String reportedContentId,
    String? reportedUserId,
    String? groupId,
    required ReportReason reportReason,
    String? reportDescription,
  }) async {
    try {
      // Check if user has already reported this content
      final existingReportResult = await hasUserReportedContent(
        userId: reporterId,
        contentType: reportedContentType,
        contentId: reportedContentId,
      );

      if (existingReportResult.isRight()) {
        final hasReported = existingReportResult.fold((l) => false, (r) => r);
        if (hasReported) {
          return Left(ServerFailure('You have already reported this content'));
        }
      }

      // Determine priority based on report reason
      final priority = _determinePriority(reportReason);

      final response = await _supabaseClient
          .from('content_reports')
          .insert({
            'reporter_id': reporterId,
            'reported_content_type': reportedContentType.value,
            'reported_content_id': reportedContentId,
            'reported_user_id': reportedUserId,
            'group_id': groupId,
            'report_reason': reportReason.value,
            'report_description': reportDescription,
            'status': ReportStatus.pending.value,
            'priority': priority.value,
          })
          .select()
          .single();

      final report = ContentReportModel.fromJson(response);
      return Right(report);
    } catch (e) {
      return Left(ServerFailure('Failed to submit report: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ContentReport>>> getUserReports(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabaseClient
          .from('content_reports')
          .select()
          .eq('reporter_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final reports = (response as List<dynamic>)
          .map((json) => ContentReportModel.fromJson(json))
          .toList();

      return Right(reports);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch user reports: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ContentReport>>> getReportsForModeration({
    String? groupId,
    ReportStatus? status,
    ReportPriority? priority,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _supabaseClient
          .from('content_reports')
          .select();

      if (groupId != null) {
        query = query.eq('group_id', groupId);
      }

      if (status != null) {
        query = query.eq('status', status.value);
      }

      if (priority != null) {
        query = query.eq('priority', priority.value);
      }

      final response = await query
          .order('priority', ascending: false)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final reports = (response as List<dynamic>)
          .map((json) => ContentReportModel.fromJson(json))
          .toList();

      return Right(reports);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch reports for moderation: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ContentReport>> getReportById(String reportId) async {
    try {
      final response = await _supabaseClient
          .from('content_reports')
          .select()
          .eq('id', reportId)
          .single();

      final report = ContentReportModel.fromJson(response);
      return Right(report);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch report: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ContentReport>> updateReportStatus({
    required String reportId,
    required ReportStatus status,
    ReportPriority? priority,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.value,
      };

      if (priority != null) {
        updateData['priority'] = priority.value;
      }

      final response = await _supabaseClient
          .from('content_reports')
          .update(updateData)
          .eq('id', reportId)
          .select()
          .single();

      final report = ContentReportModel.fromJson(response);
      return Right(report);
    } catch (e) {
      return Left(ServerFailure('Failed to update report status: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ContentReport>>> getReportsForContent({
    required ReportedContentType contentType,
    required String contentId,
  }) async {
    try {
      final response = await _supabaseClient
          .from('content_reports')
          .select()
          .eq('reported_content_type', contentType.value)
          .eq('reported_content_id', contentId)
          .order('created_at', ascending: false);

      final reports = (response as List<dynamic>)
          .map((json) => ContentReportModel.fromJson(json))
          .toList();

      return Right(reports);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch reports for content: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasUserReportedContent({
    required String userId,
    required ReportedContentType contentType,
    required String contentId,
  }) async {
    try {
      final response = await _supabaseClient
          .from('content_reports')
          .select('id')
          .eq('reporter_id', userId)
          .eq('reported_content_type', contentType.value)
          .eq('reported_content_id', contentId)
          .limit(1);

      final hasReported = (response as List<dynamic>).isNotEmpty;
      return Right(hasReported);
    } catch (e) {
      return Left(ServerFailure('Failed to check report status: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getReportStatistics({
    String? groupId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabaseClient
          .from('content_reports')
          .select('status, priority, report_reason, created_at');

      if (groupId != null) {
        query = query.eq('group_id', groupId);
      }

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;
      final reports = response as List<dynamic>;

      // Calculate statistics
      final stats = <String, dynamic>{
        'total_reports': reports.length,
        'pending_reports': reports.where((r) => r['status'] == 'pending').length,
        'under_review_reports': reports.where((r) => r['status'] == 'under_review').length,
        'resolved_reports': reports.where((r) => r['status'] == 'resolved').length,
        'dismissed_reports': reports.where((r) => r['status'] == 'dismissed').length,
        'high_priority_reports': reports.where((r) => r['priority'] == 'high').length,
        'urgent_reports': reports.where((r) => r['priority'] == 'urgent').length,
        'reports_by_reason': <String, int>{},
        'reports_by_day': <String, int>{},
      };

      // Group by reason
      final reasonCounts = <String, int>{};
      for (final report in reports) {
        final reason = report['report_reason'] as String;
        reasonCounts[reason] = (reasonCounts[reason] ?? 0) + 1;
      }
      stats['reports_by_reason'] = reasonCounts;

      // Group by day
      final dayCounts = <String, int>{};
      for (final report in reports) {
        final date = DateTime.parse(report['created_at'] as String);
        final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        dayCounts[dayKey] = (dayCounts[dayKey] ?? 0) + 1;
      }
      stats['reports_by_day'] = dayCounts;

      return Right(stats);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch report statistics: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReport(String reportId) async {
    try {
      await _supabaseClient
          .from('content_reports')
          .delete()
          .eq('id', reportId);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete report: ${e.toString()}'));
    }
  }

  /// Determine priority based on report reason
  ReportPriority _determinePriority(ReportReason reason) {
    switch (reason) {
      case ReportReason.violence:
      case ReportReason.hateSpeech:
        return ReportPriority.urgent;
      case ReportReason.harassment:
      case ReportReason.inappropriateContent:
        return ReportPriority.high;
      case ReportReason.spam:
      case ReportReason.misinformation:
        return ReportPriority.medium;
      case ReportReason.copyright:
      case ReportReason.other:
        return ReportPriority.low;
    }
  }
}