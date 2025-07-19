import 'package:equatable/equatable.dart';
import 'body_part_mapping.dart';

/// 운동 점수 계산 도메인 엔티티
class WorkoutScoreCalculation extends Equatable {
  final String id;
  final String userId;
  final String sessionId;
  final Map<BodyPart, int> bodyPartVolume; // 부위별 볼륨 (sets * reps * weight)
  final double totalVolume;
  final int exerciseVariety; // 운동 다양성
  final double sessionDuration;
  final DateTime calculatedAt;

  const WorkoutScoreCalculation({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.bodyPartVolume,
    required this.totalVolume,
    required this.exerciseVariety,
    required this.sessionDuration,
    required this.calculatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        sessionId,
        bodyPartVolume,
        totalVolume,
        exerciseVariety,
        sessionDuration,
        calculatedAt,
      ];

  WorkoutScoreCalculation copyWith({
    String? id,
    String? userId,
    String? sessionId,
    Map<BodyPart, int>? bodyPartVolume,
    double? totalVolume,
    int? exerciseVariety,
    double? sessionDuration,
    DateTime? calculatedAt,
  }) {
    return WorkoutScoreCalculation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      bodyPartVolume: bodyPartVolume ?? this.bodyPartVolume,
      totalVolume: totalVolume ?? this.totalVolume,
      exerciseVariety: exerciseVariety ?? this.exerciseVariety,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  /// 특정 신체 부위의 볼륨 가져오기
  int getBodyPartVolume(BodyPart bodyPart) => bodyPartVolume[bodyPart] ?? 0;

  /// 가장 많이 운동한 신체 부위
  BodyPart? get mostWorkedBodyPart {
    if (bodyPartVolume.isEmpty) return null;
    return bodyPartVolume.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// 가장 적게 운동한 신체 부위
  BodyPart? get leastWorkedBodyPart {
    if (bodyPartVolume.isEmpty) return null;
    return bodyPartVolume.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;
  }

  /// 운동한 신체 부위 개수
  int get workedBodyPartsCount => 
      bodyPartVolume.values.where((volume) => volume > 0).length;

  /// 전신 운동인지 확인 (4개 이상의 신체 부위)
  bool get isFullBodyWorkout => workedBodyPartsCount >= 4;

  /// 볼륨 점수 계산
  double calculateVolumeScore() {
    final baseScore = totalVolume * ScoreCalculationConstants.volumeBaseMultiplier;
    return (baseScore > ScoreCalculationConstants.volumeMaxScore) 
        ? ScoreCalculationConstants.volumeMaxScore 
        : baseScore;
  }

  /// 균형 점수 계산
  double calculateBalanceScore() {
    if (bodyPartVolume.isEmpty) return 0.0;

    final volumes = bodyPartVolume.values.toList();
    final maxVolume = volumes.reduce((a, b) => a > b ? a : b);
    final minVolume = volumes.reduce((a, b) => a < b ? a : b);

    if (maxVolume == 0) return 0.0;

    final balanceRatio = minVolume / maxVolume;
    return balanceRatio * ScoreCalculationConstants.balanceMaxScore;
  }

  /// 다양성 점수 계산
  double calculateVarietyScore() {
    // 운동 다양성과 신체 부위 다양성을 고려
    final varietyScore = (exerciseVariety * 10.0) + (workedBodyPartsCount * 15.0);
    return varietyScore > 100.0 ? 100.0 : varietyScore;
  }

  /// 효율성 점수 계산 (시간 대비 볼륨)
  double calculateEfficiencyScore() {
    if (sessionDuration <= 0) return 0.0;
    
    final volumePerMinute = totalVolume / sessionDuration;
    final efficiencyScore = volumePerMinute * 2.0; // 분당 볼륨 * 2
    return efficiencyScore > 100.0 ? 100.0 : efficiencyScore;
  }

  /// 신체 부위별 볼륨 비율
  Map<BodyPart, double> get bodyPartVolumeRatios {
    if (totalVolume == 0) return {};
    
    return bodyPartVolume.map(
      (bodyPart, volume) => MapEntry(bodyPart, volume / totalVolume)
    );
  }

  /// 운동 세션 요약 정보
  Map<String, dynamic> get sessionSummary => {
    'totalVolume': totalVolume,
    'duration': sessionDuration,
    'exerciseVariety': exerciseVariety,
    'bodyPartsWorked': workedBodyPartsCount,
    'isFullBody': isFullBodyWorkout,
    'mostWorkedBodyPart': mostWorkedBodyPart?.name,
    'leastWorkedBodyPart': leastWorkedBodyPart?.name,
    'volumeScore': calculateVolumeScore(),
    'balanceScore': calculateBalanceScore(),
    'varietyScore': calculateVarietyScore(),
    'efficiencyScore': calculateEfficiencyScore(),
  };
}