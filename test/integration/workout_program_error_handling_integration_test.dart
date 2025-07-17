import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:jfit/features/programs/presentation/bloc/programs_bloc.dart';
import 'package:jfit/features/programs/data/datasources/program_remote_datasource.dart';
import 'package:jfit/features/workout_program/data/models/duplicate_check_result_model.dart';
import 'package:jfit/core/error/workout_program_failures.dart';
import 'package:jfit/features/workout_session/presentation/pages/workout_session_page.dart';
import 'package:jfit/features/workout_program/utils/exercise_data_parser.dart';
import 'package:jfit/core/models/exercise.dart';

import 'workout_program_error_handling_integration_test.mocks.dart';

@GenerateMocks([
  ProgramRemoteDataSource,
])
void main() {
  group('Workout Program Error Handling Integration Tests', () {
    late MockProgramRemoteDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockProgramRemoteDataSource();
    });

    group('End-to-End Program Saving with Duplicate Handling', () {
      testWidgets('should handle complete duplicate resolution workflow', (tester) async {
        // arrange
        const templateProgramId = 'template-123';
        const userId = 'user-456';
        const duplicateInfo = ProgramDuplicateInfo(
          userProgramId: 'existing-program-id',
          programName: 'Existing Program',
          currentWeek: 2,
          currentDay: 3,
          totalWeeks: 4,
          progressPercent: 50.0,
          isCompleted: false,
          status: ProgramStatus.active,
          availableOptions: [
            ResolutionOption.continueExisting,
            ResolutionOption.restartProgram,
            ResolutionOption.createNewInstance,
            ResolutionOption.cancel,
          ],
        );

        final duplicateResult = DuplicateCheckResult.duplicate(
          existingProgramId: 'existing-program-id',
          duplicateInfo: duplicateInfo,
        );

        // First call returns duplicate
        when(mockDataSource.saveAsMyRoutine(templateProgramId, userId))
            .thenAnswer((_) async => Right(duplicateResult));

        // Resolution call succeeds
        when(mockDataSource.saveAsMyRoutineWithOption(
          templateProgramId,
          userId,
          ResolutionOption.continueExisting,
          existingProgramId: 'existing-program-id',
        )).thenAnswer((_) async => const Right(DuplicateCheckResult.noDuplicate()));

        // Create test app
        final app = MaterialApp(
          home: BlocProvider(
            create: (context) => ProgramsBloc(dataSource: mockDataSource),
            child: TestProgramSavePage(
              templateProgramId: templateProgramId,
              userId: userId,
            ),
          ),
        );

        // act & assert
        await tester.pumpWidget(app);

        // Initial state
        expect(find.text('Save Program'), findsOneWidget);
        expect(find.text('Status: initial'), findsOneWidget);

        // Trigger save
        await tester.tap(find.text('Save Program'));
        await tester.pump();

        // Should show loading
        expect(find.text('Status: loading'), findsOneWidget);
        await tester.pumpAndSettle();

        // Should show duplicate found
        expect(find.text('Status: duplicateFound'), findsOneWidget);
        expect(find.text('Duplicate: Existing Program'), findsOneWidget);

        // Resolve duplicate
        await tester.tap(find.text('Continue Existing'));
        await tester.pump();

        // Should show loading again
        expect(find.text('Status: loading'), findsOneWidget);
        await tester.pumpAndSettle();

        // Should show success
        expect(find.text('Status: success'), findsOneWidget);

        // Verify all calls were made
        verify(mockDataSource.saveAsMyRoutine(templateProgramId, userId)).called(1);
        verify(mockDataSource.saveAsMyRoutineWithOption(
          templateProgramId,
          userId,
          ResolutionOption.continueExisting,
          existingProgramId: 'existing-program-id',
        )).called(1);
      });

      testWidgets('should handle network error with retry', (tester) async {
        // arrange
        const templateProgramId = 'template-123';
        const userId = 'user-456';

        // First call fails with network error, second succeeds
        when(mockDataSource.saveAsMyRoutine(templateProgramId, userId))
            .thenAnswer((_) async => const Left(WorkoutProgramNetworkFailure()))
            .thenAnswer((_) async => const Right(DuplicateCheckResult.noDuplicate()));

        final app = MaterialApp(
          home: BlocProvider(
            create: (context) => ProgramsBloc(dataSource: mockDataSource),
            child: TestProgramSavePage(
              templateProgramId: templateProgramId,
              userId: userId,
            ),
          ),
        );

        // act & assert
        await tester.pumpWidget(app);

        // Trigger save
        await tester.tap(find.text('Save Program'));
        await tester.pumpAndSettle();

        // Should show error
        expect(find.text('Status: error'), findsOneWidget);
        expect(find.text('Error: 네트워크 연결을 확인해주세요.'), findsOneWidget);

        // Retry
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        // Should show success
        expect(find.text('Status: success'), findsOneWidget);

        // Verify retry worked
        verify(mockDataSource.saveAsMyRoutine(templateProgramId, userId)).called(2);
      });

      testWidgets('should handle server error gracefully', (tester) async {
        // arrange
        const templateProgramId = 'template-123';
        const userId = 'user-456';

        final serverFailure = WorkoutProgramServerFailure(
          statusCode: 500,
          technicalMessage: 'Internal server error',
        );

        when(mockDataSource.saveAsMyRoutine(templateProgramId, userId))
            .thenAnswer((_) async => Left(serverFailure));

        final app = MaterialApp(
          home: BlocProvider(
            create: (context) => ProgramsBloc(dataSource: mockDataSource),
            child: TestProgramSavePage(
              templateProgramId: templateProgramId,
              userId: userId,
            ),
          ),
        );

        // act & assert
        await tester.pumpWidget(app);

        // Trigger save
        await tester.tap(find.text('Save Program'));
        await tester.pumpAndSettle();

        // Should show server error
        expect(find.text('Status: error'), findsOneWidget);
        expect(find.text('Error: 서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.'), findsOneWidget);
      });
    });

    group('Exercise Data Parsing Integration Tests', () {
      test('should handle various data formats in workout day start flow', () {
        // Test JSON string format
        final jsonStringData = '''
        [
          {
            "id": 1,
            "exercise_name": "벤치프레스",
            "sets": 4,
            "reps": "10",
            "type": "strength"
          },
          {
            "id": 2,
            "exercise_name": "푸쉬업",
            "sets": 3,
            "reps": "15",
            "type": "bodyweight"
          }
        ]
        ''';

        final result1 = ExerciseDataParser.parseExercises(jsonStringData);
        expect(result1.isRight(), true);
        result1.fold(
          (failure) => fail('Should not fail'),
          (exercises) {
            expect(exercises, hasLength(2));
            expect(exercises[0].titleKo, '벤치프레스');
            expect(exercises[1].titleKo, '푸쉬업');
          },
        );

        // Test direct list format
        final listData = [
          {
            'id': 1,
            'exercise_name': '스쿼트',
            'sets': 3,
            'reps': '12',
            'type': 'strength'
          }
        ];

        final result2 = ExerciseDataParser.parseExercises(listData);
        expect(result2.isRight(), true);
        result2.fold(
          (failure) => fail('Should not fail'),
          (exercises) {
            expect(exercises, hasLength(1));
            expect(exercises[0].titleKo, '스쿼트');
          },
        );

        // Test weekly structure format
        final weeklyData = [
          {
            'days': [
              {
                'exercises': [
                  {
                    'id': 1,
                    'exercise_name': '주차별 운동',
                    'sets': 3,
                    'reps': '10'
                  }
                ]
              }
            ]
          }
        ];

        final result3 = ExerciseDataParser.parseExercisesForWeekDay(weeklyData, 1, 1);
        expect(result3.isRight(), true);
        result3.fold(
          (failure) => fail('Should not fail'),
          (exercises) {
            expect(exercises, hasLength(1));
            expect(exercises[0].titleKo, '주차별 운동');
          },
        );
      });

      test('should handle malformed data gracefully', () {
        // Test invalid JSON
        const invalidJson = '{"invalid": json}';
        final result1 = ExerciseDataParser.parseExercises(invalidJson);
        expect(result1.isLeft(), true);

        // Test unsupported format
        const unsupportedData = 123;
        final result2 = ExerciseDataParser.parseExercises(unsupportedData);
        expect(result2.isLeft(), true);

        // Test null data
        const nullData = null;
        final result3 = ExerciseDataParser.parseExercises(nullData);
        expect(result3.isRight(), true);
        result3.fold(
          (failure) => fail('Should not fail'),
          (exercises) => expect(exercises, isEmpty),
        );
      });

      test('should handle mixed valid and invalid exercise data', () {
        final mixedData = [
          {
            'id': 1,
            'exercise_name': '유효한 운동',
            'sets': 3,
            'reps': '10'
          },
          null, // Invalid item
          {
            'id': 2,
            'exercise_name': '또 다른 유효한 운동',
            'sets': 4,
            'reps': '12'
          },
          'invalid_item', // Invalid item
          {
            'id': 3,
            'exercise_name': '세 번째 운동',
            'sets': 2,
            'reps': '8'
          }
        ];

        final result = ExerciseDataParser.parseExercises(mixedData);
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail'),
          (exercises) {
            // Should only include valid exercises
            expect(exercises, hasLength(2)); // Only valid exercises
            expect(exercises[0].titleKo, '유효한 운동');
            expect(exercises[1].titleKo, '또 다른 유효한 운동');
          },
        );
      });
    });

    group('Error Recovery and User Experience Flow', () {
      testWidgets('should maintain state consistency during error recovery', (tester) async {
        // arrange
        const templateProgramId = 'template-123';
        const userId = 'user-456';

        // Simulate multiple error scenarios
        when(mockDataSource.saveAsMyRoutine(templateProgramId, userId))
            .thenAnswer((_) async => const Left(WorkoutProgramNetworkFailure()))
            .thenAnswer((_) async => const Left(WorkoutProgramServerFailure()))
            .thenAnswer((_) async => const Right(DuplicateCheckResult.noDuplicate()));

        final app = MaterialApp(
          home: BlocProvider(
            create: (context) => ProgramsBloc(dataSource: mockDataSource),
            child: TestProgramSavePage(
              templateProgramId: templateProgramId,
              userId: userId,
            ),
          ),
        );

        // act & assert
        await tester.pumpWidget(app);

        // First attempt - network error
        await tester.tap(find.text('Save Program'));
        await tester.pumpAndSettle();
        expect(find.text('Status: error'), findsOneWidget);
        expect(find.text('Error: 네트워크 연결을 확인해주세요.'), findsOneWidget);

        // Second attempt - server error
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();
        expect(find.text('Status: error'), findsOneWidget);
        expect(find.text('Error: 서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.'), findsOneWidget);

        // Third attempt - success
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();
        expect(find.text('Status: success'), findsOneWidget);

        // Verify all attempts were made
        verify(mockDataSource.saveAsMyRoutine(templateProgramId, userId)).called(3);
      });

      testWidgets('should handle permission errors with appropriate user guidance', (tester) async {
        // arrange
        const templateProgramId = 'template-123';
        const userId = 'user-456';

        const permissionFailure = WorkoutProgramPermissionFailure(
          technicalMessage: 'User not authenticated',
        );

        when(mockDataSource.saveAsMyRoutine(templateProgramId, userId))
            .thenAnswer((_) async => const Left(permissionFailure));

        final app = MaterialApp(
          home: BlocProvider(
            create: (context) => ProgramsBloc(dataSource: mockDataSource),
            child: TestProgramSavePage(
              templateProgramId: templateProgramId,
              userId: userId,
            ),
          ),
        );

        // act & assert
        await tester.pumpWidget(app);

        await tester.tap(find.text('Save Program'));
        await tester.pumpAndSettle();

        expect(find.text('Status: error'), findsOneWidget);
        expect(find.text('Error: 해당 작업을 수행할 권한이 없습니다.'), findsOneWidget);
        
        // Should not show retry button for permission errors
        expect(find.text('Retry'), findsNothing);
      });

      testWidgets('should handle validation errors with user feedback', (tester) async {
        // arrange
        const templateProgramId = 'template-123';
        const userId = 'user-456';

        final validationFailure = WorkoutProgramValidationFailure(
          validationErrors: ['Invalid program ID', 'Missing user ID'],
          technicalMessage: 'Validation failed',
        );

        when(mockDataSource.saveAsMyRoutine(templateProgramId, userId))
            .thenAnswer((_) async => Left(validationFailure));

        final app = MaterialApp(
          home: BlocProvider(
            create: (context) => ProgramsBloc(dataSource: mockDataSource),
            child: TestProgramSavePage(
              templateProgramId: templateProgramId,
              userId: userId,
            ),
          ),
        );

        // act & assert
        await tester.pumpWidget(app);

        await tester.tap(find.text('Save Program'));
        await tester.pumpAndSettle();

        expect(find.text('Status: error'), findsOneWidget);
        expect(find.text('Error: 입력한 정보를 다시 확인해주세요.'), findsOneWidget);
      });
    });

    group('Data Format Consistency Tests', () {
      test('should handle format detection correctly', () {
        // Test various data formats
        final testCases = [
          (null, ExerciseDataFormat.empty),
          ('', ExerciseDataFormat.empty),
          ('{"test": "data"}', ExerciseDataFormat.jsonString),
          ([{'id': 1, 'name': 'test'}], ExerciseDataFormat.exerciseList),
          ({'exercises': []}, ExerciseDataFormat.exerciseMap),
          ([{'days': []}], ExerciseDataFormat.weeklyStructure),
          ({'week_1': {'day_1': []}}, ExerciseDataFormat.weeklyMap),
          (123, ExerciseDataFormat.unknown),
        ];

        for (final (data, expectedFormat) in testCases) {
          final detectedFormat = ExerciseDataParser.detectDataFormat(data);
          expect(detectedFormat, expectedFormat, 
                 reason: 'Failed for data: $data');
        }
      });

      test('should maintain consistency across parsing methods', () {
        // Test data that should work with both general and week/day parsing
        final weeklyMapData = {
          'week_1': {
            'day_1': [
              {
                'id': 1,
                'exercise_name': '일관성 테스트 운동',
                'sets': 3,
                'reps': '10'
              }
            ]
          }
        };

        // Parse with general method
        final generalResult = ExerciseDataParser.parseExercises(weeklyMapData);
        expect(generalResult.isRight(), true);

        // Parse with specific week/day method
        final specificResult = ExerciseDataParser.parseExercisesForWeekDay(weeklyMapData, 1, 1);
        expect(specificResult.isRight(), true);

        // Results should be consistent
        generalResult.fold(
          (failure) => fail('General parsing should not fail'),
          (generalExercises) {
            specificResult.fold(
              (failure) => fail('Specific parsing should not fail'),
              (specificExercises) {
                expect(generalExercises.length, specificExercises.length);
                if (generalExercises.isNotEmpty && specificExercises.isNotEmpty) {
                  expect(generalExercises[0].titleKo, specificExercises[0].titleKo);
                }
              },
            );
          },
        );
      });
    });
  });
}

