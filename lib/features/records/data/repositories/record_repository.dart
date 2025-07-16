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

  /// 사용자의 활성 운동 프로그램 목록 가져오기
  Future<List<Map<String, dynamic>>> getUserPrograms(String userId) async {
    try {
      final response = await _supabaseClient
          .from('user_programs')
          .select('''
            *,
            workout_programs(
              id,
              name,
              creator,
              description,
              duration_weeks,
              difficulty_level,
              program_type,
              workouts_per_week,
              image_url
            )
          ''')
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('started_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get user programs: $e');
    }
  }

  /// 특정 사용자 프로그램의 운동 세부 정보 가져오기
  Future<Map<String, dynamic>?> getUserProgramDetails(String userProgramId) async {
    try {
      final response = await _supabaseClient
          .from('user_programs')
          .select('''
            *,
            workout_programs(
              id,
              name,
              creator,
              description,
              duration_weeks,
              difficulty_level,
              program_type,
              workouts_per_week,
              image_url
            )
          ''')
          .eq('id', userProgramId)
          .single();
      
      return response;
    } catch (e) {
      return null;
    }
  }

  /// 사용자 프로그램 일차 완료 상태 가져오기
  Future<List<Map<String, dynamic>>> getUserProgramDays(String userProgramId) async {
    try {
      final response = await _supabaseClient
          .from('user_program_days')
          .select('*')
          .eq('user_program_id', userProgramId)
          .order('week', ascending: true)
          .order('day', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// 사용자 프로그램 일차 완료 처리
  Future<void> completeUserProgramDay(String userProgramId, int week, int day, {String? note}) async {
    try {
      // user_id를 가져오기 위해 user_program을 먼저 조회
      final userProgram = await _supabaseClient
          .from('user_programs')
          .select('user_id')
          .eq('id', userProgramId)
          .single();
      
      // upsert를 사용하여 기존 레코드 업데이트 또는 새 레코드 생성
      await _supabaseClient
          .from('user_program_days')
          .upsert({
        'user_program_id': userProgramId,
            'user_id': userProgram['user_id'],
        'week': week,
        'day': day,
        'completed_at': DateTime.now().toIso8601String(),
        'note': note,
            'updated_at': DateTime.now().toIso8601String(),
          }, 
          onConflict: 'user_program_id,week,day' // unique constraint 기반
          );
    } catch (e) {
      throw Exception('Failed to complete program day: $e');
    }
  }

  /// 사용자 프로그램 현재 진행 상황 업데이트
  Future<void> updateUserProgramProgress(String userProgramId, int currentWeek, int currentDay) async {
    try {
      await _supabaseClient
          .from('user_programs')
          .update({
            'current_week': currentWeek,
            'current_day': currentDay,
          })
          .eq('id', userProgramId);
    } catch (e) {
      throw Exception('Failed to update program progress: $e');
    }
  }

  /// 운동 세션 생성
  Future<String> createWorkoutSession(String userProgramId, Map<String, dynamic> exercisesJson) async {
    try {
      final response = await _supabaseClient
          .from('workout_sessions')
          .insert({
            'user_program_id': userProgramId,
            'session_date': DateTime.now().toIso8601String().split('T')[0],
            'started_at': DateTime.now().toIso8601String(),
            'exercises_json': exercisesJson,
          })
          .select('id')
          .single();
      
      return response['id'] as String;
    } catch (e) {
      throw Exception('Failed to create workout session: $e');
    }
  }

  /// 운동 세션 완료 처리
  Future<void> completeWorkoutSession(String sessionId) async {
    try {
      await _supabaseClient
          .from('workout_sessions')
          .update({
            'ended_at': DateTime.now().toIso8601String(),
            'is_completed': true,
          })
          .eq('id', sessionId);
    } catch (e) {
      throw Exception('Failed to complete workout session: $e');
    }
  }

  /// 운동 실행 정보 (exercises 테이블)에서 운동 세부 정보 가져오기
  Future<List<Map<String, dynamic>>> getExerciseDetails(List<String> exerciseIds) async {
    try {
      final response = await _supabaseClient
          .from('exercises')
          .select('*')
          .inFilter('id', exerciseIds);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// 운동 이름으로 운동 정보 검색
  Future<List<Map<String, dynamic>>> searchExercises(String query) async {
    try {
      final response = await _supabaseClient
          .from('exercises')
          .select('*')
          .or('title_ko.ilike.%$query%,title_en.ilike.%$query%')
          .eq('is_active', true)
          .order('popularity_score', ascending: false)
          .limit(20);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
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

  /// 사용자 프로그램 삭제 (비활성화)
  Future<void> deleteUserProgram(String userProgramId) async {
    try {
      await _supabaseClient
          .from('user_programs')
          .update({'is_active': false})
          .eq('id', userProgramId);
    } catch (e) {
      throw Exception('Failed to delete user program: $e');
    }
  }

  // =========================== 워크아웃 세션 관련 메서드들 ===========================

  /// 워크아웃 세션 생성/업데이트
  Future<String> upsertWorkoutSession(Map<String, dynamic> sessionData) async {
    try {
      final response = await _supabaseClient
          .from('workout_sessions')
          .upsert(sessionData)
          .select('id')
          .single();
      
      return response['id'] as String;
    } catch (e) {
      throw Exception('Failed to upsert workout session: $e');
    }
  }

  /// 워크아웃 세션 조회
  Future<Map<String, dynamic>?> getWorkoutSession(String sessionId) async {
    try {
      final response = await _supabaseClient
          .from('workout_sessions')
          .select('*')
          .eq('id', sessionId)
          .single();
      
      return response;
    } catch (e) {
      return null;
    }
  }

  /// 사용자의 모든 워크아웃 세션 조회
  Future<List<Map<String, dynamic>>> getWorkoutSessions(String userId) async {
    try {
      final response = await _supabaseClient
          .from('workout_sessions')
          .select('*')
          .eq('user_id', userId)
          .order('started_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// 최근 활성 사용자 프로그램 조회
  Future<Map<String, dynamic>?> getLatestActiveUserProgram(String userId) async {
    try {
      final response = await _supabaseClient
          .from('user_programs')
          .select('*')
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('started_at', ascending: false)
          .limit(1);
      
      if (response.isNotEmpty) {
        return response.first;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 운동 이름으로 운동 ID 조회
  Future<String?> getExerciseIdByName(String exerciseName) async {
    try {
      final response = await _supabaseClient
          .from('exercises')
          .select('id')
          .or('title_ko.eq.$exerciseName,title_en.eq.$exerciseName')
          .limit(1);
      
      if (response.isNotEmpty) {
        return response.first['id'] as String;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 새로운 커스텀 운동 생성
  Future<String> createCustomExercise(String exerciseName) async {
    try {
      final response = await _supabaseClient
          .from('exercises')
          .insert({
            'title_ko': exerciseName,
            'title_en': exerciseName,
            'category': 'custom',
            'is_active': true,
            'popularity_score': 0,
          })
          .select('id')
          .single();
      
      return response['id'] as String;
    } catch (e) {
      throw Exception('Failed to create custom exercise: $e');
    }
  }

  /// 워크아웃 로그 생성
  Future<void> insertWorkoutLog({
    required String exerciseId,
    required String sessionId,
    required int sets,
    required int reps,
    required double weight,
  }) async {
    try {
      await _supabaseClient.from('workout_logs').insert({
        'exercise_id': exerciseId,
        'session_id': sessionId,
        'set_number': sets,
        'reps': reps,
        'weight': weight,
        'logged_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to insert workout log: $e');
    }
  }

  /// 특정 운동의 마지막 로그 조회
  Future<Map<String, dynamic>?> getLastWorkoutLogByExercise(String exerciseId, String userId) async {
    try {
      final response = await _supabaseClient
          .from('workout_logs')
          .select('''
            *,
            workout_sessions!inner(user_id)
          ''')
          .eq('exercise_id', exerciseId)
          .eq('workout_sessions.user_id', userId)
          .order('logged_at', ascending: false)
          .limit(1);
      
      if (response.isNotEmpty) {
        return response.first;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 현재 진행 중인 워크아웃 세션 조회 (완료되지 않은 세션)
  Future<List<Map<String, dynamic>>> getActiveWorkoutSessions(String userId) async {
    try {
      final response = await _supabaseClient
          .from('workout_sessions')
          .select('*')
          .eq('user_id', userId)
          .eq('is_completed', false)
          .order('started_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}
