import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/features/records/bloc/record_bloc.dart';
import 'package:jfit/features/records/bloc/record_event.dart';
import 'package:jfit/features/records/bloc/record_state.dart';
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_state.dart';
import 'exercise_routine_list.dart';
import 'exercise_empty_state.dart';

class ExerciseTabContent extends StatefulWidget {
  final DateTime selectedDate;
  
  const ExerciseTabContent({super.key, required this.selectedDate});

  @override
  State<ExerciseTabContent> createState() => _ExerciseTabContentState();
}

class _ExerciseTabContentState extends State<ExerciseTabContent> {
  @override
  void initState() {
    super.initState();
    _loadUserPrograms();
  }

  @override
  void didUpdateWidget(covariant ExerciseTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _loadUserPrograms();
    }
  }

  void _loadUserPrograms() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<RecordBloc>().add(LoadUserPrograms(userId: authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecordBloc, RecordState>(
      builder: (context, state) {
        if (state is RecordLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is UserProgramsLoaded) {
          final hasActivePrograms = state.userPrograms.isNotEmpty;
          
          if (hasActivePrograms) {
            return ExerciseRoutineList(
              userPrograms: state.userPrograms,
              selectedDate: widget.selectedDate,
            );
          } else {
            return const ExerciseEmptyState();
          }
        }
        
        if (state is RecordError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(height: 16),
                Text(
                  '오류가 발생했습니다',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadUserPrograms,
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          );
        }
        
        // 초기 상태 또는 다른 상태일 때 로딩 표시
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
} 