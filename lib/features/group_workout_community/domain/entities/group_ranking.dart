import 'package:equatable/equatable.dart';

/// 랭킹 기간 열거형
enum RankingPeriod {
  daily,
  weekly,
  monthly,
}

/// 그룹 랭킹 도메인 엔티티
class GroupRanking extends Equatable {
  final String id;
  final String groupId;
  final String groupName;
  final RankingPeriod rankingPeriod;
  final DateTime periodStartDate;
  final DateTime periodEndDate;
  final int totalScore;
  final int memberCount;
  final double averageScore;
  final int rankPosition;
  final int previousRank;
  final Map<String, double> scoreBreakdown; // 세부 점수 분석
  final DateTime calculatedAt;

  const GroupRanking({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.rankingPeriod,
    required this.periodStartDate,
    required this.periodEndDate,
    required this.totalScore,
    required this.memberCount,
    required this.averageScore,
    required this.rankPosition,
    required this.previousRank,
    required this.scoreBreakdown,
    required this.calculatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        groupId,
        groupName,
        rankingPeriod,
        periodStartDate,
        periodEndDate,
        totalScore,
        memberCount,
        averageScore,
        rankPosition,
        previousRank,
        scoreBreakdown,
        calculatedAt,
      ];

  GroupRanking copyWith({
    String? id,
    String? groupId,
    String? groupName,
    RankingPeriod? rankingPeriod,
    DateTime? periodStartDate,
    DateTime? periodEndDate,
    int? totalScore,
    int? memberCount,
    double? averageScore,
    int? rankPosition,
    int? previousRank,
    Map<String, double>? scoreBreakdown,
    DateTime? calculatedAt,
  }) {
    return GroupRanking(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      rankingPeriod: rankingPeriod ?? this.rankingPeriod,
      periodStartDate: periodStartDate ?? this.periodStartDate,
      periodEndDate: periodEndDate ?? this.periodEndDate,
      totalScore: totalScore ?? this.totalScore,
      memberCount: memberCount ?? this.memberCount,
      averageScore: averageScore ?? this.averageScore,
      rankPosition: rankPosition ?? this.rankPosition,
      previousRank: previousRank ?? this.previousRank,
      scoreBreakdown: scoreBreakdown ?? this.scoreBreakdown,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  /// 랭킹이 상승했는지 확인
  bool get rankImproved => previousRank > rankPosition && previousRank > 0;

  /// 랭킹이 하락했는지 확인
  bool get rankDeclined => previousRank < rankPosition && previousRank > 0;

  /// 랭킹이 유지되었는지 확인
  bool get rankMaintained => previousRank == rankPosition && previousRank > 0;

  /// 신규 랭킹인지 확인
  bool get isNewRanking => previousRank == 0;

  /// 랭킹 변화량
  int get rankChange => previousRank > 0 ? previousRank - rankPosition : 0;

  /// 상위 랭킹인지 확인 (10위 이내)
  bool get isTopRanking => rankPosition <= 10;

  /// 특정 점수 카테고리의 점수 가져오기
  double getScoreBreakdown(String category) => scoreBreakdown[category] ?? 0.0;

  /// 볼륨 점수
  double get volumeScore => getScoreBreakdown('volume');

  /// 균형 점수
  double get balanceScore => getScoreBreakdown('balance');

  /// 변화량 점수
  double get progressScore => getScoreBreakdown('progress');

  /// 일관성 점수
  double get consistencyScore => getScoreBreakdown('consistency');

  /// 그룹의 강점 분야 (가장 높은 점수 카테고리)
  String? get strongestCategory {
    if (scoreBreakdown.isEmpty) return null;
    return scoreBreakdown.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// 그룹의 약점 분야 (가장 낮은 점수 카테고리)
  String? get weakestCategory {
    if (scoreBreakdown.isEmpty) return null;
    return scoreBreakdown.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;
  }

  /// 랭킹 기간이 현재 기간인지 확인
  bool get isCurrentPeriod {
    final now = DateTime.now();
    return now.isAfter(periodStartDate) && now.isBefore(periodEndDate);
  }

  /// 랭킹 기간 문자열
  String get periodString {
    switch (rankingPeriod) {
      case RankingPeriod.daily:
        return '일간';
      case RankingPeriod.weekly:
        return '주간';
      case RankingPeriod.monthly:
        return '월간';
    }
  }

  /// 랭킹 변화 상태 문자열
  String get rankChangeStatus {
    if (isNewRanking) return '신규';
    if (rankImproved) return '상승 ${rankChange}';
    if (rankDeclined) return '하락 ${rankChange.abs()}';
    return '유지';
  }

  /// 그룹 성과 요약
  Map<String, dynamic> get performanceSummary => {
    'rank': rankPosition,
    'previousRank': previousRank,
    'rankChange': rankChange,
    'rankChangeStatus': rankChangeStatus,
    'totalScore': totalScore,
    'averageScore': averageScore,
    'memberCount': memberCount,
    'strongestCategory': strongestCategory,
    'weakestCategory': weakestCategory,
    'isTopRanking': isTopRanking,
    'period': periodString,
  };
}