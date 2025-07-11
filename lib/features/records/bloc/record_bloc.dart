import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/features/records/bloc/record_event.dart';
import 'package:jfit/features/records/bloc/record_state.dart';
import 'package:jfit/features/records/data/repositories/record_repository.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecordBloc extends Bloc<RecordEvent, RecordState> {
  final RecordRepository _recordRepository;
  final SupabaseClient _supabaseClient;

  RecordBloc({
    required RecordRepository recordRepository,
    SupabaseClient? supabaseClient,
  }) : _recordRepository = recordRepository,
        _supabaseClient = supabaseClient ?? Supabase.instance.client,
        super(RecordInitial()) {
    on<LoadMealRecords>(_onLoadMealRecords);
    on<AddMealRecord>(_onAddMealRecord);
    on<UpdateMealRecord>(_onUpdateMealRecord);
    on<DeleteMealRecord>(_onDeleteMealRecord);
    on<LoadDailySummary>(_onLoadDailySummary);
    
    // 운동 관련 이벤트 핸들러들
    on<LoadUserPrograms>(_onLoadUserPrograms);
    on<LoadWorkoutSessions>(_onLoadWorkoutSessions);
    on<StartWorkoutSession>(_onStartWorkoutSession);
    on<CompleteWorkoutSession>(_onCompleteWorkoutSession);
    on<UpdateProgramProgress>(_onUpdateProgramProgress);
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

  // 운동 관련 이벤트 핸들러들
  Future<void> _onLoadUserPrograms(LoadUserPrograms event, Emitter<RecordState> emit) async {
    emit(RecordLoading());
    try {
      // TODO: 실제 Supabase 연결 전까지 테스트용 더미 데이터 사용
      final userPrograms = [
        UserProgram(
          id: 'test-program-1',
          userId: event.userId,
          programId: 'program-1',
          programName: '아놀드 골든 식스',
          startedAt: DateTime.now().subtract(const Duration(days: 5)),
          currentWeek: 1,
          currentDay: 3,
          isActive: true,
          exercisesJson: {
            'exercises': [
              {
                'exercise_name': '스쿼트',
                'sets': 3,
                'reps': '10회',
                'image_url': 'https://wger.de/media/exercise-images/4/Barbell-squat-1.png',
              },
              {
                'exercise_name': '벤치프레스',
                'sets': 3,
                'reps': '10회',
                'image_url': 'https://wger.de/media/exercise-images/14/Wide-grip-bench-press-1.png',
              },
            ],
          },
        ),
        UserProgram(
          id: 'test-program-2',
          userId: event.userId,
          programId: 'program-2',
          programName: '원펀맨 운동법',
          startedAt: DateTime.now().subtract(const Duration(days: 10)),
          currentWeek: 2,
          currentDay: 5,
          isActive: true,
          exercisesJson: {
            'exercises': [
              {
                'exercise_name': '윗몸일으키기',
                'sets': 1,
                'reps': '100회',
              },
              {
                'exercise_name': '스쿼트',
                'sets': 1,
                'reps': '100회',
              },
              {
                'exercise_name': '팔굽혀펴기',
                'sets': 1,
                'reps': '100회',
              },
            ],
          },
        ),
      ];

      emit(UserProgramsLoaded(userPrograms: userPrograms));
      
      // 실제 Supabase 연결 코드 (주석 처리)
      /*
      final response = await _supabaseClient
          .from('user_programs')
          .select('*, workout_programs(name)')
          .eq('user_id', event.userId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final userPrograms = (response as List).map((data) {
        return UserProgram(
          id: data['id'],
          userId: data['user_id'],
          programId: data['program_id'],
          programName: data['workout_programs']['name'] ?? 'Unknown Program',
          startedAt: DateTime.parse(data['started_at']),
          currentWeek: data['current_week'],
          currentDay: data['current_day'],
          isActive: data['is_active'],
          exercisesJson: data['exercises_json'] ?? {},
        );
      }).toList();

      emit(UserProgramsLoaded(userPrograms: userPrograms));
      */
    } catch (e) {
      emit(RecordError(message: '사용자 프로그램을 불러오는 중 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _onLoadWorkoutSessions(LoadWorkoutSessions event, Emitter<RecordState> emit) async {
    emit(RecordLoading());
    try {
      final response = await _supabaseClient
          .from('workout_sessions')
          .select('*')
          .eq('user_id', event.userId)
          .eq('session_date', event.date.toIso8601String().split('T')[0])
          .order('created_at', ascending: false);

      final workoutSessions = (response as List).map((data) {
        return WorkoutSession(
          id: data['id'],
          userProgramId: data['user_program_id'],
          sessionDate: DateTime.parse(data['session_date']),
          startedAt: data['started_at'] != null ? DateTime.parse(data['started_at']) : null,
          endedAt: data['ended_at'] != null ? DateTime.parse(data['ended_at']) : null,
          isCompleted: data['is_completed'],
          exercisesJson: data['exercises_json'],
        );
      }).toList();

      emit(WorkoutSessionsLoaded(workoutSessions: workoutSessions));
    } catch (e) {
      emit(RecordError(message: '운동 세션을 불러오는 중 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _onStartWorkoutSession(StartWorkoutSession event, Emitter<RecordState> emit) async {
    emit(RecordLoading());
    try {
      final response = await _supabaseClient
          .from('workout_sessions')
          .insert({
            'user_program_id': event.userProgramId,
            'session_date': event.date.toIso8601String().split('T')[0],
            'started_at': DateTime.now().toIso8601String(),
            'is_completed': false,
          })
          .select()
          .single();

      final session = WorkoutSession(
        id: response['id'],
        userProgramId: response['user_program_id'],
        sessionDate: DateTime.parse(response['session_date']),
        startedAt: DateTime.parse(response['started_at']),
        endedAt: null,
        isCompleted: response['is_completed'],
        exercisesJson: response['exercises_json'],
      );

      emit(WorkoutSessionStarted(session: session));
    } catch (e) {
      emit(RecordError(message: '운동 세션을 시작하는 중 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _onCompleteWorkoutSession(CompleteWorkoutSession event, Emitter<RecordState> emit) async {
    emit(RecordLoading());
    try {
      await _supabaseClient
          .from('workout_sessions')
          .update({
            'ended_at': DateTime.now().toIso8601String(),
            'is_completed': true,
          })
          .eq('id', event.sessionId);

      emit(WorkoutSessionCompleted(sessionId: event.sessionId));
    } catch (e) {
      emit(RecordError(message: '운동 세션을 완료하는 중 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _onUpdateProgramProgress(UpdateProgramProgress event, Emitter<RecordState> emit) async {
    emit(RecordLoading());
    try {
      await _supabaseClient
          .from('user_programs')
          .update({
            'current_week': event.currentWeek,
            'current_day': event.currentDay,
          })
          .eq('id', event.userProgramId);

      emit(ProgramProgressUpdated(
        userProgramId: event.userProgramId,
        currentWeek: event.currentWeek,
        currentDay: event.currentDay,
      ));
    } catch (e) {
      emit(RecordError(message: '프로그램 진행률을 업데이트하는 중 오류가 발생했습니다: $e'));
    }
  }
}
