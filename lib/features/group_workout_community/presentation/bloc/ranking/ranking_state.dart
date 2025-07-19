import 'package:equatable/equatable.dart';
import '../../../domain/entities/group_ranking.dart';
import '../../../domain/entities/user_workout_score.dart';
import '../../../domain/entities/body_part_mapping.dart';

/// Base class for all ranking states
abstract class RankingState extends Equatable {
  const RankingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class RankingInitial extends RankingState {
  const RankingInitial();
}

/// Loading state
class RankingLoading extends RankingState {
  const RankingLoading();
}

/// Loaded state with ranking data
class RankingLoaded extends RankingState {
  final List<GroupRanking> groupRankings;
  final List<UserWorkoutScore> userScores;
  final List<Map<String, dynamic>> groupMemberScores;
  final Map<String, dynamic>? scoreBreakdown;
  final List<Map<String, dynamic>> userGroupRankings;
  final List<Map<String, dynamic>> groupTopPerformers;
  final List<Map<String, dynamic>> groupRankingTrends;
  final List<Map<String, dynamic>> userScoreTrends;
  final Map<String, dynamic>? groupPerformanceStats;
  final Map<String, dynamic>? userComparison;
  final Map<String, dynamic>? workoutAnalysis;
  final Map<BodyPart, double>? bodyPartDistribution;
  final RankingPeriod currentPeriod;
  final DateTime lastUpdated;

