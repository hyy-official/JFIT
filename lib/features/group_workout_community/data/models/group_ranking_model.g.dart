// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_ranking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupRankingModel _$GroupRankingModelFromJson(Map<String, dynamic> json) =>
    GroupRankingModel(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      groupName: json['groupName'] as String,
      rankingPeriod: $enumDecode(_$RankingPeriodEnumMap, json['rankingPeriod']),
      periodStartDate: DateTime.parse(json['periodStartDate'] as String),
      periodEndDate: DateTime.parse(json['periodEndDate'] as String),
      totalScore: (json['totalScore'] as num).toInt(),
      memberCount: (json['memberCount'] as num).toInt(),
      averageScore: (json['averageScore'] as num).toDouble(),
      rankPosition: (json['rankPosition'] as num).toInt(),
      previousRank: (json['previousRank'] as num).toInt(),
      scoreBreakdown: (json['scoreBreakdown'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );

Map<String, dynamic> _$GroupRankingModelToJson(GroupRankingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'groupName': instance.groupName,
      'rankingPeriod': _$RankingPeriodEnumMap[instance.rankingPeriod]!,
      'periodStartDate': instance.periodStartDate.toIso8601String(),
      'periodEndDate': instance.periodEndDate.toIso8601String(),
      'totalScore': instance.totalScore,
      'memberCount': instance.memberCount,
      'averageScore': instance.averageScore,
      'rankPosition': instance.rankPosition,
      'previousRank': instance.previousRank,
      'scoreBreakdown': instance.scoreBreakdown,
      'calculatedAt': instance.calculatedAt.toIso8601String(),
    };

const _$RankingPeriodEnumMap = {
  RankingPeriod.daily: 'daily',
  RankingPeriod.weekly: 'weekly',
  RankingPeriod.monthly: 'monthly',
};
