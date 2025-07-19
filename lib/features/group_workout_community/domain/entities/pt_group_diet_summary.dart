import 'package:equatable/equatable.dart';

/// PT 그룹 식단 요약 도메인 엔티티
class PTGroupDietSummary extends Equatable {
  final String id;
  final String groupId;
  final String memberId;
  final String memberName;
  final DateTime summaryDate;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final int mealCount;
  final double calorieGoal;
  final double proteinGoal;
  final List<String> mealPhotoUrls;
  final String? trainerNote;
  final DateTime lastMealTime;

  const PTGroupDietSummary({
    required this.id,
    required this.groupId,
    required this.memberId,
    required this.memberName,
    required this.summaryDate,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.mealCount,
    required this.calorieGoal,
    required this.proteinGoal,
    required this.mealPhotoUrls,
    this.trainerNote,
    required this.lastMealTime,
  });

  @override
  List<Object?> get props => [
        id,
        groupId,
        memberId,
        memberName,
        summaryDate,
        totalCalories,
        totalProtein,
        totalCarbs,
        totalFat,
        mealCount,
        calorieGoal,
        proteinGoal,
        mealPhotoUrls,
        trainerNote,
        lastMealTime,
      ];

  PTGroupDietSummary copyWith({
    String? id,
    String? groupId,
    String? memberId,
    String? memberName,
    DateTime? summaryDate,
    double? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
    int? mealCount,
    double? calorieGoal,
    double? proteinGoal,
    List<String>? mealPhotoUrls,
    String? trainerNote,
    DateTime? lastMealTime,
  }) {
    return PTGroupDietSummary(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      summaryDate: summaryDate ?? this.summaryDate,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      mealCount: mealCount ?? this.mealCount,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      mealPhotoUrls: mealPhotoUrls ?? this.mealPhotoUrls,
      trainerNote: trainerNote ?? this.trainerNote,
      lastMealTime: lastMealTime ?? this.lastMealTime,
    );
  }

  /// 칼로리 목표 달성률 (%)
  double get calorieAchievementRate {
    if (calorieGoal <= 0) return 0.0;
    return (totalCalories / calorieGoal) * 100;
  }

  /// 단백질 목표 달성률 (%)
  double get proteinAchievementRate {
    if (proteinGoal <= 0) return 0.0;
    return (totalProtein / proteinGoal) * 100;
  }

  /// 칼로리 목표를 달성했는지 확인
  bool get isCalorieGoalMet => calorieAchievementRate >= 90.0 && calorieAchievementRate <= 110.0;

  /// 단백질 목표를 달성했는지 확인
  bool get isProteinGoalMet => proteinAchievementRate >= 90.0;

  /// 칼로리가 과다한지 확인 (목표의 120% 초과)
  bool get isCalorieExcessive => calorieAchievementRate > 120.0;

  /// 칼로리가 부족한지 확인 (목표의 80% 미만)
  bool get isCalorieDeficient => calorieAchievementRate < 80.0;

  /// 식사 사진이 있는지 확인
  bool get hasMealPhotos => mealPhotoUrls.isNotEmpty;

  /// 트레이너 노트가 있는지 확인
  bool get hasTrainerNote => trainerNote != null && trainerNote!.isNotEmpty;

  /// 충분한 식사를 했는지 확인 (3끼 이상)
  bool get hasAdequateMeals => mealCount >= 3;

  /// 마지막 식사가 최근인지 확인 (6시간 이내)
  bool get isRecentMeal {
    final now = DateTime.now();
    final difference = now.difference(lastMealTime);
    return difference.inHours <= 6;
  }

  /// 탄수화물 비율 (%)
  double get carbsPercentage {
    final totalMacros = totalProtein + totalCarbs + totalFat;
    if (totalMacros <= 0) return 0.0;
    return (totalCarbs / totalMacros) * 100;
  }

  /// 단백질 비율 (%)
  double get proteinPercentage {
    final totalMacros = totalProtein + totalCarbs + totalFat;
    if (totalMacros <= 0) return 0.0;
    return (totalProtein / totalMacros) * 100;
  }

  /// 지방 비율 (%)
  double get fatPercentage {
    final totalMacros = totalProtein + totalCarbs + totalFat;
    if (totalMacros <= 0) return 0.0;
    return (totalFat / totalMacros) * 100;
  }

  /// 식단 상태 평가
  String get dietStatus {
    if (isCalorieGoalMet && isProteinGoalMet && hasAdequateMeals) {
      return '우수';
    } else if (isCalorieGoalMet || isProteinGoalMet) {
      return '양호';
    } else if (isCalorieDeficient || !hasAdequateMeals) {
      return '부족';
    } else if (isCalorieExcessive) {
      return '과다';
    } else {
      return '보통';
    }
  }

  /// 식단 요약 정보
  Map<String, dynamic> get dietSummary => {
    'memberName': memberName,
    'totalCalories': totalCalories,
    'calorieGoal': calorieGoal,
    'calorieAchievementRate': calorieAchievementRate,
    'proteinAchievementRate': proteinAchievementRate,
    'mealCount': mealCount,
    'dietStatus': dietStatus,
    'isCalorieGoalMet': isCalorieGoalMet,
    'isProteinGoalMet': isProteinGoalMet,
    'hasAdequateMeals': hasAdequateMeals,
    'hasMealPhotos': hasMealPhotos,
    'hasTrainerNote': hasTrainerNote,
    'macroBreakdown': {
      'carbs': carbsPercentage,
      'protein': proteinPercentage,
      'fat': fatPercentage,
    },
  };
}