import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'record_event.dart';
import 'record_state.dart';

class RecordBloc extends Bloc<RecordEvent, RecordState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  RecordBloc() : super(RecordInitial()) {
    on<LoadUserPrograms>(_onLoadUserPrograms);
    on<LoadWorkoutSessions>(_onLoadWorkoutSessions);
    on<StartWorkoutSession>(_onStartWorkoutSession);
    on<CompleteWorkoutSession>(_onCompleteWorkoutSession);
    on<UpdateProgramProgress>(_onUpdateProgramProgress);
  }

  Future<void> _onLoadUserPrograms(
      LoadUserPrograms event, Emitter<RecordState> emit) async {
    emit(RecordLoading());
    try {
      final response = await _supabase
          .from('user_programs')
          .select('''
            id,
            program_id,
            started_at,
            current_week,
            current_day,
            is_active,
            completed_at,
            exercises_json,
            image_url,
            workout_programs!inner (
              id,
              name,
              creator,
              description,
              duration_weeks,
              difficulty_level,
              program_type,
              workouts_per_week,
              weekly_schedule,
              image_url
            )
          ''')
          .eq('is_active', true)
          .order('started_at', ascending: false);

      final userPrograms = response.map((data) {
        final programData = data['workout_programs'] as Map<String, dynamic>;
        return UserProgram(
          id: data['id'],
          name: programData['name'] ?? '',
          creator: programData['creator'] ?? '',
          description: programData['description'] ?? '',
          currentWeek: data['current_week'] ?? 1,
          currentDay: data['current_day'] ?? 1,
          totalWeeks: programData['duration_weeks'] ?? 1,
          difficulty: programData['difficulty_level'] ?? 'beginner',
          programType: programData['program_type'] ?? 'strength',
          workoutsPerWeek: programData['workouts_per_week'] ?? 3,
          exercisesJson: data['exercises_json'] ?? {},
          imageUrl: data['image_url'] ?? programData['image_url'],
          startedAt: DateTime.parse(data['started_at']),
          completedAt: data['completed_at'] != null
              ? DateTime.parse(data['completed_at'])
              : null,
          isActive: data['is_active'] ?? false,
          weeklySchedule: programData['weekly_schedule'] ?? [],
          programId: data['program_id'],
        );
      }).toList();

      emit(UserProgramsLoaded(userPrograms));
    } catch (e) {
      emit(RecordError('사용자 프로그램을 불러오는 데 실패했습니다: $e'));
    }
  }

  Future<void> _onLoadWorkoutSessions(
      LoadWorkoutSessions event, Emitter<RecordState> emit) async {
    try {
      final response = await _supabase
          .from('workout_sessions')
          .select('''
            id,
            user_program_id,
            session_date,
            started_at,
            ended_at,
            is_completed,
            exercises_json
          ''')
          .eq('user_program_id', event.userProgramId)
          .order('session_date', ascending: false);

      final sessions = response.map((data) {
        return WorkoutSession(
          id: data['id'],
          userProgramId: data['user_program_id'],
          sessionDate: DateTime.parse(data['session_date']),
          startedAt: data['started_at'] != null
              ? DateTime.parse(data['started_at'])
              : null,
          endedAt: data['ended_at'] != null
              ? DateTime.parse(data['ended_at'])
              : null,
          isCompleted: data['is_completed'] ?? false,
          exercisesJson: data['exercises_json'] ?? {},
        );
      }).toList();

      emit(WorkoutSessionsLoaded(sessions));
    } catch (e) {
      emit(RecordError('운동 세션을 불러오는 데 실패했습니다: $e'));
    }
  }

  Future<void> _onStartWorkoutSession(
      StartWorkoutSession event, Emitter<RecordState> emit) async {
    try {
      final response = await _supabase
          .from('workout_sessions')
          .insert({
            'user_program_id': event.userProgramId,
            'session_date': event.sessionDate.toIso8601String().split('T')[0],
            'started_at': DateTime.now().toIso8601String(),
            'exercises_json': event.exercisesJson,
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
        isCompleted: false,
        exercisesJson: response['exercises_json'] ?? {},
      );

      emit(WorkoutSessionStarted(session));
    } catch (e) {
      emit(RecordError('운동 세션을 시작하는 데 실패했습니다: $e'));
    }
  }

  Future<void> _onCompleteWorkoutSession(
      CompleteWorkoutSession event, Emitter<RecordState> emit) async {
    try {
      await _supabase
          .from('workout_sessions')
          .update({
            'ended_at': DateTime.now().toIso8601String(),
            'is_completed': true,
          })
          .eq('id', event.sessionId);

      emit(WorkoutSessionCompleted(event.sessionId));
    } catch (e) {
      emit(RecordError('운동 세션을 완료하는 데 실패했습니다: $e'));
    }
  }

  Future<void> _onUpdateProgramProgress(
      UpdateProgramProgress event, Emitter<RecordState> emit) async {
    try {
      await _supabase
          .from('user_programs')
          .update({
            'current_week': event.currentWeek,
            'current_day': event.currentDay,
          })
          .eq('id', event.userProgramId);

      // user_program_days 테이블에도 기록
      await _supabase
          .from('user_program_days')
          .upsert({
            'user_program_id': event.userProgramId,
            'week': event.currentWeek,
            'day': event.currentDay,
            'completed_at': DateTime.now().toIso8601String(),
          });

      emit(ProgramProgressUpdated(event.userProgramId, event.currentWeek, event.currentDay));
    } catch (e) {
      emit(RecordError('프로그램 진도를 업데이트하는 데 실패했습니다: $e'));
    }
  }
}
