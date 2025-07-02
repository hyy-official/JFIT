
import 'package:jfit/features/analytics/domain/entities/diet_score_data.dart';
import 'package:jfit/features/analytics/domain/entities/nutrition_data.dart';
import 'package:jfit/features/analytics/domain/entities/workout_composition_data.dart';
import 'package:jfit/features/analytics/domain/entities/workout_time_data.dart';
import 'package:jfit/features/analytics/domain/entities/body_data.dart';

abstract class AnalyticsRepository {
  Future<List<DietScoreData>> getDietScoreData(String period);
  Future<List<NutritionData>> getNutritionData(String period);
  Future<List<WorkoutTimeData>> getWorkoutTimeData(String period);
  Future<List<WorkoutCompositionData>> getWorkoutCompositionData(String period);
  Future<List<BodyData>> getBodyData(String period);
}
