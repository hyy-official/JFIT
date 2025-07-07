import 'dart:math';

import 'package:intl/intl.dart';
import 'package:jfit/features/analytics/domain/entities/diet_score_data.dart';
import 'package:jfit/features/analytics/domain/entities/nutrition_data.dart';
import 'package:jfit/features/analytics/domain/entities/workout_composition_data.dart';
import 'package:jfit/features/analytics/domain/entities/workout_time_data.dart';
import 'package:jfit/features/analytics/domain/entities/body_data.dart';
import 'package:jfit/features/analytics/domain/repositories/analytics_repository.dart';


//차트 데이터 모의 데이터 저장소
class MockAnalyticsRepository implements AnalyticsRepository {
  final Random _random = Random();

  @override
  Future<List<DietScoreData>> getDietScoreData() async {
    final now = DateTime.now();
    return List.generate(7, (index) {
      return DietScoreData(
        date: now.subtract(Duration(days: 6 - index)),
        score: 60 + _random.nextDouble() * 40, // 60-100 점수
      );
    });
  }

  @override
  Future<List<NutritionData>> getNutritionData() async {
    final now = DateTime.now();
    return List.generate(7, (index) {
      return NutritionData(
        date: now.subtract(Duration(days: 6 - index)),
        calories: 1500 + _random.nextDouble() * 800, // 1500-2300 칼로리
        protein: 60 + _random.nextDouble() * 40, // 60-100g
        carbs: 150 + _random.nextDouble() * 100, // 150-250g
        fat: 40 + _random.nextDouble() * 30, // 40-70g
      );
    });
  }

  @override
  Future<List<WorkoutTimeData>> getWorkoutTimeData() async {
    final now = DateTime.now();
    return List.generate(7, (index) {
      return WorkoutTimeData(
        date: now.subtract(Duration(days: 6 - index)),
        duration: 30 + _random.nextDouble() * 90, // 30-120분
      );
    });
  }

  @override
  Future<List<WorkoutCompositionData>> getWorkoutCompositionData() async {
    final categories = ['웨이트', '유산소', '스트레칭', '기타'];
    final colors = [0xFF4ECDC4, 0xFF45B7D1, 0xFF96CEB4, 0xFFFECE8A];
    
    return List.generate(categories.length, (index) {
      return WorkoutCompositionData(
        category: categories[index],
        value: 20 + _random.nextDouble() * 60, // 20-80분
        color: colors[index],
      );
    });
  }

  @override
  Future<List<BodyData>> getBodyData() async {
    final now = DateTime.now();
    return List.generate(7, (index) {
      return BodyData(
        date: now.subtract(Duration(days: 6 - index)),
        weight: 65 + _random.nextDouble() * 10, // 65-75kg
        muscleMass: 25 + _random.nextDouble() * 10, // 25-35kg
        bodyFat: 15 + _random.nextDouble() * 10, // 15-25%
      );
    });
  }
} 