  const RankingLoaded({
    this.groupRankings = const [],
    this.userScores = const [],
    this.groupMemberScores = const [],
    this.scoreBreakdown,
    this.userGroupRankings = const [],
    this.groupTopPerformers = const [],
    this.groupRankingTrends = const [],
    this.userScoreTrends = const [],
    this.groupPerformanceStats,
    this.userComparison,
    this.workoutAnalysis,
    this.bodyPartDistribution,
    this.currentPeriod = RankingPeriod.weekly,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        groupRankings,
        userScores,
        groupMemberScores,
        scoreBreakdown,
        userGroupRankings,
        groupTopPerformers,
        groupRankingTrends,
        userScoreTrends,
        groupPerformanceStats,
        userComparison,
        workoutAnalysis,
        bodyPartDistribution,
        currentPeriod,
        lastUpdated,
      ];

  RankingLoaded copyWith({
    List<GroupRanking>? groupRankings,
    List<UserWorkoutScore>? userScores,
    List<Map<String, dynamic>>? groupMemberScores,
    Map<String, dynamic>? scoreBreakdown,
    List<Map<String, dynamic>>? userGroupRankings,
    List<Map<String, dynamic>>? groupTopPerformers,
    List<Map<String, dynamic>>? groupRankingTrends,
    List<Map<String, dynamic>>? userScoreTrends,
    Map<String, dynamic>? groupPerformanceStats,
    Map<String, dynamic>? userComparison,
    Map<String, dynamic>? workoutAnalysis,
    Map<BodyPart, double>? bodyPartDistribution,
    RankingPeriod? currentPeriod,
    DateTime? lastUpdated,
  }) {
    return RankingLoaded(
      groupRankings: groupRankings ?? this.groupRankings,
      userScores: userScores ?? this.userScores,
      groupMemberScores: groupMemberScores ?? this.groupMemberScores,
      scoreBreakdown: scoreBreakdown ?? this.scoreBreakdown,
      userGroupRankings: userGroupRankings ?? this.userGroupRankings,
      groupTopPerformers: groupTopPerformers ?? this.groupTopPerformers,
      groupRankingTrends: groupRankingTrends ?? this.groupRankingTrends,
      userScoreTrends: userScoreTrends ?? this.userScoreTrends,
      groupPerformanceStats: groupPerformanceStats ?? this.groupPerformanceStats,
      userComparison: userComparison ?? this.userComparison,
      workoutAnalysis: workoutAnalysis ?? this.workoutAnalysis,
      bodyPartDistribution: bodyPartDistribution ?? this.bodyPartDistribution,
      currentPeriod: currentPeriod ?? this.currentPeriod,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Check if group rankings are available
  bool get hasGroupRankings => groupRankings.isNotEmpty;

  /// Check if user scores are available
  bool get hasUserScores => userScores.isNotEmpty;

  /// Check if group member scores are available
  bool get hasGroupMemberScores => groupMemberScores.isNotEmpty;

  /// Check if score breakdown is available
  bool get hasScoreBreakdown => scoreBreakdown != null;

  /// Check if ranking trends are available
  bool get hasRankingTrends => groupRankingTrends.isNotEmpty || userScoreTrends.isNotEmpty;

  /// Check if workout analysis is available
  bool get hasWorkoutAnalysis => workoutAnalysis != null;

  /// Check if body part distribution is available
  bool get hasBodyPartDistribution => bodyPartDistribution != null && bodyPartDistribution!.isNotEmpty;

  /// Get current user's latest score
  UserWorkoutScore? get latestUserScore => userScores.isNotEmpty ? userScores.first : null;

  /// Get current user's score for a specific date
  UserWorkoutScore? getUserScoreForDate(DateTime date) {
    return userScores.where((score) => 
      score.scoreDate.year == date.year &&
      score.scoreDate.month == date.month &&
      score.scoreDate.day == date.day
    ).firstOrNull;
  }

  /// Get top ranking groups (top 10)
  List<GroupRanking> get topRankingGroups => 
      groupRankings.where((ranking) => ranking.isTopRanking).toList();

  /// Get user's best performing body part
  BodyPart? get userBestBodyPart => latestUserScore?.strongestBodyPart;

  /// Get user's worst performing body part
  BodyPart? get userWorstBodyPart => latestUserScore?.weakestBodyPart;

  /// Get user's current score grade
  String? get userScoreGrade => latestUserScore?.scoreGrade;

  /// Check if user's workout is balanced
  bool get isUserWorkoutBalanced => latestUserScore?.isBalanced ?? false;

  /// Get user's score trend (improving, declining, stable)
  String get userScoreTrend {
    if (userScores.length < 2) return 'insufficient_data';
    
    final latest = userScores[0].totalScore;
    final previous = userScores[1].totalScore;
    
    if (latest > previous + 5) return 'improving';
    if (latest < previous - 5) return 'declining';
    return 'stable';
  }

  /// Get period display string
  String get periodDisplayString {
    switch (currentPeriod) {
      case RankingPeriod.daily:
        return '일간';
      case RankingPeriod.weekly:
        return '주간';
      case RankingPeriod.monthly:
        return '월간';
    }
  }

  /// Check if data is stale (older than 1 hour)
  bool get isDataStale {
    final now = DateTime.now();
    return now.difference(lastUpdated).inHours > 1;
  }

  /// Get summary statistics
  Map<String, dynamic> get summaryStats {
    final userScore = latestUserScore;
    return {
      'totalGroups': groupRankings.length,
      'userTotalScore': userScore?.totalScore ?? 0.0,
      'userScoreGrade': userScore?.scoreGrade ?? 'N/A',
      'userRank': userGroupRankings.isNotEmpty ? userGroupRankings.first['rank'] ?? 0 : 0,
      'isBalanced': userScore?.isBalanced ?? false,
      'strongestBodyPart': userScore?.strongestBodyPart?.displayName ?? 'N/A',
      'weakestBodyPart': userScore?.weakestBodyPart?.displayName ?? 'N/A',
      'scoreTrend': userScoreTrend,
      'period': periodDisplayString,
      'lastUpdated': lastUpdated,
    };
  }
}

/// Error state
class RankingError extends RankingState {
  final String message;
  final String? errorCode;

  const RankingError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

/// Loading specific data state
class RankingPartialLoading extends RankingState {
  final RankingLoaded currentState;
  final String loadingType; // 'rankings', 'scores', 'trends', etc.

  const RankingPartialLoading({
    required this.currentState,
    required this.loadingType,
  });

  @override
  List<Object?> get props => [currentState, loadingType];
}

/// Score calculation in progress
class RankingCalculating extends RankingState {
  final String userId;
  final DateTime scoreDate;

  const RankingCalculating({
    required this.userId,
    required this.scoreDate,
  });

  @override
  List<Object?> get props => [userId, scoreDate];
}

/// Rankings update in progress
class RankingUpdating extends RankingState {
  final RankingPeriod period;

  const RankingUpdating({required this.period});

  @override
  List<Object?> get props => [period];
}

/// Success state for operations
class RankingOperationSuccess extends RankingState {
  final String message;
  final String operationType;

  const RankingOperationSuccess({
    required this.message,
    required this.operationType,
  });

  @override
  List<Object?> get props => [message, operationType];
}