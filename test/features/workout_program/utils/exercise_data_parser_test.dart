import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/models/exercise.dart';
import 'package:jfit/features/workout_program/utils/exercise_data_parser.dart';

void main() {
  group('ExerciseDataParser', () {
    group('parseExercises', () {
      test('null 데이터 처리', () {
        // arrange
        const dynamic nullData = null;

        // act
        final result = ExerciseDataParser.parseExercises(nullData);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail'),
          (exercises) => expect(exercises, isEmpty),
        );
      });

      test('빈 문자열 처리', () {
        // arrange
        const String emptyString = '';

        // act
        final result = ExerciseDataParser.parseExercises(emptyString);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail'),
          (exercises) => expect(exercises, isEmpty),
        );
      });

      test('JSON 문자열 형식 파싱', () {
        // arrange
        final exerciseData = [
          {
            'id': 1,
            'exercise_name': '벤치프레스',
            'sets': 4,
            'reps': '10',
            'type': 'strength'
          },
          {
            'id': 2,
            'exercise_name': '푸쉬업',
            'sets': 3,
            'reps': '15',
            'type': 'bodyweight'
          }
        ];
        final jsonString = jsonEncode(exerciseData);

        // act
        final result = ExerciseDataParser.parseExercises(jsonString);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail: ${failure.message}'),
          (exercises) {
            expect(exercises, hasLength(2));
            expect(exercises[0].id, 1);
            expect(exercises[0].titleKo, '벤치프레스');
            expect(exercises[1].id, 2);
            expect(exercises[1].titleKo, '푸쉬업');
          },
        );
      });

      test('직접 리스트 형식 파싱', () {
        // arrange
        final exerciseData = [
          {
            'id': 1,
            'exercise_name': '스쿼트',
            'sets': 3,
            'reps': '12',
            'type': 'strength'
          }
        ];

        // act
        final result = ExerciseDataParser.parseExercises(exerciseData);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail: ${failure.message}'),
          (exercises) {
            expect(exercises, hasLength(1));
            expect(exercises[0].titleKo, '스쿼트');
          },
        );
      });

      test('맵 형식 (exercises 키 포함) 파싱', () {
        // arrange
        final exerciseData = {
          'exercises': [
            {
              'id': 1,
              'exercise_name': '데드리프트',
              'sets': 5,
              'reps': '5',
              'type': 'strength'
            }
          ]
        };

        // act
        final result = ExerciseDataParser.parseExercises(exerciseData);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail: ${failure.message}'),
          (exercises) {
            expect(exercises, hasLength(1));
            expect(exercises[0].titleKo, '데드리프트');
          },
        );
      });

      test('잘못된 JSON 문자열 처리', () {
        // arrange
        const String invalidJson = '{"invalid": json}';

        // act
        final result = ExerciseDataParser.parseExercises(invalidJson);

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<DataParsingFailure>());
            final dataFailure = failure as DataParsingFailure;
            expect(dataFailure.technicalMessage, contains('Failed to decode JSON string'));
          },
          (exercises) => fail('Should fail'),
        );
      });

      test('지원하지 않는 데이터 형식 처리', () {
        // arrange
        const int unsupportedData = 123;

        // act
        final result = ExerciseDataParser.parseExercises(unsupportedData);

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<DataParsingFailure>());
            final dataFailure = failure as DataParsingFailure;
            expect(dataFailure.technicalMessage, contains('Unsupported exercises data format'));
          },
          (exercises) => fail('Should fail'),
        );
      });

      test('null 운동 항목 건너뛰기', () {
        // arrange
        final exerciseData = [
          {
            'id': 1,
            'exercise_name': '벤치프레스',
            'sets': 4,
            'reps': '10'
          },
          null, // null 항목
          {
            'id': 2,
            'exercise_name': '푸쉬업',
            'sets': 3,
            'reps': '15'
          }
        ];

        // act
        final result = ExerciseDataParser.parseExercises(exerciseData);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail: ${failure.message}'),
          (exercises) {
            expect(exercises, hasLength(2)); // null 항목은 제외
            expect(exercises[0].titleKo, '벤치프레스');
            expect(exercises[1].titleKo, '푸쉬업');
          },
        );
      });
    });

    group('parseExercisesForWeekDay', () {
      test('주차별 배열 구조에서 특정 주차/일차 파싱', () {
        // arrange
        final exerciseData = [
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

        // act
        final result = ExerciseDataParser.parseExercisesForWeekDay(exerciseData, 1, 2);

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

      test('주차별 맵 구조에서 특정 주차/일차 파싱', () {
        // arrange
        final exerciseData = {
          'week_1': {
            'day_1': [
              {
                'id': 1,
                'exercise_name': '맵 구조 운동',
                'sets': 3,
                'reps': '8'
              }
            ]
          }
        };

        // act
        final result = ExerciseDataParser.parseExercisesForWeekDay(exerciseData, 1, 1);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail: ${failure.message}'),
          (exercises) {
            expect(exercises, hasLength(1));
            expect(exercises[0].titleKo, '맵 구조 운동');
          },
        );
      });

      test('존재하지 않는 주차/일차 요청', () {
        // arrange
        final exerciseData = [
          {
            'days': [
              {
                'exercises': [
                  {
                    'id': 1,
                    'exercise_name': '운동',
                    'sets': 3,
                    'reps': '10'
                  }
                ]
              }
            ]
          }
        ];

        // act
        final result = ExerciseDataParser.parseExercisesForWeekDay(exerciseData, 2, 1); // 2주차는 없음

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail: ${failure.message}'),
          (exercises) => expect(exercises, isEmpty),
        );
      });

      test('JSON 문자열 형식의 주차별 데이터 파싱', () {
        // arrange
        final exerciseData = {
          'week_1': {
            'day_1': [
              {
                'id': 1,
                'exercise_name': 'JSON 문자열 운동',
                'sets': 3,
                'reps': '10'
              }
            ]
          }
        };
        final jsonString = jsonEncode(exerciseData);

        // act
        final result = ExerciseDataParser.parseExercisesForWeekDay(jsonString, 1, 1);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail: ${failure.message}'),
          (exercises) {
            expect(exercises, hasLength(1));
            expect(exercises[0].titleKo, 'JSON 문자열 운동');
          },
        );
      });
    });

    group('detectDataFormat', () {
      test('null 데이터 형식 감지', () {
        // act
        final format = ExerciseDataParser.detectDataFormat(null);

        // assert
        expect(format, ExerciseDataFormat.empty);
      });

      test('빈 문자열 형식 감지', () {
        // act
        final format = ExerciseDataParser.detectDataFormat('');

        // assert
        expect(format, ExerciseDataFormat.empty);
      });

      test('JSON 문자열 형식 감지', () {
        // act
        final format = ExerciseDataParser.detectDataFormat('{"test": "data"}');

        // assert
        expect(format, ExerciseDataFormat.jsonString);
      });

      test('운동 리스트 형식 감지', () {
        // arrange
        final data = [
          {'id': 1, 'exercise_name': '운동1'},
          {'id': 2, 'exercise_name': '운동2'}
        ];

        // act
        final format = ExerciseDataParser.detectDataFormat(data);

        // assert
        expect(format, ExerciseDataFormat.exerciseList);
      });

      test('주차별 구조 형식 감지', () {
        // arrange
        final data = [
          {
            'days': [
              {'exercises': []}
            ]
          }
        ];

        // act
        final format = ExerciseDataParser.detectDataFormat(data);

        // assert
        expect(format, ExerciseDataFormat.weeklyStructure);
      });

      test('주차별 맵 형식 감지', () {
        // arrange
        final data = {
          'week_1': {
            'day_1': []
          }
        };

        // act
        final format = ExerciseDataParser.detectDataFormat(data);

        // assert
        expect(format, ExerciseDataFormat.weeklyMap);
      });

      test('exercises 키를 가진 맵 형식 감지', () {
        // arrange
        final data = {
          'exercises': [
            {'id': 1, 'exercise_name': '운동'}
          ]
        };

        // act
        final format = ExerciseDataParser.detectDataFormat(data);

        // assert
        expect(format, ExerciseDataFormat.exerciseMap);
      });
    });

    group('Exercise 생성 테스트 (통합)', () {
      test('최소 필수 필드로 Exercise 생성', () {
        // arrange
        final data = [
          {
            'id': 1,
            'exercise_name': '테스트 운동'
          }
        ];

        // act
        final result = ExerciseDataParser.parseExercises(data);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail: ${failure.message}'),
          (exercises) {
            expect(exercises, hasLength(1));
            final exercise = exercises[0];
            expect(exercise.id, 1);
            expect(exercise.titleKo, '테스트 운동');
            expect(exercise.descKo, '');
            expect(exercise.difficulty, 'beginner');
            expect(exercise.isActive, true);
          },
        );
      });

      test('모든 필드가 포함된 Exercise 생성', () {
        // arrange
        final data = [
          {
            'id': 1,
            'exercise_name': '완전한 운동',
            'title_en': 'Complete Exercise',
            'desc_ko': '운동 설명',
            'difficulty': 'intermediate',
            'type': 'strength',
            'equipment': 'barbell',
            'sets': 4,
            'reps': '10',
            'rest_seconds': 60,
            'is_active': true,
            'popularity_score': 85
          }
        ];

        // act
        final result = ExerciseDataParser.parseExercises(data);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail: ${failure.message}'),
          (exercises) {
            expect(exercises, hasLength(1));
            final exercise = exercises[0];
            expect(exercise.id, 1);
            expect(exercise.titleKo, '완전한 운동');
            expect(exercise.titleEn, 'Complete Exercise');
            expect(exercise.descKo, '운동 설명');
            expect(exercise.difficulty, 'intermediate');
            expect(exercise.type, 'strength');
            expect(exercise.equipment, 'barbell');
            expect(exercise.recommendedSets, '4');
            expect(exercise.recommendedReps, '10');
            expect(exercise.recommendedRestSeconds, 60);
            expect(exercise.isActive, true);
            expect(exercise.popularityScore, 85);
          },
        );
      });

      test('다양한 필드명 매핑', () {
        // arrange
        final data = [
          {
            'exercise_id': 123, // id 대신 exercise_id
            'name': '매핑 테스트', // exercise_name 대신 name
            'custom_type': 'cardio', // type 대신 custom_type
            'description': '설명 테스트' // desc_ko 대신 description
          }
        ];

        // act
        final result = ExerciseDataParser.parseExercises(data);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail: ${failure.message}'),
          (exercises) {
            expect(exercises, hasLength(1));
            final exercise = exercises[0];
            expect(exercise.id, 123);
            expect(exercise.titleKo, '매핑 테스트');
            expect(exercise.type, 'cardio');
            expect(exercise.descKo, '설명 테스트');
          },
        );
      });
    });
  });
}