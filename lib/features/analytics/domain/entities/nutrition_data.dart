import 'package:equatable/equatable.dart';

class NutritionData extends Equatable {
  final DateTime date;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const NutritionData({
    required this.date,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  List<Object> get props => [date, calories, protein, carbs, fat];

  // 호환성을 위한 getter
  String get dateLabel => '${date.month}/${date.day}';
} 