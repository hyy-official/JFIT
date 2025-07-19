import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import '../../domain/repositories/pt_diet_repository.dart';
import '../../domain/entities/pt_group_diet_summary.dart';
import '../../domain/entities/diet_feedback.dart';
import '../../domain/entities/pt_group_diet_permission.dart';
import '../models/pt_group_diet_summary_model.dart';
import '../models/diet_feedback_model.dart';

/// Implementation of PTDietRepository using Supabase as the data source
class PTDietRepositoryImpl extends PTDietRepository with BaseRepositoryMixin {
  final SupabaseClient _supabaseClient;
  final Uuid _uuid = const Uuid();

  PTDietRepositoryImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<Either<Failure, List<PTGroupDietSummary>>> getGroupDietSummaries(
    String groupId,
    DateTime date,
  ) async {
    return safeCall(() async {
      // Get all active members in the PT group
      final membersResponse = await _supabaseClient
          .from('group_members')
          .select('''
            user_id,
            user_profiles!inner(
              username,
              daily_calorie_goal
            )
          ''')
          .eq('group_id', groupId)
          .eq('is_active', true);

      final members = membersResponse as List;
      final summaries = <PTGroupDietSummary>[];

      for (final member in members) {
        final userId = member['user_id'] as String;
        final userProfile = member['user_profiles'] as Map<String, dynamic>;
        final username = userProfile['username'] as String;
        final calorieGoal = (userProfile['daily_calorie_goal'] as num?)?.toDouble() ?? 2000.0;

        // Get or create diet summary for this member
        final summaryResult = await getMemberDietSummary(groupId, userId, date);
        final existingSummary = summaryResult.fold(
          (failure) => null,
          (summary) => summary,
        );

        if (existingSummary != null) {
          summaries.add(existingSummary);
        } else {
          // Create summary from meal data
          final createdSummary = await createDietSummary(groupId, userId, date);
          final summary = createdSummary.fold(
            (failure) => null,
            (summary) => summary,
          );
          
          if (summary != null) {
            summaries.add(summary);
          }
        }
      }

      return summaries;
    });
  }

