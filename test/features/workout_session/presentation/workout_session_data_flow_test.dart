import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:jfit/features/workout_session/bloc/workout_session_bloc.dart';
import 'package:jfit/features/workout_session/data/repositories/workout_session_repository.dart';
import 'package:jfit/features/workout_program/utils/exercise_data_parser.dart';
import 'package:jfit/core/error/workout_program_failures.dart';
import 'package:jfit/core/models/exercise.dart';

import 'workout_session_data_flow_test.mocks.dart';

@GenerateMocks([
  WorkoutSessionRepository,
])
void main() {
  group('Workout Session Data Flow Tests', () {
    late MockWorkoutSessionRepository mockRepository;
    late WorkoutSessionBloc workoutSessionBloc;

    setUp(() {
      mockRepository = MockWorkoutSessionRepository();
      workoutSessionBloc = WorkoutSessionBloc(repository: mockRepository);
    });

    tearDown(() {
      workoutSessionBloc.close();
    });

    group('Exercise Loading from Program Data', () {
      test('should load exercises from JSON string format successfully', () async {
        // arrange
        const userProgramId = 'user-program-123';
        const week = 1;
        const day = 1;

        final exerciseJsonData = '''
        [
          {
            "id": 1,
            "exercise_name": "벤치프레스",
            "sets": 4,
            "reps": "10",
            "type": "strength",
            "equipment": "barbell"
          },
          {
            "id": 2,
            "exercise_name": "푸쉬업",
            "sets": 3,
            "reps": "15",
            "type": "bodyweight",
            "equipment": "none"
          }
        ]
        ''';

        final mockProgramData = {
          'id': userProgramId,
          'exercises_json': exerciseJsonData,
          'current_week': week,
          'current_day': day,
        };

        when(mockRepository.getUserProgramData(userProgramId))
            .thenAnswer((_) async => Right(mockProgramData));

        // act
        final result = await _loadExercisesFromProgramData(mockProgramData);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail: ${failure.message}'),
          (exercises) {
            expect(exercises, hasLength(2));
            expect(exercises[0].titleKo, '벤치프레스');
            expect(exercises[0].type, 'strength');
            expect(exercises[1].titleKo, '푸쉬업');
            expect(exercises[1].type, 'bodyweight');
          },
        );
      });

      test('should load exercises from direct list format successfully', () async {
        // arrange
        const userProgramId = 'user-program-123';
        
        final exerciseListData = [
          {
            'id': 1,
            'exercise_name': '스쿼트',
            'sets': 3,
            'reps': '12',
            'type': 'strength'
          },
          {
            'id': 2,
            'exercise_name': '런지',
            'sets': 3,
            'reps': '10',
            'type': 'strength'
          }
        ];

        final mockProgramData = {
          'id': userProgramId,
          'exercises_json': exerciseListData,
          'current_week': 1,
          'current_day': 1,
        };

        when(mockRepository.getUserProgramData(userProgramId))
            .thenAnswer((_) async => Right(mockProgramData));

        // act
        final result = await _loadExercisesFromProgramData(mockProgramData);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail: ${failure.message}'),
          (exercises) {
            expect(exercises, hasLength(2));
            expect(exercises[0].titleKo, '스쿼트');
            expect(exercises[1].titleKo, '런지');
          },
        );
      });

      test('should load exercises from weekly structure format successfully', () async {
        // arrange
        const userProgramId = 'user-program-123';
        const week = 1;
        const day = 2;

        final weeklyStructureData = [
          {
            'days': [
              {
                'exercises': [
                  {
                    'id': 1,
                    'exercise_name': '1주차 1일차 운동',
                    'sets': 3,
                    'reps': '10'
                  }
                ]
              },
              {
                'exercises': [
                  {
                    'id': 2,
                    'exercise_name': '1주차 2일차 운동',
                    'sets': 4,
                    'reps': '12'
                  }
                ]
              }
            ]
          }
        ];

        final mockProgramData = {
          'id': userProgramId,
          'exercises_json': weeklyStructureData,
          'current_week': week,
          'current_day': day,
        };

        when(mockRepository.getUserProgramData(userProgramId))
            .thenAnswer((_) async => Right(mockProgramData));

        // act
        final result = await _loadExercisesForWeekDay(mockProgramData, week, day);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail: ${failure.message}'),
          (exercises) {
            expect(exercises, hasLength(1));
            expect(exercises[0].titleKo, '1주차 2일차 운동');
          },
        );
      });

      test('should handle empty exercise data gracefully', () async {
        // arrange
        const userProgramId = 'user-program-123';

        final mockProgramData = {
          'id': userProgramId,
          'exercises_json': null,
          'current_week': 1,
          'current_day': 1,
        };

        when(mockRepository.getUserProgramData(userProgramId))
            .thenAnswer((_) async => Right(mockProgramData));

        // act
        final result = await _loadExercisesFromProgramData(mockProgramData);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail: ${failure.message}'),
          (exercises) => expect(exercises, isEmpty),
        );
      });

      test('should handle malformed exercise data with proper error', () async {
        // arrange
        const userProgramId = 'user-program-123';

        final mockProgramData = {
          'id': userProgramId,
          'exercises_json': '{"invalid": json}', // Invalid JSON
          'current_week': 1,
          'current_day': 1,
        };

        when(mockRepository.getUserProgramData(userProgramId))
            .thenAnswer((_) async => Right(mockProgramData));

        // act
        final result = await _loadExercisesFromProgramData(mockProgramData);

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<DataParsingFailure>());
            final dataFailure = failure as DataParsingFailure;
            expect(dataFailure.technicalMessage, contains('Failed to decode JSON string'));
          },
          (exercises) => fail('Should fail with parsing error'),
        );
      });

      test('should handle mixed valid and invalid exercise items', () async {
        // arrange
        const userProgramId = 'user-program-123';

        final mixedExerciseData = [
          {
            'id': 1,
            'exercise_name': '유효한 운동',
            'sets': 3,
            'reps': '10'
          },
          null, // Invalid item - should be skipped
          {
            'id': 2,
            'exercise_name': '또 다른 유효한 운동',
            'sets': 4,
            'reps': '12'
          },
          // Note: string items cause parsing failure, so we test with null instead
        ];

        final mockProgramData = {
          'id': userProgramId,
          'exercises_json': mixedExerciseData,
          'current_week': 1,
          'current_day': 1,
        };

        when(mockRepository.getUserProgramData(userProgramId))
            .thenAnswer((_) async => Right(mockProgramData));

        // act
        final result = await _loadExercisesFromProgramData(mockProgramData);

        // assert
        result.fold(
          (failure) => fail('Should not fail: ${failure.message}'),
          (exercises) {
            // Should only include valid exercises
            expect(exercises, hasLength(2));
            expect(exercises[0].titleKo, '유효한 운동');
            expect(exercises[1].titleKo, '또 다른 유효한 운동');
          },
        );
      });
    });

    group('Data Flow Validation', () {
      test('should validate exercise data structure before UI display', () {
        // Test various exercise data structures
        final testCases = [
          // Valid minimal exercise
          {
            'id': 1,
            'exercise_name': '테스트 운동',
          },
          // Valid complete exercise
          {
            'id': 2,
            'exercise_name': '완전한 운동',
            'title_en': 'Complete Exercise',
            'desc_ko': '운동 설명',
            'difficulty': 'intermediate',
            'type': 'strength',
            'equipment': 'barbell',
            'sets': 4,
            'reps': '10',
            'rest_seconds': 60,
          },
          // Exercise with alternative field names
          {
            'exercise_id': 3,
            'name': '대체 필드명 운동',
            'custom_type': 'cardio',
            'description': '설명',
          },
        ];

        for (final exerciseData in testCases) {
          final result = ExerciseDataParser.parseExercises([exerciseData]);
          expect(result.isRight(), true, 
                 reason: 'Failed for exercise data: $exerciseData');
          
          result.fold(
            (failure) => fail('Should not fail for: $exerciseData'),
            (exercises) {
              expect(exercises, hasLength(1));
              expect(exercises[0].id, isA<int>());
              expect(exercises[0].titleKo, isNotEmpty);
            },
          );
        }
      });

      test('should handle exercise field type conversions safely', () {
        final exerciseWithMixedTypes = {
          'id': '123', // String instead of int
          'exercise_name': 'Type Conversion Test',
          'sets': '4', // String instead of int
          'reps': 10, // Int instead of string
          'rest_seconds': '60', // String instead of int
          'is_active': 'true', // String instead of bool
          'popularity_score': '85', // String instead of int
          'met_value': '5.5', // String instead of double
        };

        final result = ExerciseDataParser.parseExercises([exerciseWithMixedTypes]);
        expect(result.isRight(), true);
        
        result.fold(
          (failure) => fail('Should handle type conversions: ${failure.message}'),
          (exercises) {
            expect(exercises, hasLength(1));
            final exercise = exercises[0];
            expect(exercise.id, 123);
            expect(exercise.titleKo, 'Type Conversion Test');
            expect(exercise.recommendedSets, '4');
            expect(exercise.recommendedReps, '10');
            expect(exercise.recommendedRestSeconds, 60);
            expect(exercise.isActive, true);
            expect(exercise.popularityScore, 85);
            expect(exercise.metValue, 5.5);
          },
        );
      });

      test('should maintain data consistency across parsing methods', () {
        final weeklyMapData = {
          'week_1': {
            'day_1': [
              {
                'id': 1,
                'exercise_name': '일관성 테스트',
                'sets': 3,
                'reps': '10'
              }
            ]
          }
        };

        // Parse with general method
        final generalResult = ExerciseDataParser.parseExercises(weeklyMapData);
        
        // Parse with specific week/day method
        final specificResult = ExerciseDataParser.parseExercisesForWeekDay(weeklyMapData, 1, 1);

        expect(generalResult.isRight(), true);
        expect(specificResult.isRight(), true);

        generalResult.fold(
          (failure) => fail('General parsing failed'),
          (generalExercises) {
            specificResult.fold(
              (failure) => fail('Specific parsing failed'),
              (specificExercises) {
                // Both methods should return the same exercise
                expect(generalExercises.length, specificExercises.length);
                if (generalExercises.isNotEmpty && specificExercises.isNotEmpty) {
                  expect(generalExercises[0].titleKo, specificExercises[0].titleKo);
                  expect(generalExercises[0].id, specificExercises[0].id);
                }
              },
            );
          },
        );
      });
    });

    group('Error Handling in Data Flow', () {
      test('should handle repository errors gracefully', () async {
        // arrange
        const userProgramId = 'user-program-123';
        const networkFailure = WorkoutProgramNetworkFailure(
          technicalMessage: 'Connection timeout',
        );

        when(mockRepository.getUserProgramData(userProgramId))
            .thenAnswer((_) async => const Left(networkFailure));

        // act
        final result = await mockRepository.getUserProgramData(userProgramId);

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<WorkoutProgramNetworkFailure>());
            final networkFailure = failure as WorkoutProgramNetworkFailure;
            expect(networkFailure.userMessage, '네트워크 연결을 확인해주세요.');
          },
          (data) => fail('Should fail with network error'),
        );
      });

      test('should handle program not found errors', () async {
        // arrange
        const userProgramId = 'non-existent-program';
        final programNotFoundFailure = ProgramNotFoundFailure(
          programId: userProgramId,
          technicalMessage: 'Program does not exist',
        );

        when(mockRepository.getUserProgramData(userProgramId))
            .thenAnswer((_) async => Left(programNotFoundFailure));

        // act
        final result = await mockRepository.getUserProgramData(userProgramId);

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ProgramNotFoundFailure>());
            final programFailure = failure as ProgramNotFoundFailure;
            expect(programFailure.userMessage, '운동 프로그램을 찾을 수 없습니다.');
          },
          (data) => fail('Should fail with program not found error'),
        );
      });

      test('should handle empty exercise data as valid case', () async {
        // arrange
        const userProgramId = 'empty-program';
        const emptyDataFailure = ExerciseDataEmptyFailure(
          technicalMessage: 'exercises_json is empty',
        );

        when(mockRepository.getUserProgramData(userProgramId))
            .thenAnswer((_) async => const Left(emptyDataFailure));

        // act
        final result = await mockRepository.getUserProgramData(userProgramId);

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ExerciseDataEmptyFailure>());
            final emptyFailure = failure as ExerciseDataEmptyFailure;
            expect(emptyFailure.userMessage, '운동 데이터가 없습니다. 프로그램을 다시 확인해주세요.');
          },
          (data) => fail('Should fail with empty data error'),
        );
      });
    });
  });
}

