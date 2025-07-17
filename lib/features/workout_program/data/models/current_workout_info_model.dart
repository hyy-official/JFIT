import 'package:equatable/equatable.dart';
import 'package:jfit/features/workout_program/data/models/user_program_model.dart';

/// Model representing current workout information for a user
class CurrentWorkoutInfoModel extends Equatable {
  final UserProgramModel? activeProgram;
  final int? currentWeek;
  final int? currentDay;
  final bool hasActiveProgram;
  final DateTime? lastWorkoutDate;
  final int totalCompletedDays;
  final double progressPercentage;

  const CurrentWorkoutInfoModel({
    this.activeProgram,
    this.currentWeek,
    this.currentDay,
    required this.hasActiveProgram,
    this.lastWorkoutDate,
    required this.totalCompletedDays,
    required this.progressPercentage,
  });

  factory CurrentWorkoutInfoModel.empty() {
    return const CurrentWorkoutInfoModel(
      hasActiveProgram: false,
      totalCompletedDays: 0,
      progressPercentage: 0.0,
    );
  }

  factory CurrentWorkoutInfoModel.fromUserProgram(
    UserProgramModel userProgram, {
    DateTime? lastWorkoutDate,
    int totalCompletedDays = 0,
  }) {
    final totalDays = (userProgram.workoutProgram?.durationWeeks ?? 1) * 
                     (userProgram.workoutProgram?.workoutsPerWeek ?? 3);
    final progressPercentage = totalDays > 0 ? (totalCompletedDays / totalDays) * 100 : 0.0;

    return CurrentWorkoutInfoModel(
      activeProgram: userProgram,
      currentWeek: userProgram.currentWeek,
      currentDay: userProgram.currentDay,
      hasActiveProgram: userProgram.isActive,
      lastWorkoutDate: lastWorkoutDate,
      totalCompletedDays: totalCompletedDays,
      progressPercentage: progressPercentage.clamp(0.0, 100.0),
    );
  }

  CurrentWorkoutInfoModel copyWith({
    UserProgramModel? activeProgram,
    int? currentWeek,
    int? currentDay,
    bool? hasActiveProgram,
    DateTime? lastWorkoutDate,
    int? totalCompletedDays,
    double? progressPercentage,
  }) {
    return CurrentWorkoutInfoModel(
      activeProgram: activeProgram ?? this.activeProgram,
      currentWeek: currentWeek ?? this.currentWeek,
      currentDay: currentDay ?? this.currentDay,
      hasActiveProgram: hasActiveProgram ?? this.hasActiveProgram,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      totalCompletedDays: totalCompletedDays ?? this.totalCompletedDays,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }

  @override
  List<Object?> get props => [
        activeProgram,
        currentWeek,
        currentDay,
        hasActiveProgram,
        lastWorkoutDate,
        totalCompletedDays,
        progressPercentage,
      ];
}