  @override
  Future<Either<Failure, PTGroupDietSummary?>> getMemberDietSummary(
    String groupId,
    String memberId,
    DateTime date,
  ) async {
    return safeCall(() async {
      try {
        final response = await _supabaseClient
            .from('pt_group_diet_summaries')
            .select('''
              *,
              user_profiles!inner(username)
            ''')
            .eq('group_id', groupId)
            .eq('member_id', memberId)
            .eq('summary_date', date.toIso8601String().split('T')[0])
            .single();

        final userProfile = response['user_profiles'] as Map<String, dynamic>;
        response['member_name'] = userProfile['username'];
        
        return PTGroupDietSummaryModel.fromJson(response).toEntity();
      } catch (e) {
        if (e is PostgrestException && (e.code == 'PGRST116' || e.message.contains('0 rows'))) {
          return null;
        }
        rethrow;
      }
    });
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getMemberMealEntries(
    String memberId,
    DateTime startDate,
    DateTime endDate, {
    bool includePhotos = true,
  }) async {
    return safeCall(() async {
      var query = _supabaseClient
          .from('user_meal_entries')
          .select('''
            *,
            food_items!inner(
              name,
              energy_kcal,
              protein_g,
              carbohydrate_g,
              fat_g
            )
          ''')
          .eq('user_id', memberId)
          .gte('entry_date', startDate.toIso8601String().split('T')[0])
          .lte('entry_date', endDate.toIso8601String().split('T')[0])
          .order('entry_date', ascending: false)
          .order('created_at', ascending: false);

      final response = await query;
      final mealEntries = response as List;

      return mealEntries.map((entry) {
        final foodItem = entry['food_items'] as Map<String, dynamic>;
        final quantity = (entry['quantity_g'] as num?)?.toDouble() ?? 100.0;
        
        // Calculate nutrition based on quantity
        final calories = (foodItem['energy_kcal'] as num?)?.toDouble() ?? 0.0;
        final protein = (foodItem['protein_g'] as num?)?.toDouble() ?? 0.0;
        final carbs = (foodItem['carbohydrate_g'] as num?)?.toDouble() ?? 0.0;
        final fat = (foodItem['fat_g'] as num?)?.toDouble() ?? 0.0;
        
        final multiplier = quantity / 100.0; // Nutrition per 100g
        
        return {
          'id': entry['id'],
          'meal_type': entry['meal_type'],
          'food_name': foodItem['name'],
          'quantity_g': quantity,
          'calories': calories * multiplier,
          'protein_g': protein * multiplier,
          'carbohydrate_g': carbs * multiplier,
          'fat_g': fat * multiplier,
          'entry_date': entry['entry_date'],
          'created_at': entry['created_at'],
          'meal_photo_url': includePhotos ? entry['meal_photo_url'] : null,
          'satisfaction_rating': entry['satisfaction_rating'],
        };
      }).toList();
    });
  }

  @override
  Future<Either<Failure, DietFeedback>> addDietFeedback(
    CreateDietFeedbackRequest request,
  ) async {
    return safeCall(() async {
      final feedbackId = _uuid.v4();
      final now = DateTime.now();

      final feedbackData = {
        'id': feedbackId,
        'group_id': request.groupId,
        'member_id': request.memberId,
        'trainer_id': request.trainerId,
        'meal_entry_id': request.mealEntryId,
        'feedback_text': request.feedbackText,
        'feedback_type': _feedbackTypeToString(request.feedbackType),
        'created_at': now.toIso8601String(),
        'is_read': false,
      };

      await _supabaseClient
          .from('diet_feedbacks')
          .insert(feedbackData);

      return DietFeedbackModel.fromJson(feedbackData).toEntity();
    });
  }

  @override
  Future<Either<Failure, List<DietFeedback>>> getDietFeedbacks(
    String groupId,
    String memberId, {
    int limit = 20,
    int offset = 0,
    FeedbackType? feedbackType,
  }) async {
    return safeCall(() async {
      var query = _supabaseClient
          .from('diet_feedbacks')
          .select('''
            *,
            user_profiles!trainer_id(username, profile_image_url)
          ''')
          .eq('group_id', groupId)
          .eq('member_id', memberId);

      if (feedbackType != null) {
        query = query.eq('feedback_type', _feedbackTypeToString(feedbackType));
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).map((json) {
        return DietFeedbackModel.fromJson(json).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, List<DietFeedback>>> getGroupDietFeedbacks(
    String groupId, {
    int limit = 50,
    int offset = 0,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return safeCall(() async {
      var query = _supabaseClient
          .from('diet_feedbacks')
          .select('''
            *,
            user_profiles!trainer_id(username, profile_image_url),
            member_profiles:user_profiles!member_id(username)
          ''')
          .eq('group_id', groupId);

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).map((json) {
        return DietFeedbackModel.fromJson(json).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, void>> markFeedbackAsRead(String feedbackId) async {
    return safeCall(() async {
      await _supabaseClient
          .from('diet_feedbacks')
          .update({'is_read': true})
          .eq('id', feedbackId);
    });
  }

  @override
  Future<Either<Failure, void>> markMultipleFeedbacksAsRead(
    List<String> feedbackIds,
  ) async {
    return safeCall(() async {
      await _supabaseClient
          .from('diet_feedbacks')
          .update({'is_read': true})
          .inFilter('id', feedbackIds);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDietAnalytics(
    DietAnalyticsRequest request,
  ) async {
    return safeCall(() async {
      // Get meal entries for the period
      List<String> memberIds;
      
      if (request.memberId != null) {
        memberIds = [request.memberId!];
      } else {
        // Get all group members
        final membersResponse = await _supabaseClient
            .from('group_members')
            .select('user_id')
            .eq('group_id', request.groupId)
            .eq('is_active', true);
        
        memberIds = (membersResponse as List)
            .map((m) => m['user_id'] as String)
            .toList();
      }

      final analytics = <String, dynamic>{
        'period_start': request.startDate.toIso8601String().split('T')[0],
        'period_end': request.endDate.toIso8601String().split('T')[0],
        'member_count': memberIds.length,
        'total_meals': 0,
        'average_calories_per_day': 0.0,
        'average_protein_per_day': 0.0,
        'average_carbs_per_day': 0.0,
        'average_fat_per_day': 0.0,
        'goal_achievement_rates': <String, double>{},
        'member_analytics': <Map<String, dynamic>>[],
      };

      double totalCalories = 0.0;
      double totalProtein = 0.0;
      double totalCarbs = 0.0;
      double totalFat = 0.0;
      int totalMeals = 0;

      for (final memberId in memberIds) {
        final memberMealsResult = await getMemberMealEntries(
          memberId,
          request.startDate,
          request.endDate,
          includePhotos: false,
        );

        final memberMeals = memberMealsResult.fold(
          (failure) => <Map<String, dynamic>>[],
          (meals) => meals,
        );

        final memberCalories = memberMeals.fold<double>(
          0.0,
          (sum, meal) => sum + (meal['calories'] as double),
        );
        final memberProtein = memberMeals.fold<double>(
          0.0,
          (sum, meal) => sum + (meal['protein_g'] as double),
        );
        final memberCarbs = memberMeals.fold<double>(
          0.0,
          (sum, meal) => sum + (meal['carbohydrate_g'] as double),
        );
        final memberFat = memberMeals.fold<double>(
          0.0,
          (sum, meal) => sum + (meal['fat_g'] as double),
        );

        totalCalories += memberCalories;
        totalProtein += memberProtein;
        totalCarbs += memberCarbs;
        totalFat += memberFat;
        totalMeals += memberMeals.length;

        analytics['member_analytics'].add({
          'member_id': memberId,
          'total_calories': memberCalories,
          'total_protein': memberProtein,
          'total_carbs': memberCarbs,
          'total_fat': memberFat,
          'meal_count': memberMeals.length,
        });
      }

      final days = request.endDate.difference(request.startDate).inDays + 1;
      
      analytics['total_meals'] = totalMeals;
      analytics['average_calories_per_day'] = totalCalories / days;
      analytics['average_protein_per_day'] = totalProtein / days;
      analytics['average_carbs_per_day'] = totalCarbs / days;
      analytics['average_fat_per_day'] = totalFat / days;

      return analytics;
    });
  }

  @override
  Future<Either<Failure, PTGroupDietSummary>> createDietSummary(
    String groupId,
    String memberId,
    DateTime date,
  ) async {
    return safeCall(() async {
      // Get member's meal entries for the date
      final mealEntriesResult = await getMemberMealEntries(
        memberId,
        date,
        date.add(const Duration(days: 1)),
      );

      final mealEntries = mealEntriesResult.fold(
        (failure) => <Map<String, dynamic>>[],
        (entries) => entries,
      );

      // Get member's profile and goals
      final profileResponse = await _supabaseClient
          .from('user_profiles')
          .select('username, daily_calorie_goal')
          .eq('id', memberId)
          .single();

      final username = profileResponse['username'] as String;
      final calorieGoal = (profileResponse['daily_calorie_goal'] as num?)?.toDouble() ?? 2000.0;
      final proteinGoal = calorieGoal * 0.3 / 4; // 30% of calories from protein

      // Calculate totals
      final totalCalories = mealEntries.fold<double>(
        0.0,
        (sum, meal) => sum + (meal['calories'] as double),
      );
      final totalProtein = mealEntries.fold<double>(
        0.0,
        (sum, meal) => sum + (meal['protein_g'] as double),
      );
      final totalCarbs = mealEntries.fold<double>(
        0.0,
        (sum, meal) => sum + (meal['carbohydrate_g'] as double),
      );
      final totalFat = mealEntries.fold<double>(
        0.0,
        (sum, meal) => sum + (meal['fat_g'] as double),
      );

      final mealPhotoUrls = mealEntries
          .where((meal) => meal['meal_photo_url'] != null)
          .map((meal) => meal['meal_photo_url'] as String)
          .toList();

      final lastMealTime = mealEntries.isNotEmpty
          ? DateTime.parse(mealEntries.first['created_at'] as String)
          : date;

      final summaryId = _uuid.v4();
      final summaryData = {
        'id': summaryId,
        'group_id': groupId,
        'member_id': memberId,
        'member_name': username,
        'summary_date': date.toIso8601String().split('T')[0],
        'total_calories': totalCalories,
        'total_protein': totalProtein,
        'total_carbs': totalCarbs,
        'total_fat': totalFat,
        'meal_count': mealEntries.length,
        'calorie_goal': calorieGoal,
        'protein_goal': proteinGoal,
        'meal_photo_urls': mealPhotoUrls,
        'trainer_note': null,
        'last_meal_time': lastMealTime.toIso8601String(),
      };

      // Upsert the summary
      await _supabaseClient
          .from('pt_group_diet_summaries')
          .upsert(summaryData, onConflict: 'group_id,member_id,summary_date');

      return PTGroupDietSummaryModel.fromJson(summaryData).toEntity();
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMemberGoalAchievement(
    String memberId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return safeCall(() async {
      final mealEntriesResult = await getMemberMealEntries(
        memberId,
        startDate,
        endDate,
        includePhotos: false,
      );

      final mealEntries = mealEntriesResult.fold(
        (failure) => <Map<String, dynamic>>[],
        (entries) => entries,
      );

      // Get member's goals
      final profileResponse = await _supabaseClient
          .from('user_profiles')
          .select('daily_calorie_goal')
          .eq('id', memberId)
          .single();

      final calorieGoal = (profileResponse['daily_calorie_goal'] as num?)?.toDouble() ?? 2000.0;
      final proteinGoal = calorieGoal * 0.3 / 4;

      // Group meals by date
      final mealsByDate = <String, List<Map<String, dynamic>>>{};
      for (final meal in mealEntries) {
        final date = meal['entry_date'] as String;
        mealsByDate[date] = (mealsByDate[date] ?? [])..add(meal);
      }

      final dailyAchievements = <Map<String, dynamic>>[];
      double totalCalorieAchievement = 0.0;
      double totalProteinAchievement = 0.0;

      for (final entry in mealsByDate.entries) {
        final date = entry.key;
        final dayMeals = entry.value;

        final dayCalories = dayMeals.fold<double>(
          0.0,
          (sum, meal) => sum + (meal['calories'] as double),
        );
        final dayProtein = dayMeals.fold<double>(
          0.0,
          (sum, meal) => sum + (meal['protein_g'] as double),
        );

        final calorieAchievement = (dayCalories / calorieGoal) * 100;
        final proteinAchievement = (dayProtein / proteinGoal) * 100;

        totalCalorieAchievement += calorieAchievement;
        totalProteinAchievement += proteinAchievement;

        dailyAchievements.add({
          'date': date,
          'calories': dayCalories,
          'protein': dayProtein,
          'calorie_achievement': calorieAchievement,
          'protein_achievement': proteinAchievement,
          'meal_count': dayMeals.length,
        });
      }

      final days = dailyAchievements.length;
      
      return {
        'period_start': startDate.toIso8601String().split('T')[0],
        'period_end': endDate.toIso8601String().split('T')[0],
        'calorie_goal': calorieGoal,
        'protein_goal': proteinGoal,
        'average_calorie_achievement': days > 0 ? totalCalorieAchievement / days : 0.0,
        'average_protein_achievement': days > 0 ? totalProteinAchievement / days : 0.0,
        'days_tracked': days,
        'daily_achievements': dailyAchievements,
      };
    });
  }

  @override
  Future<Either<Failure, int>> getUnreadFeedbackCount(String memberId) async {
    return safeCall(() async {
      final response = await _supabaseClient
          .from('diet_feedbacks')
          .select('id')
          .eq('member_id', memberId)
          .eq('is_read', false);

      return (response as List).length;
    });
  }

  @override
  Future<Either<Failure, void>> updateTrainerNotes(
    String summaryId,
    String trainerNotes,
  ) async {
    return safeCall(() async {
      await _supabaseClient
          .from('pt_group_diet_summaries')
          .update({'trainer_note': trainerNotes})
          .eq('id', summaryId);
    });
  }

  // Helper method to convert FeedbackType to string
  String _feedbackTypeToString(FeedbackType type) {
    switch (type) {
      case FeedbackType.positive:
        return 'positive';
      case FeedbackType.suggestion:
        return 'suggestion';
      case FeedbackType.concern:
        return 'concern';
    }
  }

  // Stub implementations for remaining abstract methods
  @override
  Future<Either<Failure, Map<String, dynamic>>> getGroupDietCompliance(String groupId, DateTime startDate, DateTime endDate) async {
    return safeCall(() async => <String, dynamic>{});
  }

  @override
  Future<Either<Failure, PTGroupDietPermission>> setDietPermissions(DietPermissionRequest request) async {
    return safeCall(() async {
      // This would require implementing PTGroupDietPermissionModel
      throw UnimplementedError('PTGroupDietPermission model not implemented');
    });
  }

  @override
  Future<Either<Failure, PTGroupDietPermission?>> getDietPermissions(String groupId, String memberId, String trainerId) async {
    return safeCall(() async => null);
  }

  @override
  Future<Either<Failure, List<PTGroupDietPermission>>> getGroupDietPermissions(String groupId, String trainerId) async {
    return safeCall(() async => <PTGroupDietPermission>[]);
  }

  @override
  Future<Either<Failure, void>> revokeDietPermissions(String groupId, String memberId, String trainerId) async {
    return safeCall(() async {});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMemberDietTrends(String memberId, DateTime startDate, DateTime endDate, {String? groupId}) async {
    return safeCall(() async => <String, dynamic>{});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getGroupDietComparison(String groupId, DateTime startDate, DateTime endDate) async {
    return safeCall(() async => <String, dynamic>{});
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getDietRecommendations(String memberId, DateTime startDate, DateTime endDate) async {
    return safeCall(() async => <Map<String, dynamic>>[]);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMealTimingAnalysis(String memberId, DateTime startDate, DateTime endDate) async {
    return safeCall(() async => <String, dynamic>{});
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getNutritionAlerts(String groupId, {String? memberId, DateTime? date}) async {
    return safeCall(() async => <Map<String, dynamic>>[]);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDietPhotoAnalysis(String mealEntryId) async {
    return safeCall(() async => <String, dynamic>{});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRecentDietActivity(String groupId, {int hours = 24}) async {
    return safeCall(() async => <String, dynamic>{});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportMemberDietData(String memberId, DateTime startDate, DateTime endDate, {String format = 'json'}) async {
    return safeCall(() async => <String, dynamic>{});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDietCoachingInsights(String groupId, String memberId, DateTime startDate, DateTime endDate) async {
    return safeCall(() async => <String, dynamic>{});
  }

  @override
  Future<Either<Failure, void>> scheduleDietReminder(String groupId, String memberId, DateTime reminderTime, String message) async {
    return safeCall(() async {});
  }

  @override
  Future<Either<Failure, double>> getDietAdherenceScore(String memberId, DateTime startDate, DateTime endDate) async {
    return safeCall(() async => 0.0);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMacroDistributionAnalysis(String memberId, DateTime startDate, DateTime endDate) async {
    return safeCall(() async => <String, dynamic>{});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getHydrationData(String memberId, DateTime startDate, DateTime endDate) async {
    return safeCall(() async => <String, dynamic>{});
  }

  @override
  Future<Either<Failure, void>> updateMemberDietGoals(String memberId, double calorieGoal, double proteinGoal, double carbGoal, double fatGoal) async {
    return safeCall(() async {});
  }
}