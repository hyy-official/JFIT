import 'package:equatable/equatable.dart';
import 'package:jfit/core/error/failures.dart';

/// 운동 프로그램 관련 실패 타입들
/// 한국어 사용자 메시지와 구조화된 에러 응답을 제공

/// 운동 프로그램 기본 실패 클래스
abstract class WorkoutProgramFailure extends Failure {
  final WorkoutProgramErrorType type;
  final String userMessage;
  final String? technicalMessage;
  final String? errorCode;
  final Map<String, dynamic>? details;

  const WorkoutProgramFailure({
    required this.type,
    required this.userMessage,
    this.technicalMessage,
    this.errorCode,
    this.details,
  }) : super(userMessage);

  @override
  List<Object> get props => [
        type,
        userMessage,
        technicalMessage ?? '',
        errorCode ?? '',
        details ?? {},
      ];
}

/// 중복 프로그램 실패
class ProgramDuplicateFailure extends WorkoutProgramFailure {
  final ProgramDuplicateInfo duplicateInfo;

  ProgramDuplicateFailure({
    required this.duplicateInfo,
    String? technicalMessage,
  }) : super(
          type: WorkoutProgramErrorType.duplicate,
          userMessage: '이미 저장된 프로그램입니다.',
          technicalMessage: technicalMessage,
          errorCode: WorkoutProgramErrorCodes.programDuplicate,
          details: {
            'duplicateInfo': duplicateInfo,
          },
        );
}

/// 리포지토리 초기화 실패
class RepositoryNotInitializedFailure extends WorkoutProgramFailure {
  const RepositoryNotInitializedFailure({
    String? technicalMessage,
  }) : super(
          type: WorkoutProgramErrorType.repositoryNotInitialized,
          userMessage: '운동 프로그램 서비스를 초기화할 수 없습니다.',
          technicalMessage: technicalMessage,
          errorCode: WorkoutProgramErrorCodes.repositoryNotInitialized,
        );
}

/// 데이터 파싱 실패
class DataParsingFailure extends WorkoutProgramFailure {
  final String? dataType;

  DataParsingFailure({
    required String message,
    this.dataType,
    String? technicalMessage,
  }) : super(
          type: WorkoutProgramErrorType.dataParsingError,
          userMessage: '운동 데이터를 불러오는 중 오류가 발생했습니다.',
          technicalMessage: technicalMessage ?? message,
          errorCode: WorkoutProgramErrorCodes.dataParsingError,
          details: {
            'dataType': dataType,
            'originalMessage': message,
          },
        );
}

/// 네트워크 연결 실패
class WorkoutProgramNetworkFailure extends WorkoutProgramFailure {
  const WorkoutProgramNetworkFailure({
    String? technicalMessage,
  }) : super(
          type: WorkoutProgramErrorType.networkError,
          userMessage: '네트워크 연결을 확인해주세요.',
          technicalMessage: technicalMessage,
          errorCode: WorkoutProgramErrorCodes.networkError,
        );
}

/// 서버 에러
class WorkoutProgramServerFailure extends WorkoutProgramFailure {
  final int? statusCode;

  WorkoutProgramServerFailure({
    this.statusCode,
    String? technicalMessage,
  }) : super(
          type: WorkoutProgramErrorType.serverError,
          userMessage: '서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.',
          technicalMessage: technicalMessage,
          errorCode: WorkoutProgramErrorCodes.serverError,
          details: {
            'statusCode': statusCode,
          },
        );
}

/// 권한 없음 실패
class WorkoutProgramPermissionFailure extends WorkoutProgramFailure {
  const WorkoutProgramPermissionFailure({
    String? technicalMessage,
  }) : super(
          type: WorkoutProgramErrorType.permissionDenied,
          userMessage: '해당 작업을 수행할 권한이 없습니다.',
          technicalMessage: technicalMessage,
          errorCode: WorkoutProgramErrorCodes.permissionDenied,
        );
}

/// 프로그램을 찾을 수 없음
class ProgramNotFoundFailure extends WorkoutProgramFailure {
  final String? programId;

  ProgramNotFoundFailure({
    this.programId,
    String? technicalMessage,
  }) : super(
          type: WorkoutProgramErrorType.programNotFound,
          userMessage: '운동 프로그램을 찾을 수 없습니다.',
          technicalMessage: technicalMessage,
          errorCode: WorkoutProgramErrorCodes.programNotFound,
          details: {
            'programId': programId,
          },
        );
}

/// 운동 데이터 없음 실패
class ExerciseDataEmptyFailure extends WorkoutProgramFailure {
  const ExerciseDataEmptyFailure({
    String? technicalMessage,
  }) : super(
          type: WorkoutProgramErrorType.exerciseDataEmpty,
          userMessage: '운동 데이터가 없습니다. 프로그램을 다시 확인해주세요.',
          technicalMessage: technicalMessage,
          errorCode: WorkoutProgramErrorCodes.exerciseDataEmpty,
        );
}

/// 검증 실패
class WorkoutProgramValidationFailure extends WorkoutProgramFailure {
  final List<String> validationErrors;

  WorkoutProgramValidationFailure({
    required this.validationErrors,
    String? technicalMessage,
  }) : super(
          type: WorkoutProgramErrorType.validationError,
          userMessage: '입력한 정보를 다시 확인해주세요.',
          technicalMessage: technicalMessage,
          errorCode: WorkoutProgramErrorCodes.validationError,
          details: {
            'validationErrors': validationErrors,
          },
        );
}

