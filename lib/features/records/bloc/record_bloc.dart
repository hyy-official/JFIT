import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/features/records/bloc/record_event.dart';
import 'package:jfit/features/records/bloc/record_state.dart';
import 'package:jfit/features/records/data/repositories/record_repository.dart';
import 'package:jfit/features/records/data/models/meal_record_model.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';

class RecordBloc extends Bloc<RecordEvent, RecordState> {
  final RecordRepository _recordRepository;

  RecordBloc({required RecordRepository recordRepository})
      : _recordRepository = recordRepository,
        super(RecordInitial()) {
    on<LoadMealRecords>(_onLoadMealRecords);
    on<AddMealRecord>(_onAddMealRecord);
    on<UpdateMealRecord>(_onUpdateMealRecord);
    on<DeleteMealRecord>(_onDeleteMealRecord);
    on<LoadDailySummary>(_onLoadDailySummary);
  }

  Future<void> _onLoadMealRecords(LoadMealRecords event, Emitter<RecordState> emit) async {
    emit(RecordLoading());
    try {
      final records = await _recordRepository.getMealRecords(event.userId, date: event.date);
      emit(MealRecordsLoaded(mealRecords: records));
    } catch (e) {
      emit(RecordError(message: e.toString()));
    }
  }

  Future<void> _onAddMealRecord(AddMealRecord event, Emitter<RecordState> emit) async {
    emit(RecordLoading());
    try {
      await _recordRepository.addMealRecord(event.mealRecord);
      // 기록 추가 후 다시 로드하여 최신 상태 반영
      final updatedRecords = await _recordRepository.getMealRecords(event.mealRecord.userId, date: event.mealRecord.mealDate);
      emit(MealRecordsLoaded(mealRecords: updatedRecords));
    } catch (e) {
      emit(RecordError(message: e.toString()));
    }
  }

  Future<void> _onUpdateMealRecord(UpdateMealRecord event, Emitter<RecordState> emit) async {
    emit(RecordLoading());
    try {
      await _recordRepository.updateMealRecord(event.mealRecord);
      final records = await _recordRepository.getMealRecords(event.mealRecord.userId, date: event.mealRecord.mealDate);
      emit(MealRecordsLoaded(mealRecords: records));
    } catch (e) {
      emit(RecordError(message: e.toString()));
    }
  }

  Future<void> _onDeleteMealRecord(DeleteMealRecord event, Emitter<RecordState> emit) async {
    emit(RecordLoading());
    try {
      await _recordRepository.deleteMealRecord(event.recordId);
      // 삭제 후 다시 로드하여 최신 상태 반영
      // TODO: 현재 사용자 ID와 날짜를 어떻게 가져올지 고민 필요 (AuthBloc에서 가져오거나, 이벤트에 포함)
      // 임시로 1번 사용자 ID와 오늘 날짜 사용
      final updatedRecords = await _recordRepository.getMealRecords(1, date: DateTime.now());
      emit(MealRecordsLoaded(mealRecords: updatedRecords));
    } catch (e) {
      emit(RecordError(message: e.toString()));
    }
  }

  Future<void> _onLoadDailySummary(LoadDailySummary event, Emitter<RecordState> emit) async {
    emit(RecordLoading());
    try {
      final summary = await _recordRepository.getDailySummary(event.userId, event.date);
      if (summary != null) {
        emit(DailySummaryLoaded(dailySummary: summary));
      } else {
        // 요약 데이터가 없는 경우, 기본값으로 초기화된 요약 반환
        emit(DailySummaryLoaded(dailySummary: UserDailySummary(id: 'new', userId: event.userId, summaryDate: event.date)));
      }
    } catch (e) {
      emit(RecordError(message: e.toString()));
    }
  }
}
