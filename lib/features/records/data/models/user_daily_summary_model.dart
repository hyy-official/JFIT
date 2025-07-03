import 'package:equatable/equatable.dart';

class UserDailySummary extends Equatable {
  final String id;
  final int userId;
  final DateTime summaryDate;
  final int totalWorkoutDurationMinutes;
  final int totalCaloriesBurned;
  final double totalCaloriesConsumed;
  final double totalProteinConsumed;
  final double totalCarbsConsumed;
  final double totalFatConsumed;

  const UserDailySummary({
    required this.id,
    required this.userId,
    required this.summaryDate,
    this.totalWorkoutDurationMinutes = 0,
    this.totalCaloriesBurned = 0,
    this.totalCaloriesConsumed = 0.0,
    this.totalProteinConsumed = 0.0,
    this.totalCarbsConsumed = 0.0,
    this.totalFatConsumed = 0.0,
  });

  @override
  List<Object> get props => [
        id,
        userId,
        summaryDate,
        totalWorkoutDurationMinutes,
        totalCaloriesBurned,
        totalCaloriesConsumed,
        totalProteinConsumed,
        totalCarbsConsumed,
        totalFatConsumed,
      ];

  factory UserDailySummary.fromJson(Map<String, dynamic> json) {
    return UserDailySummary(
      id: json['id'] as String,
      userId: json['user_id'] as int,
      summaryDate: DateTime.parse(json['summary_date'] as String),
      totalWorkoutDurationMinutes: json['total_workout_duration_minutes'] as int,
      totalCaloriesBurned: json['total_calories_burned'] as int,
      totalCaloriesConsumed: (json['total_calories_consumed'] as num).toDouble(),
      totalProteinConsumed: (json['total_protein_consumed'] as num).toDouble(),
      totalCarbsConsumed: (json['total_carbs_consumed'] as num).toDouble(),
      totalFatConsumed: (json['total_fat_consumed'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'summary_date': summaryDate.toIso8601String(),
      'total_workout_duration_minutes': totalWorkoutDurationMinutes,
      'total_calories_burned': totalCaloriesBurned,
      'total_calories_consumed': totalCaloriesConsumed,
      'total_protein_consumed': totalProteinConsumed,
      'total_carbs_consumed': totalCarbsConsumed,
      'total_fat_consumed': totalFatConsumed,
    };
  }
}
