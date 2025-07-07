import 'package:jfit/features/analytics/domain/entities/diet_score_data.dart';
import 'package:jfit/features/analytics/domain/entities/nutrition_data.dart';
import 'package:jfit/features/analytics/domain/entities/workout_composition_data.dart';
import 'package:jfit/features/analytics/domain/entities/workout_time_data.dart';
import 'package:jfit/features/analytics/domain/entities/body_data.dart';
import 'package:jfit/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:jfit/core/services/supabase_service.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final SupabaseService _supabaseService;

  AnalyticsRepositoryImpl({required SupabaseService supabaseService})
      : _supabaseService = supabaseService;

  @override
  Future<List<DietScoreData>> getDietScoreData() async {
    // TODO: Implement actual data fetching
    return [];
  }

  @override
  Future<List<NutritionData>> getNutritionData() async {
    // TODO: Implement actual data fetching
    return [];
  }

  @override
  Future<List<WorkoutTimeData>> getWorkoutTimeData() async {
    // TODO: Implement actual data fetching
    return [];
  }

  @override
  Future<List<WorkoutCompositionData>> getWorkoutCompositionData() async {
    // TODO: Implement actual data fetching
    return [];
  }

  @override
  Future<List<BodyData>> getBodyData() async {
    // TODO: Implement actual data fetching
    return [];
  }
}
