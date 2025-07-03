import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardRepository {
  final SupabaseClient _supabaseClient;

  DashboardRepository() : _supabaseClient = Supabase.instance.client;

  Future<List<UserDailySummary>> getDailySummaries(int userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      var query = _supabaseClient
          .from('user_daily_summaries')
          .select()
          .eq('user_id', userId);

      if (startDate != null) {
        query = query.gte('summary_date', startDate.toIso8601String().split('T')[0]);
      }
      if (endDate != null) {
        query = query.lte('summary_date', endDate.toIso8601String().split('T')[0]);
      }

      final response = await query.order('summary_date', ascending: true);

      return (response as List).map((json) => UserDailySummary.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load daily summaries: ${e.toString()}');
    }
  }
}
