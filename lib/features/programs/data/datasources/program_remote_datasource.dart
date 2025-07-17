import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/error/failures.dart';
import '../../../workout_program/data/models/duplicate_check_result_model.dart';
import '../models/workout_program_model.dart';
import '../models/workout_session_model.dart';
import '../models/user_program_day_model.dart';
import '../models/workout_log_model.dart';
import '../models/exercise_model.dart';

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
  Future<Either<Failure, DuplicateCheckResult>> saveAsMyRoutine(String templateProgramId, String userId);
  Future<List<WorkoutProgramModel>> getUserPrograms(String userId);
  Future<List<WorkoutProgramModel>> searchPrograms(String query);
  // Day별 상태 및 운동 루틴 관련 메서드
  Future<List<UserProgramDayModel>> getUserProgramDays(String userProgramId);
  Future<List<WorkoutSessionModel>> getWorkoutSessionsByUserProgram(String userProgramId);
  Future<List<WorkoutLogModel>> getWorkoutLogsBySession(String sessionId);
  Future<ExerciseModel> getExerciseById(String exerciseId);
  
  // 프로그램 중복 체크 및 관리
  Future<Map<String, dynamic>?> checkProgramDuplicate(String programId, String userId);
  Future<void> restartProgram(String programId, String userId);
  Future<void> continueProgram(String programId, String userId);
  Future<void> cleanupDuplicatePrograms(String userId);
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
      // 1. 중복 체크 - 이미 활성화된 프로그램이 있는지 확인
      final existingPrograms = await supabaseClient
          .from('user_programs')
          .select('id')
          .eq('user_id', userId)
          .eq('program_id', programId)
          .eq('is_active', true);

      if (existingPrograms.isNotEmpty) {
        throw Exception('이미 추가된 프로그램입니다. 중복된 프로그램은 추가할 수 없습니다.');
      }

      // 2. 프로그램 정보 조회
      final programResponse = await supabaseClient
          .from('workout_programs')
          .select('duration_weeks, workouts_per_week')
          .eq('id', programId)
          .single();
      
      final durationWeeks = programResponse['duration_weeks'] as int? ?? 1;
      final workoutsPerWeek = programResponse['workouts_per_week'] as int? ?? 3;
      
      // 데이터 유효성 검증
      if (durationWeeks <= 0 || workoutsPerWeek <= 0) {
        throw Exception('잘못된 프로그램 정보입니다. (weeks: $durationWeeks, workouts: $workoutsPerWeek)');
      }
      
      // 디버깅을 위한 로그
      print('Program details: duration_weeks=$durationWeeks, workouts_per_week=$workoutsPerWeek');
      
      // 3. user_programs 테이블에 프로그램 추가
      final userProgramResponse = await supabaseClient
          .from('user_programs')
          .insert({
            'user_id': userId,
            'program_id': programId,
            'started_at': DateTime.now().toIso8601String(),
            'current_week': 1,
            'current_day': 1,
            'is_active': true,
            'exercises_json': <String, dynamic>{},
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      
      final userProgramId = userProgramResponse['id'] as String;
      
      // 3. user_program_days 테이블에 모든 주차와 일차 데이터 생성
      final userProgramDays = <Map<String, dynamic>>[];
      
      for (int week = 1; week <= durationWeeks; week++) {
        for (int day = 1; day <= workoutsPerWeek; day++) {
          userProgramDays.add({
            'user_program_id': userProgramId,
            'user_id': userId,
            'week': week,
            'day': day,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
      }
      
      print('Generated ${userProgramDays.length} program days for user $userId');
      
      // 4. user_program_days 테이블에 일괄 삽입
      if (userProgramDays.isNotEmpty) {
        try {
          await supabaseClient.from('user_program_days').insert(userProgramDays);
          print('Successfully inserted ${userProgramDays.length} program days');
        } catch (insertError) {
          print('Error inserting program days: $insertError');
          // user_program_days 삽입 실패해도 user_programs는 생성되었으므로 
          // 사용자에게 알리고 나중에 수동으로 생성할 수 있도록 함
          throw Exception('프로그램이 추가되었지만 일정 생성에 실패했습니다: $insertError');
        }
      } else {
        print('Warning: No program days to insert');
      }
      
    } catch (e) {
      throw Exception('Failed to add program to user: $e');
    }
  }

  @override
  Future<Either<Failure, DuplicateCheckResult>> saveAsMyRoutine(String templateProgramId, String userId) async {
    try {
      // 현재 사용자 인증 확인
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        return Left(WorkoutProgramPermissionFailure(
          technicalMessage: 'User authentication failed: currentUser=${currentUser?.id}, userId=$userId',
        ));
      }

      // 1. 중복 체크 - 이미 활성화된 프로그램이 있는지 확인
      final duplicateResult = await checkProgramDuplicate(templateProgramId, userId);
      if (duplicateResult != null) {
        // 중복이 발견된 경우 DuplicateCheckResult 반환
        final duplicateCheckResult = DuplicateCheckResult.fromMap(duplicateResult);
        return Left(ProgramDuplicateFailure(
          duplicateInfo: duplicateCheckResult.duplicateInfo!,
          technicalMessage: 'Duplicate program found: $templateProgramId for user $userId',
        ));
      }

      // 2. 템플릿 프로그램 정보 조회 (공개 프로그램만)
      final templateProgram = await supabaseClient
          .from('workout_programs')
          .select('name, duration_weeks, workouts_per_week, weekly_schedule, image_url')
          .eq('id', templateProgramId)
          .eq('is_public', true)
          .single();

      final programName = templateProgram['name'] as String;
      final durationWeeks = templateProgram['duration_weeks'] as int? ?? 4;
      final workoutsPerWeek = templateProgram['workouts_per_week'] as int? ?? 3;
      final weeklySchedule = templateProgram['weekly_schedule']; // dynamic으로 받기
      final imageUrl = templateProgram['image_url'] as String?;

      // 3. RPC 함수 호출 (트랜잭션 처리)
      final result = await supabaseClient.rpc('save_program_as_routine', params: {
        'p_user_id': userId,
        'p_template_program_id': templateProgramId,
        'p_program_name': programName,
        'p_duration_weeks': durationWeeks,
        'p_workouts_per_week': workoutsPerWeek,
        'p_weekly_schedule': weeklySchedule,
        'p_image_url': imageUrl,
      });

      // === 디버그 프린트 추가 ===
      print('=== [DEBUG] RPC Result Type: ${result.runtimeType}');
      print('=== [DEBUG] RPC Result Value: $result');
      // ======================

      if (result == null) {
        return Left(WorkoutProgramServerFailure(
          technicalMessage: 'RPC function returned null response',
        ));
      }

      Map<String, dynamic> resultMap;
      if (result is Map<String, dynamic>) {
        resultMap = result;
      } else if (result is List && result.isNotEmpty && result.first is Map<String, dynamic>) {
        resultMap = result.first as Map<String, dynamic>;
      } else {
        return Left(DataParsingFailure(
          message: 'Unexpected RPC response format',
          technicalMessage: 'Expected Map or List<Map>, got ${result.runtimeType}: $result',
        ));
      }

      final success = resultMap['success'] as bool? ?? false;
      final message = resultMap['message'] as String? ?? '';
      if (!success) {
        return Left(WorkoutProgramServerFailure(
          technicalMessage: 'RPC function failed: $message',
        ));
      }
      
      print('Program saved successfully: $message');
      
      // 성공적으로 저장된 경우 중복 없음 결과 반환
      return const Right(DuplicateCheckResult.noDuplicate());

    } catch (e) {
      print('Error saving program as routine: $e');
      
      // 에러 타입에 따른 적절한 실패 반환
      if (e.toString().contains('permission denied') || e.toString().contains('권한')) {
        return Left(WorkoutProgramPermissionFailure(
          technicalMessage: e.toString(),
        ));
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        return Left(WorkoutProgramNetworkFailure(
          technicalMessage: e.toString(),
        ));
      } else if (e.toString().contains('not found') || e.toString().contains('찾을 수 없')) {
        return Left(ProgramNotFoundFailure(
          programId: templateProgramId,
          technicalMessage: e.toString(),
        ));
      } else {
        return Left(WorkoutProgramUnknownFailure(
          technicalMessage: e.toString(),
        ));
      }
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

  @override
  Future<List<UserProgramDayModel>> getUserProgramDays(String userProgramId) async {
    final response = await supabaseClient
        .from('user_program_days')
        .select()
        .eq('user_program_id', userProgramId)
        .order('week')
        .order('day');
    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => UserProgramDayModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<WorkoutSessionModel>> getWorkoutSessionsByUserProgram(String userProgramId) async {
    try {
      print('🔍 [DEBUG] Fetching workout sessions for userProgramId: $userProgramId');
      
      final response = await supabaseClient
          .from('workout_sessions')
          .select()
          .eq('user_program_id', userProgramId)
          .order('session_date');
      
    
      
      final List<dynamic> data = response as List<dynamic>;
      
      final sessions = data.map((json) {
        return WorkoutSessionModel.fromJson(json as Map<String, dynamic>);
      }).toList();
      
      return sessions;
      
    } catch (e, stackTrace) {
      return []; // 에러 발생 시 빈 리스트 반환
    }
  }

  @override
  Future<List<WorkoutLogModel>> getWorkoutLogsBySession(String sessionId) async {
    final response = await supabaseClient
        .from('workout_logs')
        .select()
        .eq('session_id', sessionId)
        .order('exercise_index')
        .order('set_number');
    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => WorkoutLogModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<ExerciseModel> getExerciseById(String exerciseId) async {
    final response = await supabaseClient
        .from('exercises')
        .select()
        .eq('id', exerciseId)
        .single();
    return ExerciseModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>?> checkProgramDuplicate(String programId, String userId) async {
    try {
      // 1. 현재 사용자 인증 확인
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw Exception('인증되지 않은 사용자입니다.');
      }

      // 2. user_programs에서 중복 체크 (보안: 본인 데이터만)
      final userProgramResponse = await supabaseClient
          .from('user_programs')
          .select('id, current_week, current_day, started_at, completed_at')
          .eq('user_id', userId)
          .eq('program_id', programId)
          .eq('is_active', true)
          .maybeSingle();

      if (userProgramResponse == null) {
        return null; // 중복 없음
      }

      final userProgramId = userProgramResponse['id'] as String;

      // 3. 프로그램 정보 가져오기 (공개 데이터)
      final programResponse = await supabaseClient
          .from('workout_programs')
          .select('name, duration_weeks')
          .eq('id', programId)
          .eq('is_public', true) // 보안: 공개된 프로그램만
          .single();

      // 4. 진행 상황 계산
      final totalWeeks = programResponse['duration_weeks'] as int? ?? 1;
      final currentWeek = userProgramResponse['current_week'] as int? ?? 1;
      final currentDay = userProgramResponse['current_day'] as int? ?? 1;
      final isCompleted = userProgramResponse['completed_at'] != null;

      // 5. user_program_days에서 완료된 일수 계산 (보안: RLS 정책 적용)
      try {
        final completedDaysResponse = await supabaseClient
            .from('user_program_days')
            .select('id')
            .eq('user_program_id', userProgramId)
            .not('completed_at', 'is', null);

        final totalDaysResponse = await supabaseClient
            .from('user_program_days')
            .select('id')
            .eq('user_program_id', userProgramId);

        final completedDays = (completedDaysResponse as List).length;
        final totalDays = (totalDaysResponse as List).length;
        final progressPercent = totalDays > 0 ? (completedDays / totalDays * 100) : 0.0;

        return {
          'userProgramId': userProgramId,
          'programName': programResponse['name'],
          'currentWeek': currentWeek,
          'currentDay': currentDay,
          'totalWeeks': totalWeeks,
          'progressPercent': progressPercent,
          'isCompleted': isCompleted,
          'startedAt': userProgramResponse['started_at'],
        };
      } catch (dayError) {
        // user_program_days 접근 실패 시 기본값으로 처리
        print('Warning: Could not access user_program_days: $dayError');
        return {
          'userProgramId': userProgramId,
          'programName': programResponse['name'],
          'currentWeek': currentWeek,
          'currentDay': currentDay,
          'totalWeeks': totalWeeks,
          'progressPercent': 0.0, // 기본값
          'isCompleted': isCompleted,
          'startedAt': userProgramResponse['started_at'],
        };
      }
    } catch (e) {
      // 구체적인 에러 메시지로 디버깅 도움
      if (e.toString().contains('permission denied')) {
        throw Exception('데이터 접근 권한이 없습니다. 로그인 상태를 확인해주세요.');
      } else if (e.toString().contains('authentication')) {
        throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
      } else {
        throw Exception('프로그램 중복 확인 중 오류가 발생했습니다: $e');
      }
    }
  }

  @override
  Future<void> restartProgram(String programId, String userId) async {
    try {
      // 1. 현재 사용자 인증 확인
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw Exception('인증되지 않은 사용자입니다.');
      }

      // 2. user_programs 초기화 (보안: 본인 데이터만)
      final updateResult = await supabaseClient
          .from('user_programs')
          .update({
            'started_at': DateTime.now().toIso8601String(),
            'current_week': 1,
            'current_day': 1,
            'completed_at': null,
            'is_active': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('program_id', programId)
          .select();

      if (updateResult.isEmpty) {
        throw Exception('해당 프로그램을 찾을 수 없거나 권한이 없습니다.');
      }

      // 3. user_program_days의 completed_at 모두 null로 초기화 (보안: RLS 적용)
      final userProgramId = updateResult.first['id'] as String;

      try {
        await supabaseClient
            .from('user_program_days')
            .update({
              'completed_at': null,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_program_id', userProgramId);
      } catch (dayError) {
        // user_program_days 업데이트 실패해도 user_programs는 초기화됨
        print('Warning: Could not reset user_program_days: $dayError');
      }

    } catch (e) {
      if (e.toString().contains('permission denied')) {
        throw Exception('프로그램 재시작 권한이 없습니다.');
      } else if (e.toString().contains('authentication')) {
        throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
      } else {
        throw Exception('프로그램 재시작 중 오류가 발생했습니다: $e');
      }
    }
  }

  @override
  Future<void> continueProgram(String programId, String userId) async {
    try {
      // 1. 현재 사용자 인증 확인
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw Exception('인증되지 않은 사용자입니다.');
      }

      // 2. user_programs를 활성화 상태로 변경 (보안: 본인 데이터만)
      final updateResult = await supabaseClient
          .from('user_programs')
          .update({
            'is_active': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('program_id', programId)
          .select();

      if (updateResult.isEmpty) {
        throw Exception('해당 프로그램을 찾을 수 없거나 권한이 없습니다.');
      }

    } catch (e) {
      if (e.toString().contains('permission denied')) {
        throw Exception('프로그램 계속하기 권한이 없습니다.');
      } else if (e.toString().contains('authentication')) {
        throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
      } else {
        throw Exception('프로그램 계속하기 중 오류가 발생했습니다: $e');
      }
    }
  }

  @override
  Future<void> cleanupDuplicatePrograms(String userId) async {
    try {
      // 1. 현재 사용자 인증 확인
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw Exception('인증되지 않은 사용자입니다.');
      }

      // 2. 중복된 프로그램들 찾기 (user_id, program_id 별로 그룹화)
      final duplicatePrograms = await supabaseClient
          .from('user_programs')
          .select('id, program_id, started_at, updated_at')
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('program_id')
          .order('updated_at', ascending: false); // 최신 것을 먼저

      // 3. program_id별로 그룹화하여 중복 체크
      final Map<String, List<dynamic>> programGroups = {};
      for (final program in duplicatePrograms) {
        final programId = program['program_id'] as String;
        if (!programGroups.containsKey(programId)) {
          programGroups[programId] = [];
        }
        programGroups[programId]!.add(program);
      }

      // 4. 각 프로그램별로 최신 것만 남기고 나머지 비활성화
      for (final entry in programGroups.entries) {
        final programs = entry.value;
        if (programs.length > 1) {
          // 첫 번째(최신)를 제외한 나머지를 비활성화
          for (int i = 1; i < programs.length; i++) {
            final programToDeactivate = programs[i];
            await supabaseClient
                .from('user_programs')
                .update({
                  'is_active': false,
                  'updated_at': DateTime.now().toIso8601String(),
                })
                .eq('id', programToDeactivate['id'])
                .eq('user_id', userId); // 보안: 본인 데이터만
          }
          
          print('프로그램 ${entry.key}: ${programs.length - 1}개 중복 제거됨');
        }
      }

    } catch (e) {
      if (e.toString().contains('permission denied')) {
        throw Exception('중복 정리 권한이 없습니다.');
      } else if (e.toString().contains('authentication')) {
        throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
      } else {
        throw Exception('중복 프로그램 정리 중 오류가 발생했습니다: $e');
      }
    }
  }
} 