import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import 'body_part_mapping.dart';

/// 사용자 운동 점수 도메인 엔티티
class UserWorkoutScore extends Equatable {
  final String id;
  final String userId;
  final String groupId;
  final DateTime scoreDate;
  final double totalScore;
  final double bodyBalanceScore; // 전신 운동 균형 점수
  final double volumeScore; // 볼륨 점수
  final double progressScore; // 변화량 점수
  final double consistencyScore; // 일관성 점수
  final Map<BodyPart, double> bodyPartScores; // 부위별 점수
  final DateTime createdAt;

  const UserWorkoutScore({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.scoreDate,
    required this.totalScore,
    required this.bodyBalanceScore,
    required this.volumeScore,
    required this.progressScore,
    required this.consistencyScore,
    required this.bodyPartScores,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        groupId,
        scoreDate,
        totalScore,
        bodyBalanceScore,
        volumeScore,
        progressScore,
        consistencyScore,
        bodyPartScores,
        createdAt,
      ];

  UserWorkoutScore copyWith({
    String? id,
    String? userId,
    String? groupId,
    DateTime? scoreDate,
    double? totalScore,
    double? bodyBalanceScore,
    double? volumeScore,
    double? progressScore,
    double? consistencyScore,
    Map<BodyPart, double>? bodyPartScores,
    DateTime? createdAt,
  }) {
    return UserWorkoutScore(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      scoreDate: scoreDate ?? this.scoreDate,
      totalScore: totalScore ?? this.totalScore,
      bodyBalanceScore: bodyBalanceScore ?? this.bodyBalanceScore,
      volumeScore: volumeScore ?? this.volumeScore,
      progressScore: progressScore ?? this.progressScore,
      consistencyScore: consistencyScore ?? this.consistencyScore,
      bodyPartScores: bodyPartScores ?? this.bodyPartScores,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 특정 신체 부위의 점수 가져오기
  double getBodyPartScore(BodyPart bodyPart) => bodyPartScores[bodyPart] ?? 0.0;

  /// 가장 높은 점수를 받은 신체 부위
  BodyPart? get strongestBodyPart {
    if (bodyPartScores.isEmpty) return null;
    return bodyPartScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// 가장 낮은 점수를 받은 신체 부위
  BodyPart? get weakestBodyPart {
    if (bodyPartScores.isEmpty) return null;
    return bodyPartScores.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;
  }

  /// 신체 부위별 점수의 표준편차 (균형도 측정)
  double get bodyPartScoreStandardDeviation {
    if (bodyPartScores.isEmpty) return 0.0;
    
    final scores = bodyPartScores.values.toList();
    final mean = scores.reduce((a, b) => a + b) / scores.length;
    final variance = scores
        .map((score) => (score - mean) * (score - mean))
        .reduce((a, b) => a + b) / scores.length;
    
    return math.sqrt(variance);
  }

  /// 운동이 균형 잡혀 있는지 확인
  bool get isBalanced => 
      bodyBalanceScore >= ScoreCalculationConstants.balanceThreshold * 100;

  /// 점수가 우수한지 확인 (80점 이상)
  bool get isExcellent => totalScore >= 80.0;

  /// 점수가 양호한지 확인 (60점 이상)
  bool get isGood => totalScore >= 60.0;

  /// 점수 등급 가져오기
  String get scoreGrade {
    if (totalScore >= 90) return 'S';
    if (totalScore >= 80) return 'A';
    if (totalScore >= 70) return 'B';
    if (totalScore >= 60) return 'C';
    if (totalScore >= 50) return 'D';
    return 'F';
  }

  /// 개선이 필요한 신체 부위들 (평균보다 20% 이상 낮은 부위)
  List<BodyPart> get bodyPartsNeedingImprovement {
    if (bodyPartScores.isEmpty) return [];
    
    final averageScore = bodyPartScores.values
        .reduce((a, b) => a + b) / bodyPartScores.length;
    final threshold = averageScore * 0.8;
    
    return bodyPartScores.entries
        .where((entry) => entry.value < threshold)
        .map((entry) => entry.key)
        .toList();
  }

  /// 점수 요약 정보
  Map<String, dynamic> get scoreSummary => {
    'total': totalScore,
    'balance': bodyBalanceScore,
    'volume': volumeScore,
    'progress': progressScore,
    'consistency': consistencyScore,
    'grade': scoreGrade,
    'isBalanced': isBalanced,
    'strongestBodyPart': strongestBodyPart?.name,
    'weakestBodyPart': weakestBodyPart?.name,
    'improvementNeeded': bodyPartsNeedingImprovement.map((bp) => bp.name).toList(),
  };
}