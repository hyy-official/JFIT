import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/core/utils/workout_program_logger.dart';
import 'package:jfit/core/error/workout_program_failures.dart';
import 'package:jfit/features/workout_program/utils/exercise_data_parser.dart';

void main() {
  group('WorkoutProgramLogger', () {
    setUp(() {
      // 각 테스트 전에 로그 히스토리 초기화
      WorkoutProgramLogger.clearLogHistory();
    });

    group('Error Logging', () {
      test('should log error with all details', () {
        // Arrange
        final failure = DataParsingFailure(
          message: 'Test parsing error',
          dataType: 'test_data',
          technicalMessage: 'Technical details',
        );

        // Act
        WorkoutProgramLogger.logError(
          failure,
          operation: 'test_operation',
          context: {'test_key': 'test_value'},
        );

        // Assert
        final logs = WorkoutProgramLogger.getLogHistory(minLevel: LogLevel.error);
        expect(logs.length, 1);
        
        final logEntry = logs.first;
        expect(logEntry.level, LogLevel.error);
        expect(logEntry.message, failure.userMessage);
        expect(logEntry.operation, 'test_operation');
        expect(logEntry.errorType, failure.type);
        expect(logEntry.errorCode, failure.errorCode);
        expect(logEntry.technicalMessage, failure.technicalMessage);
        expect(logEntry.context?['test_key'], 'test_value');
        expect(logEntry.context?['failure_details'], failure.details);
      });

      test('should log different error types correctly', () {
        // Arrange
        final failures = [
          const RepositoryNotInitializedFailure(),
          ProgramDuplicateFailure(
            duplicateInfo: const ProgramDuplicateInfo(
              userProgramId: 'test_id',
              programName: 'Test Program',
              currentWeek: 1,
              currentDay: 1,
              totalWeeks: 4,
              progressPercent: 25.0,
              isCompleted: false,
              status: ProgramStatus.active,
              availableOptions: [ResolutionOption.continueExisting],
            ),
          ),
          const WorkoutProgramNetworkFailure(),
        ];

        // Act
        for (final failure in failures) {
          WorkoutProgramLogger.logError(failure, operation: 'test_${failure.type}');
        }

        // Assert
        final logs = WorkoutProgramLogger.getLogHistory(minLevel: LogLevel.error);
        expect(logs.length, 3);
        
        expect(logs.any((log) => log.errorType == WorkoutProgramErrorType.repositoryNotInitialized), true);
        expect(logs.any((log) => log.errorType == WorkoutProgramErrorType.duplicate), true);
        expect(logs.any((log) => log.errorType == WorkoutProgramErrorType.networkError), true);
      });
    });

    group('Data Parsing Logging', () {
      test('should log successful data parsing', () {
        // Arrange
        final testData = [{'id': 1, 'name': 'Test Exercise'}];
        
        // Act
        WorkoutProgramLogger.logDataParsing(
          'test_parsing',
          testData,
          detectedFormat: ExerciseDataFormat.exerciseList,
          resultCount: 1,
          duration: const Duration(milliseconds: 50),
        );

        // Assert
        final logs = WorkoutProgramLogger.getLogHistory(minLevel: LogLevel.info);
        expect(logs.length, 1);
        
        final logEntry = logs.first;
        expect(logEntry.level, LogLevel.info);
        expect(logEntry.operation, 'test_parsing');
        expect(logEntry.context?['detected_format'], ExerciseDataFormat.exerciseList.description);
        expect(logEntry.context?['result_count'], 1);
        expect(logEntry.context?['duration_ms'], 50);
      });

      test('should log failed data parsing', () {
        // Act
        WorkoutProgramLogger.logDataParsing(
          'test_parsing_failed',
          'invalid_json',
          error: 'JSON parsing failed',
        );

        // Assert
        final logs = WorkoutProgramLogger.getLogHistory(minLevel: LogLevel.error);
        expect(logs.length, 1);
        
        final logEntry = logs.first;
        expect(logEntry.level, LogLevel.error);
        expect(logEntry.operation, 'test_parsing_failed');
        expect(logEntry.context?['parsing_error'], 'JSON parsing failed');
      });

      test('should detect and log different data formats', () {
        // Arrange
        final testCases = [
          {'data': null, 'expectedFormat': ExerciseDataFormat.empty},
          {'data': '', 'expectedFormat': ExerciseDataFormat.empty},
          {'data': '[]', 'expectedFormat': ExerciseDataFormat.jsonString},
          {'data': [], 'expectedFormat': ExerciseDataFormat.empty},
          {'data': [{'id': 1}], 'expectedFormat': ExerciseDataFormat.exerciseList},
          {'data': {'exercises': []}, 'expectedFormat': ExerciseDataFormat.exerciseMap},
        ];

        // Act & Assert
        for (int i = 0; i < testCases.length; i++) {
          final testCase = testCases[i];
          WorkoutProgramLogger.logDataParsing(
            'test_format_detection_$i',
            testCase['data'],
            detectedFormat: testCase['expectedFormat'] as ExerciseDataFormat,
          );
        }

        final logs = WorkoutProgramLogger.getLogHistory();
        expect(logs.length, testCases.length);
      });
    });

    group('Repository Operation Logging', () {
      test('should log successful repository operation', () {
        // Act
        WorkoutProgramLogger.logRepositoryOperation(
          'get_user_programs',
          'user123',
          parameters: {'limit': 10},
          success: true,
          duration: const Duration(milliseconds: 200),
        );

        // Assert
        final logs = WorkoutProgramLogger.getLogHistory(minLevel: LogLevel.info);
        expect(logs.length, 1);
        
        final logEntry = logs.first;
        expect(logEntry.level, LogLevel.info);
        expect(logEntry.operation, 'get_user_programs');
        expect(logEntry.context?['user_id'], 'user123');
        expect(logEntry.context?['success'], true);
        expect(logEntry.context?['duration_ms'], 200);
        expect(logEntry.context?['parameters'], {'limit': 10});
      });

      test('should log failed repository operation', () {
        // Act
        WorkoutProgramLogger.logRepositoryOperation(
          'save_program',
          'user123',
          programId: 'program456',
          success: false,
          error: 'Database connection failed',
          duration: const Duration(milliseconds: 5000),
        );

        // Assert
        final logs = WorkoutProgramLogger.getLogHistory(minLevel: LogLevel.error);
        expect(logs.length, 1);
        
        final logEntry = logs.first;
        expect(logEntry.level, LogLevel.error);
        expect(logEntry.operation, 'save_program');
        expect(logEntry.context?['user_id'], 'user123');
        expect(logEntry.context?['program_id'], 'program456');
        expect(logEntry.context?['success'], false);
        expect(logEntry.context?['error'], 'Database connection failed');
        expect(logEntry.context?['duration_ms'], 5000);
      });
    });

    group('BLoC State Change Logging', () {
      test('should log BLoC state changes', () {
        // Act
        WorkoutProgramLogger.logBlocStateChange(
          'WorkoutProgramBloc',
          'WorkoutProgramInitial',
          'WorkoutProgramLoading',
          event: 'LoadUserPrograms',
          eventData: {'userId': 'user123'},
          processingTime: const Duration(milliseconds: 10),
        );

        // Assert
        final logs = WorkoutProgramLogger.getLogHistory(minLevel: LogLevel.debug);
        expect(logs.length, 1);
        
        final logEntry = logs.first;
        expect(logEntry.level, LogLevel.debug);
        expect(logEntry.operation, 'bloc_state_change');
        expect(logEntry.context?['bloc_name'], 'WorkoutProgramBloc');
        expect(logEntry.context?['from_state'], 'WorkoutProgramInitial');
        expect(logEntry.context?['to_state'], 'WorkoutProgramLoading');
        expect(logEntry.context?['event'], 'LoadUserPrograms');
        expect(logEntry.context?['processing_time_ms'], 10);
      });
    });

    group('User Action Logging', () {
      test('should log user actions', () {
        // Act
        WorkoutProgramLogger.logUserAction(
          'start_workout_day',
          screen: 'ProgramDetailPage',
          actionData: {'programId': 'program123', 'week': 1, 'day': 1},
          userId: 'user456',
        );

        // Assert
        final logs = WorkoutProgramLogger.getLogHistory(minLevel: LogLevel.info);
        expect(logs.length, 1);
        
        final logEntry = logs.first;
        expect(logEntry.level, LogLevel.info);
        expect(logEntry.operation, 'user_action');
        expect(logEntry.context?['action'], 'start_workout_day');
        expect(logEntry.context?['screen'], 'ProgramDetailPage');
        expect(logEntry.context?['user_id'], 'user456');
        expect(logEntry.context?['action_data'], {'programId': 'program123', 'week': 1, 'day': 1});
      });
    });

    group('Performance Monitoring', () {
      test('should measure operation performance', () {
        // Act
        WorkoutProgramLogger.startPerformanceTimer('test_operation');
        
        // 짧은 지연 시뮬레이션
        Future.delayed(const Duration(milliseconds: 10));
        
        final duration = WorkoutProgramLogger.endPerformanceTimer('test_operation');

        // Assert
        expect(duration, isNotNull);
        expect(duration!.inMilliseconds, greaterThanOrEqualTo(0));
        
        final logs = WorkoutProgramLogger.getLogHistory(minLevel: LogLevel.debug);
        expect(logs.length, 1);
        
        final logEntry = logs.first;
        expect(logEntry.operation, 'performance_measurement');
        expect(logEntry.context?['operation_id'], 'test_operation');
        expect(logEntry.context?['duration_ms'], duration.inMilliseconds);
      });

      test('should detect slow operations', () {
        // Act
        WorkoutProgramLogger.startPerformanceTimer('slow_operation');
        final duration = WorkoutProgramLogger.endPerformanceTimer(
          'slow_operation',
          threshold: 5, // 5ms 임계값
          additionalData: {'test_data': 'value'},
        );

        // Assert
        final logs = WorkoutProgramLogger.getLogHistory(minLevel: LogLevel.debug);
        expect(logs.length, 1);
        
        final logEntry = logs.first;
        expect(logEntry.context?['operation_id'], 'slow_operation');
        expect(logEntry.context?['threshold_ms'], 5);
        expect(logEntry.context?['test_data'], 'value');
      });

      test('should handle missing timer gracefully', () {
        // Act
        final duration = WorkoutProgramLogger.endPerformanceTimer('non_existent_timer');

        // Assert
        expect(duration, isNull);
      });
    });

    group('Debug Info Generation', () {
      test('should generate comprehensive debug info', () {
        // Arrange - 몇 가지 로그 생성
        WorkoutProgramLogger.logError(
          const RepositoryNotInitializedFailure(),
          operation: 'test_error',
        );
        WorkoutProgramLogger.logDataParsing('test_parsing', []);
        WorkoutProgramLogger.startPerformanceTimer('active_timer');

        // Act
        final debugInfo = WorkoutProgramLogger.generateDebugInfo(
          userId: 'test_user',
          currentOperation: 'test_operation',
        );

        // Assert
        expect(debugInfo['user_id'], 'test_user');
        expect(debugInfo['current_operation'], 'test_operation');
        expect(debugInfo['timestamp'], isNotNull);
        
        final appInfo = debugInfo['app_info'] as Map<String, dynamic>;
        expect(appInfo.containsKey('debug_mode'), true);
        expect(appInfo.containsKey('release_mode'), true);
        
        final logSummary = debugInfo['log_summary'] as Map<String, dynamic>;
        expect(logSummary['total_logs'], greaterThan(0));
        expect(logSummary['error_count'], greaterThan(0));
        
        final performanceInfo = debugInfo['performance_info'] as Map<String, dynamic>;
        expect(performanceInfo['active_timers'], contains('active_timer'));
      });
    });

    group('Log History Management', () {
      test('should filter logs by level', () {
        // Arrange
        WorkoutProgramLogger.logError(const RepositoryNotInitializedFailure());
        WorkoutProgramLogger.logDataParsing('test', [], error: 'error');
        WorkoutProgramLogger.logDataParsing('test', []);
        WorkoutProgramLogger.logBlocStateChange('TestBloc', 'A', 'B');

        // Act
        final errorLogs = WorkoutProgramLogger.getLogHistory(minLevel: LogLevel.error);
        final infoLogs = WorkoutProgramLogger.getLogHistory(minLevel: LogLevel.info);
        final allLogs = WorkoutProgramLogger.getLogHistory();

        // Assert
        expect(errorLogs.length, 2); // 2개의 에러 로그
        expect(infoLogs.length, 3); // 에러 2개 + 정보 1개
        expect(allLogs.length, 4); // 모든 로그
      });

      test('should filter logs by operation', () {
        // Arrange
        WorkoutProgramLogger.logDataParsing('parsing_op', []);
        WorkoutProgramLogger.logRepositoryOperation('repo_op', 'user1');
        WorkoutProgramLogger.logDataParsing('parsing_op', []);

        // Act
        final parsingLogs = WorkoutProgramLogger.getLogHistory(operation: 'parsing_op');
        final repoLogs = WorkoutProgramLogger.getLogHistory(operation: 'repo_op');

        // Assert
        expect(parsingLogs.length, 2);
        expect(repoLogs.length, 1);
      });

      test('should limit log results', () {
        // Arrange
        for (int i = 0; i < 10; i++) {
          WorkoutProgramLogger.logDataParsing('test_$i', []);
        }

        // Act
        final limitedLogs = WorkoutProgramLogger.getLogHistory(limit: 5);

        // Assert
        expect(limitedLogs.length, 5);
      });

      test('should filter logs by time', () {
        // Arrange
        final now = DateTime.now();
        final oneHourAgo = now.subtract(const Duration(hours: 1));
        
        WorkoutProgramLogger.logDataParsing('old_log', []);
        
        // Act
        final recentLogs = WorkoutProgramLogger.getLogHistory(since: oneHourAgo);

        // Assert
        expect(recentLogs.length, 1);
      });

      test('should clear log history', () {
        // Arrange
        WorkoutProgramLogger.logDataParsing('test', []);
        expect(WorkoutProgramLogger.getLogHistory().length, 1);

        // Act
        WorkoutProgramLogger.clearLogHistory();

        // Assert
        expect(WorkoutProgramLogger.getLogHistory().length, 0);
      });
    });

    group('Log Entry Serialization', () {
      test('should serialize log entry to JSON', () {
        // Arrange
        final failure = DataParsingFailure(
          message: 'Test error',
          dataType: 'test',
        );
        
        WorkoutProgramLogger.logError(failure, operation: 'test_op');
        final logs = WorkoutProgramLogger.getLogHistory();
        final logEntry = logs.first;

        // Act
        final json = logEntry.toJson();

        // Assert
        expect(json['level'], 'error');
        expect(json['message'], failure.userMessage);
        expect(json['operation'], 'test_op');
        expect(json['error_type'], failure.type.toString());
        expect(json['error_code'], failure.errorCode);
        expect(json['timestamp'], isNotNull);
        expect(json['has_stack_trace'], false);
      });
    });
  });
}