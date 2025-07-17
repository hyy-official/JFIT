import 'package:jfit/core/error/failures.dart';

/// Base class for all BLOC-specific errors
/// Extends the existing Failure class to maintain consistency
abstract class BlocError extends Failure {
  final String? code;
  final Map<String, dynamic>? details;
  
  const BlocError(
    super.message, {
    this.code,
    this.details,
  });

  @override
  List<Object> get props => [message, if (code != null) code!, if (details != null) details!];
}

/// Meal-related errors
class MealError extends BlocError {
  const MealError(
    super.message, {
    super.code,
    super.details,
  });
}

/// Workout program-related errors
class WorkoutProgramError extends BlocError {
  const WorkoutProgramError(
    super.message, {
    super.code,
    super.details,
  });
}

/// Workout session-related errors
class WorkoutSessionError extends BlocError {
  const WorkoutSessionError(
    super.message, {
    super.code,
    super.details,
  });
}

/// Daily summary-related errors
class DailySummaryError extends BlocError {
  const DailySummaryError(
    super.message, {
    super.code,
    super.details,
  });
}

/// Exercise-related errors
class ExerciseError extends BlocError {
  const ExerciseError(
    super.message, {
    super.code,
    super.details,
  });
}

/// BLOC communication errors
class BlocCommunicationError extends BlocError {
  const BlocCommunicationError(
    super.message, {
    super.code,
    super.details,
  });
}

/// Common error codes for consistent error handling
class BlocErrorCodes {
  // General error codes
  static const String unknown = 'UNKNOWN_ERROR';
  static const String networkError = 'NETWORK_ERROR';
  static const String serverError = 'SERVER_ERROR';
  static const String validationError = 'VALIDATION_ERROR';
  
  // Meal-specific error codes
  static const String mealNotFound = 'MEAL_NOT_FOUND';
  static const String mealValidationFailed = 'MEAL_VALIDATION_FAILED';
  static const String mealSaveFailed = 'MEAL_SAVE_FAILED';
  static const String mealDeleteFailed = 'MEAL_DELETE_FAILED';
  
  // Workout program-specific error codes
  static const String programNotFound = 'PROGRAM_NOT_FOUND';
  static const String programValidationFailed = 'PROGRAM_VALIDATION_FAILED';
  static const String programProgressUpdateFailed = 'PROGRAM_PROGRESS_UPDATE_FAILED';
  static const String programDeleteFailed = 'PROGRAM_DELETE_FAILED';
  static const String workoutProgramUpdateFailed = 'WORKOUT_PROGRAM_UPDATE_FAILED';
  static const String workoutProgramDeleteFailed = 'WORKOUT_PROGRAM_DELETE_FAILED';
  static const String dataNotFound = 'DATA_NOT_FOUND';
  
  // Enhanced workout program error codes
  static const String programDuplicate = 'PROGRAM_DUPLICATE';
  static const String duplicateResolutionRequired = 'DUPLICATE_RESOLUTION_REQUIRED';
  static const String repositoryNotInitialized = 'REPOSITORY_NOT_INITIALIZED';
  static const String repositoryConnectionFailed = 'REPOSITORY_CONNECTION_FAILED';
  static const String dataParsingError = 'DATA_PARSING_ERROR';
  static const String exerciseDataEmpty = 'EXERCISE_DATA_EMPTY';
  static const String exerciseDataInvalid = 'EXERCISE_DATA_INVALID';
  static const String programDataCorrupted = 'PROGRAM_DATA_CORRUPTED';
  static const String connectionTimeout = 'CONNECTION_TIMEOUT';
  static const String permissionDenied = 'PERMISSION_DENIED';
  static const String authenticationRequired = 'AUTHENTICATION_REQUIRED';
  static const String programInactive = 'PROGRAM_INACTIVE';
  static const String programAlreadyCompleted = 'PROGRAM_ALREADY_COMPLETED';
  static const String invalidProgramId = 'INVALID_PROGRAM_ID';
  static const String invalidUserId = 'INVALID_USER_ID';
  static const String invalidWeekDay = 'INVALID_WEEK_DAY';
  static const String operationFailed = 'OPERATION_FAILED';
  
