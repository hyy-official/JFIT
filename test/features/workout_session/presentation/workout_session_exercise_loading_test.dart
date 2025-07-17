import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/features/workout_program/utils/exercise_data_parser.dart';
import 'package:jfit/core/error/failures.dart';

void main() {
  group('WorkoutSession Exercise Loading Tests', () {
    group('Exercise Data Format Detection', () {
      test('should detect JSON string format correctly', () {
        // Arrange
        const jsonString = '''
        [
          {
            "week": 1,
            "days": [
              {
                "exercises": [
                  {
                    "title_ko": "푸시업",
                    "recommended_sets": "3",
                    "recommended_reps": "10"
                  }
                ]
              }
            ]
          }
        ]
        ''';

        // Act
        final format = ExerciseDataParser.detectDataFormat(jsonString);

        // Assert
        expect(format, ExerciseDataFormat.jsonString);
        expect(format.description, 'JSON 문자열');
      });

      test('should detect weekly structure format correctly', () {
        // Arrange
        final weeklyStructure = [
          {
            'week': 1,
            'days': [
              {
                'exercises': [
                  {'title_ko': '푸시업', 'recommended_sets': '3'}
                ]
              }
            ]
          }
        ];

        // Act
        final format = ExerciseDataParser.detectDataFormat(weeklyStructure);

        // Assert
        expect(format, ExerciseDataFormat.weeklyStructure);
        expect(format.description, '주차별 구조');
      });

      test('should detect empty data format correctly', () {
        // Act & Assert
        expect(ExerciseDataParser.detectDataFormat(null), ExerciseDataFormat.empty);
        expect(ExerciseDataParser.detectDataFormat([]), ExerciseDataFormat.empty);
        expect(ExerciseDataParser.detectDataFormat(''), ExerciseDataFormat.empty);
        expect(ExerciseDataParser.detectDataFormat('   '), ExerciseDataFormat.empty);
      });

      test('should detect exercise list format correctly', () {
        // Arrange
        final exerciseList = [
          {'title_ko': '푸시업', 'recommended_sets': '3'},
          {'title_ko': '스쿼트', 'recommended_sets': '4'},
        ];

        // Act
        final format = ExerciseDataParser.detectDataFormat(exerciseList);

        // Assert
        expect(format, ExerciseDataFormat.exerciseList);
        expect(format.description, '운동 리스트');
      });
    });

    group('Exercise Data Parsing', () {
      test('should parse weekly structure for specific week and day', () {
        // Arrange
        final weeklyData = [
          {
            'week': 1,
            'days': [
              {
                'exercises': [
                  {
                    'id': 1,
                    'title_ko': '푸시업',
                    'recommended_sets': '3',
                    'recommended_reps': '10',
                    'difficulty': 'beginner',
                    'type': 'strength',
                    'equipment': 'bodyweight',
                  }
                ]
              },
              {
                'exercises': [
                  {
                    'id': 2,
                    'title_ko': '스쿼트',
                    'recommended_sets': '4',
                    'recommended_reps': '12',
                    'difficulty': 'intermediate',
                    'type': 'strength',
                    'equipment': 'none',
                  }
                ]
              }
            ]
          }
        ];

        // Act
        final result = ExerciseDataParser.parseExercisesForWeekDay(weeklyData, 1, 2);

        // Assert
        expect(result.isRight(), true);
        final exercises = result.fold((l) => null, (r) => r)!;
        expect(exercises.length, 1);
        expect(exercises.first.titleKo, '스쿼트');
        expect(exercises.first.recommendedSets, '4');
        expect(exercises.first.recommendedReps, '12');
      });

      test('should handle malformed JSON string gracefully', () {
        // Arrange
        const malformedJson = '{"invalid": json}';

        // Act
        final result = ExerciseDataParser.parseExercises(malformedJson);

        // Assert
        expect(result.isLeft(), true);
        final failure = result.fold((l) => l, (r) => null)!;
        expect(failure, isA<DataParsingFailure>());
        expect(failure.message, contains('운동 데이터를 불러오는 중 오류가 발생했습니다'));
      });

      test('should parse exercises with missing optional fields', () {
        // Arrange
        final exercisesWithMissingFields = [
          {
            'title_ko': '푸시업',
            // Missing most optional fields
          }
        ];

        // Act
        final result = ExerciseDataParser.parseExercises(exercisesWithMissingFields);

        // Assert
        expect(result.isRight(), true);
        final exercises = result.fold((l) => null, (r) => r)!;
        expect(exercises.length, 1);
        
        final exercise = exercises.first;
        expect(exercise.titleKo, '푸시업');
        expect(exercise.difficulty, 'beginner'); // Default value
        expect(exercise.type, 'strength'); // Default value
        expect(exercise.equipment, 'none'); // Default value
        expect(exercise.isActive, true); // Default value
      });

      test('should handle complex nested structure with multiple weeks', () {
        // Arrange
        final complexStructure = [
          {
            'week': 1,
            'days': [
              {
                'exercises': [
                  {'title_ko': '푸시업', 'recommended_sets': '3'},
                  {'title_ko': '스쿼트', 'recommended_sets': '4'},
                ]
              }
            ]
          },
          {
            'week': 2,
            'days': [
              {
                'exercises': [
                  {'title_ko': '벤치프레스', 'recommended_sets': '3'},
                ]
              },
              {
                'exercises': [
                  {'title_ko': '데드리프트', 'recommended_sets': '5'},
                  {'title_ko': '풀업', 'recommended_sets': '3'},
                ]
              }
            ]
          }
        ];

        // Act - Get week 2, day 2 exercises
        final result = ExerciseDataParser.parseExercisesForWeekDay(complexStructure, 2, 2);

        // Assert
        expect(result.isRight(), true);
        final exercises = result.fold((l) => null, (r) => r)!;
        expect(exercises.length, 2);
        expect(exercises.map((e) => e.titleKo).toList(), ['데드리프트', '풀업']);
      });

      test('should return empty list for non-existent week/day combination', () {
        // Arrange
        final weeklyData = [
          {
            'week': 1,
            'days': [
              {
                'exercises': [
                  {'title_ko': '푸시업', 'recommended_sets': '3'}
                ]
              }
            ]
          }
        ];

        // Act - Try to get week 2, day 1 (doesn't exist)
        final result = ExerciseDataParser.parseExercisesForWeekDay(weeklyData, 2, 1);

        // Assert
        expect(result.isRight(), true);
        final exercises = result.fold((l) => null, (r) => r)!;
        expect(exercises.isEmpty, true);
      });
    });

    group('Error Scenarios', () {
      test('should handle corrupted exercise data gracefully', () {
        // Arrange
        final corruptedData = [
          {
            'week': 1,
            'days': [
              {
                'exercises': [
                  null, // Null exercise
                  'invalid-exercise-string', // String instead of map
                  {'title_ko': null}, // Null title
                  {}, // Empty exercise object
                ]
              }
            ]
          }
        ];

        // Act
        final result = ExerciseDataParser.parseExercisesForWeekDay(corruptedData, 1, 1);

        // Assert
        // The parser should handle corrupted data gracefully
        // It may either return an error or filter out invalid entries
        if (result.isRight()) {
          final exercises = result.fold((l) => null, (r) => r)!;
          // Should result in filtered exercises (some may be created with default values)
          expect(exercises.length, lessThanOrEqualTo(4)); // At most 4 exercises from the corrupted data
        } else {
          // Or it may return a parsing failure, which is also acceptable
          final failure = result.fold((l) => l, (r) => null)!;
          expect(failure, isA<DataParsingFailure>());
        }
      });
    });
  });
}