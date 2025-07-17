import 'package:dartz/dartz.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import 'package:jfit/features/daily_summary/data/repositories/daily_summary_repository.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Implementation of DailySummaryRepository using Supabase
class DailySummaryRepositoryImpl extends DailySummaryRepository 
    with BaseRepositoryMixin {
  
  final SupabaseClient _supabaseClient;
  final Uuid _uuid = const Uuid();

  DailySummaryRepositoryImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  String? getCurrentUserId() {
    return _supabaseClient.auth.currentUser?.id;
  }

  @override
  Future<bool> validateUserAccess(String userId) async {
    final currentUserId = getCurrentUserId();
    return currentUserId != null && currentUserId == userId;
  }

  @override
  Future<Either<Failure, UserDailySummary?>> getDailySummary(
    String userId, 
    DateTime date,
  ) async {
    return safeCall(() async {
      if (!await validateUserAccess(userId)) {
        throw AuthFailure('Unauthorized access to user data');
      }

      try {
        final response = await _supabaseClient
            .from('user_daily_summaries')
            .select()
            .eq('user_id', userId)
            .eq('summary_date', date.toIso8601String().split('T')[0])
            .single();

        return UserDailySummary.fromJson(response);
      } on PostgrestException catch (e) {
        // If no data found, return null instead of throwing error
        if (e.code == 'PGRST116' || e.message.contains('0 rows')) {
          return null;
        }
        rethrow;
      }
    });
  }

  @override
  Future<Either<Failure, UserDailySummary>> upsertDailySummary(
    UserDailySummary summary,
  ) async {
    return safeCall(() async {
      if (!await validateUserAccess(summary.userId)) {
        throw AuthFailure('Unauthorized access to user data');
      }

      final summaryData = summary.toJson();
      
      // Ensure we have an ID for the summary
      if (summary.id.isEmpty) {
        summaryData['id'] = _uuid.v4();
      }

      await _supabaseClient
          .from('user_daily_summaries')
          .upsert(summaryData);

      return UserDailySummary.fromJson(summaryData);
    });
  }

  @override
  Future<Either<Failure, List<UserDailySummary>>> getDailySummariesForRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return safeCall(() async {
      if (!await validateUserAccess(userId)) {
        throw AuthFailure('Unauthorized access to user data');
      }

      final response = await _supabaseClient
          .from('user_daily_summaries')
          .select()
          .eq('user_id', userId)
          .gte('summary_date', startDate.toIso8601String().split('T')[0])
          .lte('summary_date', endDate.toIso8601String().split('T')[0])
          .order('summary_date', ascending: true);

      return (response as List)
          .map((json) => UserDailySummary.fromJson(json))
          .toList();
    });
  }

  @override
  Future<Either<Failure, UserDailySummary>> calculateAndUpdateDailySummary(
    String userId,
    DateTime date,
  ) async {
    return safeCall(() async {
      if (!await validateUserAccess(userId)) {
        throw AuthFailure('Unauthorized access to user data');
      }

      final dateString = date.toIso8601String().split('T')[0];

      // Calculate meal totals
      final mealTotals = await _calculateMealTotals(userId, dateString);
      
      // Calculate workout totals
      final workoutTotals = await _calculateWorkoutTotals(userId, dateString);

      // Create or update summary
      final summary = UserDailySummary(
        id: _uuid.v4(),
        userId: userId,
        summaryDate: date,
        totalWorkoutDurationMinutes: workoutTotals['duration'] ?? 0,
        totalCaloriesBurned: workoutTotals['calories_burned'] ?? 0,
        totalCaloriesConsumed: mealTotals['calories'] ?? 0.0,
        totalProteinConsumed: mealTotals['protein'] ?? 0.0,
        totalCarbsConsumed: mealTotals['carbs'] ?? 0.0,
        totalFatConsumed: mealTotals['fat'] ?? 0.0,
      );

      return await upsertDailySummary(summary).then((result) => result.fold(
        (failure) => throw failure,
        (summary) => summary,
      ));
    });
  }

  @override
  Future<Either<Failure, void>> deleteDailySummary(
    String userId,
    DateTime date,
  ) async {
    return safeCall(() async {
      if (!await validateUserAccess(userId)) {
        throw AuthFailure('Unauthorized access to user data');
      }

      await _supabaseClient
          .from('user_daily_summaries')
          .delete()
          .eq('user_id', userId)
          .eq('summary_date', date.toIso8601String().split('T')[0]);
    });
  }

  @override
  Future<Either<Failure, List<T>>> getDataForDateRange<T>(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // This is a generic method from DateBasedRepository
    // For daily summaries, we'll delegate to getDailySummariesForRange
    final result = await getDailySummariesForRange(userId, startDate, endDate);
    return result.map((summaries) => summaries.cast<T>());
  }

  @override
  Future<Either<Failure, List<T>>> getDataForDate<T>(
    String userId,
    DateTime date,
  ) async {
    // This is a generic method from DateBasedRepository
    // For daily summaries, we'll get single summary and return as list
    final result = await getDailySummary(userId, date);
    return result.map((summary) => summary != null ? [summary as T] : <T>[]);
  }

  /// Calculate meal totals for a specific date
  Future<Map<String, double>> _calculateMealTotals(String userId, String dateString) async {
    try {
      final response = await _supabaseClient
          .from('user_meal_entries')
          .select('calories, protein_g, carbohydrate_g, fat_g')
          .eq('user_id', userId)
          .eq('entry_date', dateString);

      double totalCalories = 0.0;
      double totalProtein = 0.0;
      double totalCarbs = 0.0;
      double totalFat = 0.0;

      for (final meal in response) {
        totalCalories += (meal['calories'] as num?)?.toDouble() ?? 0.0;
        totalProtein += (meal['protein_g'] as num?)?.toDouble() ?? 0.0;
        totalCarbs += (meal['carbohydrate_g'] as num?)?.toDouble() ?? 0.0;
        totalFat += (meal['fat_g'] as num?)?.toDouble() ?? 0.0;
      }

      return {
        'calories': totalCalories,
        'protein': totalProtein,
        'carbs': totalCarbs,
        'fat': totalFat,
      };
    } catch (e) {
      // Return zeros if calculation fails
      return {
        'calories': 0.0,
        'protein': 0.0,
        'carbs': 0.0,
        'fat': 0.0,
      };
    }
  }

  /// Calculate workout totals for a specific date
  Future<Map<String, int>> _calculateWorkoutTotals(String userId, String dateString) async {
    try {
      final response = await _supabaseClient
          .from('workout_sessions')
          .select('started_at, ended_at, calories_burned')
          .eq('user_id', userId)
          .gte('session_date', dateString)
          .lt('session_date', DateTime.parse(dateString).add(const Duration(days: 1)).toIso8601String().split('T')[0])
          .eq('is_completed', true);

      int totalDuration = 0;
      int totalCaloriesBurned = 0;

      for (final session in response) {
        // Calculate duration if both start and end times are available
        if (session['started_at'] != null && session['ended_at'] != null) {
          final startTime = DateTime.parse(session['started_at']);
          final endTime = DateTime.parse(session['ended_at']);
          totalDuration += endTime.difference(startTime).inMinutes;
        }

        totalCaloriesBurned += (session['calories_burned'] as int?) ?? 0;
      }

      return {
        'duration': totalDuration,
        'calories_burned': totalCaloriesBurned,
      };
    } catch (e) {
      // Return zeros if calculation fails
      return {
        'duration': 0,
        'calories_burned': 0,
      };
    }
  }
}