import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:jfit/core/theme/app_theme.dart';
import '../../domain/entities/workout_program.dart';
import '../bloc/programs_bloc.dart';
import '../bloc/programs_event.dart';
import '../bloc/programs_state.dart';

class ProgramDetailPage extends StatelessWidget {
  final WorkoutProgram program;
  const ProgramDetailPage({required this.program, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<ProgramsBloc>(),
      child: Scaffold(
      backgroundColor: AppTheme.programDetailBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
          leading: const BackButton(color: Colors.white),
          title: Text(program.name, style: const TextStyle(color: Colors.white)),
      ),
        body: BlocConsumer<ProgramsBloc, ProgramsState>(
          listener: (context, state) {
            if (state is ProgramAddedToUser) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is ProgramAddError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
                    child: program.imageUrl != null
                  ? Image.network(
                            program.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                        color: Colors.grey[800],
                        child: const Center(child: Icon(Icons.image, color: Colors.white24, size: 60)),
                      ),
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Center(child: Icon(Icons.image, color: Colors.white24, size: 60)),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                            Expanded(
                              child: Text(program.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                      const SizedBox(width: 8),
                            if (program.isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.programAccentPurple,
                            borderRadius: BorderRadius.circular(8),
                          ),
                                child: const Text('인기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                        Text(program.creator, style: const TextStyle(color: Colors.white70, fontSize: 15)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                            Text('${program.rating.toStringAsFixed(1)} (${program.totalRatings}명)', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.programCardBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.white38, size: 18),
                        const SizedBox(width: 6),
                              Text('주 ${program.workoutsPerWeek ?? 0}일 · 총 ${program.durationWeeks}주차', style: const TextStyle(color: Colors.white, fontSize: 14)),
                        const SizedBox(width: 16),
                        const Icon(Icons.bar_chart, color: Colors.white38, size: 18),
                        const SizedBox(width: 6),
                              Text(program.difficultyLevel, style: const TextStyle(color: Colors.white, fontSize: 14)),
                        const SizedBox(width: 16),
                        const Icon(Icons.fitness_center, color: Colors.white38, size: 18),
                        const SizedBox(width: 6),
                              Text(program.programType, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                        Text(program.description, style: const TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Divider(color: Colors.white24, thickness: 1),
            const SizedBox(height: 16),
                  const Text('운동 장비', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            const SizedBox(height: 16),
                  if (program.equipmentNeeded != null)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: program.equipmentNeeded!.map((equipment) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.programCardBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(equipment, style: const TextStyle(color: Colors.white)),
                      )).toList(),
                    ),
            const SizedBox(height: 32),
          ],
        ),
            );
          },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
          child: BlocBuilder<ProgramsBloc, ProgramsState>(
            builder: (context, state) {
              return ElevatedButton(
          style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.programAccentBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
                onPressed: () {
                  context.read<ProgramsBloc>().add(AddProgramToUser(program.id));
                },
                child: const Text('내 루틴에 추가하기'),
              );
            },
          ),
        ),
      ),
    );
  }
}