// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseModel _$ExerciseModelFromJson(Map<String, dynamic> json) =>
    ExerciseModel(
      id: json['id'] as String,
      titleKo: json['titleKo'] as String,
      titleEn: json['titleEn'] as String?,
      descKo: json['descKo'] as String?,
      descEn: json['descEn'] as String?,
      difficulty: json['difficulty'] as String?,
      type: json['type'] as String?,
      equipment: json['equipment'] as String?,
      caloriesPerMinute: (json['caloriesPerMinute'] as num?)?.toDouble(),
      categoryKo: json['categoryKo'] as String?,
      categoryEn: json['categoryEn'] as String?,
      recommendedSets: json['recommendedSets'] as String?,
      recommendedReps: json['recommendedReps'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$ExerciseModelToJson(ExerciseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titleKo': instance.titleKo,
      'titleEn': instance.titleEn,
      'descKo': instance.descKo,
      'descEn': instance.descEn,
      'difficulty': instance.difficulty,
      'type': instance.type,
      'equipment': instance.equipment,
      'caloriesPerMinute': instance.caloriesPerMinute,
      'categoryKo': instance.categoryKo,
      'categoryEn': instance.categoryEn,
      'recommendedSets': instance.recommendedSets,
      'recommendedReps': instance.recommendedReps,
      'imageUrl': instance.imageUrl,
    };
