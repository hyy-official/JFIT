import 'package:equatable/equatable.dart';

/// 신체 부위 열거형
enum BodyPart {
  chest,
  back,
  legs,
  shoulders,
  arms,
  core,
}

/// BodyPart 확장 메서드
extension BodyPartExtension on BodyPart {
  /// 표시용 이름 (한국어)
  String get displayName {
    switch (this) {
      case BodyPart.chest:
        return '가슴';
      case BodyPart.back:
        return '등';
      case BodyPart.legs:
        return '다리';
      case BodyPart.shoulders:
        return '어깨';
      case BodyPart.arms:
        return '팔';
      case BodyPart.core:
        return '코어';
    }
  }

  /// 영어 이름
  String get englishName {
    switch (this) {
      case BodyPart.chest:
        return 'Chest';
      case BodyPart.back:
        return 'Back';
      case BodyPart.legs:
        return 'Legs';
      case BodyPart.shoulders:
        return 'Shoulders';
      case BodyPart.arms:
        return 'Arms';
      case BodyPart.core:
        return 'Core';
    }
  }
}

/// 운동별 신체 부위 매핑 도메인 엔티티
class BodyPartMapping extends Equatable {
  final String id;
  final String exerciseId;
  final BodyPart primaryBodyPart;
  final List<BodyPart> secondaryBodyParts;
  final double intensityMultiplier; // 운동 강도 배수
  final DateTime createdAt;

  const BodyPartMapping({
    required this.id,
    required this.exerciseId,
    required this.primaryBodyPart,
    required this.secondaryBodyParts,
    required this.intensityMultiplier,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        exerciseId,
        primaryBodyPart,
        secondaryBodyParts,
        intensityMultiplier,
        createdAt,
      ];

  BodyPartMapping copyWith({
    String? id,
    String? exerciseId,
    BodyPart? primaryBodyPart,
    List<BodyPart>? secondaryBodyParts,
    double? intensityMultiplier,
    DateTime? createdAt,
  }) {
    return BodyPartMapping(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      primaryBodyPart: primaryBodyPart ?? this.primaryBodyPart,
      secondaryBodyParts: secondaryBodyParts ?? this.secondaryBodyParts,
      intensityMultiplier: intensityMultiplier ?? this.intensityMultiplier,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 모든 관련 신체 부위 (주요 + 보조)
  List<BodyPart> get allBodyParts => [primaryBodyPart, ...secondaryBodyParts];

  /// 보조 근육이 있는지 확인
  bool get hasSecondaryMuscles => secondaryBodyParts.isNotEmpty;

  /// 특정 신체 부위가 포함되어 있는지 확인
  bool includesBodyPart(BodyPart bodyPart) => allBodyParts.contains(bodyPart);

  /// 복합 운동인지 확인 (2개 이상의 신체 부위 사용)
  bool get isCompoundExercise => allBodyParts.length >= 2;
}

/// 신체 부위별 가중치 상수
class BodyPartWeights {
  static const Map<BodyPart, double> weights = {
    BodyPart.chest: 1.0,
    BodyPart.back: 1.0,
    BodyPart.legs: 1.2, // 하체는 더 큰 근육군이므로 가중치 높음
    BodyPart.shoulders: 0.8,
    BodyPart.arms: 0.7,
    BodyPart.core: 0.9,
  };

  /// 특정 신체 부위의 가중치 가져오기
  static double getWeight(BodyPart bodyPart) => weights[bodyPart] ?? 1.0;

  /// 모든 신체 부위의 평균 가중치
  static double get averageWeight => 
      weights.values.reduce((a, b) => a + b) / weights.length;
}

/// 점수 계산 공식 상수
class ScoreCalculationConstants {
  // 볼륨 점수 계산 상수
  static const double volumeBaseMultiplier = 0.1;
  static const double volumeMaxScore = 100.0;

  // 균형 점수 계산 상수
  static const double balanceMaxScore = 100.0;
  static const double balanceThreshold = 0.8; // 80% 이상이면 균형 잡힌 것으로 간주

  // 변화량 점수 계산 상수
  static const double progressMaxScore = 100.0;
  static const double progressBaseMultiplier = 10.0;

  // 일관성 점수 계산 상수
  static const double consistencyMaxScore = 100.0;
  static const int consistencyDaysThreshold = 7; // 7일 기준

  // 전체 점수 가중치
  static const Map<String, double> scoreWeights = {
    'volume': 0.3,      // 볼륨 30%
    'balance': 0.25,    // 균형 25%
    'progress': 0.25,   // 변화량 25%
    'consistency': 0.2, // 일관성 20%
  };

  /// 가중 평균 점수 계산
  static double calculateWeightedScore({
    required double volumeScore,
    required double balanceScore,
    required double progressScore,
    required double consistencyScore,
  }) {
    return (volumeScore * scoreWeights['volume']!) +
           (balanceScore * scoreWeights['balance']!) +
           (progressScore * scoreWeights['progress']!) +
           (consistencyScore * scoreWeights['consistency']!);
  }
}