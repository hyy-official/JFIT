// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pt_group_diet_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PTGroupDietSummaryModel _$PTGroupDietSummaryModelFromJson(
        Map<String, dynamic> json) =>
    PTGroupDietSummaryModel(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String,
      summaryDate: DateTime.parse(json['summaryDate'] as String),
      totalCalories: (json['totalCalories'] as num).toDouble(),
      totalProtein: (json['totalProtein'] as num).toDouble(),
      totalCarbs: (json['totalCarbs'] as num).toDouble(),
      totalFat: (json['totalFat'] as num).toDouble(),
      mealCount: (json['mealCount'] as num).toInt(),
      calorieGoal: (json['calorieGoal'] as num).toDouble(),
      proteinGoal: (json['proteinGoal'] as num).toDouble(),
      mealPhotoUrls: (json['mealPhotoUrls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      trainerNote: json['trainerNote'] as String?,
      lastMealTime: DateTime.parse(json['lastMealTime'] as String),
    );

Map<String, dynamic> _$PTGroupDietSummaryModelToJson(
        PTGroupDietSummaryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'memberId': instance.memberId,
      'memberName': instance.memberName,
      'summaryDate': instance.summaryDate.toIso8601String(),
      'totalCalories': instance.totalCalories,
      'totalProtein': instance.totalProtein,
      'totalCarbs': instance.totalCarbs,
      'totalFat': instance.totalFat,
      'mealCount': instance.mealCount,
      'calorieGoal': instance.calorieGoal,
      'proteinGoal': instance.proteinGoal,
      'mealPhotoUrls': instance.mealPhotoUrls,
      'trainerNote': instance.trainerNote,
      'lastMealTime': instance.lastMealTime.toIso8601String(),
    };
