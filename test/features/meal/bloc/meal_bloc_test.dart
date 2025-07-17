import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/core/error/bloc_errors.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/features/meal/bloc/meal_bloc.dart';
import 'package:jfit/features/meal/bloc/meal_event.dart';
import 'package:jfit/features/meal/bloc/meal_state.dart';
import 'package:jfit/features/meal/data/repositories/meal_repository.dart';
import 'package:jfit/features/records/data/models/meal_record_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'meal_bloc_test.mocks.dart';

@GenerateMocks([MealRepository])
void main() {
  group('MealBloc', () {
    late MealBloc mealBloc;
    late MockMealRepository mockMealRepository;

    setUp(() {
      mockMealRepository = MockMealRepository();
      mealBloc = MealBloc(mealRepository: mockMealRepository);
    });

    tearDown(() {
      mealBloc.close();
    });

    test('initial state is MealInitial', () {
      expect(mealBloc.state, equals(MealInitial()));
    });

    group('LoadMealRecords', () {
      const userId = 'test-user-id';
      final testDate = DateTime.now().subtract(Duration(days: 1)); // Yesterday
      final mealRecords = [
        MealRecord(
          id: '1',
          userId: userId,
          mealDate: testDate,
          mealType: 'breakfast',
          totalCalories: 300.0,
          totalProtein: 15.0,
          totalCarbs: 40.0,
          totalFat: 10.0,
        ),
        MealRecord(
          id: '2',
          userId: userId,
          mealDate: testDate,
          mealType: 'lunch',
          totalCalories: 500.0,
          totalProtein: 25.0,
          totalCarbs: 60.0,
          totalFat: 20.0,
        ),
      ];

      blocTest<MealBloc, MealState>(
        'emits [MealLoading, MealRecordsLoaded] when LoadMealRecords succeeds',
        build: () {
          when(mockMealRepository.getMealRecords(userId, date: testDate))
              .thenAnswer((_) async => Right(mealRecords));
          return mealBloc;
        },
        act: (bloc) => bloc.add(LoadMealRecords(userId: userId, date: testDate)),
        expect: () => [
          MealLoading(),
          MealRecordsLoaded(mealRecords: mealRecords),
        ],
        verify: (_) {
          verify(mockMealRepository.getMealRecords(userId, date: testDate))
              .called(1);
        },
      );

      blocTest<MealBloc, MealState>(
        'emits [MealLoading, MealRecordsLoaded] when LoadMealRecords succeeds without date',
        build: () {
          when(mockMealRepository.getMealRecords(userId))
              .thenAnswer((_) async => Right(mealRecords));
          return mealBloc;
        },
        act: (bloc) => bloc.add(LoadMealRecords(userId: userId)),
        expect: () => [
          MealLoading(),
          MealRecordsLoaded(mealRecords: mealRecords),
        ],
        verify: (_) {
          verify(mockMealRepository.getMealRecords(userId, date: null))
              .called(1);
        },
      );

      blocTest<MealBloc, MealState>(
        'emits [MealLoading, MealErrorState] when LoadMealRecords fails',
        build: () {
          when(mockMealRepository.getMealRecords(userId, date: testDate))
              .thenAnswer((_) async => Left(ServerFailure('Server error')));
          return mealBloc;
        },
        act: (bloc) => bloc.add(LoadMealRecords(userId: userId, date: testDate)),
        expect: () => [
          MealLoading(),
          isA<MealErrorState>(),
        ],
        verify: (_) {
          verify(mockMealRepository.getMealRecords(userId, date: testDate))
              .called(1);
        },
      );

      blocTest<MealBloc, MealState>(
        'emits [MealErrorState] when userId is empty',
        build: () => mealBloc,
        act: (bloc) => bloc.add(LoadMealRecords(userId: '', date: testDate)),
        expect: () => [
          isA<MealErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.validationError,
          ),
        ],
        verify: (_) {
          verifyZeroInteractions(mockMealRepository);
        },
      );
    });

    group('AddMealRecord', () {
      final testMealRecord = MealRecord(
        id: 'test-id',
        userId: 'test-user-id',
        mealDate: DateTime.now().subtract(Duration(days: 1)), // Yesterday
        mealType: 'breakfast',
        totalCalories: 300.0,
        totalProtein: 15.0,
        totalCarbs: 40.0,
        totalFat: 10.0,
      );

      blocTest<MealBloc, MealState>(
        'emits [MealLoading, MealRecordAdded] when AddMealRecord succeeds',
        build: () {
          when(mockMealRepository.addMealRecord(testMealRecord))
              .thenAnswer((_) async => Right(null));
          return mealBloc;
        },
        act: (bloc) => bloc.add(AddMealRecord(mealRecord: testMealRecord)),
        expect: () => [
          MealLoading(),
          MealRecordAdded(mealRecord: testMealRecord),
        ],
        verify: (_) {
          verify(mockMealRepository.addMealRecord(testMealRecord)).called(1);
        },
      );

      blocTest<MealBloc, MealState>(
        'emits [MealLoading, MealErrorState] when AddMealRecord fails',
        build: () {
          when(mockMealRepository.addMealRecord(testMealRecord))
              .thenAnswer((_) async => Left(DatabaseFailure('Database error')));
          return mealBloc;
        },
        act: (bloc) => bloc.add(AddMealRecord(mealRecord: testMealRecord)),
        expect: () => [
          MealLoading(),
          isA<MealErrorState>(),
        ],
        verify: (_) {
          verify(mockMealRepository.addMealRecord(testMealRecord)).called(1);
        },
      );

      blocTest<MealBloc, MealState>(
        'emits [MealErrorState] when meal record validation fails - empty ID',
        build: () => mealBloc,
        act: (bloc) => bloc.add(AddMealRecord(
          mealRecord: testMealRecord.copyWith(id: ''),
        )),
        expect: () => [
          isA<MealErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.mealValidationFailed,
          ),
        ],
        verify: (_) {
          verifyZeroInteractions(mockMealRepository);
        },
      );

      blocTest<MealBloc, MealState>(
        'emits [MealErrorState] when meal record validation fails - empty userId',
        build: () => mealBloc,
        act: (bloc) => bloc.add(AddMealRecord(
          mealRecord: testMealRecord.copyWith(userId: ''),
        )),
        expect: () => [
          isA<MealErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.mealValidationFailed,
          ),
        ],
        verify: (_) {
          verifyZeroInteractions(mockMealRepository);
        },
      );

      blocTest<MealBloc, MealState>(
        'emits [MealErrorState] when meal record validation fails - invalid meal type',
        build: () => mealBloc,
        act: (bloc) => bloc.add(AddMealRecord(
          mealRecord: testMealRecord.copyWith(mealType: 'invalid'),
        )),
        expect: () => [
          isA<MealErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.mealValidationFailed,
          ),
        ],
        verify: (_) {
          verifyZeroInteractions(mockMealRepository);
        },
      );

      blocTest<MealBloc, MealState>(
        'emits [MealErrorState] when meal record validation fails - negative calories',
        build: () => mealBloc,
        act: (bloc) => bloc.add(AddMealRecord(
          mealRecord: testMealRecord.copyWith(totalCalories: -100.0),
        )),
        expect: () => [
          isA<MealErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.mealValidationFailed,
          ),
        ],
        verify: (_) {
          verifyZeroInteractions(mockMealRepository);
        },
      );

      blocTest<MealBloc, MealState>(
        'emits [MealErrorState] when meal record validation fails - future date',
        build: () => mealBloc,
        act: (bloc) => bloc.add(AddMealRecord(
          mealRecord: testMealRecord.copyWith(
            mealDate: DateTime.now().add(Duration(days: 2)),
          ),
        )),
        expect: () => [
          isA<MealErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.mealValidationFailed,
          ),
        ],
        verify: (_) {
          verifyZeroInteractions(mockMealRepository);
        },
      );
    });

    group('UpdateMealRecord', () {
      final testMealRecord = MealRecord(
        id: 'test-id',
        userId: 'test-user-id',
        mealDate: DateTime.now().subtract(Duration(days: 1)), // Yesterday
        mealType: 'lunch',
        totalCalories: 400.0,
        totalProtein: 20.0,
        totalCarbs: 50.0,
        totalFat: 15.0,
      );

      blocTest<MealBloc, MealState>(
        'emits [MealLoading, MealRecordUpdated] when UpdateMealRecord succeeds',
        build: () {
          when(mockMealRepository.updateMealRecord(testMealRecord))
              .thenAnswer((_) async => Right(null));
          return mealBloc;
        },
        act: (bloc) => bloc.add(UpdateMealRecord(mealRecord: testMealRecord)),
        expect: () => [
          MealLoading(),
          MealRecordUpdated(mealRecord: testMealRecord),
        ],
        verify: (_) {
          verify(mockMealRepository.updateMealRecord(testMealRecord)).called(1);
        },
      );

      blocTest<MealBloc, MealState>(
        'emits [MealLoading, MealErrorState] when UpdateMealRecord fails',
        build: () {
          when(mockMealRepository.updateMealRecord(testMealRecord))
              .thenAnswer((_) async => Left(NetworkFailure('Network error')));
          return mealBloc;
        },
        act: (bloc) => bloc.add(UpdateMealRecord(mealRecord: testMealRecord)),
        expect: () => [
          MealLoading(),
          isA<MealErrorState>(),
        ],
        verify: (_) {
          verify(mockMealRepository.updateMealRecord(testMealRecord)).called(1);
        },
      );

      blocTest<MealBloc, MealState>(
        'emits [MealErrorState] when meal record validation fails',
        build: () => mealBloc,
        act: (bloc) => bloc.add(UpdateMealRecord(
          mealRecord: testMealRecord.copyWith(mealType: ''),
        )),
        expect: () => [
          isA<MealErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.mealValidationFailed,
          ),
        ],
        verify: (_) {
          verifyZeroInteractions(mockMealRepository);
        },
      );
    });

    group('DeleteMealRecord', () {
      const recordId = 'test-record-id';
      const userId = 'test-user-id';
      final testDate = DateTime.now().subtract(Duration(days: 1)); // Yesterday

      blocTest<MealBloc, MealState>(
        'emits [MealLoading, MealRecordDeleted] when DeleteMealRecord succeeds',
        build: () {
          when(mockMealRepository.deleteMealRecord(recordId))
              .thenAnswer((_) async => Right(null));
          return mealBloc;
        },
        act: (bloc) => bloc.add(DeleteMealRecord(
          recordId: recordId,
          userId: userId,
          date: testDate,
        )),
        expect: () => [
          MealLoading(),
          MealRecordDeleted(recordId: recordId),
        ],
        verify: (_) {
          verify(mockMealRepository.deleteMealRecord(recordId)).called(1);
        },
      );

      blocTest<MealBloc, MealState>(
        'emits [MealLoading, MealErrorState] when DeleteMealRecord fails',
        build: () {
          when(mockMealRepository.deleteMealRecord(recordId))
              .thenAnswer((_) async => Left(DatabaseFailure('Delete failed')));
          return mealBloc;
        },
        act: (bloc) => bloc.add(DeleteMealRecord(
          recordId: recordId,
          userId: userId,
          date: testDate,
        )),
        expect: () => [
          MealLoading(),
          isA<MealErrorState>(),
        ],
        verify: (_) {
          verify(mockMealRepository.deleteMealRecord(recordId)).called(1);
        },
      );

      blocTest<MealBloc, MealState>(
        'emits [MealErrorState] when recordId is empty',
        build: () => mealBloc,
        act: (bloc) => bloc.add(DeleteMealRecord(
          recordId: '',
          userId: userId,
          date: testDate,
        )),
        expect: () => [
          isA<MealErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.validationError,
          ),
        ],
        verify: (_) {
          verifyZeroInteractions(mockMealRepository);
        },
      );

      blocTest<MealBloc, MealState>(
        'emits [MealErrorState] when userId is empty',
        build: () => mealBloc,
        act: (bloc) => bloc.add(DeleteMealRecord(
          recordId: recordId,
          userId: '',
          date: testDate,
        )),
        expect: () => [
          isA<MealErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.validationError,
          ),
        ],
        verify: (_) {
          verifyZeroInteractions(mockMealRepository);
        },
      );
    });

    group('Error Handling', () {
      final testMealRecord = MealRecord(
        id: 'test-id',
        userId: 'test-user-id',
        mealDate: DateTime.now().subtract(Duration(days: 1)), // Yesterday
        mealType: 'breakfast',
        totalCalories: 300.0,
      );

      blocTest<MealBloc, MealState>(
        'handles unexpected exceptions during LoadMealRecords',
        setUp: () {
          reset(mockMealRepository);
        },
        build: () {
          when(mockMealRepository.getMealRecords('test-user-id', date: null))
              .thenThrow(Exception('Unexpected error'));
          return mealBloc;
        },
        act: (bloc) => bloc.add(LoadMealRecords(userId: 'test-user-id')),
        expect: () => [
          MealLoading(),
          isA<MealErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.unknown,
          ),
        ],
      );

      blocTest<MealBloc, MealState>(
        'handles unexpected exceptions during AddMealRecord',
        setUp: () {
          reset(mockMealRepository);
        },
        build: () {
          when(mockMealRepository.addMealRecord(testMealRecord))
              .thenThrow(Exception('Unexpected error'));
          return mealBloc;
        },
        act: (bloc) => bloc.add(AddMealRecord(mealRecord: testMealRecord)),
        expect: () => [
          MealLoading(),
          isA<MealErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.mealSaveFailed,
          ),
        ],
      );

      blocTest<MealBloc, MealState>(
        'handles unexpected exceptions during UpdateMealRecord',
        setUp: () {
          reset(mockMealRepository);
        },
        build: () {
          when(mockMealRepository.updateMealRecord(testMealRecord))
              .thenThrow(Exception('Unexpected error'));
          return mealBloc;
        },
        act: (bloc) => bloc.add(UpdateMealRecord(mealRecord: testMealRecord)),
        expect: () => [
          MealLoading(),
          isA<MealErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.mealSaveFailed,
          ),
        ],
      );

      blocTest<MealBloc, MealState>(
        'handles unexpected exceptions during DeleteMealRecord',
        setUp: () {
          reset(mockMealRepository);
        },
        build: () {
          when(mockMealRepository.deleteMealRecord('test-id'))
              .thenThrow(Exception('Unexpected error'));
          return mealBloc;
        },
        act: (bloc) => bloc.add(DeleteMealRecord(
          recordId: 'test-id',
          userId: 'test-user-id',
          date: DateTime.now().subtract(Duration(days: 1)),
        )),
        expect: () => [
          MealLoading(),
          isA<MealErrorState>().having(
            (state) => state.failure.code,
            'error code',
            BlocErrorCodes.mealDeleteFailed,
          ),
        ],
      );
    });
  });
}

// Extension to add copyWith method to MealRecord for testing
extension MealRecordCopyWith on MealRecord {
  MealRecord copyWith({
    String? id,
    String? userId,
    DateTime? mealDate,
    String? mealType,
    double? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
    String? notes,
    String? photoUrl,
  }) {
    return MealRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mealDate: mealDate ?? this.mealDate,
      mealType: mealType ?? this.mealType,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}