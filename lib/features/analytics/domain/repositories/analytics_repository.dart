import 'package:jfit/features/analytics/domain/entities/diet_score_data.dart';
import 'package:jfit/features/analytics/domain/entities/nutrition_data.dart';
import 'package:jfit/features/analytics/domain/entities/workout_composition_data.dart';
import 'package:jfit/features/analytics/domain/entities/workout_time_data.dart';
import 'package:jfit/features/analytics/domain/entities/body_data.dart';

abstract class AnalyticsRepository {
  Future<List<DietScoreData>> getDietScoreData();
  Future<List<NutritionData>> getNutritionData();
  Future<List<WorkoutTimeData>> getWorkoutTimeData();
  Future<List<WorkoutCompositionData>> getWorkoutCompositionData();
  Future<List<BodyData>> getBodyData();
}
