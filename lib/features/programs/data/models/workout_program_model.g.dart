// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_program_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutProgramModel _$WorkoutProgramModelFromJson(Map<String, dynamic> json) =>
    WorkoutProgramModel(
      id: json['id'] as String,
      name: json['name'] as String,
      creator: json['creator'] as String,
      description: json['description'] as String,
      durationWeeks: (json['durationWeeks'] as num).toInt(),
      difficultyLevel: json['difficultyLevel'] as String,
      programType: json['programType'] as String,
      workoutsPerWeek: (json['workoutsPerWeek'] as num?)?.toInt(),
      equipmentNeeded: (json['equipmentNeeded'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      weeklySchedule: json['weeklySchedule'],
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      rating: (json['rating'] as num).toDouble(),
      totalRatings: (json['totalRatings'] as num).toInt(),
      isPopular: json['isPopular'] as bool,
      isPublic: json['isPublic'] as bool,
      createdBy: json['createdBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      version: (json['version'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
      isSample: json['isSample'] as bool,
    );

Map<String, dynamic> _$WorkoutProgramModelToJson(
  WorkoutProgramModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'creator': instance.creator,
  'description': instance.description,
  'durationWeeks': instance.durationWeeks,
  'difficultyLevel': instance.difficultyLevel,
  'programType': instance.programType,
  'workoutsPerWeek': instance.workoutsPerWeek,
  'equipmentNeeded': instance.equipmentNeeded,
  'weeklySchedule': instance.weeklySchedule,
  'tags': instance.tags,
  'rating': instance.rating,
  'totalRatings': instance.totalRatings,
  'isPopular': instance.isPopular,
  'isPublic': instance.isPublic,
  'createdBy': instance.createdBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'version': instance.version,
  'imageUrl': instance.imageUrl,
  'isSample': instance.isSample,
};
