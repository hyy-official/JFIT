import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import 'package:jfit/features/programs/data/models/workout_session_model.dart';
import 'workout_session_repository.dart';

/// Implementation of WorkoutSessionRepository
/// Handles workout session data operations using Supabase
class WorkoutSessionRepositoryImpl extends WorkoutSessionRepository with BaseRepositoryMixin {
  final SupabaseClient _supabaseClient;

  WorkoutSessionRepositoryImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<Either<Failure, String>> createWorkoutSession({
    required String userProgramId,
    required Map<String, dynamic> exercisesJson,
  }) async {
    return safeCall(() async {
      // Get user_id from user_program
      final userProgramResponse = await _supabaseClient
          .from('user_programs')
          .select('user_id')
          .eq('id', userProgramId)
          .single();

      final userId = userProgramResponse['user_id'] as String;

      final response = await _supabaseClient
          .from('workout_sessions')
          .insert({
            'user_id': userId,
            'user_program_id': userProgramId,
            'session_date': DateTime.now().toIso8601String().split('T')[0],
            'started_at': DateTime.now().toIso8601String(),
            'exercises_json': exercisesJson,
            'is_completed': false,
          })
          .select('id')
          .single();

      return response['id'] as String;
    });
  }

  @override
  Future<Either<Failure, WorkoutSessionModel?>> getWorkoutSession(String sessionId) async {
    return safeCall(() async {
      try {
        final response = await _supabaseClient
            .from('workout_sessions')
            .select('*')
            .eq('id', sessionId)
            .single();

        return WorkoutSessionModel.fromJson(response);
      } on PostgrestException catch (e) {
        if (e.code == 'PGRST116' || e.message.contains('0 rows')) {
          return null;
        }
        rethrow;
      }
    });
  }

  @override
  Future<Either<Failure, List<WorkoutSessionModel>>> getWorkoutSessions(String userId) async {
    return safeCall(() async {
      final response = await _supabaseClient
          .from('workout_sessions')
          .select('*')
          .eq('user_id', userId)
          .order('started_at', ascending: false);

      return (response as List)
          .map((json) => WorkoutSessionModel.fromJson(json))
          .toList();
    });
  }

  @override
  Future<Either<Failure, List<WorkoutSessionModel>>> getActiveWorkoutSessions(String userId) async {
    return safeCall(() async {
      final response = await _supabaseClient
          .from('workout_sessions')
          .select('*')
          .eq('user_id', userId)
          .eq('is_completed', false)
          .order('started_at', ascending: false);

      return (response as List)
          .map((json) => WorkoutSessionModel.fromJson(json))
          .toList();
    });
  }

  @override
  Future<Either<Failure, WorkoutSessionModel>> updateWorkoutSession({
    required String sessionId,
    required Map<String, dynamic> updates,
  }) async {
    return safeCall(() async {
      final response = await _supabaseClient
          .from('workout_sessions')
          .update(updates)
          .eq('id', sessionId)
          .select('*')
          .single();

      return WorkoutSessionModel.fromJson(response);
    });
  }

  @override
  Future<Either<Failure, WorkoutSessionModel>> completeWorkoutSession(String sessionId) async {
    return safeCall(() async {
      final response = await _supabaseClient
          .from('workout_sessions')
          .update({
            'ended_at': DateTime.now().toIso8601String(),
            'is_completed': true,
          })
          .eq('id', sessionId)
          .select('*')
          .single();

      return WorkoutSessionModel.fromJson(response);
    });
  }

  @override
  Future<Either<Failure, void>> logWorkoutSet({
    required String sessionId,
    required String exerciseId,
    required int setNumber,
    required int reps,
    required double weight,
  }) async {
    return safeCall(() async {
      await _supabaseClient.from('workout_logs').insert({
        'session_id': sessionId,
        'exercise_id': exerciseId,
        'set_number': setNumber,
        'reps': reps,
        'weight': weight,
        'logged_at': DateTime.now().toIso8601String(),
      });
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> getLastWorkoutLogByExercise({
    required String exerciseId,
    required String userId,
  }) async {
    return safeCall(() async {
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
          return response.first as Map<String, dynamic>;
        }
        return null;
      } on PostgrestException catch (e) {
        if (e.code == 'PGRST116' || e.message.contains('0 rows')) {
          return null;
        }
        rethrow;
      }
    });
  }

  @override
  Future<Either<Failure, String>> getOrCreateExerciseId(String exerciseName) async {
    return safeCall(() async {
      // First try to find existing exercise
      final existingResponse = await _supabaseClient
          .from('exercises')
          .select('id')
          .or('title_ko.eq.$exerciseName,title_en.eq.$exerciseName')
          .limit(1);

      if (existingResponse.isNotEmpty) {
        return existingResponse.first['id'] as String;
      }

      // Create new custom exercise if not found
      final createResponse = await _supabaseClient
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

      return createResponse['id'] as String;
    });
  }
}