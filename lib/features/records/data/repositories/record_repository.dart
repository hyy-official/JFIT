import 'package:jfit/features/records/data/models/meal_record_model.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecordRepository {
  final SupabaseClient _supabaseClient;

  RecordRepository() : _supabaseClient = Supabase.instance.client;


  Future<List<MealRecord>> getMealRecords(int userId, {DateTime? date}) async {
    try {
      var query = _supabaseClient
          .from('meal_records')
          .select('*, meal_items!inner(*, foods!inner(*))')
          .eq('user_id', userId);

      if (date != null) {
        query = query.eq('meal_date', date.toIso8601String().split('T')[0]);
      }

      final response = await query.order('meal_date', ascending: false);

      return (response as List).map((json) => MealRecord.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load meal records: ${e.toString()}');
    }
  }

  Future<MealRecord> addMealRecord(MealRecord record) async {
    try {
      final response = await _supabaseClient.from('meal_records').insert({
        'user_id': record.userId,
        'meal_date': record.mealDate.toIso8601String().split('T')[0],
        'meal_type': record.mealType,
        'total_calories': record.totalCalories,
        'total_protein': record.totalProtein,
        'total_carbs': record.totalCarbs,
        'total_fat': record.totalFat,
        'notes': record.notes,
        'photo_url': record.photoUrl,
      }).select().single();

      // TODO: meal_items 및 foods 테이블에 대한 추가 로직 구현 필요
      // (예: 기존 음식 조회, 새 음식 추가, 식사 항목 추가)

      return MealRecord.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add meal record: ${e.toString()}');
    }
  }

  Future<MealRecord> updateMealRecord(MealRecord record) async {
    try {
      final response = await _supabaseClient.from('meal_records').update({
        'meal_date': record.mealDate.toIso8601String().split('T')[0],
        'meal_type': record.mealType,
        'total_calories': record.totalCalories,
        'total_protein': record.totalProtein,
        'total_carbs': record.totalCarbs,
        'total_fat': record.totalFat,
        'notes': record.notes,
        'photo_url': record.photoUrl,
      }).eq('id', record.id).select().single();

      // TODO: meal_items 업데이트 로직 구현 필요

      return MealRecord.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update meal record: ${e.toString()}');
    }
  }

  Future<void> deleteMealRecord(String recordId) async {
    try {
      await _supabaseClient.from('meal_records').delete().eq('id', recordId);
      // TODO: meal_items도 함께 삭제되는지 확인 (CASCADE 설정에 따라 다름)
    } catch (e) {
      throw Exception('Failed to delete meal record: ${e.toString()}');
    }
  }

  Future<UserDailySummary?> getDailySummary(int userId, DateTime date) async {
    try {
      final response = await _supabaseClient
          .from('user_daily_summaries')
          .select()
          .eq('user_id', userId)
          .eq('summary_date', date.toIso8601String().split('T')[0])
          .single();

      return UserDailySummary.fromJson(response);
    } catch (e) {
      // 데이터가 없으면 예외가 발생할 수 있으므로 null 반환
      if (e is PostgrestException && e.message.contains('0 rows')) {
        return null;
      }
      throw Exception('Failed to load daily summary: ${e.toString()}');
    }
  }
}
