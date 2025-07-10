import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/workout_program.dart';

part 'workout_program_model.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkoutProgramModel extends WorkoutProgram {
  const WorkoutProgramModel({
    required super.id,
    required super.name,
    required super.creator,
    required super.description,
    required super.durationWeeks,
    required super.difficultyLevel,
    required super.programType,
    super.workoutsPerWeek,
    super.equipmentNeeded,
    super.weeklySchedule,
    super.tags,
    required super.rating,
    required super.totalRatings,
    required super.isPopular,
    required super.isPublic,
    super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    required super.version,
    super.imageUrl,
    required super.isSample,
  });

  factory WorkoutProgramModel.fromJson(Map<String, dynamic> json) {
    return WorkoutProgramModel(
      id: json['id'] as String,
      name: json['name'] as String,
      creator: json['creator'] as String,
      description: json['description'] as String? ?? '',
      durationWeeks: json['duration_weeks'] as int? ?? 1,
      difficultyLevel: json['difficulty_level'] as String? ?? 'beginner',
      programType: json['program_type'] as String? ?? 'strength',
      workoutsPerWeek: json['workouts_per_week'] as int?,
      equipmentNeeded: json['equipment_needed'] != null
          ? (json['equipment_needed'] is List 
              ? List<String>.from(json['equipment_needed'] as List)
              : <String>[])
          : null,
      weeklySchedule: json['weekly_schedule'] != null
          ? (json['weekly_schedule'] is Map
              ? Map<String, dynamic>.from(json['weekly_schedule'] as Map)
              : null)
          : null,
      tags: json['tags'] != null
          ? (json['tags'] is List
              ? List<String>.from(json['tags'] as List)
              : <String>[])
          : null,
      rating: _parseDouble(json['rating']) ?? 0.0,
      totalRatings: json['total_ratings'] as int? ?? 0,
      isPopular: json['is_popular'] as bool? ?? false,
      isPublic: json['is_public'] as bool? ?? true,
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      version: json['version'] as int? ?? 1,
      imageUrl: json['image_url'] as String?,
      isSample: json['is_sample'] as bool? ?? false,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'creator': creator,
      'description': description,
      'duration_weeks': durationWeeks,
      'difficulty_level': difficultyLevel,
      'program_type': programType,
      'workouts_per_week': workoutsPerWeek,
      'equipment_needed': equipmentNeeded,
      'weekly_schedule': weeklySchedule,
      'tags': tags,
      'rating': rating,
      'total_ratings': totalRatings,
      'is_popular': isPopular,
      'is_public': isPublic,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'version': version,
      'image_url': imageUrl,
      'is_sample': isSample,
    };
  }

  WorkoutProgram toEntity() {
    return WorkoutProgram(
      id: id,
      name: name,
      creator: creator,
      description: description,
      durationWeeks: durationWeeks,
      difficultyLevel: difficultyLevel,
      programType: programType,
      workoutsPerWeek: workoutsPerWeek,
      equipmentNeeded: equipmentNeeded,
      weeklySchedule: weeklySchedule,
      tags: tags,
      rating: rating,
      totalRatings: totalRatings,
      isPopular: isPopular,
      isPublic: isPublic,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      version: version,
      imageUrl: imageUrl,
      isSample: isSample,
    );
  }

  factory WorkoutProgramModel.fromEntity(WorkoutProgram entity) {
    return WorkoutProgramModel(
      id: entity.id,
      name: entity.name,
      creator: entity.creator,
      description: entity.description,
      durationWeeks: entity.durationWeeks,
      difficultyLevel: entity.difficultyLevel,
      programType: entity.programType,
      workoutsPerWeek: entity.workoutsPerWeek,
      equipmentNeeded: entity.equipmentNeeded,
      weeklySchedule: entity.weeklySchedule,
      tags: entity.tags,
      rating: entity.rating,
      totalRatings: entity.totalRatings,
      isPopular: entity.isPopular,
      isPublic: entity.isPublic,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      version: entity.version,
      imageUrl: entity.imageUrl,
      isSample: entity.isSample,
    );
  }
} 