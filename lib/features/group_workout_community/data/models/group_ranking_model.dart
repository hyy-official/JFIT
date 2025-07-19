import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/group_ranking.dart';

part 'group_ranking_model.g.dart';

@JsonSerializable(explicitToJson: true)
class GroupRankingModel extends GroupRanking {
  const GroupRankingModel({
    required super.id,
    required super.groupId,
    required super.groupName,
    required super.rankingPeriod,
    required super.periodStartDate,
    required super.periodEndDate,
    required super.totalScore,
    required super.memberCount,
    required super.averageScore,
    required super.rankPosition,
    required super.previousRank,
    required super.scoreBreakdown,
    required super.calculatedAt,
  });

  factory GroupRankingModel.fromJson(Map<String, dynamic> json) {
    return GroupRankingModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      groupName: json['group_name'] as String? ?? '',
      rankingPeriod: _parseRankingPeriod(json['ranking_period'] as String?),
      periodStartDate: json['period_start_date'] != null
          ? DateTime.parse(json['period_start_date'] as String)
          : DateTime.now(),
      periodEndDate: json['period_end_date'] != null
          ? DateTime.parse(json['period_end_date'] as String)
          : DateTime.now(),
      totalScore: json['total_score'] as int? ?? 0,
      memberCount: json['member_count'] as int? ?? 0,
      averageScore: _parseDouble(json['average_score']) ?? 0.0,
      rankPosition: json['rank_position'] as int? ?? 0,
      previousRank: json['previous_rank'] as int? ?? 0,
      scoreBreakdown: _parseScoreBreakdown(json['score_breakdown']),
      calculatedAt: json['calculated_at'] != null
          ? DateTime.parse(json['calculated_at'] as String)
          : DateTime.now(),
    );
  }

  static RankingPeriod _parseRankingPeriod(String? value) {
    switch (value) {
      case 'daily':
        return RankingPeriod.daily;
      case 'monthly':
        return RankingPeriod.monthly;
      case 'weekly':
      default:
        return RankingPeriod.weekly;
    }
  }

  static String _rankingPeriodToString(RankingPeriod period) {
    switch (period) {
      case RankingPeriod.daily:
        return 'daily';
      case RankingPeriod.weekly:
        return 'weekly';
      case RankingPeriod.monthly:
        return 'monthly';
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static Map<String, double> _parseScoreBreakdown(dynamic value) {
    if (value == null) return {};
    if (value is! Map) return {};
    
    final Map<String, double> result = {};
    final map = value as Map<String, dynamic>;
    
    for (final entry in map.entries) {
      result[entry.key] = _parseDouble(entry.value);
    }
    
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'group_name': groupName,
      'ranking_period': _rankingPeriodToString(rankingPeriod),
      'period_start_date': periodStartDate.toIso8601String().split('T')[0], // Date only
      'period_end_date': periodEndDate.toIso8601String().split('T')[0], // Date only
      'total_score': totalScore,
      'member_count': memberCount,
      'average_score': averageScore,
      'rank_position': rankPosition,
      'previous_rank': previousRank,
      'score_breakdown': scoreBreakdown,
      'calculated_at': calculatedAt.toIso8601String(),
    };
  }

  GroupRanking toEntity() {
    return GroupRanking(
      id: id,
      groupId: groupId,
      groupName: groupName,
      rankingPeriod: rankingPeriod,
      periodStartDate: periodStartDate,
      periodEndDate: periodEndDate,
      totalScore: totalScore,
      memberCount: memberCount,
      averageScore: averageScore,
      rankPosition: rankPosition,
      previousRank: previousRank,
      scoreBreakdown: scoreBreakdown,
      calculatedAt: calculatedAt,
    );
  }

  factory GroupRankingModel.fromEntity(GroupRanking entity) {
    return GroupRankingModel(
      id: entity.id,
      groupId: entity.groupId,
      groupName: entity.groupName,
      rankingPeriod: entity.rankingPeriod,
      periodStartDate: entity.periodStartDate,
      periodEndDate: entity.periodEndDate,
      totalScore: entity.totalScore,
      memberCount: entity.memberCount,
      averageScore: entity.averageScore,
      rankPosition: entity.rankPosition,
      previousRank: entity.previousRank,
      scoreBreakdown: entity.scoreBreakdown,
      calculatedAt: entity.calculatedAt,
    );
  }
}