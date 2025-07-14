import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/features/programs/presentation/pages/program_detail_page.dart';
import 'package:jfit/features/records/presentation/widgets/program_detail_sheet.dart';
import '../../domain/entities/workout_program.dart';
import 'package:jfit/features/programs/presentation/bloc/programs_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProgramCardVertical extends StatelessWidget {
  final WorkoutProgram program;
  const ProgramCardVertical({required this.program, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final bloc = context.read<ProgramsBloc>();
        final isDesktop = MediaQuery.of(context).size.width > 600;
        if (isDesktop) {
          showDialog(
            context: context,
            builder: (context) => Center(
              child: SizedBox(
                width: 600,
                child: BlocProvider.value(
                  value: bloc,
                  child: ProgramDetailPage(program: program),
                ),
              ),
            ),
          );
        } else {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => BlocProvider.value(
              value: bloc,
              child: ProgramDetailPage(program: program),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.programCardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 60,
                height: 60,
                color: Colors.grey[800],
                child: program.imageUrl != null
                    ? Image.network(
                        program.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.image, color: Colors.white24, size: 24),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image, color: Colors.white24, size: 24),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (program.isPopular) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accent1,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('인기', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          program.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    program.creator,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(program.difficultyLevel, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      const SizedBox(width: 8),
                      Text('주 ${program.workoutsPerWeek ?? 0}일', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 