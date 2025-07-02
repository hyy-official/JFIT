import 'dart:math';

import 'package:intl/intl.dart';
import 'package:jfit/features/analytics/domain/entities/diet_score_data.dart';
import 'package:jfit/features/analytics/domain/entities/nutrition_data.dart';
import 'package:jfit/features/analytics/domain/entities/workout_composition_data.dart';
import 'package:jfit/features/analytics/domain/entities/workout_time_data.dart';
import 'package:jfit/features/analytics/domain/entities/body_data.dart';
import 'package:jfit/features/analytics/domain/repositories/analytics_repository.dart';

class MockAnalyticsRepository implements AnalyticsRepository {
  final Random _random = Random();

  // Helper to generate a list of dates ending today
  List<DateTime> _getDates(String period) {
    final now = DateTime.now();
    switch (period) {
      case '7d':
        return List.generate(7, (i) => now.subtract(Duration(days: i))).reversed.toList();
      case '1m':
        return List.generate(30, (i) => now.subtract(Duration(days: i))).reversed.toList();
      case '3m':
        // Show 12 bars, one for each week's average
        return List.generate(12, (i) => now.subtract(Duration(days: i * 7))).reversed.toList();
      case '1y':
        // Generate 12 dates, each representing the first day of the month,
        // starting from (current month - 11) up to the current month.
        final List<DateTime> months = [];
        for (int i = 11; i >= 0; i--) {
          final monthDate = DateTime(now.year, now.month - i, 1);
          months.add(monthDate);
        }
        return months;
      default:
        return [];
    }
  }

  // Helper to format date labels
  String _getLabel(DateTime date, String period) {
    switch (period) {
      case '7d':
        return DateFormat('E', 'ko_KR').format(date); // '월', '화'
      case '1m':
        return DateFormat('MM/dd').format(date); // '06/03'
      case '3m':
         return DateFormat('MM/dd').format(date); // '04/23'
      case '1y':
         return DateFormat('yy/MM').format(date); // '24/09'
      default:
        return '';
    }
  }

  Future<List<DietScoreData>> getDietScoreData(String period) async {
    final dates = _getDates(period);
    
    return List.generate(dates.length, (index) {
      return DietScoreData(
        dateLabel: _getLabel(dates[index], period),
        score: 1.0 + _random.nextDouble() * 4.0, // 1.0 to 5.0
      );
    });
  }

  Future<List<NutritionData>> getNutritionData(String period) async {
    final dates = _getDates(period);

    return List.generate(dates.length, (index) {
        return NutritionData(
          dateLabel: _getLabel(dates[index], period),
          carbs: 50.0 + _random.nextDouble() * 100.0, // 50 to 150
          protein: 20.0 + _random.nextDouble() * 80.0,  // 20 to 100
          fat: 10.0 + _random.nextDouble() * 50.0,      // 10 to 60
        );
    });
  }

  Future<List<WorkoutTimeData>> getWorkoutTimeData(String period) async {
    final dates = _getDates(period);
    return List.generate(dates.length, (index) {
      return WorkoutTimeData(
        dateLabel: _getLabel(dates[index], period),
        minutes: 20 + _random.nextInt(100).toDouble(), // 20~120분
      );
    });
  }

  Future<List<WorkoutCompositionData>> getWorkoutCompositionData(String period) async {
    // 반환용 예시 데이터 5카테고리
    final labels = ['웨이트', '유산소', '스트레칭', '스포츠', '워킹'];

    return labels.map((label) {
      return WorkoutCompositionData(
        category: label,
        minutes: (30 + _random.nextInt(120)).toDouble(),
      );
    }).toList();
  }

  @override
  Future<List<BodyData>> getBodyData(String period) async {
    final dates = _getDates(period);
    return List.generate(dates.length, (index) {
      return BodyData(
        dateLabel: DateFormat('yyyy-MM-dd').format(dates[index]),
        weight: 60.0 + _random.nextDouble() * 20.0, // 60kg to 80kg
        skeletalMuscleMass: 25.0 + _random.nextDouble() * 10.0, // 25kg to 35kg
        bodyFatPercentage: 15.0 + _random.nextDouble() * 10.0, // 15% to 25%
      );
    });
  }
} 