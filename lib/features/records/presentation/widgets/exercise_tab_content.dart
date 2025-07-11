import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/features/records/bloc/record_bloc.dart';
import 'package:jfit/features/records/bloc/record_event.dart';
import 'package:jfit/features/records/bloc/record_state.dart';
import 'package:jfit/features/records/presentation/widgets/exercise_routine_list.dart';
import 'package:jfit/l10n/app_localizations.dart';

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
    // 사용자 프로그램 로드
    context.read<RecordBloc>().add(LoadUserPrograms());
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return BlocBuilder<RecordBloc, RecordState>(
      builder: (context, state) {
        if (state is RecordLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RecordError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red[300],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<RecordBloc>().add(LoadUserPrograms());
                  },
                  child: Text(localizations.retry),
                ),
              ],
            ),
          );
        } else if (state is UserProgramsLoaded) {
          final userPrograms = state.userPrograms;
          
          if (userPrograms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.noRoutinesFound,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ExerciseRoutineList(
            userPrograms: userPrograms,
            selectedDate: widget.selectedDate,
            onRoutineSelected: (userProgram) {
              // 루틴 선택 시 상세 페이지로 이동
              Navigator.pushNamed(
                context,
                '/exercise-routine-detail',
                arguments: userProgram,
              );
            },
          );
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  localizations.noRoutinesFound,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
} 