/// Test widget for program saving functionality
class TestProgramSavePage extends StatelessWidget {
  final String templateProgramId;
  final String userId;

  const TestProgramSavePage({
    super.key,
    required this.templateProgramId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProgramsBloc, ProgramsState>(
        builder: (context, state) {
          return Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  context.read<ProgramsBloc>().add(SaveAsMyRoutineEvent(
                    templateProgramId: templateProgramId,
                    userId: userId,
                  ));
                },
                child: const Text('Save Program'),
              ),
              Text('Status: ${state.status.name}'),
              if (state.failure != null)
                Text('Error: ${state.failure!.userMessage}'),
              if (state.duplicateCheckResult?.isDuplicate == true)
                Text('Duplicate: ${state.duplicateCheckResult!.duplicateInfo!.programName}'),
              if (state.status == ProgramsStatus.error)
                ElevatedButton(
                  onPressed: () {
                    context.read<ProgramsBloc>().add(SaveAsMyRoutineEvent(
                      templateProgramId: templateProgramId,
                      userId: userId,
                    ));
                  },
                  child: const Text('Retry'),
                ),
              if (state.status == ProgramsStatus.duplicateFound)
                ElevatedButton(
                  onPressed: () {
                    context.read<ProgramsBloc>().add(ResolveDuplicateEvent(
                      templateProgramId: templateProgramId,
                      userId: userId,
                      resolution: ResolutionOption.continueExisting,
                      existingProgramId: state.duplicateCheckResult!.existingProgramId!,
                    ));
                  },
                  child: const Text('Continue Existing'),
                ),
            ],
          );
        },
      ),
    );
  }
}