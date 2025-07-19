import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../domain/repositories/content_report_repository.dart';
import '../../../domain/repositories/moderation_action_repository.dart';
import '../../../data/services/content_moderation_service.dart';
import 'content_moderation_event.dart';
import 'content_moderation_state.dart';

class ContentModerationBloc extends Bloc<ContentModerationEvent, ContentModerationState> {
  final ContentReportRepository _contentReportRepository;
  final ModerationActionRepository _moderationActionRepository;
  final ContentModerationService _contentModerationService;
  final AuthService _authService;

  ContentModerationBloc({
    required ContentReportRepository contentReportRepository,
    required ModerationActionRepository moderationActionRepository,
    required ContentModerationService contentModerationService,
    required AuthService authService,
  })  : _contentReportRepository = contentReportRepository,
        _moderationActionRepository = moderationActionRepository,
        _contentModerationService = contentModerationService,
        _authService = authService,
        super(ContentModerationInitial()) {
    on<SubmitContentReportEvent>(_onSubmitContentReport);
    on<LoadUserReportsEvent>(_onLoadUserReports);
    on<LoadReportsForModerationEvent>(_onLoadReportsForModeration);
    on<UpdateReportStatusEvent>(_onUpdateReportStatus);
    on<CreateModerationActionEvent>(_onCreateModerationAction);
    on<LoadModerationActionsForUserEvent>(_onLoadModerationActionsForUser);
    on<CheckUserBanStatusEvent>(_onCheckUserBanStatus);
    on<ModerateContentEvent>(_onModerateContent);
    on<LoadReportStatisticsEvent>(_onLoadReportStatistics);
    on<LoadModerationStatisticsEvent>(_onLoadModerationStatistics);
  }

  Future<void> _onSubmitContentReport(
    SubmitContentReportEvent event,
    Emitter<ContentModerationState> emit,
  ) async {
    emit(ContentModerationLoading());

    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      emit(const ContentModerationError('User not authenticated'));
      return;
    }

    final result = await _contentReportRepository.submitReport(
      reporterId: currentUser.id,
      reportedContentType: event.contentType,
      reportedContentId: event.contentId,
      reportedUserId: event.reportedUserId,
      groupId: event.groupId,
      reportReason: event.reportReason,
      reportDescription: event.reportDescription,
    );

    result.fold(
      (failure) => emit(ContentModerationError(failure.message)),
      (report) => emit(ContentReportSubmitted(report)),
    );
  }

  Future<void> _onLoadUserReports(
    LoadUserReportsEvent event,
    Emitter<ContentModerationState> emit,
  ) async {
    emit(ContentModerationLoading());

    final result = await _contentReportRepository.getUserReports(
      event.userId,
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      (failure) => emit(ContentModerationError(failure.message)),
      (reports) => emit(UserReportsLoaded(
        reports: reports,
        hasMore: reports.length == event.limit,
      )),
    );
  }

  Future<void> _onLoadReportsForModeration(
    LoadReportsForModerationEvent event,
    Emitter<ContentModerationState> emit,
  ) async {
    emit(ContentModerationLoading());

    final result = await _contentReportRepository.getReportsForModeration(
      groupId: event.groupId,
      status: event.status,
      priority: event.priority,
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      (failure) => emit(ContentModerationError(failure.message)),
      (reports) => emit(ModerationReportsLoaded(
        reports: reports,
        hasMore: reports.length == event.limit,
      )),
    );
  }

  Future<void> _onUpdateReportStatus(
    UpdateReportStatusEvent event,
    Emitter<ContentModerationState> emit,
  ) async {
    emit(ContentModerationLoading());

    final result = await _contentReportRepository.updateReportStatus(
      reportId: event.reportId,
      status: event.status,
      priority: event.priority,
    );

    result.fold(
      (failure) => emit(ContentModerationError(failure.message)),
      (report) => emit(ReportStatusUpdated(report)),
    );
  }

  Future<void> _onCreateModerationAction(
    CreateModerationActionEvent event,
    Emitter<ContentModerationState> emit,
  ) async {
    emit(ContentModerationLoading());

    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      emit(const ContentModerationError('User not authenticated'));
      return;
    }

    final result = await _moderationActionRepository.createModerationAction(
      moderatorId: currentUser.id,
      reportId: event.reportId,
      targetContentType: event.targetContentType,
      targetContentId: event.targetContentId,
      targetUserId: event.targetUserId,
      actionType: event.actionType,
      actionReason: event.actionReason,
      actionDetails: event.actionDetails,
      durationHours: event.durationHours,
    );

    result.fold(
      (failure) => emit(ContentModerationError(failure.message)),
      (action) => emit(ModerationActionCreated(action)),
    );
  }

  Future<void> _onLoadModerationActionsForUser(
    LoadModerationActionsForUserEvent event,
    Emitter<ContentModerationState> emit,
  ) async {
    emit(ContentModerationLoading());

    final result = await _moderationActionRepository.getModerationActionsForUser(
      event.userId,
      activeOnly: event.activeOnly,
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      (failure) => emit(ContentModerationError(failure.message)),
      (actions) => emit(UserModerationActionsLoaded(
        actions: actions,
        hasMore: actions.length == event.limit,
      )),
    );
  }

  Future<void> _onCheckUserBanStatus(
    CheckUserBanStatusEvent event,
    Emitter<ContentModerationState> emit,
  ) async {
    emit(ContentModerationLoading());

    final result = await _moderationActionRepository.isUserBanned(
      userId: event.userId,
      groupId: event.groupId,
    );

    result.fold(
      (failure) => emit(ContentModerationError(failure.message)),
      (isBanned) => emit(UserBanStatusChecked(isBanned)),
    );
  }

  Future<void> _onModerateContent(
    ModerateContentEvent event,
    Emitter<ContentModerationState> emit,
  ) async {
    emit(ContentModerationLoading());

    final result = await _contentModerationService.moderateContent(event.content);

    result.fold(
      (failure) => emit(ContentModerationError(failure.message)),
      (moderationResult) => emit(ContentModerated(moderationResult)),
    );
  }

  Future<void> _onLoadReportStatistics(
    LoadReportStatisticsEvent event,
    Emitter<ContentModerationState> emit,
  ) async {
    emit(ContentModerationLoading());

    final result = await _contentReportRepository.getReportStatistics(
      groupId: event.groupId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(ContentModerationError(failure.message)),
      (statistics) => emit(ReportStatisticsLoaded(statistics)),
    );
  }

  Future<void> _onLoadModerationStatistics(
    LoadModerationStatisticsEvent event,
    Emitter<ContentModerationState> emit,
  ) async {
    emit(ContentModerationLoading());

    final result = await _moderationActionRepository.getModerationStatistics(
      moderatorId: event.moderatorId,
      groupId: event.groupId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(ContentModerationError(failure.message)),
      (statistics) => emit(ModerationStatisticsLoaded(statistics)),
    );
  }
}