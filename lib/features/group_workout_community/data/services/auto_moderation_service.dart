import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/content_filter.dart';
import '../../domain/entities/content_report.dart';
import '../../domain/repositories/content_report_repository.dart';
import 'content_moderation_service.dart';

/// Service that automatically moderates content and creates reports for flagged content
class AutoModerationService {
  final ContentModerationService _contentModerationService;
  final ContentReportRepository _contentReportRepository;

  AutoModerationService(
    this._contentModerationService,
    this._contentReportRepository,
  );

  /// Moderate content before posting and handle the result
  Future<Either<Failure, AutoModerationResult>> moderateBeforePost({
    required String content,
    required String authorId,
    required ReportedContentType contentType,
    required String contentId,
    String? groupId,
  }) async {
    try {
      // First, moderate the content
      final moderationResult = await _contentModerationService.moderateContent(content);
      
      if (moderationResult.isLeft()) {
        return Left(moderationResult.fold((l) => l, (r) => throw Exception()));
      }

      final result = moderationResult.fold((l) => throw Exception(), (r) => r);

      // If content is blocked, don't allow posting
      if (result.isBlocked) {
        return Right(AutoModerationResult(
          isAllowed: false,
          filteredContent: null,
          reason: 'Content blocked due to policy violations',
          triggeredFilters: result.triggeredFilters,
          severity: result.highestSeverity,
        ));
      }

      // If content is flagged, create an automatic report
      if (result.isFlagged) {
        await _createAutomaticReport(
          contentType: contentType,
          contentId: contentId,
          reportedUserId: authorId,
          groupId: groupId,
          triggeredFilters: result.triggeredFilters,
          severity: result.highestSeverity,
        );
      }

      // Allow posting with potentially filtered content
      return Right(AutoModerationResult(
        isAllowed: true,
        filteredContent: result.filteredContent,
        reason: result.isFlagged ? 'Content flagged for review' : null,
        triggeredFilters: result.triggeredFilters,
        severity: result.highestSeverity,
        isFlagged: result.isFlagged,
      ));
    } catch (e) {
      return Left(ServerFailure('Auto-moderation failed: ${e.toString()}'));
    }
  }

  /// Create an automatic report for flagged content
  Future<void> _createAutomaticReport({
    required ReportedContentType contentType,
    required String contentId,
    required String reportedUserId,
    String? groupId,
    required List<String> triggeredFilters,
    ContentFilterSeverity? severity,
  }) async {
    try {
      // Determine report reason based on triggered filters
      final reportReason = _determineReportReason(triggeredFilters);
      
      // Create system report (using a system user ID or special handling)
      await _contentReportRepository.submitReport(
        reporterId: 'system', // This would need to be handled properly in your system
        reportedContentType: contentType,
        reportedContentId: contentId,
        reportedUserId: reportedUserId,
        groupId: groupId,
        reportReason: reportReason,
        reportDescription: 'Automatically flagged by content filter. Triggered filters: ${triggeredFilters.join(', ')}',
      );
    } catch (e) {
      // Log error but don't fail the main operation
      print('Failed to create automatic report: $e');
    }
  }

  /// Determine appropriate report reason based on triggered filters
  ReportReason _determineReportReason(List<String> triggeredFilters) {
    // This is a simple heuristic - you might want to make this more sophisticated
    final filterText = triggeredFilters.join(' ').toLowerCase();
    
    if (filterText.contains('spam') || filterText.contains('advertisement')) {
      return ReportReason.spam;
    } else if (filterText.contains('harassment') || filterText.contains('bullying')) {
      return ReportReason.harassment;
    } else if (filterText.contains('hate') || filterText.contains('discriminat')) {
      return ReportReason.hateSpeech;
    } else if (filterText.contains('violence') || filterText.contains('threat')) {
      return ReportReason.violence;
    } else if (filterText.contains('inappropriate') || filterText.contains('profanity')) {
      return ReportReason.inappropriateContent;
    } else {
      return ReportReason.other;
    }
  }

  /// Batch moderate multiple pieces of content
  Future<Either<Failure, List<AutoModerationResult>>> moderateBatch({
    required List<ContentModerationRequest> requests,
  }) async {
    try {
      final results = <AutoModerationResult>[];
      
      for (final request in requests) {
        final result = await moderateBeforePost(
          content: request.content,
          authorId: request.authorId,
          contentType: request.contentType,
          contentId: request.contentId,
          groupId: request.groupId,
        );
        
        if (result.isLeft()) {
          return Left(result.fold((l) => l, (r) => throw Exception()));
        }
        
        results.add(result.fold((l) => throw Exception(), (r) => r));
      }
      
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('Batch moderation failed: ${e.toString()}'));
    }
  }

  /// Check if user is allowed to post (not banned)
  Future<Either<Failure, bool>> canUserPost({
    required String userId,
    String? groupId,
  }) async {
    try {
      // This would integrate with your moderation action repository
      // to check if user is currently banned
      // For now, returning true as placeholder
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure('Failed to check user posting permissions: ${e.toString()}'));
    }
  }
}

class AutoModerationResult {
  final bool isAllowed;
  final String? filteredContent;
  final String? reason;
  final List<String> triggeredFilters;
  final ContentFilterSeverity? severity;
  final bool isFlagged;

  const AutoModerationResult({
    required this.isAllowed,
    this.filteredContent,
    this.reason,
    this.triggeredFilters = const [],
    this.severity,
    this.isFlagged = false,
  });

  bool get hasViolations => !isAllowed || isFlagged;
}

class ContentModerationRequest {
  final String content;
  final String authorId;
  final ReportedContentType contentType;
  final String contentId;
  final String? groupId;

  const ContentModerationRequest({
    required this.content,
    required this.authorId,
    required this.contentType,
    required this.contentId,
    this.groupId,
  });
}