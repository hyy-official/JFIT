import 'package:dartz/dartz.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import 'package:jfit/features/workout_program/data/repositories/workout_program_repository.dart';
import 'package:jfit/features/workout_program/data/models/user_program_model.dart';
import 'package:jfit/features/workout_program/data/models/current_workout_info_model.dart';
import 'package:jfit/features/programs/data/models/user_program_day_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutProgramRepositoryImpl extends WorkoutProgramRepository with BaseRepositoryMixin {
  final SupabaseClient _supabaseClient;

  WorkoutProgramRepositoryImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<Either<Failure, List<UserProgramModel>>> getUserPrograms(String userId) async {
    return safeCall(() async {
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
      
      return (response as List)
          .map((json) => UserProgramModel.fromJson(json))
          .toList();
    });
  }

  @override
  Future<Either<Failure, UserProgramModel?>> getUserProgramDetails(String userProgramId) async {
    return safeCall(() async {
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
        
        return UserProgramModel.fromJson(response);
      } catch (e) {
        // If no data found, return null instead of throwing
        if (e is PostgrestException && (e.code == 'PGRST116' || e.message.contains('0 rows'))) {
          return null;
        }
        rethrow;
      }
    });
  }

  @override
  Future<Either<Failure, List<UserProgramDayModel>>> getUserProgramDays(String userProgramId) async {
    return safeCall(() async {
      final response = await _supabaseClient
          .from('user_program_days')
          .select('*')
          .eq('user_program_id', userProgramId)
          .order('week', ascending: true)
          .order('day', ascending: true);
      
      return (response as List)
          .map((json) => UserProgramDayModel.fromJson(json))
          .toList();
    });
  }

  @override
  Future<Either<Failure, void>> updateUserProgramProgress(
    String userProgramId,
    int currentWeek,
    int currentDay,
  ) async {
    return safeCall(() async {
      await _supabaseClient
          .from('user_programs')
          .update({
            'current_week': currentWeek,
            'current_day': currentDay,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userProgramId);
    });
  }

  @override
  Future<Either<Failure, void>> completeUserProgramDay(
    String userProgramId,
    int week,
    int day, {
    String? note,
  }) async {
    return safeCall(() async {
      // Get user_id from user_program first
      final userProgram = await _supabaseClient
          .from('user_programs')
          .select('user_id')
          .eq('id', userProgramId)
          .single();
      
      // Upsert the program day completion
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
          onConflict: 'user_program_id,week,day'
          );
    });
  }

  @override
  Future<Either<Failure, void>> deleteUserProgram(String userProgramId) async {
    return safeCall(() async {
      await _supabaseClient
          .from('user_programs')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userProgramId);
    });
  }

  @override
  Future<Either<Failure, CurrentWorkoutInfoModel>> getCurrentWorkoutInfo(String userId) async {
    return safeCall(() async {
      // Get latest active user program
      final latestProgramResult = await getLatestActiveUserProgram(userId);
      
      return latestProgramResult.fold(
        (failure) => throw failure,
        (userProgram) async {
          if (userProgram == null) {
            return CurrentWorkoutInfoModel.empty();
          }

          // Get completed days count
          final completedDaysResponse = await _supabaseClient
              .from('user_program_days')
              .select('id')
              .eq('user_program_id', userProgram.id)
              .not('completed_at', 'is', null);

          final totalCompletedDays = (completedDaysResponse as List).length;

          // Get last workout date
          DateTime? lastWorkoutDate;
          if (completedDaysResponse.isNotEmpty) {
            final lastCompletedResponse = await _supabaseClient
                .from('user_program_days')
                .select('completed_at')
                .eq('user_program_id', userProgram.id)
                .not('completed_at', 'is', null)
                .order('completed_at', ascending: false)
                .limit(1);

            if (lastCompletedResponse.isNotEmpty) {
              lastWorkoutDate = DateTime.parse(lastCompletedResponse.first['completed_at'] as String);
            }
          }

          return CurrentWorkoutInfoModel.fromUserProgram(
            userProgram,
            lastWorkoutDate: lastWorkoutDate,
            totalCompletedDays: totalCompletedDays,
          );
        },
      );
    });
  }

  @override
  Future<Either<Failure, UserProgramModel?>> getLatestActiveUserProgram(String userId) async {
    return safeCall(() async {
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
            .order('started_at', ascending: false)
            .limit(1);
        
        if ((response as List).isNotEmpty) {
          return UserProgramModel.fromJson(response.first);
        }
        return null;
      } catch (e) {
        // If no data found, return null instead of throwing
        if (e is PostgrestException && (e.code == 'PGRST116' || e.message.contains('0 rows'))) {
          return null;
        }
        rethrow;
      }
    });
  }
}