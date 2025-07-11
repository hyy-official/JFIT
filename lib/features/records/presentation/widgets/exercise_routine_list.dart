import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/features/records/bloc/record_state.dart';
import 'exercise_routine_card.dart';

class ExerciseRoutineList extends StatelessWidget {
  final List<UserProgram> userPrograms;
  final DateTime selectedDate;
  
  const ExerciseRoutineList({
    super.key,
    required this.userPrograms,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: userPrograms.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final program = userPrograms[index];
        return ExerciseRoutineCard(
          title: program.programName,
          currentWeek: program.currentWeek,
          currentDay: program.currentDay,
          userProgram: program,
          selectedDate: selectedDate,
        );
      },
    );
  }
} 