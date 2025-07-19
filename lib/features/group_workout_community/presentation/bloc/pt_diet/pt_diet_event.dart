import 'package:equatable/equatable.dart';
import '../../../domain/repositories/pt_diet_repository.dart';
import '../../../domain/entities/diet_feedback.dart';

/// Base class for all PT diet events
abstract class PTDietEvent extends Equatable {
  const PTDietEvent();

  @override
  List<Object?> get props => [];
}

/// Load group diet summaries for a specific date
class LoadGroupDietSummaries extends PTDietEvent {
  final String groupId;
  final DateTime date;

  const LoadGroupDietSummaries({
    required this.groupId,
    required this.date,
  });

  @override
  List<Object?> get props => [groupId, date];
}

/// Load member diet summary for a specific date
class LoadMemberDietSummary extends PTDietEvent {
  final String groupId;
  final String memberId;
  final DateTime date;

  const LoadMemberDietSummary({
    required this.groupId,
    required this.memberId,
    required this.date,
  });

  @override
  List<Object?> get props => [groupId, memberId, date];
}

/// Load member meal entries for a date range
class LoadMemberMealEntries extends PTDietEvent {
  final String memberId;
  final DateTime startDate;
  final DateTime endDate;
  final bool includePhotos;

  const LoadMemberMealEntries({
    required this.memberId,
    required this.startDate,
    required this.endDate,
    this.includePhotos = true,
  });

  @override
  List<Object?> get props => [memberId, startDate, endDate, includePhotos];
}

/// Add diet feedback from trainer to member
class AddDietFeedback extends PTDietEvent {
  final CreateDietFeedbackRequest request;

  const AddDietFeedback({required this.request});

  @override
  List<Object?> get props => [request];
}

/// Load diet feedbacks for a specific member
class LoadDietFeedbacks extends PTDietEvent {
  final String groupId;
  final String memberId;
  final int limit;
  final int offset;
  final FeedbackType? feedbackType;

  const LoadDietFeedbacks({
    required this.groupId,
    required this.memberId,
    this.limit = 20,
    this.offset = 0,
    this.feedbackType,
  });

  @override
  List<Object?> get props => [groupId, memberId, limit, offset, feedbackType];
}

