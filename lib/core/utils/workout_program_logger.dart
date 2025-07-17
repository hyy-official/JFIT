import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:jfit/core/error/workout_program_failures.dart';
import 'package:jfit/features/workout_program/utils/exercise_data_parser.dart';

/// 운동 프로그램 관련 로깅을 담당하는 클래스
/// 에러 추적, 성능 모니터링, 디버그 정보 생성을 제공합니다.
class WorkoutProgramLogger {
  static const String _logTag = 'WorkoutProgram';
  static final Map<String, DateTime> _operationStartTimes = {};
  static final List<WorkoutProgramLogEntry> _logHistory = [];
  static const int _maxLogHistorySize = 1000;

  /// 에러 로깅
  static void logError(
    WorkoutProgramFailure failure, {
    String? operation,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  }) {
    final logEntry = WorkoutProgramLogEntry(
      level: LogLevel.error,
      message: failure.userMessage,
      operation: operation,
      errorType: failure.type,
      errorCode: failure.errorCode,
      technicalMessage: failure.technicalMessage,
      context: {
        ...?context,
        'failure_details': failure.details,
      },
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
    );

    _addToHistory(logEntry);
    _logToConsole(logEntry);
    _logToExternalService(logEntry);
  }

  /// 데이터 파싱 로깅
  static void logDataParsing(
    String operation,
    dynamic inputData, {
    ExerciseDataFormat? detectedFormat,
    int? resultCount,
    Duration? duration,
    String? error,
  }) {
    final logEntry = WorkoutProgramLogEntry(
      level: error != null ? LogLevel.error : LogLevel.info,
      message: error ?? 'Data parsing completed',
      operation: operation,
      context: {
        'input_data_type': inputData?.runtimeType.toString(),
        'input_data_size': _getDataSize(inputData),
        'detected_format': detectedFormat?.description,
        'result_count': resultCount,
        'duration_ms': duration?.inMilliseconds,
        'parsing_error': error,
        if (kDebugMode && inputData != null) 'input_sample': _getSampleData(inputData),
      },
      timestamp: DateTime.now(),
    );

    _addToHistory(logEntry);
    _logToConsole(logEntry);
  }

  /// 리포지토리 작업 로깅
  static void logRepositoryOperation(
    String operation,
    String? userId, {
    String? programId,
    Map<String, dynamic>? parameters,
    bool success = true,
    String? error,
    Duration? duration,
  }) {
    final logEntry = WorkoutProgramLogEntry(
      level: success ? LogLevel.info : LogLevel.error,
      message: success ? 'Repository operation completed' : 'Repository operation failed',
      operation: operation,
      context: {
        'user_id': userId,
        'program_id': programId,
        'parameters': parameters,
        'success': success,
        'error': error,
        'duration_ms': duration?.inMilliseconds,
      },
      timestamp: DateTime.now(),
    );

    _addToHistory(logEntry);
    _logToConsole(logEntry);
  }

  /// BLoC 상태 변화 로깅
  static void logBlocStateChange(
    String blocName,
    String fromState,
    String toState, {
    String? event,
    Map<String, dynamic>? eventData,
    Duration? processingTime,
  }) {
    final logEntry = WorkoutProgramLogEntry(
      level: LogLevel.debug,
      message: 'BLoC state changed',
      operation: 'bloc_state_change',
      context: {
        'bloc_name': blocName,
        'from_state': fromState,
        'to_state': toState,
        'event': event,
        'event_data': eventData,
        'processing_time_ms': processingTime?.inMilliseconds,
      },
      timestamp: DateTime.now(),
    );

    _addToHistory(logEntry);
    if (kDebugMode) {
      _logToConsole(logEntry);
    }
  }

  /// 사용자 액션 로깅
  static void logUserAction(
    String action, {
    String? screen,
    Map<String, dynamic>? actionData,
    String? userId,
  }) {
    final logEntry = WorkoutProgramLogEntry(
      level: LogLevel.info,
      message: 'User action performed',
      operation: 'user_action',
      context: {
        'action': action,
        'screen': screen,
        'action_data': actionData,
        'user_id': userId,
      },
      timestamp: DateTime.now(),
    );

    _addToHistory(logEntry);
    if (kDebugMode) {
      _logToConsole(logEntry);
    }
  }

