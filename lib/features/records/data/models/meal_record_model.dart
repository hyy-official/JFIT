import 'package:equatable/equatable.dart';

class MealRecord extends Equatable {
  final String id;
  final int userId;
  final DateTime mealDate;
  final String mealType;
  final double? totalCalories;
  final double? totalProtein;
  final double? totalCarbs;
  final double? totalFat;
  final String? notes;
  final String? photoUrl;

  const MealRecord({
    required this.id,
    required this.userId,
    required this.mealDate,
    required this.mealType,
    this.totalCalories,
    this.totalProtein,
    this.totalCarbs,
    this.totalFat,
    this.notes,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        mealDate,
        mealType,
        totalCalories,
        totalProtein,
        totalCarbs,
        totalFat,
        notes,
        photoUrl,
      ];

  factory MealRecord.fromJson(Map<String, dynamic> json) {
    return MealRecord(
      id: json['id'] as String,
      userId: json['user_id'] as int,
      mealDate: DateTime.parse(json['meal_date'] as String),
      mealType: json['meal_type'] as String,
      totalCalories: (json['total_calories'] as num?)?.toDouble(),
      totalProtein: (json['total_protein'] as num?)?.toDouble(),
      totalCarbs: (json['total_carbs'] as num?)?.toDouble(),
      totalFat: (json['total_fat'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'meal_date': mealDate.toIso8601String(),
      'meal_type': mealType,
      'total_calories': totalCalories,
      'total_protein': totalProtein,
      'total_carbs': totalCarbs,
      'total_fat': totalFat,
      'notes': notes,
      'photo_url': photoUrl,
    };
  }
}
