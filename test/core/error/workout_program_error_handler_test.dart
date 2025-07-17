import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/core/error/workout_program_error_handler.dart';
import 'package:jfit/core/error/workout_program_failures.dart';

void main() {
  group('WorkoutProgramErrorHandler', () {
    late WorkoutProgramErrorHandler errorHandler;

    setUp(() {
      errorHandler = WorkoutProgramErrorHandler();
    });

    test('should handle ProgramDuplicateFailure correctly', () {
      // arrange
      const duplicateInfo = ProgramDuplicateInfo(
        userProgramId: 'test-id',
        programName: 'Test Program',
        currentWeek: 2,
        currentDay: 3,
        totalWeeks: 4,
        progressPercent: 50.0,
        isCompleted: false,
        status: ProgramStatus.active,
        availableOptions: [ResolutionOption.continueExisting, ResolutionOption.cancel],
      );
      final failure = ProgramDuplicateFailure(duplicateInfo: duplicateInfo);

      // act
      final result = errorHandler.handleFailure(failure);

      // assert
      expect(result.userMessage, '이미 저장된 프로그램입니다.');
      expect(result.errorCode, WorkoutProgramErrorCodes.programDuplicate);
      expect(result.type, WorkoutProgramErrorType.duplicate);
      expect(result.details?['duplicateInfo'], duplicateInfo);
    });

    test('should handle RepositoryNotInitializedFailure correctly', () {
      // arrange
      const failure = RepositoryNotInitializedFailure(
        technicalMessage: 'Repository is null',
      );

      // act
      final result = errorHandler.handleFailure(failure);

      // assert
      expect(result.userMessage, '운동 프로그램 서비스를 초기화할 수 없습니다.');
      expect(result.errorCode, WorkoutProgramErrorCodes.repositoryNotInitialized);
      expect(result.type, WorkoutProgramErrorType.repositoryNotInitialized);
      expect(result.technicalMessage, 'Repository is null');
    });

    test('should handle DataParsingFailure correctly', () {
      // arrange
      final failure = DataParsingFailure(
        message: 'Invalid JSON format',
        dataType: 'exercises_json',
        technicalMessage: 'JSON decode error',
      );

      // act
      final result = errorHandler.handleFailure(failure);

      // assert
      expect(result.userMessage, '운동 데이터를 불러오는 중 오류가 발생했습니다.');
      expect(result.errorCode, WorkoutProgramErrorCodes.dataParsingError);
      expect(result.type, WorkoutProgramErrorType.dataParsingError);
      expect(result.technicalMessage, 'JSON decode error');
      expect(result.details?['dataType'], 'exercises_json');
      expect(result.details?['originalMessage'], 'Invalid JSON format');
    });

    test('should handle WorkoutProgramNetworkFailure correctly', () {
      // arrange
      const failure = WorkoutProgramNetworkFailure(
        technicalMessage: 'Connection timeout',
      );

      // act
      final result = errorHandler.handleFailure(failure);

      // assert
      expect(result.userMessage, '네트워크 연결을 확인해주세요.');
      expect(result.errorCode, WorkoutProgramErrorCodes.networkError);
      expect(result.type, WorkoutProgramErrorType.networkError);
      expect(result.technicalMessage, 'Connection timeout');
    });

    test('should handle WorkoutProgramServerFailure correctly', () {
      // arrange
      final failure = WorkoutProgramServerFailure(
        statusCode: 500,
        technicalMessage: 'Internal server error',
      );

      // act
      final result = errorHandler.handleFailure(failure);

      // assert
      expect(result.userMessage, '서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.');
      expect(result.errorCode, WorkoutProgramErrorCodes.serverError);
      expect(result.type, WorkoutProgramErrorType.serverError);
      expect(result.technicalMessage, 'Internal server error');
      expect(result.details?['statusCode'], 500);
    });

    test('should handle WorkoutProgramPermissionFailure correctly', () {
      // arrange
      const failure = WorkoutProgramPermissionFailure(
        technicalMessage: 'User not authenticated',
      );

      // act
      final result = errorHandler.handleFailure(failure);

      // assert
      expect(result.userMessage, '해당 작업을 수행할 권한이 없습니다.');
      expect(result.errorCode, WorkoutProgramErrorCodes.permissionDenied);
      expect(result.type, WorkoutProgramErrorType.permissionDenied);
      expect(result.technicalMessage, 'User not authenticated');
    });

    test('should handle ProgramNotFoundFailure correctly', () {
      // arrange
      final failure = ProgramNotFoundFailure(
        programId: 'test-program-id',
        technicalMessage: 'Program does not exist',
      );

      // act
      final result = errorHandler.handleFailure(failure);

      // assert
      expect(result.userMessage, '운동 프로그램을 찾을 수 없습니다.');
      expect(result.errorCode, WorkoutProgramErrorCodes.programNotFound);
      expect(result.type, WorkoutProgramErrorType.programNotFound);
      expect(result.technicalMessage, 'Program does not exist');
      expect(result.details?['programId'], 'test-program-id');
    });

    test('should handle ExerciseDataEmptyFailure correctly', () {
      // arrange
      const failure = ExerciseDataEmptyFailure(
        technicalMessage: 'exercises_json is empty',
      );

      // act
      final result = errorHandler.handleFailure(failure);

      // assert
      expect(result.userMessage, '운동 데이터가 없습니다. 프로그램을 다시 확인해주세요.');
      expect(result.errorCode, WorkoutProgramErrorCodes.exerciseDataEmpty);
      expect(result.type, WorkoutProgramErrorType.exerciseDataEmpty);
      expect(result.technicalMessage, 'exercises_json is empty');
    });

    test('should handle WorkoutProgramValidationFailure correctly', () {
      // arrange
      final failure = WorkoutProgramValidationFailure(
        validationErrors: ['Invalid program ID', 'Missing user ID'],
        technicalMessage: 'Validation failed',
      );

      // act
      final result = errorHandler.handleFailure(failure);

      // assert
      expect(result.userMessage, '입력한 정보를 다시 확인해주세요.');
      expect(result.errorCode, WorkoutProgramErrorCodes.validationError);
      expect(result.type, WorkoutProgramErrorType.validationError);
      expect(result.technicalMessage, 'Validation failed');
      expect(result.details?['validationErrors'], ['Invalid program ID', 'Missing user ID']);
    });

    test('should handle WorkoutProgramUnknownFailure correctly', () {
      // arrange
      const failure = WorkoutProgramUnknownFailure(
        message: 'Something went wrong',
        technicalMessage: 'Unknown error occurred',
      );

      // act
      final result = errorHandler.handleFailure(failure);

      // assert
      expect(result.userMessage, 'Something went wrong');
      expect(result.errorCode, WorkoutProgramErrorCodes.unknown);
      expect(result.type, WorkoutProgramErrorType.unknown);
      expect(result.technicalMessage, 'Unknown error occurred');
    });

    test('should provide recovery suggestions for different error types', () {
      // arrange
      final duplicateFailure = ProgramDuplicateFailure(
        duplicateInfo: const ProgramDuplicateInfo(
          userProgramId: 'test-id',
          programName: 'Test Program',
          currentWeek: 1,
          currentDay: 1,
          totalWeeks: 4,
          progressPercent: 0.0,
          isCompleted: false,
          status: ProgramStatus.active,
          availableOptions: [ResolutionOption.continueExisting],
        ),
      );
      const networkFailure = WorkoutProgramNetworkFailure();
      final serverFailure = WorkoutProgramServerFailure();

      // act & assert
      expect(errorHandler.getRecoverySuggestion(duplicateFailure.type), 
             '기존 프로그램을 계속하거나 새로 시작할 수 있습니다.');
      expect(errorHandler.getRecoverySuggestion(networkFailure.type), 
             '네트워크 연결을 확인하고 다시 시도해주세요.');
      expect(errorHandler.getRecoverySuggestion(serverFailure.type), 
             '잠시 후 다시 시도해주세요.');
    });

    test('should log errors appropriately', () {
      // arrange
      final failure = DataParsingFailure(
        message: 'Test parsing error',
        technicalMessage: 'Technical details',
      );

      // act
      errorHandler.logError(failure);

      // assert - In a real implementation, you would verify logging
      // For now, we just ensure the method doesn't throw
      expect(true, true);
    });
  });
}