  /// 성능 측정 시작
  static void startPerformanceTimer(String operationId) {
    _operationStartTimes[operationId] = DateTime.now();
    
    if (kDebugMode) {
      developer.log(
        'Performance timer started: $operationId',
        name: _logTag,
        level: 800, // INFO level
      );
    }
  }

  /// 성능 측정 종료 및 로깅
  static Duration? endPerformanceTimer(
    String operationId, {
    Map<String, dynamic>? additionalData,
    int? threshold,
  }) {
    final startTime = _operationStartTimes.remove(operationId);
    if (startTime == null) return null;

    final duration = DateTime.now().difference(startTime);
    final isSlowOperation = threshold != null && duration.inMilliseconds > threshold;

    final logEntry = WorkoutProgramLogEntry(
      level: isSlowOperation ? LogLevel.warning : LogLevel.debug,
      message: isSlowOperation 
          ? 'Slow operation detected: $operationId'
          : 'Operation completed: $operationId',
      operation: 'performance_measurement',
      context: {
        'operation_id': operationId,
        'duration_ms': duration.inMilliseconds,
        'is_slow': isSlowOperation,
        'threshold_ms': threshold,
        ...?additionalData,
      },
      timestamp: DateTime.now(),
    );

    _addToHistory(logEntry);
    _logToConsole(logEntry);

    return duration;
  }

  /// 디버그 정보 생성
  static Map<String, dynamic> generateDebugInfo({
    String? userId,
    String? currentOperation,
  }) {
    final recentLogs = _logHistory
        .where((log) => DateTime.now().difference(log.timestamp).inMinutes < 30)
        .toList();

    final errorLogs = recentLogs.where((log) => log.level == LogLevel.error).toList();
    final warningLogs = recentLogs.where((log) => log.level == LogLevel.warning).toList();

    return {
      'timestamp': DateTime.now().toIso8601String(),
      'user_id': userId,
      'current_operation': currentOperation,
      'app_info': {
        'debug_mode': kDebugMode,
        'release_mode': kReleaseMode,
        'profile_mode': kProfileMode,
      },
      'log_summary': {
        'total_logs': recentLogs.length,
        'error_count': errorLogs.length,
        'warning_count': warningLogs.length,
        'recent_errors': errorLogs.take(5).map((log) => {
          'timestamp': log.timestamp.toIso8601String(),
          'operation': log.operation,
          'error_type': log.errorType?.toString(),
          'error_code': log.errorCode,
          'message': log.message,
        }).toList(),
      },
      'performance_info': {
        'active_timers': _operationStartTimes.keys.toList(),
        'slow_operations': recentLogs
            .where((log) => 
                log.operation == 'performance_measurement' && 
                log.context?['is_slow'] == true)
            .take(5)
            .map((log) => {
              'operation_id': log.context?['operation_id'],
              'duration_ms': log.context?['duration_ms'],
              'timestamp': log.timestamp.toIso8601String(),
            })
            .toList(),
      },
      'system_state': {
        'log_history_size': _logHistory.length,
        'memory_usage': _getMemoryUsageInfo(),
      },
    };
  }

  /// 로그 히스토리 조회
  static List<WorkoutProgramLogEntry> getLogHistory({
    LogLevel? minLevel,
    String? operation,
    DateTime? since,
    int? limit,
  }) {
    var filteredLogs = _logHistory.where((log) {
      if (minLevel != null && log.level.index < minLevel.index) return false;
      if (operation != null && log.operation != operation) return false;
      if (since != null && log.timestamp.isBefore(since)) return false;
      return true;
    }).toList();

    // 최신 순으로 정렬
    filteredLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (limit != null && filteredLogs.length > limit) {
      filteredLogs = filteredLogs.take(limit).toList();
    }

    return filteredLogs;
  }

  /// 로그 히스토리 초기화
  static void clearLogHistory() {
    _logHistory.clear();
    if (kDebugMode) {
      developer.log('Log history cleared', name: _logTag);
    }
  }

