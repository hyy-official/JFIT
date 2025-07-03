import 'package:jfit/features/exercise/data/models/exercise_record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExerciseRepository {
  final SupabaseClient _supabaseClient;

  ExerciseRepository() : _supabaseClient = Supabase.instance.client;

  Future<List<ExerciseRecord>> getExerciseRecords(int userId) async {
    try {
      final response = await _supabaseClient
          .from('workout_exercises')
          .select('*, workout_sessions!inner(session_date, user_id), exercises!inner(name, type)')
          .eq('workout_sessions.user_id', userId)
          .order('workout_sessions.session_date', ascending: false)
          .order('order_in_session', ascending: true);

      return (response as List).map((json) {
        return ExerciseRecord(
          id: json['id'] as String,
          userId: json['workout_sessions']['user_id'] as int,
          exerciseName: json['exercises']['name'] as String,
          exerciseType: json['exercises']['type'] as String,
          durationMinutes: json['duration_minutes'] as int? ?? 0,
          caloriesBurned: json['calories_burned'] as int? ?? 0,
          exerciseDate: DateTime.parse(json['workout_sessions']['session_date'] as String),
          weightKg: (json['weight_kg'] as num?)?.toDouble(),
          sets: json['sets'] as int?,
          reps: json['reps'] as int?,
          distanceKm: (json['distance_km'] as num?)?.toDouble(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load exercise records: ${e.toString()}');
    }
  }

  Future<ExerciseRecord> addExerciseRecord(ExerciseRecord record) async {
    try {
      // 1. workout_sessions에 세션 추가 또는 기존 세션 ID 사용
      // 여기서는 간단하게 매번 새로운 세션을 생성한다고 가정합니다.
      // 실제 앱에서는 해당 날짜의 세션이 있는지 확인하고 재사용하는 로직이 필요합니다.
      final sessionResponse = await _supabaseClient.from('workout_sessions').insert({
        'user_id': record.userId,
        'session_date': record.exerciseDate.toIso8601String().split('T')[0], // 날짜만 저장
        'total_duration_minutes': record.durationMinutes,
        'total_calories_burned': record.caloriesBurned,
      }).select('id').single();

      final sessionId = sessionResponse['id'] as String;

      // 2. exercises 테이블에서 exercise_id 가져오기 (없으면 추가)
      // 실제로는 미리 정의된 운동 목록에서 선택하거나, 사용자가 새로운 운동을 추가할 수 있도록 해야 합니다.
      var exerciseId;
      try {
        final exerciseLookup = await _supabaseClient
            .from('exercises')
            .select('id')
            .eq('name', record.exerciseName)
            .single();
        exerciseId = exerciseLookup['id'] as String;
      } catch (_) {
        // 운동이 없으면 새로 추가 (간단한 예시)
        final newExercise = await _supabaseClient.from('exercises').insert({
          'name': record.exerciseName,
          'type': record.exerciseType,
        }).select('id').single();
        exerciseId = newExercise['id'] as String;
      }

      // 3. workout_exercises에 운동 기록 추가
      final response = await _supabaseClient.from('workout_exercises').insert({
        'session_id': sessionId,
        'exercise_id': exerciseId,
        'sets': record.sets,
        'reps': record.reps,
        'weight_kg': record.weightKg,
        'duration_minutes': record.durationMinutes,
        'distance_km': record.distanceKm,
        'calories_burned': record.caloriesBurned,
        'order_in_session': 1, // 임시로 1
      }).select().single();

      return ExerciseRecord.fromJson({
        ...response,
        'workout_sessions': {'session_date': record.exerciseDate.toIso8601String().split('T')[0], 'user_id': record.userId},
        'exercises': {'name': record.exerciseName, 'type': record.exerciseType},
      });
    } catch (e) {
      throw Exception('Failed to add exercise record: ${e.toString()}');
    }
  }

  Future<ExerciseRecord> updateExerciseRecord(ExerciseRecord record) async {
    try {
      // workout_exercises 테이블 업데이트
      final response = await _supabaseClient.from('workout_exercises').update({
        'sets': record.sets,
        'reps': record.reps,
        'weight_kg': record.weightKg,
        'duration_minutes': record.durationMinutes,
        'distance_km': record.distanceKm,
        'calories_burned': record.caloriesBurned,
      }).eq('id', record.id).select().single();

      // 관련 workout_sessions 업데이트 (예: 총 시간, 칼로리)
      // 이 부분은 복잡하므로, 실제 앱에서는 트리거 또는 백엔드 함수로 처리하는 것이 좋습니다.
      // 여기서는 간단히 해당 세션의 총합을 다시 계산하여 업데이트합니다.
      final sessionData = await _supabaseClient
          .from('workout_exercises')
          .select('duration_minutes, calories_burned')
          .eq('session_id', response['session_id'] as String);

      int totalDuration = 0;
      int totalCalories = 0;
      for (var item in sessionData) {
        totalDuration += (item['duration_minutes'] as int? ?? 0);
        totalCalories += (item['calories_burned'] as int? ?? 0);
      }

      await _supabaseClient.from('workout_sessions').update({
        'total_duration_minutes': totalDuration,
        'total_calories_burned': totalCalories,
      }).eq('id', response['session_id'] as String);

      return ExerciseRecord.fromJson({
        ...response,
        'workout_sessions': {'session_date': record.exerciseDate.toIso8601String().split('T')[0], 'user_id': record.userId},
        'exercises': {'name': record.exerciseName, 'type': record.exerciseType},
      });
    } catch (e) {
      throw Exception('Failed to update exercise record: ${e.toString()}');
    }
  }

  Future<void> deleteExerciseRecord(String recordId) async {
    try {
      // 삭제할 workout_exercise의 session_id를 먼저 가져옵니다.
      final recordToDelete = await _supabaseClient
          .from('workout_exercises')
          .select('session_id')
          .eq('id', recordId)
          .single();
      final sessionId = recordToDelete['session_id'] as String;

      // workout_exercises에서 해당 기록 삭제
      await _supabaseClient.from('workout_exercises').delete().eq('id', recordId);

      // 해당 세션에 더 이상 운동 기록이 없으면 workout_sessions에서도 삭제
      final remainingExercises = await _supabaseClient
          .from('workout_exercises')
          .select('id')
          .eq('session_id', sessionId);

      if (remainingExercises.isEmpty) {
        await _supabaseClient.from('workout_sessions').delete().eq('id', sessionId);
      } else {
        // 세션에 운동 기록이 남아있으면 total_duration_minutes와 total_calories_burned 업데이트
        final sessionData = await _supabaseClient
            .from('workout_exercises')
            .select('duration_minutes, calories_burned')
            .eq('session_id', sessionId);

        int totalDuration = 0;
        int totalCalories = 0;
        for (var item in sessionData) {
          totalDuration += (item['duration_minutes'] as int? ?? 0);
          totalCalories += (item['calories_burned'] as int? ?? 0);
        }

        await _supabaseClient.from('workout_sessions').update({
          'total_duration_minutes': totalDuration,
          'total_calories_burned': totalCalories,
        }).eq('id', sessionId);
      }
    } catch (e) {
      throw Exception('Failed to delete exercise record: ${e.toString()}');
    }
  }
}