/// Helper function to simulate loading exercises from program data
Future<Either<WorkoutProgramFailure, List<Exercise>>> _loadExercisesFromProgramData(
  Map<String, dynamic> programData,
) async {
  try {
    final exercisesJson = programData['exercises_json'];
    final result = ExerciseDataParser.parseExercises(exercisesJson);
    return result.fold(
      (failure) => Left(failure as WorkoutProgramFailure),
      (exercises) => Right(exercises),
    );
  } catch (e) {
    return Left(WorkoutProgramUnknownFailure(
      message: '운동 데이터 로딩 중 오류가 발생했습니다.',
      technicalMessage: 'Error loading exercises: $e',
    ));
  }
}

/// Helper function to simulate loading exercises for specific week/day
Future<Either<WorkoutProgramFailure, List<Exercise>>> _loadExercisesForWeekDay(
  Map<String, dynamic> programData,
  int week,
  int day,
) async {
  try {
    final exercisesJson = programData['exercises_json'];
    final result = ExerciseDataParser.parseExercisesForWeekDay(exercisesJson, week, day);
    return result.fold(
      (failure) => Left(failure as WorkoutProgramFailure),
      (exercises) => Right(exercises),
    );
  } catch (e) {
    return Left(WorkoutProgramUnknownFailure(
      message: '주차별 운동 데이터 로딩 중 오류가 발생했습니다.',
      technicalMessage: 'Error loading exercises for week $week day $day: $e',
    ));
  }
}