// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_model.dart';

ExerciseModel _$ExerciseModelFromJson(Map<String, dynamic> json) => ExerciseModel(
      id: json['id'] as String,
      titleKo: json['title_ko'] as String,
      titleEn: json['title_en'] as String?,
      descKo: json['desc_ko'] as String?,
      descEn: json['desc_en'] as String?,
      difficulty: json['difficulty'] as String?,
      type: json['type'] as String?,
      equipment: json['equipment'] as String?,
      caloriesPerMinute: (json['calories_per_minute'] as num?)?.toDouble(),
      categoryKo: json['category_ko'] as String?,
      categoryEn: json['category_en'] as String?,
      recommendedSets: json['recommended_sets'] as String?,
      recommendedReps: json['recommended_reps'] as String?,
      imageUrl: json['image_url'] as String?,
    );

Map<String, dynamic> _$ExerciseModelToJson(ExerciseModel instance) => <String, dynamic>{
      'id': instance.id,
      'title_ko': instance.titleKo,
      'title_en': instance.titleEn,
      'desc_ko': instance.descKo,
      'desc_en': instance.descEn,
      'difficulty': instance.difficulty,
      'type': instance.type,
      'equipment': instance.equipment,
      'calories_per_minute': instance.caloriesPerMinute,
      'category_ko': instance.categoryKo,
      'category_en': instance.categoryEn,
      'recommended_sets': instance.recommendedSets,
      'recommended_reps': instance.recommendedReps,
      'image_url': instance.imageUrl,
    }; 