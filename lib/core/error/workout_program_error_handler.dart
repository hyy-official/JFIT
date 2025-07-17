import 'package:flutter/foundation.dart';
import 'workout_program_failures.dart';
import 'package:jfit/core/utils/workout_program_logger.dart';

/// 운동 프로그램 관련 에러를 처리하는 핸들러
/// 에러 로깅, 사용자 메시지 생성, 복구 제안 등을 담당
class WorkoutProgramErrorHandler {
  /// 실패를 처리하고 구조화된 에러 정보를 반환
  WorkoutProgramFailure handleFailure(
    WorkoutProgramFailure failure, {
    String? operation,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  }) {
    // 향상된 에러 로깅
    WorkoutProgramLogger.logError(
      failure,
      operation: operation,
      context: context,
      stackTrace: stackTrace,
    );
    
    // 실패 객체를 그대로 반환 (이미 구조화되어 있음)
    return failure;
  }

  /// 에러 타입에 따른 복구 제안 메시지 반환
  String getRecoverySuggestion(WorkoutProgramErrorType errorType) {
    switch (errorType) {
      case WorkoutProgramErrorType.duplicate:
        return '기존 프로그램을 계속하거나 새로 시작할 수 있습니다.';
      case WorkoutProgramErrorType.repositoryNotInitialized:
        return '앱을 다시 시작하거나 로그인을 다시 해주세요.';
      case WorkoutProgramErrorType.dataParsingError:
        return '프로그램을 다시 불러오거나 앱을 재시작해주세요.';
      case WorkoutProgramErrorType.networkError:
        return '네트워크 연결을 확인하고 다시 시도해주세요.';
      case WorkoutProgramErrorType.serverError:
        return '잠시 후 다시 시도해주세요.';
      case WorkoutProgramErrorType.permissionDenied:
        return '로그인 상태를 확인하고 다시 시도해주세요.';
      case WorkoutProgramErrorType.programNotFound:
        return '프로그램 목록을 새로고침하고 다시 시도해주세요.';
      case WorkoutProgramErrorType.exerciseDataEmpty:
        return '프로그램을 다시 선택하거나 새로고침해주세요.';
      case WorkoutProgramErrorType.validationError:
        return '입력한 정보를 확인하고 다시 시도해주세요.';
      case WorkoutProgramErrorType.unknown:
        return '앱을 다시 시작하거나 고객센터에 문의해주세요.';
    }
  }

  /// 에러 로깅
  void logError(WorkoutProgramFailure failure) {
    if (kDebugMode) {
      print('=== WorkoutProgram Error ===');
      print('Type: ${failure.type}');
      print('Code: ${failure.errorCode}');
      print('User Message: ${failure.userMessage}');
      print('Technical Message: ${failure.technicalMessage}');
      print('Details: ${failure.details}');
      print('========================');
    }
    
    // 프로덕션에서는 실제 로깅 서비스에 전송
    // 예: Firebase Crashlytics, Sentry 등
    _logToService(failure);
  }

  /// 실제 로깅 서비스에 에러 전송 (구현 예시)
  void _logToService(WorkoutProgramFailure failure) {
    // 프로덕션 환경에서만 실행
    if (kReleaseMode) {
      // 예시: Firebase Crashlytics
      // FirebaseCrashlytics.instance.recordError(
      //   failure.userMessage,
      //   null,
      //   fatal: false,
      //   information: [
      //     DiagnosticsProperty('errorType', failure.type.toString()),
      //     DiagnosticsProperty('errorCode', failure.errorCode),
      //     DiagnosticsProperty('technicalMessage', failure.technicalMessage),
      //     DiagnosticsProperty('details', failure.details.toString()),
      //   ],
      // );
    }
  }

  /// 에러 타입별 심각도 레벨 반환
  ErrorSeverity getSeverityLevel(WorkoutProgramErrorType errorType) {
    switch (errorType) {
      case WorkoutProgramErrorType.duplicate:
        return ErrorSeverity.info;
      case WorkoutProgramErrorType.repositoryNotInitialized:
        return ErrorSeverity.critical;
      case WorkoutProgramErrorType.dataParsingError:
        return ErrorSeverity.high;
      case WorkoutProgramErrorType.networkError:
        return ErrorSeverity.medium;
      case WorkoutProgramErrorType.serverError:
        return ErrorSeverity.high;
      case WorkoutProgramErrorType.permissionDenied:
        return ErrorSeverity.medium;
      case WorkoutProgramErrorType.programNotFound:
        return ErrorSeverity.medium;
      case WorkoutProgramErrorType.exerciseDataEmpty:
        return ErrorSeverity.medium;
      case WorkoutProgramErrorType.validationError:
        return ErrorSeverity.low;
      case WorkoutProgramErrorType.unknown:
        return ErrorSeverity.critical;
    }
  }

  /// 에러가 재시도 가능한지 확인
  bool isRetryable(WorkoutProgramErrorType errorType) {
    switch (errorType) {
      case WorkoutProgramErrorType.duplicate:
        return false; // 사용자 선택 필요
      case WorkoutProgramErrorType.repositoryNotInitialized:
        return true;
      case WorkoutProgramErrorType.dataParsingError:
        return true;
      case WorkoutProgramErrorType.networkError:
        return true;
      case WorkoutProgramErrorType.serverError:
        return true;
      case WorkoutProgramErrorType.permissionDenied:
        return false; // 인증 필요
      case WorkoutProgramErrorType.programNotFound:
        return true;
      case WorkoutProgramErrorType.exerciseDataEmpty:
        return true;
      case WorkoutProgramErrorType.validationError:
        return false; // 입력 수정 필요
      case WorkoutProgramErrorType.unknown:
        return true;
    }
  }

  /// 사용자에게 표시할 액션 버튼 텍스트 반환
  String getActionButtonText(WorkoutProgramErrorType errorType) {
    switch (errorType) {
      case WorkoutProgramErrorType.duplicate:
        return '선택하기';
      case WorkoutProgramErrorType.repositoryNotInitialized:
        return '다시 시도';
      case WorkoutProgramErrorType.dataParsingError:
        return '새로고침';
      case WorkoutProgramErrorType.networkError:
        return '다시 시도';
      case WorkoutProgramErrorType.serverError:
        return '다시 시도';
      case WorkoutProgramErrorType.permissionDenied:
        return '로그인';
      case WorkoutProgramErrorType.programNotFound:
        return '새로고침';
      case WorkoutProgramErrorType.exerciseDataEmpty:
        return '새로고침';
      case WorkoutProgramErrorType.validationError:
        return '확인';
      case WorkoutProgramErrorType.unknown:
        return '다시 시도';
    }
  }
}

/// 에러 심각도 레벨
enum ErrorSeverity {
  info,    // 정보성 (중복 등)
  low,     // 낮음 (검증 오류 등)
  medium,  // 보통 (네트워크, 권한 등)
  high,    // 높음 (데이터 파싱, 서버 오류 등)
  critical, // 심각 (리포지토리 초기화 실패, 알 수 없는 오류 등)
}