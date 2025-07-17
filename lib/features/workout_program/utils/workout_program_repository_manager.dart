import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jfit/core/error/workout_program_failures.dart';
import 'package:jfit/features/workout_program/data/repositories/workout_program_repository.dart';
import 'package:jfit/features/workout_program/data/repositories/workout_program_repository_impl.dart';
import 'package:jfit/core/utils/workout_program_logger.dart';

/// 운동 프로그램 리포지토리 관리자
/// 리포지토리 초기화, null 안전성 검사, 폴백 메커니즘을 제공
class WorkoutProgramRepositoryManager {
  static WorkoutProgramRepository? _instance;
  static bool _initializationAttempted = false;

  /// 리포지토리 인스턴스를 안전하게 가져옴
  /// null인 경우 초기화를 시도하고, 실패하면 폴백 인스턴스 생성
  static WorkoutProgramRepository? getInstance() {
    WorkoutProgramLogger.startPerformanceTimer('repository_get_instance');
    
    if (_instance != null) {
      WorkoutProgramLogger.endPerformanceTimer('repository_get_instance');
      return _instance;
    }

    if (!_initializationAttempted) {
      _initializeRepository();
    }

    final duration = WorkoutProgramLogger.endPerformanceTimer('repository_get_instance');
    
    WorkoutProgramLogger.logRepositoryOperation(
      'get_instance',
      null,
      success: _instance != null,
      error: _instance == null ? 'Repository initialization failed' : null,
      duration: duration,
    );

    return _instance;
  }

  /// 리포지토리 초기화 시도
  static void _initializeRepository() {
    WorkoutProgramLogger.startPerformanceTimer('repository_initialization');
    _initializationAttempted = true;
    
    WorkoutProgramLogger.logRepositoryOperation(
      'initialize_repository_start',
      null,
      parameters: {'initialization_attempted': _initializationAttempted},
    );
    
    try {
      // GetIt에서 등록된 인스턴스 가져오기 시도
      if (GetIt.instance.isRegistered<WorkoutProgramRepository>()) {
        _instance = GetIt.instance<WorkoutProgramRepository>();
        final duration = WorkoutProgramLogger.endPerformanceTimer('repository_initialization');
        
        WorkoutProgramLogger.logRepositoryOperation(
          'initialize_repository_getit_success',
          null,
          success: true,
          duration: duration,
        );
        return;
      }
    } catch (e) {
      WorkoutProgramLogger.logRepositoryOperation(
        'initialize_repository_getit_failed',
        null,
        success: false,
        error: 'Failed to get WorkoutProgramRepository from GetIt: $e',
      );
    }

    // GetIt에서 실패한 경우 직접 생성 시도
    try {
      final supabaseClient = _getSupabaseClient();
      if (supabaseClient != null) {
        _instance = WorkoutProgramRepositoryImpl(supabaseClient: supabaseClient);
        final duration = WorkoutProgramLogger.endPerformanceTimer('repository_initialization');
        
        WorkoutProgramLogger.logRepositoryOperation(
          'initialize_repository_fallback_success',
          null,
          success: true,
          duration: duration,
        );
      } else {
        final duration = WorkoutProgramLogger.endPerformanceTimer('repository_initialization');
        
        WorkoutProgramLogger.logRepositoryOperation(
          'initialize_repository_fallback_failed',
          null,
          success: false,
          error: 'Supabase client is not available',
          duration: duration,
        );
      }
    } catch (e) {
      final duration = WorkoutProgramLogger.endPerformanceTimer('repository_initialization');
      
      WorkoutProgramLogger.logRepositoryOperation(
        'initialize_repository_fallback_failed',
        null,
        success: false,
        error: 'Failed to create fallback WorkoutProgramRepository: $e',
        duration: duration,
      );
    }
  }

  /// Supabase 클라이언트를 안전하게 가져옴
  static SupabaseClient? _getSupabaseClient() {
    try {
      // GetIt에서 SupabaseClient 가져오기 시도
      if (GetIt.instance.isRegistered<SupabaseClient>()) {
        return GetIt.instance<SupabaseClient>();
      }
      
      // Supabase.instance에서 직접 가져오기 시도
      return Supabase.instance.client;
    } catch (e) {
      print('Failed to get SupabaseClient: $e');
      return null;
    }
  }

  /// 리포지토리 상태 검사
  static RepositoryHealthStatus checkRepositoryHealth() {
    final repository = getInstance();
    
    if (repository == null) {
      return RepositoryHealthStatus.notInitialized;
    }

    // 추가적인 건강 상태 검사 (예: 네트워크 연결 등)
    try {
      final supabaseClient = _getSupabaseClient();
      if (supabaseClient == null) {
        return RepositoryHealthStatus.clientUnavailable;
      }
      
      return RepositoryHealthStatus.healthy;
    } catch (e) {
      return RepositoryHealthStatus.unhealthy;
    }
  }

  /// 리포지토리 강제 재초기화
  static void forceReinitialize() {
    _instance = null;
    _initializationAttempted = false;
    _initializeRepository();
  }

  /// 리포지토리 인스턴스 수동 설정 (테스트용)
  static void setInstance(WorkoutProgramRepository repository) {
    _instance = repository;
    _initializationAttempted = true;
  }

  /// 인스턴스 초기화 (테스트용)
  static void reset() {
    _instance = null;
    _initializationAttempted = false;
  }

  /// 리포지토리 초기화 실패에 대한 구조화된 에러 생성
  static RepositoryNotInitializedFailure createInitializationFailure() {
    final healthStatus = checkRepositoryHealth();
    String technicalMessage;
    
    switch (healthStatus) {
      case RepositoryHealthStatus.notInitialized:
        technicalMessage = 'Repository instance could not be created';
        break;
      case RepositoryHealthStatus.clientUnavailable:
        technicalMessage = 'Supabase client is not available';
        break;
      case RepositoryHealthStatus.unhealthy:
        technicalMessage = 'Repository is in unhealthy state';
        break;
      case RepositoryHealthStatus.healthy:
        technicalMessage = 'Repository appears healthy but initialization failed';
        break;
    }

    return RepositoryNotInitializedFailure(
      technicalMessage: technicalMessage,
    );
  }
}

/// 리포지토리 건강 상태
enum RepositoryHealthStatus {
  healthy,
  notInitialized,
  clientUnavailable,
  unhealthy,
}