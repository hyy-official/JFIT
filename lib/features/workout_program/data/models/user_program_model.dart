import 'package:equatable/equatable.dart';
import 'package:jfit/features/programs/domain/entities/workout_program.dart';

/// Model representing a user's enrolled workout program
class UserProgramModel extends Equatable {
  final String id;
  final String userId;
  final String programId;
  final int currentWeek;
  final int currentDay;
  final bool isActive;
  final DateTime startedAt;
  final DateTime? completedAt;
  final dynamic exercisesJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Joined data from workout_programs table
  final WorkoutProgram? workoutProgram;

  const UserProgramModel({
    required this.id,
    required this.userId,
    required this.programId,
    required this.currentWeek,
    required this.currentDay,
    required this.isActive,
    required this.startedAt,
    this.completedAt,
    this.exercisesJson,
    required this.createdAt,
    required this.updatedAt,
    this.workoutProgram,
  });

  factory UserProgramModel.fromJson(Map<String, dynamic> json) {
    return UserProgramModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      programId: json['program_id'] as String,
      currentWeek: json['current_week'] as int? ?? 1,
      currentDay: json['current_day'] as int? ?? 1,
      isActive: json['is_active'] as bool? ?? true,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      exercisesJson: json['exercises_json'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      workoutProgram: json['workout_programs'] != null
          ? WorkoutProgram(
              id: json['workout_programs']['id'] as String,
              name: json['workout_programs']['name'] as String,
              creator: json['workout_programs']['creator'] as String? ?? '',
              description: json['workout_programs']['description'] as String? ?? '',
              durationWeeks: json['workout_programs']['duration_weeks'] as int? ?? 1,
              difficultyLevel: json['workout_programs']['difficulty_level'] as String? ?? 'beginner',
              programType: json['workout_programs']['program_type'] as String? ?? 'strength',
              workoutsPerWeek: json['workout_programs']['workouts_per_week'] as int?,
              rating: (json['workout_programs']['rating'] as num?)?.toDouble() ?? 0.0,
              totalRatings: json['workout_programs']['total_ratings'] as int? ?? 0,
              isPopular: json['workout_programs']['is_popular'] as bool? ?? false,
              isPublic: json['workout_programs']['is_public'] as bool? ?? true,
              createdBy: json['workout_programs']['created_by'] as String?,
              createdAt: json['workout_programs']['created_at'] != null
                  ? DateTime.parse(json['workout_programs']['created_at'] as String)
                  : DateTime.now(),
              updatedAt: json['workout_programs']['updated_at'] != null
                  ? DateTime.parse(json['workout_programs']['updated_at'] as String)
                  : DateTime.now(),
              version: json['workout_programs']['version'] as int? ?? 1,
              imageUrl: json['workout_programs']['image_url'] as String?,
              isSample: json['workout_programs']['is_sample'] as bool? ?? false,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'program_id': programId,
      'current_week': currentWeek,
      'current_day': currentDay,
      'is_active': isActive,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'exercises_json': exercisesJson,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'workout_programs': workoutProgram != null ? {
        'id': workoutProgram!.id,
        'name': workoutProgram!.name,
        'creator': workoutProgram!.creator,
        'description': workoutProgram!.description,
        'duration_weeks': workoutProgram!.durationWeeks,
        'difficulty_level': workoutProgram!.difficultyLevel,
        'program_type': workoutProgram!.programType,
        'workouts_per_week': workoutProgram!.workoutsPerWeek,
        'rating': workoutProgram!.rating,
        'total_ratings': workoutProgram!.totalRatings,
        'is_popular': workoutProgram!.isPopular,
        'is_public': workoutProgram!.isPublic,
        'created_by': workoutProgram!.createdBy,
        'created_at': workoutProgram!.createdAt.toIso8601String(),
        'updated_at': workoutProgram!.updatedAt.toIso8601String(),
        'version': workoutProgram!.version,
        'image_url': workoutProgram!.imageUrl,
        'is_sample': workoutProgram!.isSample,
      } : null,
    };
  }

  UserProgramModel copyWith({
    String? id,
    String? userId,
    String? programId,
    int? currentWeek,
    int? currentDay,
    bool? isActive,
    DateTime? startedAt,
    DateTime? completedAt,
    dynamic exercisesJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    WorkoutProgram? workoutProgram,
  }) {
    return UserProgramModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      programId: programId ?? this.programId,
      currentWeek: currentWeek ?? this.currentWeek,
      currentDay: currentDay ?? this.currentDay,
      isActive: isActive ?? this.isActive,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      exercisesJson: exercisesJson ?? this.exercisesJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workoutProgram: workoutProgram ?? this.workoutProgram,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        programId,
        currentWeek,
        currentDay,
        isActive,
        startedAt,
        completedAt,
        exercisesJson,
        createdAt,
        updatedAt,
        workoutProgram,
      ];
}