  /// 로그 히스토리에 추가
  static void _addToHistory(WorkoutProgramLogEntry entry) {
    _logHistory.add(entry);
    
    // 히스토리 크기 제한
    if (_logHistory.length > _maxLogHistorySize) {
      _logHistory.removeRange(0, _logHistory.length - _maxLogHistorySize);
    }
  }

  /// 콘솔에 로그 출력
  static void _logToConsole(WorkoutProgramLogEntry entry) {
    if (!kDebugMode && entry.level == LogLevel.debug) return;

    final levelText = entry.level.name.toUpperCase();
    final timestamp = entry.timestamp.toIso8601String();
    final operation = entry.operation ?? 'unknown';
    
    String logMessage = '[$levelText] [$timestamp] [$operation] ${entry.message}';
    
    if (entry.context != null && entry.context!.isNotEmpty) {
      logMessage += '\nContext: ${_formatContext(entry.context!)}';
    }
    
    if (entry.technicalMessage != null) {
      logMessage += '\nTechnical: ${entry.technicalMessage}';
    }

    // Flutter의 developer.log 사용
    developer.log(
      logMessage,
      name: _logTag,
      level: _getLogLevel(entry.level),
      error: entry.level == LogLevel.error ? entry.message : null,
      stackTrace: entry.stackTrace,
    );
  }

  /// 외부 로깅 서비스에 전송
  static void _logToExternalService(WorkoutProgramLogEntry entry) {
    if (!kReleaseMode) return;

    // 프로덕션 환경에서만 실행
    // 예: Firebase Crashlytics, Sentry 등에 전송
    // 실제 구현 시 해당 서비스의 SDK 사용
  }

  /// 데이터 크기 계산
  static int _getDataSize(dynamic data) {
    if (data == null) return 0;
    
    try {
      if (data is String) {
        return data.length;
      } else if (data is List) {
        return data.length;
      } else if (data is Map) {
        return data.length;
      } else {
        return data.toString().length;
      }
    } catch (e) {
      return 0;
    }
  }

  /// 샘플 데이터 추출 (디버깅용)
  static String _getSampleData(dynamic data) {
    try {
      if (data is String) {
        return data.length > 200 ? '${data.substring(0, 200)}...' : data;
      } else {
        final jsonString = jsonEncode(data);
        return jsonString.length > 200 ? '${jsonString.substring(0, 200)}...' : jsonString;
      }
    } catch (e) {
      return data.toString();
    }
  }

  /// 컨텍스트 정보 포맷팅
  static String _formatContext(Map<String, dynamic> context) {
    try {
      return jsonEncode(context);
    } catch (e) {
      return context.toString();
    }
  }

  /// 로그 레벨을 developer.log 레벨로 변환
  static int _getLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500; // FINE
      case LogLevel.info:
        return 800; // INFO
      case LogLevel.warning:
        return 900; // WARNING
      case LogLevel.error:
        return 1000; // SEVERE
    }
  }

  /// 메모리 사용량 정보 (간단한 버전)
  static Map<String, dynamic> _getMemoryUsageInfo() {
    return {
      'log_entries_count': _logHistory.length,
      'active_timers_count': _operationStartTimes.length,
      // 실제 메모리 사용량은 플랫폼별 구현 필요
    };
  }
}

/// 로그 엔트리 클래스
class WorkoutProgramLogEntry {
  final LogLevel level;
  final String message;
  final String? operation;
  final WorkoutProgramErrorType? errorType;
  final String? errorCode;
  final String? technicalMessage;
  final Map<String, dynamic>? context;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  const WorkoutProgramLogEntry({
    required this.level,
    required this.message,
    this.operation,
    this.errorType,
    this.errorCode,
    this.technicalMessage,
    this.context,
    this.stackTrace,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'level': level.name,
      'message': message,
      'operation': operation,
      'error_type': errorType?.toString(),
      'error_code': errorCode,
      'technical_message': technicalMessage,
      'context': context,
      'timestamp': timestamp.toIso8601String(),
      'has_stack_trace': stackTrace != null,
    };
  }
}

/// 로그 레벨 열거형
enum LogLevel {
  debug,
  info,
  warning,
  error,
}