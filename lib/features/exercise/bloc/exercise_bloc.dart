import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/features/exercise/bloc/exercise_event.dart';
import 'package:jfit/features/exercise/bloc/exercise_state.dart';
import 'package:jfit/features/exercise/data/repositories/exercise_repository.dart';
import 'package:jfit/features/exercise/data/models/exercise_record.dart';

class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  final ExerciseRepository _exerciseRepository;

  ExerciseBloc({required ExerciseRepository exerciseRepository})
      : _exerciseRepository = exerciseRepository,
        super(ExerciseInitial()) {
    on<LoadExerciseRecords>(_onLoadExerciseRecords);
    on<AddExerciseRecord>(_onAddExerciseRecord);
    on<UpdateExerciseRecord>(_onUpdateExerciseRecord);
    on<DeleteExerciseRecord>(_onDeleteExerciseRecord);
  }

  Future<void> _onLoadExerciseRecords(LoadExerciseRecords event, Emitter<ExerciseState> emit) async {
    emit(ExerciseLoading());
    try {
      final records = await _exerciseRepository.getExerciseRecords(event.userId);
      emit(ExerciseLoaded(records: records));
    } catch (e) {
      emit(ExerciseError(message: e.toString()));
    }
  }

  Future<void> _onAddExerciseRecord(AddExerciseRecord event, Emitter<ExerciseState> emit) async {
    emit(ExerciseLoading());
    try {
      final newRecord = ExerciseRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // 임시 ID
        userId: event.userId,
        exerciseName: event.exerciseName,
        exerciseType: event.exerciseType,
        durationMinutes: event.durationMinutes,
        caloriesBurned: event.caloriesBurned,
        exerciseDate: event.exerciseDate,
        weightKg: event.weightKg,
        sets: event.sets,
        reps: event.reps,
        distanceKm: event.distanceKm,
      );
      await _exerciseRepository.addExerciseRecord(newRecord);
      // 기록 추가 후 다시 로드하여 최신 상태 반영
      final updatedRecords = await _exerciseRepository.getExerciseRecords(event.userId);
      emit(ExerciseLoaded(records: updatedRecords));
    } catch (e) {
      emit(ExerciseError(message: e.toString()));
    }
  }

  Future<void> _onUpdateExerciseRecord(UpdateExerciseRecord event, Emitter<ExerciseState> emit) async {
    emit(ExerciseLoading());
    try {
      final updatedRecord = ExerciseRecord(
        id: event.recordId,
        userId: event.userId,
        exerciseName: event.exerciseName,
        exerciseType: event.exerciseType,
        durationMinutes: event.durationMinutes,
        caloriesBurned: event.caloriesBurned,
        exerciseDate: event.exerciseDate,
        weightKg: event.weightKg,
        sets: event.sets,
        reps: event.reps,
        distanceKm: event.distanceKm,
      );
      await _exerciseRepository.updateExerciseRecord(updatedRecord);
      final records = await _exerciseRepository.getExerciseRecords(event.userId);
      emit(ExerciseLoaded(records: records));
    } catch (e) {
      emit(ExerciseError(message: e.toString()));
    }
  }

  Future<void> _onDeleteExerciseRecord(DeleteExerciseRecord event, Emitter<ExerciseState> emit) async {
    emit(ExerciseLoading());
    try {
      await _exerciseRepository.deleteExerciseRecord(event.recordId);
      // 삭제 후 다시 로드하여 최신 상태 반영
      // TODO: 현재 사용자 ID를 어떻게 가져올지 고민 필요 (AuthBloc에서 가져오거나, 이벤트에 포함)
      // 임시로 1번 사용자 ID 사용
      final updatedRecords = await _exerciseRepository.getExerciseRecords(1);
      emit(ExerciseLoaded(records: updatedRecords));
    } catch (e) {
      emit(ExerciseError(message: e.toString()));
    }
  }
}