/// 알 수 없는 에러
class WorkoutProgramUnknownFailure extends WorkoutProgramFailure {
  const WorkoutProgramUnknownFailure({
    String? message,
    String? technicalMessage,
  }) : super(
          type: WorkoutProgramErrorType.unknown,
          userMessage: message ?? '알 수 없는 오류가 발생했습니다.',
          technicalMessage: technicalMessage,
          errorCode: WorkoutProgramErrorCodes.unknown,
        );
}

/// 운동 프로그램 에러 타입 열거형
enum WorkoutProgramErrorType {
  duplicate,
  repositoryNotInitialized,
  dataParsingError,
  networkError,
  serverError,
  permissionDenied,
  programNotFound,
  exerciseDataEmpty,
  validationError,
  unknown,
}

/// 중복 프로그램 정보
class ProgramDuplicateInfo extends Equatable {
  final String userProgramId;
  final String programName;
  final int currentWeek;
  final int currentDay;
  final int totalWeeks;
  final double progressPercent;
  final bool isCompleted;
  final DateTime? startedAt;
  final ProgramStatus status;
  final List<ResolutionOption> availableOptions;

  const ProgramDuplicateInfo({
    required this.userProgramId,
    required this.programName,
    required this.currentWeek,
    required this.currentDay,
    required this.totalWeeks,
    required this.progressPercent,
    required this.isCompleted,
    this.startedAt,
    required this.status,
    required this.availableOptions,
  });

  @override
  List<Object?> get props => [
        userProgramId,
        programName,
        currentWeek,
        currentDay,
        totalWeeks,
        progressPercent,
        isCompleted,
        startedAt,
        status,
        availableOptions,
      ];

  /// 진행 상황 텍스트 반환
  String get progressText {
    if (isCompleted) {
      return '완료됨';
    }
    return '$currentWeek주차 $currentDay일차 (${progressPercent.toStringAsFixed(1)}%)';
  }

  /// 상태별 한국어 텍스트
  String get statusText {
    switch (status) {
      case ProgramStatus.active:
        return '진행 중';
      case ProgramStatus.completed:
        return '완료';
      case ProgramStatus.paused:
        return '일시정지';
    }
  }
}

/// 프로그램 상태
enum ProgramStatus {
  active,
  completed,
  paused,
}

/// 중복 해결 옵션
enum ResolutionOption {
  continueExisting,
  restartProgram,
  createNewInstance,
  cancel,
}

/// 해결 옵션별 한국어 텍스트
extension ResolutionOptionExtension on ResolutionOption {
  String get displayText {
    switch (this) {
      case ResolutionOption.continueExisting:
        return '기존 프로그램 계속하기';
      case ResolutionOption.restartProgram:
        return '프로그램 다시 시작하기';
      case ResolutionOption.createNewInstance:
        return '새로운 프로그램으로 저장';
      case ResolutionOption.cancel:
        return '취소';
    }
  }

  String get description {
    switch (this) {
      case ResolutionOption.continueExisting:
        return '현재 진행 중인 프로그램을 그대로 계속합니다.';
      case ResolutionOption.restartProgram:
        return '프로그램을 처음부터 다시 시작합니다.';
      case ResolutionOption.createNewInstance:
        return '동일한 프로그램의 새로운 인스턴스를 생성합니다.';
      case ResolutionOption.cancel:
        return '작업을 취소합니다.';
    }
  }
}

/// 운동 프로그램 에러 코드 상수
class WorkoutProgramErrorCodes {
  // 중복 관련
  static const String programDuplicate = 'PROGRAM_DUPLICATE';
  static const String duplicateResolutionRequired = 'DUPLICATE_RESOLUTION_REQUIRED';

  // 리포지토리 관련
  static const String repositoryNotInitialized = 'REPOSITORY_NOT_INITIALIZED';
  static const String repositoryConnectionFailed = 'REPOSITORY_CONNECTION_FAILED';

  // 데이터 관련
  static const String dataParsingError = 'DATA_PARSING_ERROR';
  static const String exerciseDataEmpty = 'EXERCISE_DATA_EMPTY';
  static const String exerciseDataInvalid = 'EXERCISE_DATA_INVALID';
  static const String programDataCorrupted = 'PROGRAM_DATA_CORRUPTED';

  // 네트워크 관련
  static const String networkError = 'NETWORK_ERROR';
  static const String connectionTimeout = 'CONNECTION_TIMEOUT';
  static const String serverError = 'SERVER_ERROR';

  // 권한 관련
  static const String permissionDenied = 'PERMISSION_DENIED';
  static const String authenticationRequired = 'AUTHENTICATION_REQUIRED';

  // 프로그램 관련
  static const String programNotFound = 'PROGRAM_NOT_FOUND';
  static const String programInactive = 'PROGRAM_INACTIVE';
  static const String programAlreadyCompleted = 'PROGRAM_ALREADY_COMPLETED';

  // 검증 관련
  static const String validationError = 'VALIDATION_ERROR';
  static const String invalidProgramId = 'INVALID_PROGRAM_ID';
  static const String invalidUserId = 'INVALID_USER_ID';
  static const String invalidWeekDay = 'INVALID_WEEK_DAY';

  // 일반
  static const String unknown = 'UNKNOWN_ERROR';
  static const String operationFailed = 'OPERATION_FAILED';
}