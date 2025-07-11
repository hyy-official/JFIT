import 'package:flutter/material.dart';
import 'package:jfit/features/records/presentation/widgets/exercise_routine_card.dart';
import 'package:jfit/features/records/bloc/record_state.dart';

class ExerciseRoutineList extends StatelessWidget {
  final List<UserProgram> userPrograms;
  final DateTime selectedDate;
  final Function(UserProgram) onRoutineSelected;

  const ExerciseRoutineList({
    super.key,
    required this.userPrograms,
    required this.selectedDate,
    required this.onRoutineSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: userPrograms.length,
      itemBuilder: (context, index) {
        final userProgram = userPrograms[index];
        
        return ExerciseRoutineCard(
          userProgram: userProgram,
          selectedDate: selectedDate,
          onTap: () => onRoutineSelected(userProgram),
        );
      },
    );
  }
} 