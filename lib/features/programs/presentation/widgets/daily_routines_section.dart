import 'package:flutter/material.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/features/programs/presentation/widgets/program_card_vertical.dart';
import '../../domain/entities/workout_program.dart';

class DailyRoutinesSection extends StatelessWidget {
  final List<String> partFilters;
  final List<WorkoutProgram> partPrograms;
  
  const DailyRoutinesSection({
    required this.partFilters,
    required this.partPrograms,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 일일 루틴 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '부위별 일일 루틴',
            style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const SizedBox(height: 12),
        // 부위별 필터
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: partFilters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final part = partFilters[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.colors.outline),
                ),
                child: Text(
                  part,
                  style: TextStyle(color: context.colors.textSecondary),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // 부위별 루틴 리스트
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ...partPrograms.map((p) => ProgramCardVertical(program: p)),
            ],
          ),
        ),
      ],
    );
  }
} 