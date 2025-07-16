import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/features/records/bloc/record_event.dart';
import 'package:jfit/features/records/bloc/record_state.dart';
import 'package:jfit/features/records/data/repositories/record_repository.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';

class RecordBloc extends Bloc<RecordEvent, RecordState> {
  final RecordRepository _recordRepository;

  // Repository getter 추가
  RecordRepository get recordRepository => _recordRepository;

  RecordBloc({required RecordRepository recordRepository})
      : _recordRepository = recordRepository,
        super(RecordInitial()) {
    on<LoadMealRecords>(_onLoadMealRecords);
    on<AddMealRecord>(_onAddMealRecord);
    on<UpdateMealRecord>(_onUpdateMealRecord);
    on<DeleteMealRecord>(_onDeleteMealRecord);
    on<LoadDailySummary>(_onLoadDailySummary);
    
    // 운동 프로그램 관련 이벤트 핸들러들
    on<LoadUserPrograms>(_onLoadUserPrograms);
    on<LoadUserProgramDetails>(_onLoadUserProgramDetails);
    on<LoadUserProgramDays>(_onLoadUserProgramDays);
    on<CompleteUserProgramDay>(_onCompleteUserProgramDay);
    on<UpdateUserProgramProgress>(_onUpdateUserProgramProgress);
    on<CreateWorkoutSession>(_onCreateWorkoutSession);
    on<CompleteWorkoutSession>(_onCompleteWorkoutSession);
    on<LoadExerciseDetails>(_onLoadExerciseDetails);
    on<SearchExercises>(_onSearchExercises);
    on<DeleteUserProgram>(_onDeleteUserProgram);
    on<LoadWorkoutSession>(_onLoadWorkoutSession);
    on<UpdateWorkoutSession>(_onUpdateWorkoutSession);
    on<LogWorkoutSet>(_onLogWorkoutSet);
    on<LoadCurrentWorkoutInfo>(_onLoadCurrentWorkoutInfo);
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
      // 삭제 후에는 현재 상태를 유지하거나 새로고침이 필요한 경우 별도 이벤트 발생
      // 현재는 삭제만 수행하고 UI에서 별도로 새로고침 호출
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
        emit(DailySummaryLoaded(dailySummary: UserDailySummary(
          id: 'new', 
          userId: event.userId, 
          summaryDate: event.date
        )));
      }
    } catch (e) {
      emit(RecordError(message: e.toString()));
    }
  }

  // 운동 프로그램 관련 이벤트 핸들러들
  Future<void> _onLoadUserPrograms(LoadUserPrograms event, Emitter<RecordState> emit) async {
    emit(RecordLoading());
    try {
      final userPrograms = await _recordRepository.getUserPrograms(event.userId);
      emit(UserProgramsLoaded(userPrograms: userPrograms));
    } catch (e) {
      emit(RecordError(message: e.toString()));
    }
  }

  Future<void> _onLoadUserProgramDetails(LoadUserProgramDetails event, Emitter<RecordState> emit) async {
    emit(RecordLoading());
    try {
      final programDetails = await _recordRepository.getUserProgramDetails(event.userProgramId);
      if (programDetails != null) {
        emit(UserProgramDetailsLoaded(programDetails: programDetails));
      } else {
        emit(const RecordError(message: 'Program details not found'));
      }
    } catch (e) {
      emit(RecordError(message: e.toString()));
    }
  }

  Future<void> _onLoadUserProgramDays(LoadUserProgramDays event, Emitter<RecordState> emit) async {
    emit(RecordLoading());
    try {
      final programDays = await _recordRepository.getUserProgramDays(event.userProgramId);
      emit(UserProgramDaysLoaded(programDays: programDays));
    } catch (e) {
      emit(RecordError(message: e.toString()));
    }
  }

  Future<void> _onCompleteUserProgramDay(CompleteUserProgramDay event, Emitter<RecordState> emit) async {
    try {
      await _recordRepository.completeUserProgramDay(
        event.userProgramId,
        event.week,
        event.day,
        note: event.note,
      );
      emit(const UserProgramDayCompleted(message: '운동 일차가 완료되었습니다!'));
    } catch (e) {
      emit(RecordError(message: e.toString()));
    }
  }

  Future<void> _onUpdateUserProgramProgress(UpdateUserProgramProgress event, Emitter<RecordState> emit) async {
    try {
      await _recordRepository.updateUserProgramProgress(
        event.userProgramId,
        event.currentWeek,
        event.currentDay,
      );
      emit(const UserProgramProgressUpdated(message: '진행 상황이 업데이트되었습니다!'));
    } catch (e) {
      emit(RecordError(message: e.toString()));
    }
  }

  Future<void> _onCreateWorkoutSession(CreateWorkoutSession event, Emitter<RecordState> emit) async {
    try {
      final sessionId = await _recordRepository.createWorkoutSession(
        event.userProgramId,
        event.exercisesJson,
      );
      emit(WorkoutSessionCreated(sessionId: sessionId));
    } catch (e) {
      emit(RecordError(message: e.toString()));
    }
  }

  Future<void> _onCompleteWorkoutSession(CompleteWorkoutSession event, Emitter<RecordState> emit) async {
    try {
      await _recordRepository.completeWorkoutSession(event.sessionId);
      emit(const WorkoutSessionCompleted(message: '운동 세션이 완료되었습니다!'));
    } catch (e) {
      emit(RecordError(message: e.toString()));
    }
  }

  Future<void> _onLoadExerciseDetails(LoadExerciseDetails event, Emitter<RecordState> emit) async {
    emit(RecordLoading());
    try {
      final exerciseDetails = await _recordRepository.getExerciseDetails(event.exerciseIds);
      emit(ExerciseDetailsLoaded(exerciseDetails: exerciseDetails));
    } catch (e) {
      emit(RecordError(message: e.toString()));
    }
  }

  Future<void> _onSearchExercises(SearchExercises event, Emitter<RecordState> emit) async {
    emit(RecordLoading());
    try {
      final searchResults = await _recordRepository.searchExercises(event.query);
      emit(ExerciseSearchResults(searchResults: searchResults));
    } catch (e) {
      emit(RecordError(message: e.toString()));
    }
  }

  Future<void> _onDeleteUserProgram(
    DeleteUserProgram event,
    Emitter<RecordState> emit,
  ) async {
    try {
      await _recordRepository.deleteUserProgram(event.userProgramId);
      emit(UserProgramDeleted(message: '운동 프로그램이 삭제되었습니다.'));
    } catch (e) {
      emit(RecordError(message: e.toString()));
    }
  }

  Future<void> _onLoadWorkoutSession(
    LoadWorkoutSession event,
    Emitter<RecordState> emit,
  ) async {
    try {
      emit(RecordLoading());
      final session = await _recordRepository.getWorkoutSession(event.sessionId);
      if (session != null) {
        emit(WorkoutSessionLoaded(session: session));
      } else {
        emit(RecordError(message: '워크아웃 세션을 찾을 수 없습니다.'));
      }
    } catch (e) {
      emit(RecordError(message: e.toString()));
    }
  }

  Future<void> _onUpdateWorkoutSession(
    UpdateWorkoutSession event,
    Emitter<RecordState> emit,
  ) async {
    try {
      await _recordRepository.upsertWorkoutSession(event.sessionData);
      emit(WorkoutSessionUpdated(message: '워크아웃 세션이 업데이트되었습니다.'));
    } catch (e) {
      emit(RecordError(message: e.toString()));
    }
  }

  Future<void> _onLogWorkoutSet(
    LogWorkoutSet event,
    Emitter<RecordState> emit,
  ) async {
    try {
      await _recordRepository.insertWorkoutLog(
        exerciseId: event.exerciseId,
        sessionId: event.sessionId,
        sets: event.setNumber,
        reps: event.reps,
        weight: event.weight,
      );
      emit(WorkoutSetLogged(message: '세트가 기록되었습니다.'));
    } catch (e) {
      emit(RecordError(message: e.toString()));
    }
  }

  Future<void> _onLoadCurrentWorkoutInfo(
    LoadCurrentWorkoutInfo event,
    Emitter<RecordState> emit,
  ) async {
    try {
      print('🔍 [RecordBloc] Loading current workout info for user: ${event.userId}');
      
      // 현재 진행 중인 사용자 프로그램 조회
      final userPrograms = await _recordRepository.getUserPrograms(event.userId);
      print('📊 [RecordBloc] Found ${userPrograms.length} user programs');
      
      if (userPrograms.isEmpty) {
        print('❌ [RecordBloc] No user programs found');
        emit(CurrentWorkoutInfoLoaded(workoutInfo: const CurrentWorkoutInfo()));
        return;
      }

      // 가장 최근에 시작한 프로그램 또는 진행 중인 프로그램 찾기
      Map<String, dynamic>? currentProgram;
      for (final program in userPrograms) {
        final programName = program['workout_programs']?['name'] ?? 'Unknown Program';
        print('🔍 [RecordBloc] Checking program: $programName - Week: ${program['current_week']}, Day: ${program['current_day']}');
        if (program['current_week'] != null && program['current_day'] != null) {
          currentProgram = program;
          break;
        }
      }

      if (currentProgram == null) {
        print('❌ [RecordBloc] No current program found');
        emit(CurrentWorkoutInfoLoaded(workoutInfo: const CurrentWorkoutInfo()));
        return;
      }

      final programName = currentProgram['workout_programs']?['name'] ?? 'Unknown Program';
      print('✅ [RecordBloc] Found current program: $programName');

      // 프로그램 상세 정보 조회
      final programDetails = await _recordRepository.getUserProgramDetails(currentProgram['id']);
      final programDays = await _recordRepository.getUserProgramDays(currentProgram['id']);

      // 활성 세션 확인 (진행 중인 운동이 있는지)
      final activeSessions = await _recordRepository.getActiveWorkoutSessions(event.userId);
      final hasActiveSession = activeSessions.isNotEmpty;

      // 완료된 일차 계산
      int completedDays = 0;
      for (final day in programDays) {
        if (day['completed_at'] != null) {
          completedDays++;
        }
      }

      final workoutInfo = CurrentWorkoutInfo(
        programName: programName, // 이미 위에서 올바르게 가져온 프로그램 이름 사용
        currentWeek: currentProgram['current_week'],
        currentDay: currentProgram['current_day'],
        totalWeeks: programDetails?['duration_weeks'] ?? currentProgram['workout_programs']?['duration_weeks'],
        completedDays: completedDays,
        totalDays: programDays.length,
        userProgramId: currentProgram['id'],
        hasActiveSession: hasActiveSession,
      );

      print('🎉 [RecordBloc] Created workout info: ${workoutInfo.programName} - ${workoutInfo.progressText}');

      emit(CurrentWorkoutInfoLoaded(workoutInfo: workoutInfo));
    } catch (e) {
      emit(RecordError(message: e.toString()));
    }
  }
}
