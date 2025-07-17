import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/core/widgets/enhanced_error_feedback.dart';
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_state.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_bloc.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_event.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_state.dart';
import 'package:jfit/features/programs/presentation/bloc/programs_bloc.dart';
import 'package:get_it/get_it.dart';
import 'exercise_routine_list.dart';
import 'exercise_empty_state.dart';

class ExerciseTabContent extends StatefulWidget {
  const ExerciseTabContent({super.key});

  @override
  State<ExerciseTabContent> createState() => _ExerciseTabContentState();
}

class _ExerciseTabContentState extends State<ExerciseTabContent> 
    with AutomaticKeepAliveClientMixin {
  
  late WorkoutProgramBloc _workoutProgramBloc;

  @override
  void initState() {
    super.initState();
    _workoutProgramBloc = GetIt.instance<WorkoutProgramBloc>();
    _loadCurrentWorkoutInfo(); // 현재 운동 정보 로드 추가
  }

  @override
  void dispose() {
    _workoutProgramBloc.close();
    super.dispose();
  }

  void _refreshUserPrograms() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _workoutProgramBloc.add(LoadUserPrograms(userId: authState.user.id));
    }
  }
  
  void _loadCurrentWorkoutInfo() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      print('🎯 [ExerciseTab] Loading current workout info for user: ${authState.user.id}');
      _workoutProgramBloc.add(LoadCurrentWorkoutInfo(userId: authState.user.id));
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 요구사항
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GetIt.instance<ProgramsBloc>()),
        BlocProvider.value(value: _workoutProgramBloc),
      ],
      child: BlocConsumer<WorkoutProgramBloc, WorkoutProgramState>(
        listener: (context, state) {
          if (state is ProgramDayCompleted) {
            EnhancedErrorFeedback.showSuccessSnackBar(
              context,
              message: 'Day ${state.day} 완료되었습니다!',
            );
            _refreshUserPrograms(); // 완료 후 새로고침
          } else if (state is ProgramProgressUpdated) {
            EnhancedErrorFeedback.showInfoSnackBar(
              context,
              message: '프로그램 진행 상황이 업데이트되었습니다',
            );
            _refreshUserPrograms(); // 업데이트 후 새로고침
          } else if (state is UserProgramDeleted) {
            EnhancedErrorFeedback.showInfoSnackBar(
              context,
              message: '프로그램이 삭제되었습니다',
            );
            _refreshUserPrograms(); // 삭제 후 새로고침
          } else if (state is WorkoutProgramErrorState) {
            if (state.isRetryable && state.retryAction != null) {
              EnhancedErrorFeedback.showErrorSnackBar(
                context,
                message: state.userMessage,
                actionLabel: state.actionButtonText,
                onActionPressed: state.retryAction!,
                isRetryable: true,
              );
            } else {
              EnhancedErrorFeedback.showErrorSnackBar(
                context,
                message: state.userMessage,
                isRetryable: false,
              );
            }
          }
        },
        builder: (context, state) {
          // 단순하게 BLoC 상태만 구독
          if (state is WorkoutProgramLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserProgramsLoaded) {
            if (state.userPrograms.isEmpty) {
              return const ExerciseEmptyState();
            } else {
              return ExerciseRoutineList(
                userPrograms: state.userPrograms.map((program) => program.toJson()).toList(),
                onReturnFromDetail: _refreshUserPrograms, // 돌아올 때 새로고침
              );
            }
          } else if (state is WorkoutProgramErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: context.colors.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    '운동 프로그램을 불러오는 중 오류가 발생했습니다',
                    style: TextStyle(color: context.colors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.userMessage,
                    style: TextStyle(color: context.colors.textMuted, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshUserPrograms,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          } else {
            // 초기 상태이거나 다른 상태면 사용자 프로그램 로드
            _refreshUserPrograms();
            return const ExerciseEmptyState();
          }
        },
      ),
    );
  }
} 