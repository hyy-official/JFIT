import 'package:dartz/dartz.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import '../entities/group_ranking.dart';
import '../entities/user_workout_score.dart';
import '../entities/workout_score_calculation.dart';
import '../entities/body_part_mapping.dart';

/// Request models for ranking operations
class CalculateScoreRequest {
  final String userId;
  final String groupId;
  final DateTime scoreDate;
  final List<String> sessionIds; // Workout sessions to include in calculation

  const CalculateScoreRequest({
    required this.userId,
    required this.groupId,
    required this.scoreDate,
    required this.sessionIds,
  });
}

class RankingPeriodRequest {
  final RankingPeriod period;
  final DateTime? startDate; // Optional: custom start date
  final DateTime? endDate; // Optional: custom end date

  const RankingPeriodRequest({
    required this.period,
    this.startDate,
    this.endDate,
  });

  /// Get the actual start and end dates for the period
  Map<String, DateTime> get periodDates {
    final now = DateTime.now();
    
    if (startDate != null && endDate != null) {
      return {'start': startDate!, 'end': endDate!};
    }

    switch (period) {
      case RankingPeriod.daily:
        final start = DateTime(now.year, now.month, now.day);
        final end = start.add(const Duration(days: 1));
        return {'start': start, 'end': end};
        
      case RankingPeriod.weekly:
        final weekday = now.weekday;
        final start = now.subtract(Duration(days: weekday - 1));
        final weekStart = DateTime(start.year, start.month, start.day);
        final weekEnd = weekStart.add(const Duration(days: 7));
        return {'start': weekStart, 'end': weekEnd};
        
      case RankingPeriod.monthly:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1);
        return {'start': start, 'end': end};
    }
  }
}

/// Repository interface for ranking system operations
/// Handles score calculation, ranking updates, and leaderboards
abstract class RankingRepository extends BaseRepository {
  /// Get group rankings for a specific period
  /// Returns rankings ordered by total score (highest first)
  Future<Either<Failure, List<GroupRanking>>> getGroupRankings(
    RankingPeriodRequest request, {
    int limit = 100,
    int offset = 0,
  });

  /// Get ranking for a specific group
  Future<Either<Failure, GroupRanking?>> getGroupRanking(
    String groupId,
    RankingPeriodRequest request,
  );

  /// Get user workout scores for a specific period
  /// Returns scores ordered by date (most recent first)
  Future<Either<Failure, List<UserWorkoutScore>>> getUserScores(
    String userId, {
    String? groupId,
    RankingPeriodRequest? period,
    int limit = 30,
  });

  /// Get user scores within a specific group
  Future<Either<Failure, List<UserWorkoutScore>>> getGroupMemberScores(
    String groupId,
    RankingPeriodRequest request, {
    int limit = 50,
  });

  /// Calculate workout score for a user on a specific date
  /// Analyzes workout sessions and calculates comprehensive score
  Future<Either<Failure, UserWorkoutScore>> calculateUserScore(
    CalculateScoreRequest request,
  );

  /// Update group rankings for a specific period
  /// Recalculates all group scores and updates rankings
  Future<Either<Failure, void>> updateGroupRankings(RankingPeriodRequest request);

  /// Get detailed score breakdown for a user
  /// Returns analysis of different score components
  Future<Either<Failure, Map<String, dynamic>>> getScoreBreakdown(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get user's ranking within their groups
  /// Returns ranking position in each group the user belongs to
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserGroupRankings(
    String userId,
    RankingPeriodRequest request,
  );

  /// Get top performers in a specific group
  /// Returns highest scoring members for the period
  Future<Either<Failure, List<Map<String, dynamic>>>> getGroupTopPerformers(
    String groupId,
    RankingPeriodRequest request, {
    int limit = 10,
  });

  /// Get workout score calculations for analysis
  /// Returns raw calculation data for debugging/analysis
  Future<Either<Failure, List<WorkoutScoreCalculation>>> getScoreCalculations(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  });

  /// Calculate body part balance score
  /// Analyzes how evenly user exercises different muscle groups
  Future<Either<Failure, double>> calculateBodyBalanceScore(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Calculate volume score based on total workout volume
  /// Considers weight, sets, reps across all exercises
  Future<Either<Failure, double>> calculateVolumeScore(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Calculate progress score based on improvement over time
  /// Compares current performance to previous periods
  Future<Either<Failure, double>> calculateProgressScore(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Calculate consistency score based on workout frequency
  /// Measures how regularly user exercises
  Future<Either<Failure, double>> calculateConsistencyScore(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get body part exercise distribution for a user
  /// Returns how much each body part is exercised
  Future<Either<Failure, Map<BodyPart, double>>> getBodyPartDistribution(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get ranking trends for a group over time
  /// Shows how group ranking has changed over multiple periods
  Future<Either<Failure, List<Map<String, dynamic>>>> getGroupRankingTrends(
    String groupId, {
    RankingPeriod period = RankingPeriod.weekly,
    int periodCount = 12,
  });

  /// Get user score trends over time
  /// Shows how user's scores have changed over multiple periods
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserScoreTrends(
    String userId, {
    String? groupId,
    RankingPeriod period = RankingPeriod.weekly,
    int periodCount = 12,
  });

  /// Get comparative analysis between users
  /// Compares two users' performance across different metrics
  Future<Either<Failure, Map<String, dynamic>>> compareUsers(
    String userId1,
    String userId2,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get group performance statistics
  /// Returns comprehensive stats about group's overall performance
  Future<Either<Failure, Map<String, dynamic>>> getGroupPerformanceStats(
    String groupId,
    RankingPeriodRequest request,
  );

  /// Get leaderboard for specific body part training
  /// Shows who trains specific muscle groups most effectively
  Future<Either<Failure, List<Map<String, dynamic>>>> getBodyPartLeaderboard(
    BodyPart bodyPart,
    RankingPeriodRequest request, {
    String? groupId,
    int limit = 20,
  });

  /// Get achievement milestones for ranking system
  /// Returns users who reached significant milestones
  Future<Either<Failure, List<Map<String, dynamic>>>> getRankingAchievements(
    RankingPeriodRequest request, {
    String? groupId,
  });

  /// Recalculate all scores for a specific period
  /// Useful for fixing calculation errors or updating algorithms
  Future<Either<Failure, void>> recalculateAllScores(
    RankingPeriodRequest request, {
    String? groupId,
  });

  /// Get ranking system configuration
  /// Returns current scoring weights and thresholds
  Future<Either<Failure, Map<String, dynamic>>> getRankingConfiguration();

  /// Update ranking system configuration
  /// Allows adjusting scoring weights and parameters
  Future<Either<Failure, void>> updateRankingConfiguration(
    Map<String, dynamic> configuration,
  );

  /// Get detailed workout analysis for score calculation
  /// Returns comprehensive analysis of workout data used in scoring
  Future<Either<Failure, Map<String, dynamic>>> getWorkoutAnalysis(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get group competition status
  /// Returns information about ongoing competitions between groups
  Future<Either<Failure, Map<String, dynamic>>> getGroupCompetitionStatus(
    List<String> groupIds,
    RankingPeriodRequest request,
  );

  /// Create or update workout score calculation record
  /// Stores detailed calculation data for audit purposes
  Future<Either<Failure, WorkoutScoreCalculation>> createScoreCalculation(
    String userId,
    String sessionId,
    Map<BodyPart, int> bodyPartVolumes,
    double totalVolume,
    int exerciseVariety,
    int sessionDurationMinutes,
  );
}