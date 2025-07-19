import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/pt_group_diet_summary.dart';

part 'pt_group_diet_summary_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PTGroupDietSummaryModel extends PTGroupDietSummary {
  const PTGroupDietSummaryModel({
    required super.id,
    required super.groupId,
    required super.memberId,
    required super.memberName,
    required super.summaryDate,
    required super.totalCalories,
    required super.totalProtein,
    required super.totalCarbs,
    required super.totalFat,
    required super.mealCount,
    required super.calorieGoal,
    required super.proteinGoal,
    required super.mealPhotoUrls,
    super.trainerNote,
    required super.lastMealTime,
  });

  factory PTGroupDietSummaryModel.fromJson(Map<String, dynamic> json) {
    return PTGroupDietSummaryModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      memberId: json['member_id'] as String,
      memberName: json['member_name'] as String,
      summaryDate: json['summary_date'] != null
          ? DateTime.parse(json['summary_date'] as String)
          : DateTime.now(),
      totalCalories: _parseDouble(json['total_calories']) ?? 0.0,
      totalProtein: _parseDouble(json['total_protein']) ?? 0.0,
      totalCarbs: _parseDouble(json['total_carbs']) ?? 0.0,
      totalFat: _parseDouble(json['total_fat']) ?? 0.0,
      mealCount: json['meal_count'] as int? ?? 0,
      calorieGoal: _parseDouble(json['calorie_goal']) ?? 0.0,
      proteinGoal: _parseDouble(json['protein_goal']) ?? 0.0,
      mealPhotoUrls: json['meal_photo_urls'] != null
          ? List<String>.from(json['meal_photo_urls'] as List)
          : <String>[],
      trainerNote: json['trainer_note'] as String?,
      lastMealTime: json['last_meal_time'] != null
          ? DateTime.parse(json['last_meal_time'] as String)
          : DateTime.now(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'member_id': memberId,
      'member_name': memberName,
      'summary_date': summaryDate.toIso8601String().split('T')[0], // Date only
      'total_calories': totalCalories,
      'total_protein': totalProtein,
      'total_carbs': totalCarbs,
      'total_fat': totalFat,
      'meal_count': mealCount,
      'calorie_goal': calorieGoal,
      'protein_goal': proteinGoal,
      'meal_photo_urls': mealPhotoUrls,
      'trainer_note': trainerNote,
      'last_meal_time': lastMealTime.toIso8601String(),
    };
  }

  PTGroupDietSummary toEntity() {
    return PTGroupDietSummary(
      id: id,
      groupId: groupId,
      memberId: memberId,
      memberName: memberName,
      summaryDate: summaryDate,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      mealCount: mealCount,
      calorieGoal: calorieGoal,
      proteinGoal: proteinGoal,
      mealPhotoUrls: mealPhotoUrls,
      trainerNote: trainerNote,
      lastMealTime: lastMealTime,
    );
  }

  factory PTGroupDietSummaryModel.fromEntity(PTGroupDietSummary entity) {
    return PTGroupDietSummaryModel(
      id: entity.id,
      groupId: entity.groupId,
      memberId: entity.memberId,
      memberName: entity.memberName,
      summaryDate: entity.summaryDate,
      totalCalories: entity.totalCalories,
      totalProtein: entity.totalProtein,
      totalCarbs: entity.totalCarbs,
      totalFat: entity.totalFat,
      mealCount: entity.mealCount,
      calorieGoal: entity.calorieGoal,
      proteinGoal: entity.proteinGoal,
      mealPhotoUrls: entity.mealPhotoUrls,
      trainerNote: entity.trainerNote,
      lastMealTime: entity.lastMealTime,
    );
  }
}