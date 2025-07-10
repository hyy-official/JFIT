import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout_program_model.dart';

abstract class ProgramRemoteDataSource {
  Future<List<WorkoutProgramModel>> getPopularPrograms();
  Future<List<WorkoutProgramModel>> getPrograms({
    String? searchQuery,
    String? difficultyLevel,
    String? programType,
    int? workoutsPerWeek,
    List<String>? tags,
  });
  Future<WorkoutProgramModel> getProgramById(String id);
  Future<void> addProgramToUser(String programId, String userId);
  Future<List<WorkoutProgramModel>> getUserPrograms(String userId);
  Future<List<WorkoutProgramModel>> searchPrograms(String query);
}

class ProgramRemoteDataSourceImpl implements ProgramRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProgramRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<WorkoutProgramModel>> getPopularPrograms() async {
    try {
      final response = await supabaseClient
          .from('workout_programs')
          .select()
          .eq('is_popular', true)
          .eq('is_public', true)
          .order('rating', ascending: false)
          .limit(10);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((json) => WorkoutProgramModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch popular programs: $e');
    }
  }

  @override
  Future<List<WorkoutProgramModel>> getPrograms({
    String? searchQuery,
    String? difficultyLevel,
    String? programType,
    int? workoutsPerWeek,
    List<String>? tags,
  }) async {
    try {
      var query = supabaseClient
          .from('workout_programs')
          .select()
          .eq('is_public', true);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%,creator.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      if (difficultyLevel != null) {
        query = query.eq('difficulty_level', difficultyLevel);
      }

      if (programType != null) {
        query = query.eq('program_type', programType);
      }

      if (workoutsPerWeek != null) {
        query = query.eq('workouts_per_week', workoutsPerWeek);
      }

      if (tags != null && tags.isNotEmpty) {
        query = query.contains('tags', tags);
      }

      final response = await query
          .order('rating', ascending: false)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((json) => WorkoutProgramModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch programs: $e');
    }
  }

  @override
  Future<WorkoutProgramModel> getProgramById(String id) async {
    try {
      final response = await supabaseClient
          .from('workout_programs')
          .select()
          .eq('id', id)
          .single();

      return WorkoutProgramModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch program: $e');
    }
  }

  @override
  Future<void> addProgramToUser(String programId, String userId) async {
    try {
      await supabaseClient.from('user_programs').insert({
        'user_id': userId,
        'program_id': programId,
        'started_at': DateTime.now().toIso8601String(),
        'current_week': 1,
        'current_day': 1,
        'is_active': true,
        'exercises_json': <String, dynamic>{},
      });
    } catch (e) {
      throw Exception('Failed to add program to user: $e');
    }
  }

  @override
  Future<List<WorkoutProgramModel>> getUserPrograms(String userId) async {
    try {
      final response = await supabaseClient
          .from('user_programs')
          .select('*, workout_programs(*)')
          .eq('user_id', userId)
          .eq('is_active', true);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((json) {
            final Map<String, dynamic> item = json as Map<String, dynamic>;
            return WorkoutProgramModel.fromJson(item['workout_programs'] as Map<String, dynamic>);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user programs: $e');
    }
  }

  @override
  Future<List<WorkoutProgramModel>> searchPrograms(String query) async {
    try {
      final response = await supabaseClient
          .from('workout_programs')
          .select()
          .eq('is_public', true)
          .or('name.ilike.%$query%,creator.ilike.%$query%,description.ilike.%$query%')
          .order('rating', ascending: false)
          .limit(20);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((json) => WorkoutProgramModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search programs: $e');
    }
  }
} 