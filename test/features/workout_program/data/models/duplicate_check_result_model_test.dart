import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/features/workout_program/data/models/duplicate_check_result_model.dart';
import 'package:jfit/core/error/workout_program_failures.dart';

void main() {
  group('DuplicateCheckResult', () {
    test('should create noDuplicate result correctly', () {
      // arrange & act
      const result = DuplicateCheckResult.noDuplicate();

      // assert
      expect(result.isDuplicate, false);
      expect(result.existingProgramId, null);
      expect(result.status, null);
      expect(result.progressPercent, null);
      expect(result.duplicateInfo, null);
    });

    test('should create duplicate result correctly', () {
      // arrange
      const duplicateInfo = ProgramDuplicateInfo(
        userProgramId: 'test-user-program-id',
        programName: 'Test Program',
        currentWeek: 2,
        currentDay: 3,
        totalWeeks: 4,
        progressPercent: 50.0,
        isCompleted: false,
        status: ProgramStatus.active,
        availableOptions: [
          ResolutionOption.continueExisting,
          ResolutionOption.restartProgram,
          ResolutionOption.cancel,
        ],
      );

      // act
      final result = DuplicateCheckResult.duplicate(
        existingProgramId: 'test-user-program-id',
        duplicateInfo: duplicateInfo,
      );

      // assert
      expect(result.isDuplicate, true);
      expect(result.existingProgramId, 'test-user-program-id');
      expect(result.status, ProgramStatus.active);
      expect(result.progressPercent, 50.0);
      expect(result.duplicateInfo, duplicateInfo);
    });

    test('should create from null map correctly', () {
      // arrange & act
      final result = DuplicateCheckResult.fromMap(null);

      // assert
      expect(result.isDuplicate, false);
      expect(result.existingProgramId, null);
      expect(result.status, null);
      expect(result.progressPercent, null);
      expect(result.duplicateInfo, null);
    });

    test('should create from map with active program correctly', () {
      // arrange
      final map = {
        'userProgramId': 'test-user-program-id',
        'programName': 'Test Program',
        'currentWeek': 2,
        'currentDay': 3,
        'totalWeeks': 4,
        'progressPercent': 50.0,
        'isCompleted': false,
        'startedAt': '2024-01-01T00:00:00.000Z',
      };

      // act
      final result = DuplicateCheckResult.fromMap(map);

      // assert
      expect(result.isDuplicate, true);
      expect(result.existingProgramId, 'test-user-program-id');
      expect(result.status, ProgramStatus.active);
      expect(result.progressPercent, 50.0);
      expect(result.duplicateInfo, isNotNull);
      expect(result.duplicateInfo!.userProgramId, 'test-user-program-id');
      expect(result.duplicateInfo!.programName, 'Test Program');
      expect(result.duplicateInfo!.currentWeek, 2);
      expect(result.duplicateInfo!.currentDay, 3);
      expect(result.duplicateInfo!.totalWeeks, 4);
      expect(result.duplicateInfo!.progressPercent, 50.0);
      expect(result.duplicateInfo!.isCompleted, false);
      expect(result.duplicateInfo!.status, ProgramStatus.active);
      expect(result.duplicateInfo!.availableOptions, contains(ResolutionOption.continueExisting));
      expect(result.duplicateInfo!.availableOptions, contains(ResolutionOption.restartProgram));
      expect(result.duplicateInfo!.availableOptions, contains(ResolutionOption.createNewInstance));
      expect(result.duplicateInfo!.availableOptions, contains(ResolutionOption.cancel));
    });

    test('should create from map with completed program correctly', () {
      // arrange
      final map = {
        'userProgramId': 'test-user-program-id',
        'programName': 'Test Program',
        'currentWeek': 4,
        'currentDay': 7,
        'totalWeeks': 4,
        'progressPercent': 100.0,
        'isCompleted': true,
        'startedAt': '2024-01-01T00:00:00.000Z',
      };

      // act
      final result = DuplicateCheckResult.fromMap(map);

      // assert
      expect(result.isDuplicate, true);
      expect(result.duplicateInfo!.isCompleted, true);
      expect(result.duplicateInfo!.status, ProgramStatus.completed);
      expect(result.duplicateInfo!.availableOptions, contains(ResolutionOption.restartProgram));
      expect(result.duplicateInfo!.availableOptions, contains(ResolutionOption.createNewInstance));
      expect(result.duplicateInfo!.availableOptions, contains(ResolutionOption.cancel));
      expect(result.duplicateInfo!.availableOptions, isNot(contains(ResolutionOption.continueExisting)));
    });

    test('should create from map with paused program correctly', () {
      // arrange
      final map = {
        'userProgramId': 'test-user-program-id',
        'programName': 'Test Program',
        'currentWeek': 1,
        'currentDay': 1,
        'totalWeeks': 4,
        'progressPercent': 0.0,
        'isCompleted': false,
        'startedAt': '2024-01-01T00:00:00.000Z',
      };

      // act
      final result = DuplicateCheckResult.fromMap(map);

      // assert
      expect(result.isDuplicate, true);
      expect(result.duplicateInfo!.status, ProgramStatus.paused);
      expect(result.duplicateInfo!.availableOptions, contains(ResolutionOption.continueExisting));
      expect(result.duplicateInfo!.availableOptions, contains(ResolutionOption.restartProgram));
      expect(result.duplicateInfo!.availableOptions, contains(ResolutionOption.createNewInstance));
      expect(result.duplicateInfo!.availableOptions, contains(ResolutionOption.cancel));
    });

    test('should handle missing fields with defaults', () {
      // arrange
      final map = {
        'userProgramId': 'test-user-program-id',
        'programName': 'Test Program',
        // Missing other fields
      };

      // act
      final result = DuplicateCheckResult.fromMap(map);

      // assert
      expect(result.isDuplicate, true);
      expect(result.duplicateInfo!.currentWeek, 1);
      expect(result.duplicateInfo!.currentDay, 1);
      expect(result.duplicateInfo!.totalWeeks, 1);
      expect(result.duplicateInfo!.progressPercent, 0.0);
      expect(result.duplicateInfo!.isCompleted, false);
      expect(result.duplicateInfo!.status, ProgramStatus.paused);
    });

    test('should handle invalid startedAt date', () {
      // arrange
      final map = {
        'userProgramId': 'test-user-program-id',
        'programName': 'Test Program',
        'startedAt': 'invalid-date',
      };

      // act
      final result = DuplicateCheckResult.fromMap(map);

      // assert
      expect(result.isDuplicate, true);
      expect(result.duplicateInfo!.startedAt, null);
    });
  });
}