  // Workout session-specific error codes
  static const String sessionNotFound = 'SESSION_NOT_FOUND';
  static const String sessionCreateFailed = 'SESSION_CREATE_FAILED';
  static const String sessionUpdateFailed = 'SESSION_UPDATE_FAILED';
  static const String sessionCompleteFailed = 'SESSION_COMPLETE_FAILED';
  static const String workoutLogFailed = 'WORKOUT_LOG_FAILED';
  
  // Daily summary-specific error codes
  static const String summaryCalculationFailed = 'SUMMARY_CALCULATION_FAILED';
  static const String summaryNotFound = 'SUMMARY_NOT_FOUND';
  static const String summaryUpdateFailed = 'SUMMARY_UPDATE_FAILED';
  
  // Exercise-specific error codes
  static const String exerciseNotFound = 'EXERCISE_NOT_FOUND';
  static const String exerciseSearchFailed = 'EXERCISE_SEARCH_FAILED';
  
  // Communication error codes
  static const String communicationError = 'COMMUNICATION_ERROR';
  static const String communicationTimeout = 'COMMUNICATION_TIMEOUT';
  static const String communicationFailed = 'COMMUNICATION_FAILED';
}

/// Error handler utility for consistent error processing
class BlocErrorHandler {
  /// Convert generic exceptions to appropriate BLOC errors
  static BlocError handleException(Exception exception, BlocErrorType type) {
    final message = exception.toString();
    
    switch (type) {
      case BlocErrorType.meal:
        return MealError(message, code: BlocErrorCodes.unknown);
      case BlocErrorType.workoutProgram:
        return WorkoutProgramError(message, code: BlocErrorCodes.unknown);
      case BlocErrorType.workoutSession:
        return WorkoutSessionError(message, code: BlocErrorCodes.unknown);
      case BlocErrorType.dailySummary:
        return DailySummaryError(message, code: BlocErrorCodes.unknown);
      case BlocErrorType.exercise:
        return ExerciseError(message, code: BlocErrorCodes.unknown);
      case BlocErrorType.communication:
        return BlocCommunicationError(message, code: BlocErrorCodes.unknown);
    }
  }

