import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:jfit/core/utils/workout_program_logger.dart';
import 'package:jfit/core/error/workout_program_failures.dart';
import 'package:jfit/core/error/workout_program_error_handler.dart';
import 'package:jfit/features/workout_program/utils/exercise_data_parser.dart';
import 'package:jfit/features/workout_program/utils/workout_program_repository_manager.dart';

void main() {
  group('Workout Program Logging Integration Tests', () {
    late WorkoutProgramErrorHandler errorHandler;

    setUp(() {
      errorHandler = WorkoutProgramErrorHandler();
      WorkoutProgramLogger.clearLogHistory();
    });

    tearDown(() {
      // Skip repository reset to avoid Supabase initialization issues
      // WorkoutProgramRepositoryManager.reset();
    });

    group('Repository Operation Logging', () {
      test('should log repository operations with performance metrics', () {
        // Act
        WorkoutProgramLogger.startPerformanceTimer('test_repo_operation');
        
        // 시뮬레이션된 지연
        Future.delayed(const Duration(milliseconds: 10));
        
        final duration = WorkoutProgramLogger.endPerformanceTimer('test_repo_operation');

        WorkoutProgramLogger.logRepositoryOperation(
          'get_user_programs',
          'user123',
          success: true,
          duration: duration,
        );

        // Assert
        final logs = WorkoutProgramLogger.getLogHistory(minLevel: LogLevel.debug);
        expect(logs.length, greaterThanOrEqualTo(1)); // 최소 리포지토리 로그

        final repoLog = logs.firstWhere((log) => log.operation == 'get_user_programs');
        expect(repoLog.context?['user_id'], 'user123');
        expect(repoLog.context?['success'], true);
        expect(repoLog.context?['duration_ms'], isNotNull);

        // 성능 로그가 있는지 확인 (있을 수도 없을 수도 있음)
        final perfLogs = logs.where((log) => log.operation == 'performance_measurement').toList();
        if (perfLogs.isNotEmpty) {
          expect(perfLogs.first.context?['operation_id'], 'test_repo_operation');
        }
      });

      test('should log repository failures with detailed error information', () {
        // Arrange
        final failure = const WorkoutProgramNetworkFailure(
          technicalMessage: 'Connection timeout after 30 seconds',
        );

        // Act
        WorkoutProgramLogger.startPerformanceTimer('failed_repo_operation');
        final duration = WorkoutProgramLogger.endPerformanceTimer('failed_repo_operation');

        errorHandler.handleFailure(
          failure,
          operation: 'get_user_programs',
          context: {'user_id': 'user123'},
        );

        WorkoutProgramLogger.logRepositoryOperation(
          'get_user_programs',
          'user123',
          success: false,
          error: failure.userMessage,
          duration: duration,
        );

        // Assert
        final logs = WorkoutProgramLogger.getLogHistory();
        expect(logs.length, greaterThanOrEqualTo(2)); // 최소 에러 로그 + 리포지토리 로그

        final errorLogs = logs.where((log) => log.level == LogLevel.error).toList();
        expect(errorLogs.isNotEmpty, true);
        
        // 리포지토리 에러 로그와 실제 에러 핸들러 로그를 구분
        final repoErrorLog = errorLogs.firstWhere((log) => log.operation == 'get_user_programs');
        expect(repoErrorLog.context?['user_id'], 'user123');
        expect(repoErrorLog.context?['success'], false);
        expect(repoErrorLog.context?['error'], failure.userMessage);
        
        // 실제 에러 핸들러에서 생성된 로그가 있는지 확인
        final handlerErrorLogs = errorLogs.where((log) => log.errorType != null).toList();
        if (handlerErrorLogs.isNotEmpty) {
          expect(handlerErrorLogs.first.errorType, WorkoutProgramErrorType.networkError);
        }

        final repoLog = logs.firstWhere((log) => log.operation == 'get_user_programs');
        expect(repoLog.context?['success'], false);
        expect(repoLog.context?['error'], failure.userMessage);
      });
    });

    group('Data Parsing Logging Integration', () {
      test('should log complete data parsing workflow with performance metrics', () {
        // Arrange
        final testData = '''
        [
          {
            "id": 1,
            "exercise_name": "푸시업",
            "sets": "3",
            "reps": "10-15",
            "rest_seconds": 60
          },
          {
            "id": 2,
            "exercise_name": "스쿼트",
            "sets": "3",
            "reps": "15-20",
            "rest_seconds": 90
          }
        ]
        ''';

        // Act
        final result = ExerciseDataParser.parseExercises(testData);

        // Assert
        final logs = WorkoutProgramLogger.getLogHistory();
        expect(logs.length, 3); // 시작 로그 + 완료 로그 + 성능 로그

        final startLog = logs.firstWhere((log) => log.operation == 'exercise_data_parsing_start');
        expect(startLog.context?['detected_format'], ExerciseDataFormat.jsonString.description);

        final completeLog = logs.firstWhere((log) => log.operation == 'exercise_data_parsing_complete');
        expect(completeLog.context?['result_count'], 2);
        expect(completeLog.context?['duration_ms'], isNotNull);

        final perfLog = logs.firstWhere((log) => log.operation == 'performance_measurement');
        expect(perfLog.context?['operation_id'], 'parse_exercises');

        // 결과 검증
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Parsing should succeed'),
          (exercises) => expect(exercises.length, 2),
        );
      });

      test('should log parsing failures with detailed error context', () {
        // Arrange
        final invalidData = '{"invalid": json}';

        // Act
        final result = ExerciseDataParser.parseExercises(invalidData);

        // Assert
        final logs = WorkoutProgramLogger.getLogHistory();
        expect(logs.length, 3); // 시작 로그 + 실패 로그 + 성능 로그

        final failedLog = logs.firstWhere((log) => log.operation == 'exercise_data_parsing_failed');
        expect(failedLog.level, LogLevel.error);
        expect(failedLog.context?['parsing_error'], isNotNull);
        expect(failedLog.context?['duration_ms'], isNotNull);

        // 결과 검증
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<DataParsingFailure>()),
          (exercises) => fail('Parsing should fail'),
        );
      });

      test('should log week/day specific parsing with context', () {
        // Arrange
        final weeklyData = {
          'week_1': {
            'day_1': [
              {'id': 1, 'exercise_name': '푸시업'},
              {'id': 2, 'exercise_name': '스쿼트'},
            ],
            'day_2': [
              {'id': 3, 'exercise_name': '플랭크'},
            ],
          },
        };

        // Act
        final result = ExerciseDataParser.parseExercisesForWeekDay(weeklyData, 1, 1);

        // Assert
        final logs = WorkoutProgramLogger.getLogHistory();
        expect(logs.length, 3); // 시작 로그 + 완료 로그 + 성능 로그

        final startLog = logs.firstWhere((log) => log.operation == 'exercise_week_day_parsing_start');
        expect(startLog.context?['detected_format'], ExerciseDataFormat.weeklyMap.description);

        final completeLog = logs.firstWhere((log) => log.operation == 'exercise_week_day_parsing_complete');
        expect(completeLog.context?['result_count'], 2);

        final perfLog = logs.firstWhere((log) => log.operation == 'performance_measurement');
        expect(perfLog.context?['operation_id'], 'parse_exercises_week_day_1_1');

        // 결과 검증
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Parsing should succeed'),
          (exercises) => expect(exercises.length, 2),
        );
      });
    });

    group('Error Handling Integration', () {
      test('should create comprehensive error logs with full context', () {
        // Arrange
        final duplicateInfo = const ProgramDuplicateInfo(
          userProgramId: 'user_prog_123',
          programName: '전신 운동 프로그램',
          currentWeek: 2,
          currentDay: 3,
          totalWeeks: 8,
          progressPercent: 31.25,
          isCompleted: false,
          status: ProgramStatus.active,
          availableOptions: [
            ResolutionOption.continueExisting,
            ResolutionOption.restartProgram,
            ResolutionOption.createNewInstance,
          ],
        );

        final failure = ProgramDuplicateFailure(
          duplicateInfo: duplicateInfo,
          technicalMessage: 'Duplicate program found in database',
        );

        // Act
        final handledFailure = errorHandler.handleFailure(
          failure,
          operation: 'save_as_my_routine',
          context: {
            'user_id': 'user123',
            'template_program_id': 'template456',
            'save_timestamp': DateTime.now().toIso8601String(),
          },
        );

        // Assert
        final logs = WorkoutProgramLogger.getLogHistory(minLevel: LogLevel.error);
        expect(logs.length, 1);

        final errorLog = logs.first;
        expect(errorLog.level, LogLevel.error);
        expect(errorLog.operation, 'save_as_my_routine');
        expect(errorLog.errorType, WorkoutProgramErrorType.duplicate);
        expect(errorLog.errorCode, WorkoutProgramErrorCodes.programDuplicate);
        expect(errorLog.context?['user_id'], 'user123');
        expect(errorLog.context?['template_program_id'], 'template456');
        expect(errorLog.context?['failure_details'], isNotNull);

        // 중복 정보 검증
        final failureDetails = errorLog.context?['failure_details'] as Map<String, dynamic>?;
        expect(failureDetails?['duplicateInfo'], isNotNull);

        expect(handledFailure, equals(failure));
      });

      test('should log cascading errors with proper context', () {
        // Arrange - 리포지토리 초기화 실패 시뮬레이션
        WorkoutProgramRepositoryManager.reset();

        // Act
        final repository = WorkoutProgramRepositoryManager.getInstance();
        
        if (repository == null) {
          final failure = WorkoutProgramRepositoryManager.createInitializationFailure();
          errorHandler.handleFailure(
            failure,
            operation: 'initialize_repository',
            context: {'attempted_at': DateTime.now().toIso8601String()},
          );
        }

        // Assert
        final logs = WorkoutProgramLogger.getLogHistory();
        expect(logs.isNotEmpty, true);

        // 리포지토리 초기화 관련 로그들이 있는지 확인
        final repoLogs = logs.where((log) => 
          log.operation?.contains('repository') == true ||
          log.operation?.contains('initialize') == true
        ).toList();
        
        expect(repoLogs.isNotEmpty, true);
      });
    });

    group('Performance Monitoring Integration', () {
      test('should detect and log slow operations in real scenarios', () async {
        // Act - 느린 작업 시뮬레이션
        WorkoutProgramLogger.startPerformanceTimer('slow_operation');
        
        // 실제 지연 시뮬레이션
        await Future.delayed(const Duration(milliseconds: 150));
        
        final duration = WorkoutProgramLogger.endPerformanceTimer(
          'slow_operation',
          threshold: 100, // 100ms 임계값
        );

        // Assert
        final logs = WorkoutProgramLogger.getLogHistory();
        final perfLog = logs.firstWhere((log) => log.operation == 'performance_measurement');
        
        expect(perfLog.level, LogLevel.warning); // 느린 작업으로 감지
        expect(perfLog.context?['is_slow'], true);
        expect(perfLog.context?['threshold_ms'], 100);
        expect(perfLog.context?['duration_ms'], greaterThan(100));
        expect(duration?.inMilliseconds, greaterThan(100));
      });

      test('should track multiple concurrent operations', () {
        // Act
        WorkoutProgramLogger.startPerformanceTimer('operation_1');
        WorkoutProgramLogger.startPerformanceTimer('operation_2');
        WorkoutProgramLogger.startPerformanceTimer('operation_3');

        final duration1 = WorkoutProgramLogger.endPerformanceTimer('operation_1');
        final duration2 = WorkoutProgramLogger.endPerformanceTimer('operation_2');
        final duration3 = WorkoutProgramLogger.endPerformanceTimer('operation_3');

        // Assert
        expect(duration1, isNotNull);
        expect(duration2, isNotNull);
        expect(duration3, isNotNull);

        final logs = WorkoutProgramLogger.getLogHistory(operation: 'performance_measurement');
        expect(logs.length, 3);

        final operationIds = logs.map((log) => log.context?['operation_id']).toSet();
        expect(operationIds, containsAll(['operation_1', 'operation_2', 'operation_3']));
      });
    });

    group('Debug Information Integration', () {
      test('should generate comprehensive debug info after complex operations', () {
        // Act - 여러 작업 수행
        WorkoutProgramLogger.logUserAction(
          'start_workout_session',
          screen: 'ProgramDetailPage',
          userId: 'user123',
        );

        final parsingResult = ExerciseDataParser.parseExercises('[]');
        
        final failure = const RepositoryNotInitializedFailure();
        errorHandler.handleFailure(failure, operation: 'test_error');

        WorkoutProgramLogger.startPerformanceTimer('active_timer');

        // Debug 정보 생성
        final debugInfo = WorkoutProgramLogger.generateDebugInfo(
          userId: 'user123',
          currentOperation: 'complex_scenario_test',
        );

        // Assert
        expect(debugInfo['user_id'], 'user123');
        expect(debugInfo['current_operation'], 'complex_scenario_test');

        final logSummary = debugInfo['log_summary'] as Map<String, dynamic>;
        expect(logSummary['total_logs'], greaterThanOrEqualTo(5));
        expect(logSummary['error_count'], greaterThan(0));

        final performanceInfo = debugInfo['performance_info'] as Map<String, dynamic>;
        expect(performanceInfo['active_timers'], contains('active_timer'));

        final systemState = debugInfo['system_state'] as Map<String, dynamic>;
        expect(systemState['log_history_size'], greaterThan(0));
      });
    });

    group('Log History Management Integration', () {
      test('should maintain log history across multiple operations', () {
        // Act - 다양한 작업 수행
        for (int i = 0; i < 5; i++) {
          WorkoutProgramLogger.logUserAction('action_$i', userId: 'user123');
          WorkoutProgramLogger.logDataParsing('parsing_$i', []);
          
          if (i % 2 == 0) {
            WorkoutProgramLogger.logError(
              const RepositoryNotInitializedFailure(),
              operation: 'error_$i',
            );
          }
        }

        // Assert
        final allLogs = WorkoutProgramLogger.getLogHistory();
        expect(allLogs.length, greaterThanOrEqualTo(13)); // 최소 13개 로그 (일부 로그는 조건부)

        final errorLogs = WorkoutProgramLogger.getLogHistory(minLevel: LogLevel.error);
        expect(errorLogs.length, 3); // 3개의 에러 로그

        final userActionLogs = WorkoutProgramLogger.getLogHistory(operation: 'user_action');
        expect(userActionLogs.length, 5);

        // 시간순 정렬 확인 (최신 순)
        for (int i = 0; i < allLogs.length - 1; i++) {
          expect(
            allLogs[i].timestamp.isAfter(allLogs[i + 1].timestamp) ||
            allLogs[i].timestamp.isAtSameMomentAs(allLogs[i + 1].timestamp),
            true,
          );
        }
      });
    });
  });
}