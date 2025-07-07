import 'package:jfit/features/records/data/models/meal_record_model.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecordRepository {
  final SupabaseClient _supabaseClient;

  RecordRepository() : _supabaseClient = Supabase.instance.client;

  Future<List<MealRecord>> getMealRecords(String userId, {DateTime? date}) async {
    try {
      var query = _supabaseClient
          .from('meal_records')
          // 대시보드에서는 meal_items/foods 조인이 필요 없으므로 단순 조회로 변경
          .select('*')
          .eq('user_id', userId);

      if (date != null) {
        query = query.eq('meal_date', date.toIso8601String().split('T')[0]);
      }

      final response = await query.order('meal_date', ascending: false);

      return (response as List).map((json) => MealRecord.fromJson(json)).toList();
    } on PostgrestException catch (_) {
      // 관계가 없거나 데이터가 없으면 빈 리스트 반환
      return [];
    } catch (e) {
      // 기타 예외도 빈 리스트 처리해 UI가 오류 대신 "데이터 없음" 표시하도록 함
      return [];
    }
  }

  Future<void> addMealRecord(MealRecord mealRecord) async {
    try {
      await _supabaseClient.from('meal_records').insert(mealRecord.toJson());
    } catch (e) {
      throw Exception('Failed to add meal record: $e');
    }
  }

  Future<void> updateMealRecord(MealRecord mealRecord) async {
    try {
      await _supabaseClient
          .from('meal_records')
          .update(mealRecord.toJson())
          .eq('id', mealRecord.id);
    } catch (e) {
      throw Exception('Failed to update meal record: $e');
    }
  }

  Future<void> deleteMealRecord(String recordId) async {
    try {
      await _supabaseClient.from('meal_records').delete().eq('id', recordId);
    } catch (e) {
      throw Exception('Failed to delete meal record: $e');
    }
  }

  Future<UserDailySummary?> getDailySummary(String userId, DateTime date) async {
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
      if (e is PostgrestException && (e.code == 'PGRST116' || e.message.contains('0 rows'))) {
        // 데이터가 없으면 null을 반환하여 BLoC에서 처리하도록 함
        return null;
      }
      throw Exception('Failed to load daily summary: $e');
    }
  }

  Future<void> upsertDailySummary(UserDailySummary summary) async {
    try {
      await _supabaseClient
          .from('user_daily_summaries')
          .upsert(summary.toJson());
    } catch (e) {
      throw Exception('Failed to upsert daily summary: $e');
    }
  }
}