/// Load all diet feedbacks in a group
class LoadGroupDietFeedbacks extends PTDietEvent {
  final String groupId;
  final int limit;
  final int offset;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadGroupDietFeedbacks({
    required this.groupId,
    this.limit = 50,
    this.offset = 0,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [groupId, limit, offset, startDate, endDate];
}

/// Mark feedback as read
class MarkFeedbackAsRead extends PTDietEvent {
  final String feedbackId;

  const MarkFeedbackAsRead({required this.feedbackId});

  @override
  List<Object?> get props => [feedbackId];
}

/// Mark multiple feedbacks as read
class MarkMultipleFeedbacksAsRead extends PTDietEvent {
  final List<String> feedbackIds;

  const MarkMultipleFeedbacksAsRead({required this.feedbackIds});

  @override
  List<Object?> get props => [feedbackIds];
}

/// Load diet analytics
class LoadDietAnalytics extends PTDietEvent {
  final DietAnalyticsRequest request;

  const LoadDietAnalytics({required this.request});

  @override
  List<Object?> get props => [request];
}

/// Load member goal achievement
class LoadMemberGoalAchievement extends PTDietEvent {
  final String memberId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadMemberGoalAchievement({
    required this.memberId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [memberId, startDate, endDate];
}

/// Load group diet compliance
class LoadGroupDietCompliance extends PTDietEvent {
  final String groupId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadGroupDietCompliance({
    required this.groupId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [groupId, startDate, endDate];
}

/// Set diet permissions
class SetDietPermissions extends PTDietEvent {
  final DietPermissionRequest request;

  const SetDietPermissions({required this.request});

  @override
  List<Object?> get props => [request];
}

/// Load diet permissions
class LoadDietPermissions extends PTDietEvent {
  final String groupId;
  final String memberId;
  final String trainerId;

  const LoadDietPermissions({
    required this.groupId,
    required this.memberId,
    required this.trainerId,
  });

  @override
  List<Object?> get props => [groupId, memberId, trainerId];
}

/// Load group diet permissions
class LoadGroupDietPermissions extends PTDietEvent {
  final String groupId;
  final String trainerId;

  const LoadGroupDietPermissions({
    required this.groupId,
    required this.trainerId,
  });

  @override
  List<Object?> get props => [groupId, trainerId];
}

/// Revoke diet permissions
class RevokeDietPermissions extends PTDietEvent {
  final String groupId;
  final String memberId;
  final String trainerId;

  const RevokeDietPermissions({
    required this.groupId,
    required this.memberId,
    required this.trainerId,
  });

  @override
  List<Object?> get props => [groupId, memberId, trainerId];
}

/// Load member diet trends
class LoadMemberDietTrends extends PTDietEvent {
  final String memberId;
  final DateTime startDate;
  final DateTime endDate;
  final String? groupId;

  const LoadMemberDietTrends({
    required this.memberId,
    required this.startDate,
    required this.endDate,
    this.groupId,
  });

  @override
  List<Object?> get props => [memberId, startDate, endDate, groupId];
}

/// Load group diet comparison
class LoadGroupDietComparison extends PTDietEvent {
  final String groupId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadGroupDietComparison({
    required this.groupId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [groupId, startDate, endDate];
}

/// Load diet recommendations
class LoadDietRecommendations extends PTDietEvent {
  final String memberId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadDietRecommendations({
    required this.memberId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [memberId, startDate, endDate];
}

/// Load unread feedback count
class LoadUnreadFeedbackCount extends PTDietEvent {
  final String memberId;

  const LoadUnreadFeedbackCount({required this.memberId});

  @override
  List<Object?> get props => [memberId];
}

/// Update trainer notes
class UpdateTrainerNotes extends PTDietEvent {
  final String summaryId;
  final String trainerNotes;

  const UpdateTrainerNotes({
    required this.summaryId,
    required this.trainerNotes,
  });

  @override
  List<Object?> get props => [summaryId, trainerNotes];
}

/// Load recent diet activity
class LoadRecentDietActivity extends PTDietEvent {
  final String groupId;
  final int hours;

  const LoadRecentDietActivity({
    required this.groupId,
    this.hours = 24,
  });

  @override
  List<Object?> get props => [groupId, hours];
}

/// Load meal timing analysis
class LoadMealTimingAnalysis extends PTDietEvent {
  final String memberId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadMealTimingAnalysis({
    required this.memberId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [memberId, startDate, endDate];
}

/// Load nutrition alerts
class LoadNutritionAlerts extends PTDietEvent {
  final String groupId;
  final String? memberId;
  final DateTime? date;

  const LoadNutritionAlerts({
    required this.groupId,
    this.memberId,
    this.date,
  });

  @override
  List<Object?> get props => [groupId, memberId, date];
}

/// Load diet adherence score
class LoadDietAdherenceScore extends PTDietEvent {
  final String memberId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadDietAdherenceScore({
    required this.memberId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [memberId, startDate, endDate];
}

/// Load macro distribution analysis
class LoadMacroDistributionAnalysis extends PTDietEvent {
  final String memberId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadMacroDistributionAnalysis({
    required this.memberId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [memberId, startDate, endDate];
}

/// Update member diet goals
class UpdateMemberDietGoals extends PTDietEvent {
  final String memberId;
  final double calorieGoal;
  final double proteinGoal;
  final double carbGoal;
  final double fatGoal;

  const UpdateMemberDietGoals({
    required this.memberId,
    required this.calorieGoal,
    required this.proteinGoal,
    required this.carbGoal,
    required this.fatGoal,
  });

  @override
  List<Object?> get props => [memberId, calorieGoal, proteinGoal, carbGoal, fatGoal];
}

/// Refresh PT diet data
class RefreshPTDietData extends PTDietEvent {
  const RefreshPTDietData();
}

/// Reset PT diet state
class ResetPTDietState extends PTDietEvent {
  const ResetPTDietState();
}

/// Change selected date for diet summaries
class ChangeSelectedDate extends PTDietEvent {
  final DateTime date;

  const ChangeSelectedDate({required this.date});

  @override
  List<Object?> get props => [date];
}

/// Change selected member for detailed view
class ChangeSelectedMember extends PTDietEvent {
  final String memberId;

  const ChangeSelectedMember({required this.memberId});

  @override
  List<Object?> get props => [memberId];
}

/// Load diet coaching insights
class LoadDietCoachingInsights extends PTDietEvent {
  final String groupId;
  final String memberId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadDietCoachingInsights({
    required this.groupId,
    required this.memberId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [groupId, memberId, startDate, endDate];
}

/// Export member diet data
class ExportMemberDietData extends PTDietEvent {
  final String memberId;
  final DateTime startDate;
  final DateTime endDate;
  final String format;

  const ExportMemberDietData({
    required this.memberId,
    required this.startDate,
    required this.endDate,
    this.format = 'json',
  });

  @override
  List<Object?> get props => [memberId, startDate, endDate, format];
}