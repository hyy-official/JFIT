import 'package:equatable/equatable.dart';
import '../../../domain/entities/group_ranking.dart';
import '../../../domain/repositories/ranking_repository.dart';

/// Base class for all ranking events
abstract class RankingEvent extends Equatable {
  const RankingEvent();

  @override
  List<Object?> get props => [];
}

/// Load group rankings for a specific period
class LoadGroupRankings extends RankingEvent {
  final RankingPeriodRequest request;
  final int limit;
  final int offset;

  const LoadGroupRankings({
    required this.request,
    this.limit = 100,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [request, limit, offset];
}

/// Load user workout scores
class LoadUserScores extends RankingEvent {
  final String userId;
  final String? groupId;
  final RankingPeriodRequest? period;
  final int limit;

  const LoadUserScores({
    required this.userId,
    this.groupId,
    this.period,
    this.limit = 30,
  });

  @override
  List<Object?> get props => [userId, groupId, period, limit];
}

/// Load group member scores
class LoadGroupMemberScores extends RankingEvent {
  final String groupId;
  final RankingPeriodRequest request;
  final int limit;

  const LoadGroupMemberScores({
    required this.groupId,
    required this.request,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [groupId, request, limit];
}

/// Calculate user score for a specific date
class CalculateUserScore extends RankingEvent {
  final CalculateScoreRequest request;

  const CalculateUserScore({required this.request});

  @override
  List<Object?> get props => [request];
}

/// Load score breakdown for detailed analysis
class LoadScoreBreakdown extends RankingEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadScoreBreakdown({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

/// Load user's ranking within their groups
class LoadUserGroupRankings extends RankingEvent {
  final String userId;
  final RankingPeriodRequest request;

  const LoadUserGroupRankings({
    required this.userId,
    required this.request,
  });

  @override
  List<Object?> get props => [userId, request];
}

/// Load top performers in a group
class LoadGroupTopPerformers extends RankingEvent {
  final String groupId;
  final RankingPeriodRequest request;
  final int limit;

  const LoadGroupTopPerformers({
    required this.groupId,
    required this.request,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [groupId, request, limit];
}

/// Load ranking trends for a group
class LoadGroupRankingTrends extends RankingEvent {
  final String groupId;
  final RankingPeriod period;
  final int periodCount;

  const LoadGroupRankingTrends({
    required this.groupId,
    this.period = RankingPeriod.weekly,
    this.periodCount = 12,
  });

  @override
  List<Object?> get props => [groupId, period, periodCount];
}

/// Load user score trends
class LoadUserScoreTrends extends RankingEvent {
  final String userId;
  final String? groupId;
  final RankingPeriod period;
  final int periodCount;

  const LoadUserScoreTrends({
    required this.userId,
    this.groupId,
    this.period = RankingPeriod.weekly,
    this.periodCount = 12,
  });

  @override
  List<Object?> get props => [userId, groupId, period, periodCount];
}

/// Load group performance statistics
class LoadGroupPerformanceStats extends RankingEvent {
  final String groupId;
  final RankingPeriodRequest request;

  const LoadGroupPerformanceStats({
    required this.groupId,
    required this.request,
  });

  @override
  List<Object?> get props => [groupId, request];
}

/// Compare two users' performance
class CompareUsers extends RankingEvent {
  final String userId1;
  final String userId2;
  final DateTime startDate;
  final DateTime endDate;

  const CompareUsers({
    required this.userId1,
    required this.userId2,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [userId1, userId2, startDate, endDate];
}

/// Refresh rankings data
class RefreshRankings extends RankingEvent {
  const RefreshRankings();
}

/// Change ranking period filter
class ChangeRankingPeriod extends RankingEvent {
  final RankingPeriod period;

  const ChangeRankingPeriod({required this.period});

  @override
  List<Object?> get props => [period];
}

/// Update group rankings
class UpdateGroupRankings extends RankingEvent {
  final RankingPeriodRequest request;

  const UpdateGroupRankings({required this.request});

  @override
  List<Object?> get props => [request];
}

/// Load workout analysis for detailed view
class LoadWorkoutAnalysis extends RankingEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadWorkoutAnalysis({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

/// Load body part distribution
class LoadBodyPartDistribution extends RankingEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadBodyPartDistribution({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

/// Reset ranking state
class ResetRankingState extends RankingEvent {
  const ResetRankingState();
}