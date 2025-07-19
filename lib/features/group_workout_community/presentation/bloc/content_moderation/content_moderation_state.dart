import 'package:equatable/equatable.dart';
import '../../../domain/entities/content_report.dart';
import '../../../domain/entities/moderation_action.dart';
import '../../../data/services/content_moderation_service.dart';

abstract class ContentModerationState extends Equatable {
  const ContentModerationState();

  @override
  List<Object?> get props => [];
}

class ContentModerationInitial extends ContentModerationState {}

class ContentModerationLoading extends ContentModerationState {}

class ContentModerationSuccess extends ContentModerationState {
  final String? message;

  const ContentModerationSuccess({this.message});

  @override
  List<Object?> get props => [message];
}

class ContentModerationError extends ContentModerationState {
  final String message;

  const ContentModerationError(this.message);

  @override
  List<Object?> get props => [message];
}

// Content Report States
class ContentReportSubmitted extends ContentModerationState {
  final ContentReport report;

  const ContentReportSubmitted(this.report);

  @override
  List<Object?> get props => [report];
}

class UserReportsLoaded extends ContentModerationState {
  final List<ContentReport> reports;
  final bool hasMore;

  const UserReportsLoaded({
    required this.reports,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [reports, hasMore];
}

class ModerationReportsLoaded extends ContentModerationState {
  final List<ContentReport> reports;
  final bool hasMore;

  const ModerationReportsLoaded({
    required this.reports,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [reports, hasMore];
}

class ReportStatusUpdated extends ContentModerationState {
  final ContentReport report;

  const ReportStatusUpdated(this.report);

  @override
  List<Object?> get props => [report];
}

// Moderation Action States
class ModerationActionCreated extends ContentModerationState {
  final ModerationAction action;

  const ModerationActionCreated(this.action);

  @override
  List<Object?> get props => [action];
}

class UserModerationActionsLoaded extends ContentModerationState {
  final List<ModerationAction> actions;
  final bool hasMore;

  const UserModerationActionsLoaded({
    required this.actions,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [actions, hasMore];
}

class UserBanStatusChecked extends ContentModerationState {
  final bool isBanned;

  const UserBanStatusChecked(this.isBanned);

  @override
  List<Object?> get props => [isBanned];
}

// Content Filtering States
class ContentModerated extends ContentModerationState {
  final ContentModerationResult result;

  const ContentModerated(this.result);

  @override
  List<Object?> get props => [result];
}

// Statistics States
class ReportStatisticsLoaded extends ContentModerationState {
  final Map<String, dynamic> statistics;

  const ReportStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

class ModerationStatisticsLoaded extends ContentModerationState {
  final Map<String, dynamic> statistics;

  const ModerationStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}