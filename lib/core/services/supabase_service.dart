import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jfit/features/analytics/domain/entities/diet_score_data.dart';
import 'package:jfit/features/analytics/domain/entities/nutrition_data.dart';
import 'package:jfit/features/analytics/domain/entities/workout_composition_data.dart';
import 'package:jfit/features/analytics/domain/entities/workout_time_data.dart';
import 'package:jfit/features/analytics/domain/entities/body_data.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:jfit/features/records/data/models/diet_entry.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  // Helper to get date range based on period
  Map<String, DateTime> _getDateRange(String period) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (period) {
      case '7d':
        startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
        break;
      case '1m':
        startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
        break;
      case '3m':
        startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 89));
        break;
      case '1y':
        startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 364));
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    }
    return {'startDate': startDate, 'endDate': endDate};
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

  // Diet Score Data
  Future<List<DietScoreData>> getDietScoreData(String period) async {
    if (_currentUserId == null) return [];

    final dateRange = _getDateRange(period);
    final startDate = dateRange['startDate']!;
    final endDate = dateRange['endDate']!;

    try {
      final response = await _supabase
          .from('user_meal_entries')
          .select('entry_date, calories')
          .eq('user_id', _currentUserId!)
          .gte('entry_date', DateFormat('yyyy-MM-dd').format(startDate))
          .lte('entry_date', DateFormat('yyyy-MM-dd').format(endDate))
          .order('entry_date', ascending: true);

      if (response == null || response.isEmpty) {
        return [];
      }

      // 날짜별 칼로리 합계 계산
      final Map<String, double> dailyCalories = {};
      for (var entry in response) {
        final dateStr = entry['entry_date'] as String;
        final calories = (entry['calories'] as num?)?.toDouble() ?? 0.0;
        dailyCalories.update(dateStr, (value) => value + calories, ifAbsent: () => calories);
      }

      // DietScoreData 형식으로 변환 (임시로 칼로리 기반 점수)
      return dailyCalories.entries.map((entry) {
        final date = DateTime.parse(entry.key);
        // 임시 식단 점수 로직: 1000kcal 미만 5점, 1000-2000kcal 4점, 2000-3000kcal 3점, 3000-4000kcal 2점, 4000kcal 이상 1점
        double score;
        if (entry.value < 1000) {
          score = 5.0;
        } else if (entry.value < 2000) {
          score = 4.0;
        } else if (entry.value < 3000) {
          score = 3.0;
        } else if (entry.value < 4000) {
          score = 2.0;
        } else {
          score = 1.0;
        }
        return DietScoreData(
          date: date,
          score: score,
        );
      }).toList();
    } catch (e) {
      print('Error fetching diet score data: $e');
      return [];
    }
  }

  // Nutrition Data
  Future<List<NutritionData>> getNutritionData(String period) async {
    if (_currentUserId == null) return [];

    final dateRange = _getDateRange(period);
    final startDate = dateRange['startDate']!;
    final endDate = dateRange['endDate']!;

    try {
      final response = await _supabase
          .from('user_meal_entries')
          .select('entry_date, calories, protein, carbohydrates, fat')
          .eq('user_id', _currentUserId!)
          .gte('entry_date', DateFormat('yyyy-MM-dd').format(startDate))
          .lte('entry_date', DateFormat('yyyy-MM-dd').format(endDate))
          .order('entry_date', ascending: true);

      if (response == null || response.isEmpty) {
        return [];
      }

      // 날짜별 탄단지 합계 계산
      final Map<String, Map<String, double>> dailyNutrition = {};
      for (var entry in response) {
        final dateStr = entry['entry_date'] as String;
        final protein = (entry['protein'] as num?)?.toDouble() ?? 0.0;
        final carbs = (entry['carbohydrates'] as num?)?.toDouble() ?? 0.0;
        final fat = (entry['fat'] as num?)?.toDouble() ?? 0.0;
        final calories = (entry['calories'] as num?)?.toDouble() ?? 0.0;

        dailyNutrition.update(dateStr, (value) {
          value['protein'] = (value['protein'] ?? 0.0) + protein;
          value['carbs'] = (value['carbs'] ?? 0.0) + carbs;
          value['fat'] = (value['fat'] ?? 0.0) + fat;
          value['calories'] = (value['calories'] ?? 0.0) + calories;
          return value;
        }, ifAbsent: () => {'protein': protein, 'carbs': carbs, 'fat': fat, 'calories': calories});
      }

      return dailyNutrition.entries.map((entry) {
        final date = DateTime.parse(entry.key);
        return NutritionData(
          date: date,
          calories: entry.value['calories']!,
          protein: entry.value['protein']!,
          carbs: entry.value['carbs']!,
          fat: entry.value['fat']!,
        );
      }).toList();
    } catch (e) {
      print('Error fetching nutrition data: $e');
      return [];
    }
  }

  // Workout Time Data
  Future<List<WorkoutTimeData>> getWorkoutTimeData(String period) async {
    if (_currentUserId == null) return [];

    final dateRange = _getDateRange(period);
    final startDate = dateRange['startDate']!;
    final endDate = dateRange['endDate']!;

    try {
      final response = await _supabase
          .from('user_workout_sessions')
          .select('start_time, total_duration_minutes')
          .eq('user_id', _currentUserId!)
          .gte('start_time', DateFormat('yyyy-MM-dd').format(startDate))
          .lte('start_time', DateFormat('yyyy-MM-dd').format(endDate))
          .order('start_time', ascending: true);

      if (response == null || response.isEmpty) {
        return [];
      }

      final Map<String, double> dailyWorkoutMinutes = {};
      for (var entry in response) {
        final dateStr = (entry['start_time'] as String).substring(0, 10); // YYYY-MM-DD
        final duration = (entry['total_duration_minutes'] as num?)?.toDouble() ?? 0.0;
        dailyWorkoutMinutes.update(dateStr, (value) => value + duration, ifAbsent: () => duration);
      }

      return dailyWorkoutMinutes.entries.map((entry) {
        final date = DateTime.parse(entry.key);
        return WorkoutTimeData(
          date: date,
          duration: entry.value,
        );
      }).toList();
    } catch (e) {
      print('Error fetching workout time data: $e');
      return [];
    }
  }

  // Workout Composition Data
  Future<List<WorkoutCompositionData>> getWorkoutCompositionData(String period) async {
    if (_currentUserId == null) return [];

    final dateRange = _getDateRange(period);
    final startDate = dateRange['startDate']!;
    final endDate = dateRange['endDate']!;

    try {
      final response = await _supabase
          .from('user_workout_sessions')
          .select('exercises') // exercises JSONB 컬럼 선택
          .eq('user_id', _currentUserId!)
          .gte('start_time', DateFormat('yyyy-MM-dd').format(startDate))
          .lte('start_time', DateFormat('yyyy-MM-dd').format(endDate));

      if (response == null || response.isEmpty) {
        return [];
      }

      final Map<String, double> categoryMinutes = {};

      for (var session in response) {
        final exercises = session['exercises'] as List<dynamic>?;
        if (exercises != null) {
          for (var exercise in exercises) {
            final exerciseType = exercise['exercise_type'] as String?;
            final sets = exercise['sets'] as List<dynamic>?;

            if (exerciseType != null && sets != null) {
              double exerciseDuration = 0.0;
              for (var set in sets) {
                // 세트별 시간 계산 로직 (예: reps * time_per_rep 또는 duration_minutes)
                // 현재 스키마에 세트별 duration_minutes가 없으므로 임시로 1분으로 가정
                exerciseDuration += 1.0; // 임시: 각 세트당 1분으로 가정
              }
              categoryMinutes.update(exerciseType, (value) => value + exerciseDuration, ifAbsent: () => exerciseDuration);
            }
          }
        }
      }

      return categoryMinutes.entries.map((entry) {
        return WorkoutCompositionData(
          category: entry.key,
          value: entry.value,
          color: 0xFF6366F1,
        );
      }).toList();
    } catch (e) {
      print('Error fetching workout composition data: $e');
      return [];
    }
  }

  // Body Data (현재 스키마에 해당 테이블 없음)
  Future<List<BodyData>> getBodyData(String period) async {
    // TODO: user_body_metrics 테이블이 추가되면 구현
    return [];
  }

  // Save DietEntry to user_meal_entries
  Future<void> saveDietEntry(DietEntry entry) async {
    if (_currentUserId == null) throw Exception('Not authenticated');

    String? imageUrl;
    if (entry.imagePath != null && entry.imagePath!.isNotEmpty) {
      final file = File(entry.imagePath!);
      if (await file.exists()) {
        final ext = p.extension(file.path);
        final fileName = '${const Uuid().v4()}$ext';
        final storagePath = '${_currentUserId!}/$fileName';
        try {
          final path = await _supabase.storage.from('meal-photos').uploadBinary(storagePath, await file.readAsBytes());
          imageUrl = _supabase.storage.from('meal-photos').getPublicUrl(path);
        } catch (e) {
          throw Exception('이미지 업로드 실패: $e');
        }
      }
    }

    final data = {
      'user_id': _currentUserId,
      'food_name': entry.foodName,
      'meal_types': entry.mealTypes,
      'satisfaction': entry.satisfaction,
      'score': entry.score,
      'entry_date': DateFormat('yyyy-MM-dd').format(entry.time),
      'entry_time': entry.time.toUtc().toIso8601String(),
      'image_url': imageUrl,
      'notes': entry.memo,
      'accompaniments': entry.accompaniments,
      'is_bookmarked': entry.isBookmarked,
      'calories': entry.calories,
      'protein': entry.protein,
      'carbohydrates': entry.carbs,
      'fat': entry.fat,
    }..removeWhere((key, value) => value == null || (value is List && value.isEmpty));

    await _supabase.from('user_meal_entries').insert(data);
  }

  Future<List<Map<String, dynamic>>> searchFoodItems(String query) async {
    final filter = query.trim();


// ['id', 'name',
//  'category_name',
//  'standard_size_g',
//  'energy_kcal',
//  'water_g',
//  'protein_g',
//  'fat_g',
//  'saturated_fat_g',
//  'trans_fat_g',
//  'carbohydrate_g',
//  'sugars_g',
//  'dietary_fiber_g',
//  'cholesterol_mg',
//  'calcium_mg',
//  'iron_mg',
//  'sodium_mg',
//  'potassium_mg',
//  'vitamin_a_ug_rae',
//  'vitamin_c_mg',
//  'source_name',
//  'brand',
//  'serving_size_g',
//  'is_imported',
//  'country_name',
//  'total_size_g',
//  'unit',
//  'type']

    var builder = _supabase
        .from('food_items')
        .select('id,name,brand,standard_size_g,total_size_g,energy_kcal,protein_g,carbohydrate_g,fat_g,total_energy_kcal,total_protein_g,total_carbohydrate_g,total_fat_g');

    if (filter.isNotEmpty) {
      builder = builder.or('name.ilike.%$filter%,brand.ilike.%$filter%');
    }

    final resp = await builder.order('name', ascending: true).limit(30);

    return (resp as List).cast<Map<String, dynamic>>();
  }

  // Save meal entry with food item reference
  Future<String> saveMealEntry({
    required String foodName,
    required String mealType, // breakfast, lunch, dinner, snack
    required double quantityG,
    required DateTime entryDate,
    required double calories,
    required double protein,
    required double carbohydrates,
    required double fat,
    String? foodItemId,
    String? notes,
    List<String>? mealTypes,
    String? satisfaction,
    int? score,
    List<String>? accompaniments,
    String? imagePath,
  }) async {
    if (_currentUserId == null) throw Exception('Not authenticated');

    String? imageUrl;
    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (await file.exists()) {
        final ext = p.extension(file.path);
        final fileName = '${const Uuid().v4()}$ext';
        final storagePath = '${_currentUserId!}/$fileName';
        try {
          final path = await _supabase.storage.from('meal-photos').uploadBinary(storagePath, await file.readAsBytes());
          imageUrl = _supabase.storage.from('meal-photos').getPublicUrl(path);
        } catch (e) {
          // 실패해도 저장은 계속 진행
          print('이미지 업로드 실패: $e');
        }
      }
    }

    final data = {
      'user_id': _currentUserId,
      'food_item_id': foodItemId,
      'food_name': foodName,
      'meal_type': mealType,
      'quantity_g': quantityG,
      'entry_date': DateFormat('yyyy-MM-dd').format(entryDate),
      'entry_time': entryDate.toUtc().toIso8601String(),
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fat': fat,
      'notes': notes,
      'meal_types': mealTypes,
      'satisfaction': satisfaction,
      'score': score,
      'accompaniments': accompaniments,
      'image_url': imageUrl,
    }..removeWhere((key, value) => value == null);

    final response = await _supabase
        .from('user_meal_entries')
        .insert(data)
        .select('id')
        .single();

    return response['id'] as String;
  }

  // Save meal entry from food search (with food_item_id)
  Future<String> saveMealEntryFromFoodItem({
    required String foodItemId,
    required String foodName,
    required String mealType,
    required double quantityG,
    required DateTime entryDate,
    required double calories,
    required double protein,
    required double carbohydrates,
    required double fat,
    String? notes,
    List<String>? mealTypes,
    String? satisfaction,
    int? score,
    List<String>? accompaniments,
    String? imagePath,
  }) async {
    return await saveMealEntry(
      foodItemId: foodItemId,
      foodName: foodName,
      mealType: mealType,
      quantityG: quantityG,
      entryDate: entryDate,
      calories: calories,
      protein: protein,
      carbohydrates: carbohydrates,
      fat: fat,
      notes: notes,
      mealTypes: mealTypes,
      satisfaction: satisfaction,
      score: score,
      accompaniments: accompaniments,
      imagePath: imagePath,
    );
  }

  // Save meal entry from manual input (without food_item_id)
  Future<String> saveMealEntryManual({
    required String foodName,
    required String mealType,
    required double quantityG,
    required DateTime entryDate,
    required double calories,
    required double protein,
    required double carbohydrates,
    required double fat,
    String? notes,
    List<String>? mealTypes,
    String? satisfaction,
    int? score,
    List<String>? accompaniments,
    String? imagePath,
  }) async {
    return await saveMealEntry(
      foodName: foodName,
      mealType: mealType,
      quantityG: quantityG,
      entryDate: entryDate,
      calories: calories,
      protein: protein,
      carbohydrates: carbohydrates,
      fat: fat,
      notes: notes,
      mealTypes: mealTypes,
      satisfaction: satisfaction,
      score: score,
      accompaniments: accompaniments,
      imagePath: imagePath,
    );
  }

  // Get user's meal entries for a specific date
  Future<List<Map<String, dynamic>>> getMealEntriesForDate(DateTime date) async {
    if (_currentUserId == null) return [];

    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    try {
      final response = await _supabase
          .from('user_meal_entries')
          .select('id, food_item_id, food_name, meal_type, quantity_g, calories, protein, carbohydrates, fat, entry_time, notes, created_at')
          .eq('user_id', _currentUserId!)
          .eq('entry_date', dateStr)
          .order('entry_time', ascending: true);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching meal entries: $e');
      return [];
    }
  }

  // Get user's meal entries for a date range
  Future<List<Map<String, dynamic>>> getMealEntriesForDateRange(DateTime startDate, DateTime endDate) async {
    if (_currentUserId == null) return [];

    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);

    try {
      final response = await _supabase
          .from('user_meal_entries')
          .select('id, food_item_id, food_name, meal_type, quantity_g, calories, protein, carbohydrates, fat, entry_date, entry_time, notes, created_at')
          .eq('user_id', _currentUserId!)
          .gte('entry_date', startDateStr)
          .lte('entry_date', endDateStr)
          .order('entry_date', ascending: false)
          .order('entry_time', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching meal entries for date range: $e');
      return [];
    }
  }

  // Update meal entry
  Future<void> updateMealEntry({
    required String entryId,
    String? foodName,
    String? mealType,
    double? quantityG,
    double? calories,
    double? protein,
    double? carbohydrates,
    double? fat,
    String? notes,
  }) async {
    if (_currentUserId == null) throw Exception('Not authenticated');

    final data = <String, dynamic>{};
    if (foodName != null) data['food_name'] = foodName;
    if (mealType != null) data['meal_type'] = mealType;
    if (quantityG != null) data['quantity_g'] = quantityG;
    if (calories != null) data['calories'] = calories;
    if (protein != null) data['protein'] = protein;
    if (carbohydrates != null) data['carbohydrates'] = carbohydrates;
    if (fat != null) data['fat'] = fat;
    if (notes != null) data['notes'] = notes;

    if (data.isNotEmpty) {
      data['updated_at'] = DateTime.now().toUtc().toIso8601String();
      
      await _supabase
          .from('user_meal_entries')
          .update(data)
          .eq('id', entryId)
          .eq('user_id', _currentUserId!);
    }
  }

  // Delete meal entry
  Future<void> deleteMealEntry(String entryId) async {
    if (_currentUserId == null) throw Exception('Not authenticated');

    await _supabase
        .from('user_meal_entries')
        .delete()
        .eq('id', entryId)
        .eq('user_id', _currentUserId!);
  }
}