  /// Get user-friendly error message
  static String getUserFriendlyMessage(BlocError error) {
    switch (error.code) {
      // General error codes
      case BlocErrorCodes.networkError:
        return '네트워크 연결을 확인해주세요.';
      case BlocErrorCodes.serverError:
        return '서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.';
      case BlocErrorCodes.validationError:
        return '입력한 정보를 다시 확인해주세요.';
      case BlocErrorCodes.connectionTimeout:
        return '연결 시간이 초과되었습니다. 다시 시도해주세요.';
      case BlocErrorCodes.permissionDenied:
        return '해당 작업을 수행할 권한이 없습니다.';
      case BlocErrorCodes.authenticationRequired:
        return '로그인이 필요합니다.';
      
      // Meal-related errors
      case BlocErrorCodes.mealNotFound:
        return '식사 기록을 찾을 수 없습니다.';
      case BlocErrorCodes.mealValidationFailed:
        return '식사 정보를 다시 확인해주세요.';
      case BlocErrorCodes.mealSaveFailed:
        return '식사 기록 저장에 실패했습니다.';
      case BlocErrorCodes.mealDeleteFailed:
        return '식사 기록 삭제에 실패했습니다.';
      
      // Workout program-related errors
      case BlocErrorCodes.programNotFound:
        return '운동 프로그램을 찾을 수 없습니다.';
      case BlocErrorCodes.programDuplicate:
        return '이미 저장된 프로그램입니다.';
      case BlocErrorCodes.duplicateResolutionRequired:
        return '중복된 프로그램에 대한 처리가 필요합니다.';
      case BlocErrorCodes.repositoryNotInitialized:
        return '운동 프로그램 서비스를 초기화할 수 없습니다.';
      case BlocErrorCodes.repositoryConnectionFailed:
        return '운동 프로그램 서비스 연결에 실패했습니다.';
      case BlocErrorCodes.dataParsingError:
        return '운동 데이터를 불러오는 중 오류가 발생했습니다.';
      case BlocErrorCodes.exerciseDataEmpty:
        return '운동 데이터가 없습니다. 프로그램을 다시 확인해주세요.';
      case BlocErrorCodes.exerciseDataInvalid:
        return '운동 데이터가 올바르지 않습니다.';
      case BlocErrorCodes.programDataCorrupted:
        return '프로그램 데이터가 손상되었습니다.';
      case BlocErrorCodes.programInactive:
        return '비활성화된 프로그램입니다.';
      case BlocErrorCodes.programAlreadyCompleted:
        return '이미 완료된 프로그램입니다.';
      case BlocErrorCodes.programValidationFailed:
        return '프로그램 정보를 다시 확인해주세요.';
      case BlocErrorCodes.programProgressUpdateFailed:
        return '프로그램 진행 상황 업데이트에 실패했습니다.';
      case BlocErrorCodes.programDeleteFailed:
        return '프로그램 삭제에 실패했습니다.';
      case BlocErrorCodes.workoutProgramUpdateFailed:
        return '운동 프로그램 업데이트에 실패했습니다.';
      case BlocErrorCodes.workoutProgramDeleteFailed:
        return '운동 프로그램 삭제에 실패했습니다.';
      case BlocErrorCodes.invalidProgramId:
        return '올바르지 않은 프로그램 ID입니다.';
      case BlocErrorCodes.invalidUserId:
        return '올바르지 않은 사용자 ID입니다.';
      case BlocErrorCodes.invalidWeekDay:
        return '올바르지 않은 주차 또는 일차입니다.';
      
      // Workout session-related errors
      case BlocErrorCodes.sessionNotFound:
        return '운동 세션을 찾을 수 없습니다.';
      case BlocErrorCodes.sessionCreateFailed:
        return '운동 세션 생성에 실패했습니다.';
      case BlocErrorCodes.sessionUpdateFailed:
        return '운동 세션 업데이트에 실패했습니다.';
      case BlocErrorCodes.sessionCompleteFailed:
        return '운동 세션 완료 처리에 실패했습니다.';
      case BlocErrorCodes.workoutLogFailed:
        return '운동 기록 저장에 실패했습니다.';
      
      // Exercise-related errors
      case BlocErrorCodes.exerciseNotFound:
        return '운동 정보를 찾을 수 없습니다.';
      case BlocErrorCodes.exerciseSearchFailed:
        return '운동 검색에 실패했습니다.';
      
      // Daily summary-related errors
      case BlocErrorCodes.summaryCalculationFailed:
        return '일일 요약 계산에 실패했습니다.';
      case BlocErrorCodes.summaryNotFound:
        return '일일 요약을 찾을 수 없습니다.';
      case BlocErrorCodes.summaryUpdateFailed:
        return '일일 요약 업데이트에 실패했습니다.';
      
      // Communication errors
      case BlocErrorCodes.communicationError:
        return '통신 오류가 발생했습니다.';
      case BlocErrorCodes.communicationTimeout:
        return '통신 시간이 초과되었습니다.';
      case BlocErrorCodes.communicationFailed:
        return '통신에 실패했습니다.';
      
      // General errors
      case BlocErrorCodes.dataNotFound:
        return '데이터를 찾을 수 없습니다.';
      case BlocErrorCodes.operationFailed:
        return '작업 수행에 실패했습니다.';
      case BlocErrorCodes.unknown:
      default:
        return error.message.isNotEmpty ? error.message : '알 수 없는 오류가 발생했습니다.';
    }
  }
}

/// Enum for different BLOC error types
enum BlocErrorType {
  meal,
  workoutProgram,
  workoutSession,
  dailySummary,
  exercise,
  communication,
}