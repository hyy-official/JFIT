import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_state.dart';
import 'package:jfit/features/records/bloc/record_bloc.dart';
import 'package:jfit/features/records/bloc/record_event.dart';
import 'package:jfit/features/records/bloc/record_state.dart';
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
  
  @override
  void initState() {
    super.initState();
    // 로딩 로직 제거 - RecordPage에서 이미 처리함
  }

  void _refreshUserPrograms() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<RecordBloc>().add(LoadUserPrograms(userId: authState.user.id));
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 요구사항
    
    return BlocProvider(
      create: (context) => GetIt.instance<ProgramsBloc>(),
      child: BlocConsumer<RecordBloc, RecordState>(
      listener: (context, state) {
        if (state is UserProgramDayCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          _refreshUserPrograms(); // 완료 후 새로고침
        } else if (state is UserProgramProgressUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          _refreshUserPrograms(); // 업데이트 후 새로고침
        } else if (state is UserProgramDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          _refreshUserPrograms(); // 삭제 후 새로고침
        }
      },
      builder: (context, state) {
        // 단순하게 BLoC 상태만 구독
        if (state is RecordLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is UserProgramsLoaded) {
          if (state.userPrograms.isEmpty) {
            return const ExerciseEmptyState();
          } else {
            return ExerciseRoutineList(
              userPrograms: state.userPrograms,
              onReturnFromDetail: _refreshUserPrograms, // 돌아올 때 새로고침
            );
          }
        } else if (state is RecordError) {
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
                  state.message,
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
          // 초기 상태이거나 다른 상태면 빈 상태 표시
          return const ExerciseEmptyState();
        }
      },
    ),
    );
  }
} 