import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import '../../domain/repositories/ranking_repository.dart';
import '../../domain/entities/group_ranking.dart';
import '../../domain/entities/user_workout_score.dart';
import '../../domain/entities/workout_score_calculation.dart';
import '../../domain/entities/body_part_mapping.dart';
import '../models/group_ranking_model.dart';
import '../models/user_workout_score_model.dart';

/// Implementation of RankingRepository using Supabase as the data source
class RankingRepositoryImpl extends RankingRepository with BaseRepositoryMixin {
  final SupabaseClient _supabaseClient;
  final Uuid _uuid = const Uuid();

  RankingRepositoryImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<Either<Failure, List<GroupRanking>>> getGroupRankings(
    RankingPeriodRequest request, {
    int limit = 100,
    int offset = 0,
  }) async {
    return safeCall(() async {
      final periodDates = request.periodDates;
      
      final response = await _supabaseClient
          .from('group_rankings')
          .select('''
            *,
            workout_groups!inner(name)
          ''')
          .eq('ranking_period', _rankingPeriodToString(request.period))
          .eq('period_start_date', periodDates['start']!.toIso8601String().split('T')[0])
          .eq('period_end_date', periodDates['end']!.toIso8601String().split('T')[0])
          .order('rank_position', ascending: true)
          .range(offset, offset + limit - 1);

      return (response as List).map((json) {
        final groupData = json['workout_groups'] as Map<String, dynamic>;
        json['group_name'] = groupData['name'];
        return GroupRankingModel.fromJson(json).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, GroupRanking?>> getGroupRanking(
    String groupId,
    RankingPeriodRequest request,
  ) async {
    return safeCall(() async {
      try {
        final periodDates = request.periodDates;
        
        final response = await _supabaseClient
            .from('group_rankings')
            .select('''
              *,
              workout_groups!inner(name)
            ''')
            .eq('group_id', groupId)
            .eq('ranking_period', _rankingPeriodToString(request.period))
            .eq('period_start_date', periodDates['start']!.toIso8601String().split('T')[0])
            .eq('period_end_date', periodDates['end']!.toIso8601String().split('T')[0])
            .single();

        final groupData = response['workout_groups'] as Map<String, dynamic>;
        response['group_name'] = groupData['name'];
        return GroupRankingModel.fromJson(response).toEntity();
      } catch (e) {
        if (e is PostgrestException && (e.code == 'PGRST116' || e.message.contains('0 rows'))) {
          return null;
        }
        rethrow;
      }
    });
  }

  @override
  Future<Either<Failure, List<UserWorkoutScore>>> getUserScores(
    String userId, {
    String? groupId,
    RankingPeriodRequest? period,
    int limit = 30,
  }) async {
    return safeCall(() async {
      var query = _supabaseClient
          .from('user_workout_scores')
          .select('*')
          .eq('user_id', userId);

      if (groupId != null) {
        query = query.eq('group_id', groupId);
      }

      if (period != null) {
        final periodDates = period.periodDates;
        query = query
            .gte('score_date', periodDates['start']!.toIso8601String().split('T')[0])
            .lte('score_date', periodDates['end']!.toIso8601String().split('T')[0]);
      }

      final response = await query
          .order('score_date', ascending: false)
          .limit(limit);

      return (response as List).map((json) {
        return UserWorkoutScoreModel.fromJson(json).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, List<UserWorkoutScore>>> getGroupMemberScores(
    String groupId,
    RankingPeriodRequest request, {
    int limit = 50,
  }) async {
    return safeCall(() async {
      final periodDates = request.periodDates;
      
      final response = await _supabaseClient
          .from('user_workout_scores')
          .select('''
            *,
            user_profiles!inner(username, profile_image_url)
          ''')
          .eq('group_id', groupId)
          .gte('score_date', periodDates['start']!.toIso8601String().split('T')[0])
          .lte('score_date', periodDates['end']!.toIso8601String().split('T')[0])
          .order('total_score', ascending: false)
          .limit(limit);

      return (response as List).map((json) {
        return UserWorkoutScoreModel.fromJson(json).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, UserWorkoutScore>> calculateUserScore(
    CalculateScoreRequest request,
  ) async {
    return safeCall(() async {
      final scoreId = _uuid.v4();
      final now = DateTime.now();

      // Calculate individual score components
      final bodyBalanceScore = await calculateBodyBalanceScore(
        request.userId,
        request.scoreDate,
        request.scoreDate.add(const Duration(days: 1)),
      );
      
      final volumeScore = await calculateVolumeScore(
        request.userId,
        request.scoreDate,
        request.scoreDate.add(const Duration(days: 1)),
      );
      
      final progressScore = await calculateProgressScore(
        request.userId,
        request.scoreDate,
        request.scoreDate.add(const Duration(days: 1)),
      );
      
      final consistencyScore = await calculateConsistencyScore(
        request.userId,
        request.scoreDate.subtract(const Duration(days: 7)),
        request.scoreDate.add(const Duration(days: 1)),
      );

      final bodyPartDistribution = await getBodyPartDistribution(
        request.userId,
        request.scoreDate,
        request.scoreDate.add(const Duration(days: 1)),
      );

      final balance = bodyBalanceScore.fold((failure) => 0.0, (score) => score);
      final volume = volumeScore.fold((failure) => 0.0, (score) => score);
      final progress = progressScore.fold((failure) => 0.0, (score) => score);
      final consistency = consistencyScore.fold((failure) => 0.0, (score) => score);
      final bodyParts = bodyPartDistribution.fold((failure) => <BodyPart, double>{}, (dist) => dist);

      // Calculate total score with weighted components
      final totalScore = (balance * 0.3) + (volume * 0.25) + (progress * 0.25) + (consistency * 0.2);

      final scoreData = {
        'id': scoreId,
        'user_id': request.userId,
        'group_id': request.groupId,
        'score_date': request.scoreDate.toIso8601String().split('T')[0],
        'total_score': totalScore,
        'body_balance_score': balance,
        'volume_score': volume,
        'progress_score': progress,
        'consistency_score': consistency,
        'body_part_scores': _bodyPartScoresToJson(bodyParts),
        'created_at': now.toIso8601String(),
      };

      // Upsert the score (update if exists for same user/group/date)
      await _supabaseClient
          .from('user_workout_scores')
          .upsert(scoreData, onConflict: 'user_id,group_id,score_date');

      return UserWorkoutScoreModel.fromJson(scoreData).toEntity();
    });
  }

  @override
  Future<Either<Failure, void>> updateGroupRankings(RankingPeriodRequest request) async {
    return safeCall(() async {
      final periodDates = request.periodDates;
      
      // Get all groups with members
      final groupsResponse = await _supabaseClient
          .from('workout_groups')
          .select('''
            id,
            name,
            group_members!inner(user_id)
          ''')
          .eq('is_active', true)
          .eq('group_members.is_active', true);

      final groups = groupsResponse as List;
      final rankings = <Map<String, dynamic>>[];

      for (final group in groups) {
        final groupId = group['id'] as String;
        final groupName = group['name'] as String;
        final members = group['group_members'] as List;
        
        // Get member scores for the period
        final memberScoresResult = await getGroupMemberScores(groupId, request);
        final memberScores = memberScoresResult.fold(
          (failure) => <UserWorkoutScore>[],
          (scores) => scores,
        );

        if (memberScores.isEmpty) continue;

        // Calculate group statistics
        final totalScore = memberScores.fold<double>(0, (sum, score) => sum + score.totalScore).round();
        final averageScore = memberScores.isNotEmpty ? totalScore / memberScores.length : 0.0;
        
        // Calculate score breakdown
        final scoreBreakdown = {
          'balance': memberScores.fold<double>(0, (sum, score) => sum + score.bodyBalanceScore) / memberScores.length,
          'volume': memberScores.fold<double>(0, (sum, score) => sum + score.volumeScore) / memberScores.length,
          'progress': memberScores.fold<double>(0, (sum, score) => sum + score.progressScore) / memberScores.length,
          'consistency': memberScores.fold<double>(0, (sum, score) => sum + score.consistencyScore) / memberScores.length,
        };

        rankings.add({
          'group_id': groupId,
          'group_name': groupName,
          'total_score': totalScore,
          'member_count': members.length,
          'average_score': averageScore,
          'score_breakdown': scoreBreakdown,
        });
      }

      // Sort by total score and assign rankings
      rankings.sort((a, b) => (b['total_score'] as int).compareTo(a['total_score'] as int));

      // Get previous rankings for comparison
      final previousRankings = await _getPreviousRankings(request);

      final now = DateTime.now();
      final rankingRecords = <Map<String, dynamic>>[];

      for (int i = 0; i < rankings.length; i++) {
        final ranking = rankings[i];
        final groupId = ranking['group_id'] as String;
        final previousRank = previousRankings[groupId] ?? 0;

        rankingRecords.add({
          'id': _uuid.v4(),
          'group_id': groupId,
          'ranking_period': _rankingPeriodToString(request.period),
          'period_start_date': periodDates['start']!.toIso8601String().split('T')[0],
          'period_end_date': periodDates['end']!.toIso8601String().split('T')[0],
          'total_score': ranking['total_score'],
          'member_count': ranking['member_count'],
          'average_score': ranking['average_score'],
          'rank_position': i + 1,
          'previous_rank': previousRank,
          'score_breakdown': ranking['score_breakdown'],
          'calculated_at': now.toIso8601String(),
        });
      }

      // Delete existing rankings for this period and insert new ones
      await _supabaseClient
          .from('group_rankings')
          .delete()
          .eq('ranking_period', _rankingPeriodToString(request.period))
          .eq('period_start_date', periodDates['start']!.toIso8601String().split('T')[0])
          .eq('period_end_date', periodDates['end']!.toIso8601String().split('T')[0]);

      if (rankingRecords.isNotEmpty) {
        await _supabaseClient
            .from('group_rankings')
            .insert(rankingRecords);
      }
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getScoreBreakdown(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return safeCall(() async {
      final scores = await getUserScores(
        userId,
        period: RankingPeriodRequest(
          period: RankingPeriod.daily,
          startDate: startDate,
          endDate: endDate,
        ),
      );

      final userScores = scores.fold(
        (failure) => <UserWorkoutScore>[],
        (scores) => scores,
      );

      if (userScores.isEmpty) {
        return {
          'total_score': 0.0,
          'body_balance_score': 0.0,
          'volume_score': 0.0,
          'progress_score': 0.0,
          'consistency_score': 0.0,
          'body_part_scores': <String, double>{},
          'score_trend': <Map<String, dynamic>>[],
        };
      }

      final avgTotalScore = userScores.fold<double>(0, (sum, score) => sum + score.totalScore) / userScores.length;
      final avgBalanceScore = userScores.fold<double>(0, (sum, score) => sum + score.bodyBalanceScore) / userScores.length;
      final avgVolumeScore = userScores.fold<double>(0, (sum, score) => sum + score.volumeScore) / userScores.length;
      final avgProgressScore = userScores.fold<double>(0, (sum, score) => sum + score.progressScore) / userScores.length;
      final avgConsistencyScore = userScores.fold<double>(0, (sum, score) => sum + score.consistencyScore) / userScores.length;

      // Calculate average body part scores
      final bodyPartTotals = <BodyPart, double>{};
      for (final score in userScores) {
        for (final entry in score.bodyPartScores.entries) {
          bodyPartTotals[entry.key] = (bodyPartTotals[entry.key] ?? 0) + entry.value;
        }
      }
      
      final avgBodyPartScores = <String, double>{};
      for (final entry in bodyPartTotals.entries) {
        avgBodyPartScores[entry.key.name] = entry.value / userScores.length;
      }

      // Create score trend
      final scoreTrend = userScores.map((score) => {
        'date': score.scoreDate.toIso8601String().split('T')[0],
        'total_score': score.totalScore,
        'balance_score': score.bodyBalanceScore,
        'volume_score': score.volumeScore,
        'progress_score': score.progressScore,
        'consistency_score': score.consistencyScore,
      }).toList();

      return {
        'total_score': avgTotalScore,
        'body_balance_score': avgBalanceScore,
        'volume_score': avgVolumeScore,
        'progress_score': avgProgressScore,
        'consistency_score': avgConsistencyScore,
        'body_part_scores': avgBodyPartScores,
        'score_trend': scoreTrend,
        'score_count': userScores.length,
      };
    });
  }

  @override
  Future<Either<Failure, double>> calculateBodyBalanceScore(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return safeCall(() async {
      // Get workout sessions in the period
      final sessionsResponse = await _supabaseClient
          .from('workout_sessions')
          .select('''
            id,
            workout_logs!inner(
              exercise_id,
              weight,
              reps,
              set_number,
              exercises!inner(
                body_part_mappings(
                  primary_body_part,
                  intensity_multiplier
                )
              )
            )
          ''')
          .eq('user_id', userId)
          .gte('session_date', startDate.toIso8601String().split('T')[0])
          .lte('session_date', endDate.toIso8601String().split('T')[0])
          .eq('is_completed', true);

      final sessions = sessionsResponse as List;
      if (sessions.isEmpty) return 0.0;

      // Calculate volume per body part
      final bodyPartVolumes = <String, double>{};
      
      for (final session in sessions) {
        final logs = session['workout_logs'] as List;
        
        for (final log in logs) {
          final exercise = log['exercises'] as Map<String, dynamic>;
          final bodyPartMappings = exercise['body_part_mappings'] as List?;
          
          if (bodyPartMappings != null && bodyPartMappings.isNotEmpty) {
            final mapping = bodyPartMappings.first as Map<String, dynamic>;
            final bodyPart = mapping['primary_body_part'] as String;
            final intensityMultiplier = (mapping['intensity_multiplier'] as num?)?.toDouble() ?? 1.0;
            
            final weight = (log['weight'] as num?)?.toDouble() ?? 0.0;
            final reps = (log['reps'] as int?) ?? 0;
            final volume = weight * reps * intensityMultiplier;
            
            bodyPartVolumes[bodyPart] = (bodyPartVolumes[bodyPart] ?? 0) + volume;
          }
        }
      }

      if (bodyPartVolumes.isEmpty) return 0.0;

      // Calculate balance score based on standard deviation
      final volumes = bodyPartVolumes.values.toList();
      final mean = volumes.reduce((a, b) => a + b) / volumes.length;
      final variance = volumes.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / volumes.length;
      final standardDeviation = sqrt(variance);
      
      // Convert to score (lower standard deviation = higher balance score)
      final maxStdDev = mean; // Assume max std dev is equal to mean
      final balanceScore = max(0, 100 - (standardDeviation / maxStdDev * 100));
      
      return balanceScore.toDouble();
    });
  }

  @override
  Future<Either<Failure, double>> calculateVolumeScore(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return safeCall(() async {
      // Get total volume for the period
      final sessionsResponse = await _supabaseClient
          .from('workout_sessions')
          .select('''
            workout_logs!inner(
              weight,
              reps
            )
          ''')
          .eq('user_id', userId)
          .gte('session_date', startDate.toIso8601String().split('T')[0])
          .lte('session_date', endDate.toIso8601String().split('T')[0])
          .eq('is_completed', true);

      final sessions = sessionsResponse as List;
      if (sessions.isEmpty) return 0.0;

      double totalVolume = 0.0;
      for (final session in sessions) {
        final logs = session['workout_logs'] as List;
        for (final log in logs) {
          final weight = (log['weight'] as num?)?.toDouble() ?? 0.0;
          final reps = (log['reps'] as int?) ?? 0;
          totalVolume += weight * reps;
        }
      }

      // Convert volume to score (normalize based on typical ranges)
      // This is a simplified scoring - in practice, you'd want to consider user's history and goals
      final volumeScore = min(100, (totalVolume / 10000) * 100); // Assuming 10,000 as a good weekly volume
      
      return volumeScore.toDouble();
    });
  }

  @override
  Future<Either<Failure, double>> calculateProgressScore(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return safeCall(() async {
      // Compare current period with previous period
      final periodDuration = endDate.difference(startDate);
      final previousStartDate = startDate.subtract(periodDuration);
      
      final currentVolumeResult = await calculateVolumeScore(userId, startDate, endDate);
      final previousVolumeResult = await calculateVolumeScore(userId, previousStartDate, startDate);
      
      final currentVolume = currentVolumeResult.fold((failure) => 0.0, (score) => score);
      final previousVolume = previousVolumeResult.fold((failure) => 0.0, (score) => score);
      
      if (previousVolume == 0) return currentVolume > 0 ? 50.0 : 0.0;
      
      final improvement = ((currentVolume - previousVolume) / previousVolume) * 100;
      final progressScore = max(0, min(100, 50 + improvement)); // 50 is baseline, improvement adds to it
      
      return progressScore.toDouble();
    });
  }

  @override
  Future<Either<Failure, double>> calculateConsistencyScore(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return safeCall(() async {
      // Count workout days in the period
      final sessionsResponse = await _supabaseClient
          .from('workout_sessions')
          .select('session_date')
          .eq('user_id', userId)
          .gte('session_date', startDate.toIso8601String().split('T')[0])
          .lte('session_date', endDate.toIso8601String().split('T')[0])
          .eq('is_completed', true);

      final sessions = sessionsResponse as List;
      final uniqueDates = sessions.map((s) => s['session_date']).toSet();
      
      final totalDays = endDate.difference(startDate).inDays;
      final workoutDays = uniqueDates.length;
      
      // Calculate consistency as percentage of days worked out
      // Assuming 3-4 days per week is optimal (about 50% of days)
      final optimalFrequency = totalDays * 0.5;
      final consistencyScore = min(100, (workoutDays / optimalFrequency) * 100);
      
      return consistencyScore.toDouble();
    });
  }

  @override
  Future<Either<Failure, Map<BodyPart, double>>> getBodyPartDistribution(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return safeCall(() async {
      // This is similar to calculateBodyBalanceScore but returns the actual distribution
      final sessionsResponse = await _supabaseClient
          .from('workout_sessions')
          .select('''
            workout_logs!inner(
              exercise_id,
              weight,
              reps,
              exercises!inner(
                body_part_mappings(
                  primary_body_part,
                  intensity_multiplier
                )
              )
            )
          ''')
          .eq('user_id', userId)
          .gte('session_date', startDate.toIso8601String().split('T')[0])
          .lte('session_date', endDate.toIso8601String().split('T')[0])
          .eq('is_completed', true);

      final sessions = sessionsResponse as List;
      final bodyPartVolumes = <BodyPart, double>{};
      
      for (final session in sessions) {
        final logs = session['workout_logs'] as List;
        
        for (final log in logs) {
          final exercise = log['exercises'] as Map<String, dynamic>;
          final bodyPartMappings = exercise['body_part_mappings'] as List?;
          
          if (bodyPartMappings != null && bodyPartMappings.isNotEmpty) {
            final mapping = bodyPartMappings.first as Map<String, dynamic>;
            final bodyPartString = mapping['primary_body_part'] as String;
            final bodyPart = _parseBodyPart(bodyPartString);
            
            if (bodyPart != null) {
              final intensityMultiplier = (mapping['intensity_multiplier'] as num?)?.toDouble() ?? 1.0;
              final weight = (log['weight'] as num?)?.toDouble() ?? 0.0;
              final reps = (log['reps'] as int?) ?? 0;
              final volume = weight * reps * intensityMultiplier;
              
              bodyPartVolumes[bodyPart] = (bodyPartVolumes[bodyPart] ?? 0) + volume;
            }
          }
        }
      }

      // Convert volumes to scores (normalize to 0-100 range)
      if (bodyPartVolumes.isEmpty) return <BodyPart, double>{};
      
      final maxVolume = bodyPartVolumes.values.reduce(max);
      if (maxVolume == 0) return bodyPartVolumes;
      
      final normalizedScores = <BodyPart, double>{};
      for (final entry in bodyPartVolumes.entries) {
        normalizedScores[entry.key] = (entry.value / maxVolume) * 100;
      }
      
      return normalizedScores;
    });
  }

  // Additional implementation methods would continue here...
  // For brevity, I'll implement the key remaining methods

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserGroupRankings(
    String userId,
    RankingPeriodRequest request,
  ) async {
    return safeCall(() async {
      // Get user's groups
      final userGroupsResponse = await _supabaseClient
          .from('group_members')
          .select('group_id, workout_groups!inner(name)')
          .eq('user_id', userId)
          .eq('is_active', true);

      final userGroups = userGroupsResponse as List;
      final rankings = <Map<String, dynamic>>[];

      for (final group in userGroups) {
        final groupId = group['group_id'] as String;
        final groupName = group['workout_groups']['name'] as String;

        // Get user's scores in this group
        final userScoresResult = await getUserScores(
          userId,
          groupId: groupId,
          period: request,
        );

        final userScores = userScoresResult.fold(
          (failure) => <UserWorkoutScore>[],
          (scores) => scores,
        );

        if (userScores.isEmpty) continue;

        final avgScore = userScores.fold<double>(0, (sum, score) => sum + score.totalScore) / userScores.length;

        // Get all member scores for ranking
        final allMemberScoresResult = await getGroupMemberScores(groupId, request);
        final allMemberScores = allMemberScoresResult.fold(
          (failure) => <UserWorkoutScore>[],
          (scores) => scores,
        );

        // Calculate user's rank
        final userRank = allMemberScores
            .where((score) => score.totalScore > avgScore)
            .length + 1;

        rankings.add({
          'group_id': groupId,
          'group_name': groupName,
          'user_score': avgScore,
          'user_rank': userRank,
          'total_members': allMemberScores.length,
        });
      }

      return rankings;
    });
  }

  @override
  Future<Either<Failure, WorkoutScoreCalculation>> createScoreCalculation(
    String userId,
    String sessionId,
    Map<BodyPart, int> bodyPartVolumes,
    double totalVolume,
    int exerciseVariety,
    int sessionDurationMinutes,
  ) async {
    return safeCall(() async {
      final calculationId = _uuid.v4();
      final now = DateTime.now();

      final calculationData = {
        'id': calculationId,
        'user_id': userId,
        'session_id': sessionId,
        'body_part_volumes': _bodyPartVolumesToJson(bodyPartVolumes),
        'total_volume': totalVolume,
        'exercise_variety': exerciseVariety,
        'session_duration_minutes': sessionDurationMinutes,
        'calculated_at': now.toIso8601String(),
      };

      await _supabaseClient
          .from('workout_score_calculations')
          .insert(calculationData);

      // Return the created calculation (you'd need to implement WorkoutScoreCalculationModel)
      // For now, returning a basic implementation
      return WorkoutScoreCalculation(
        id: calculationId,
        userId: userId,
        sessionId: sessionId,
        bodyPartVolume: bodyPartVolumes,
        totalVolume: totalVolume,
        exerciseVariety: exerciseVariety,
        sessionDuration: sessionDurationMinutes.toDouble(),
        calculatedAt: now,
      );
    });
  }

  // Implement remaining abstract methods with basic implementations
  @override
  Future<Either<Failure, List<WorkoutScoreCalculation>>> getScoreCalculations(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    return safeCall(() async {
      // Basic implementation - would need full WorkoutScoreCalculationModel
      return <WorkoutScoreCalculation>[];
    });
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getGroupTopPerformers(
    String groupId,
    RankingPeriodRequest request, {
    int limit = 10,
  }) async {
    return safeCall(() async {
      final memberScoresResult = await getGroupMemberScores(groupId, request, limit: limit);
      final memberScores = memberScoresResult.fold(
        (failure) => <UserWorkoutScore>[],
        (scores) => scores,
      );

      return memberScores.map((score) => {
        'user_id': score.userId,
        'total_score': score.totalScore,
        'rank': memberScores.indexOf(score) + 1,
      }).toList();
    });
  }

  // Helper methods
  Future<Map<String, int>> _getPreviousRankings(RankingPeriodRequest request) async {
    // Get previous period rankings for comparison
    final previousPeriodDates = _getPreviousPeriodDates(request);
    
    final response = await _supabaseClient
        .from('group_rankings')
        .select('group_id, rank_position')
        .eq('ranking_period', _rankingPeriodToString(request.period))
        .eq('period_start_date', previousPeriodDates['start']!.toIso8601String().split('T')[0])
        .eq('period_end_date', previousPeriodDates['end']!.toIso8601String().split('T')[0]);

    final rankings = <String, int>{};
    for (final ranking in response as List) {
      rankings[ranking['group_id'] as String] = ranking['rank_position'] as int;
    }
    
    return rankings;
  }

  Map<String, DateTime> _getPreviousPeriodDates(RankingPeriodRequest request) {
    final currentDates = request.periodDates;
    final duration = currentDates['end']!.difference(currentDates['start']!);
    
    return {
      'start': currentDates['start']!.subtract(duration),
      'end': currentDates['start']!,
    };
  }

  String _rankingPeriodToString(RankingPeriod period) {
    switch (period) {
      case RankingPeriod.daily:
        return 'daily';
      case RankingPeriod.weekly:
        return 'weekly';
      case RankingPeriod.monthly:
        return 'monthly';
    }
  }

  BodyPart? _parseBodyPart(String value) {
    switch (value) {
      case 'chest':
        return BodyPart.chest;
      case 'back':
        return BodyPart.back;
      case 'legs':
        return BodyPart.legs;
      case 'shoulders':
        return BodyPart.shoulders;
      case 'arms':
        return BodyPart.arms;
      case 'core':
        return BodyPart.core;
      default:
        return null;
    }
  }

  Map<String, double> _bodyPartScoresToJson(Map<BodyPart, double> scores) {
    return scores.map((bodyPart, score) => MapEntry(bodyPart.name, score));
  }

  Map<String, int> _bodyPartVolumesToJson(Map<BodyPart, int> volumes) {
    return volumes.map((bodyPart, volume) => MapEntry(bodyPart.name, volume));
  }

  // Stub implementations for remaining abstract methods
  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getGroupRankingTrends(String groupId, {RankingPeriod period = RankingPeriod.weekly, int periodCount = 12}) async {
    return safeCall(() async => <Map<String, dynamic>>[]);
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserScoreTrends(String userId, {String? groupId, RankingPeriod period = RankingPeriod.weekly, int periodCount = 12}) async {
    return safeCall(() async => <Map<String, dynamic>>[]);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> compareUsers(String userId1, String userId2, DateTime startDate, DateTime endDate) async {
    return safeCall(() async => <String, dynamic>{});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getGroupPerformanceStats(String groupId, RankingPeriodRequest request) async {
    return safeCall(() async => <String, dynamic>{});
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getBodyPartLeaderboard(BodyPart bodyPart, RankingPeriodRequest request, {String? groupId, int limit = 20}) async {
    return safeCall(() async => <Map<String, dynamic>>[]);
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getRankingAchievements(RankingPeriodRequest request, {String? groupId}) async {
    return safeCall(() async => <Map<String, dynamic>>[]);
  }

  @override
  Future<Either<Failure, void>> recalculateAllScores(RankingPeriodRequest request, {String? groupId}) async {
    return safeCall(() async {});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRankingConfiguration() async {
    return safeCall(() async => <String, dynamic>{});
  }

  @override
  Future<Either<Failure, void>> updateRankingConfiguration(Map<String, dynamic> configuration) async {
    return safeCall(() async {});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getWorkoutAnalysis(String userId, DateTime startDate, DateTime endDate) async {
    return safeCall(() async => <String, dynamic>{});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getGroupCompetitionStatus(List<String> groupIds, RankingPeriodRequest request) async {
    return safeCall(() async => <String, dynamic>{});
  }
}