import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jfit/features/analytics/domain/entities/diet_score_data.dart';
import 'package:jfit/features/analytics/domain/entities/nutrition_data.dart';
import 'package:jfit/features/analytics/domain/entities/workout_composition_data.dart';
import 'package:jfit/features/analytics/domain/entities/workout_time_data.dart';
import 'package:jfit/features/analytics/domain/entities/body_data.dart';
import 'package:jfit/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:intl/intl.dart';

class SupabaseAnalyticsRepository implements AnalyticsRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // 현재 로그인된 사용자의 ID를 가져오는 helper 메서드
  String? get _currentUserId => _client.auth.currentUser?.id;

  @override
  Future<List<BodyData>> getBodyData() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('사용자가 로그인되지 않았습니다.');
      }

      final response = await _client
          .from('user_body_measurements')
          .select('*')
          .eq('user_id', userId)
          .order('measured_date', ascending: true)
          .limit(10);

      if (response.isEmpty) {
        return [];
      }

      return response.map<BodyData>((row) {
        return BodyData(
          date: row['measured_date'] is String
              ? DateTime.parse(row['measured_date'])
              : (row['measured_date'] as DateTime),
          weight: (row['weight'] as num?)?.toDouble() ?? 0.0,
          muscleMass: (row['muscle_mass'] as num?)?.toDouble() ?? 0.0,
          bodyFat: (row['body_fat_percentage'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    } catch (e) {
      print('Error fetching body data: $e');
      return [];
    }
  }

  @override
  Future<List<WorkoutCompositionData>> getWorkoutCompositionData() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('사용자가 로그인되지 않았습니다.');
      }

      final response = await _client.rpc(
        'get_workout_composition',
        params: {'user_id_param': userId},
      );

      if (response == null || response.isEmpty) {
        return [];
      }

      return response.map<WorkoutCompositionData>((row) {
        return WorkoutCompositionData(
          category: row['category'] ?? 'Unknown',
          value: (row['count'] as num?)?.toDouble() ?? 0.0,
          color: _getCategoryColor(row['category']),
        );
      }).toList();
    } catch (e) {
      print('Error fetching workout composition data: $e');
      return [];
    }
  }

  @override
  Future<List<WorkoutTimeData>> getWorkoutTimeData() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('사용자가 로그인되지 않았습니다.');
      }

      final response = await _client.rpc(
        'get_workout_time_data',
        params: {'user_id_param': userId},
      );

      if (response == null || response.isEmpty) {
        return [];
      }

      return response.map<WorkoutTimeData>((row) {
        return WorkoutTimeData(
          date: DateTime.parse(row['workout_date']),
          duration: (row['total_duration'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    } catch (e) {
      print('Error fetching workout time data: $e');
      return [];
    }
  }

  @override
  Future<List<NutritionData>> getNutritionData() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('사용자가 로그인되지 않았습니다.');
      }

      final response = await _client.rpc(
        'get_nutrition_data',
        params: {'user_id_param': userId},
      );

      if (response == null || response.isEmpty) {
        return [];
      }

      return response.map<NutritionData>((row) {
        return NutritionData(
          date: DateTime.parse(row['meal_date']),
          calories: (row['total_calories'] as num?)?.toDouble() ?? 0.0,
          protein: (row['total_protein'] as num?)?.toDouble() ?? 0.0,
          carbs: (row['total_carbs'] as num?)?.toDouble() ?? 0.0,
          fat: (row['total_fat'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    } catch (e) {
      print('Error fetching nutrition data: $e');
      return [];
    }
  }

  @override
  Future<List<DietScoreData>> getDietScoreData() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('사용자가 로그인되지 않았습니다.');
      }

      final nutritionData = await getNutritionData();
      
      return nutritionData.map((nutrition) {
        // 영양소 균형 기반 식단 점수 계산
        final score = _calculateDietScore(
          nutrition.calories,
          nutrition.protein,
          nutrition.carbs,
          nutrition.fat,
        );

        return DietScoreData(
          date: nutrition.date,
          score: score,
        );
      }).toList();
    } catch (e) {
      print('Error calculating diet score data: $e');
      return [];
    }
  }

  // 카테고리별 색상 반환
  int _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'strength':
      case '근력':
        return 0xFF4ECDC4;
      case 'cardio':
      case '유산소':
        return 0xFF45B7D1;
      case 'flexibility':
      case '유연성':
        return 0xFF96CEB4;
      case 'balance':
      case '균형':
        return 0xFFFECE8A;
      default:
        return 0xFF95E1D3;
    }
  }

  // 영양소 균형 기반 식단 점수 계산 (0-100)
  double _calculateDietScore(double calories, double protein, double carbs, double fat) {
    if (calories == 0) return 0;

    // 이상적인 영양소 비율 (%)
    const idealProteinRatio = 0.25; // 25%
    const idealCarbsRatio = 0.45; // 45%
    const idealFatRatio = 0.30; // 30%

    // 현재 영양소 비율 계산
    final proteinCalories = protein * 4;
    final carbsCalories = carbs * 4;
    final fatCalories = fat * 9;

    final currentProteinRatio = proteinCalories / calories;
    final currentCarbsRatio = carbsCalories / calories;
    final currentFatRatio = fatCalories / calories;

    // 이상적인 비율과의 차이 계산
    final proteinDiff = (currentProteinRatio - idealProteinRatio).abs();
    final carbsDiff = (currentCarbsRatio - idealCarbsRatio).abs();
    final fatDiff = (currentFatRatio - idealFatRatio).abs();

    // 평균 차이를 기반으로 점수 계산 (차이가 적을수록 높은 점수)
    final avgDiff = (proteinDiff + carbsDiff + fatDiff) / 3;
    final score = (1 - avgDiff) * 100;

    return score.clamp(0, 100);
  }
} 