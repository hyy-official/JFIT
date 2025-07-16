import 'package:flutter/material.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/features/programs/presentation/pages/program_detail_page.dart';
import 'package:jfit/features/records/presentation/widgets/program_detail_sheet.dart';
import '../../domain/entities/workout_program.dart';
import 'package:jfit/features/programs/presentation/bloc/programs_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProgramCardHorizontal extends StatelessWidget {
  final WorkoutProgram program;
  const ProgramCardHorizontal({required this.program, super.key});

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
        width: 140,
        height: 200,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 90,
                width: double.infinity,
                color: context.colors.surfaceVariant,
                child: program.imageUrl != null
                    ? Image.network(
                        program.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(Icons.image, color: context.colors.textMuted, size: 40),
                        ),
                      )
                    : Center(
                        child: Icon(Icons.image, color: context.colors.textMuted, size: 40),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (program.isPopular)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('인기', style: TextStyle(color: context.colors.onPrimary, fontSize: 11)),
                    ),
                  if (program.isPopular) const SizedBox(height: 4),
                  Text(
                    program.name,
                    style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    program.creator,
                    style: TextStyle(color: context.colors.textSecondary, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(program.difficultyLevel, style: TextStyle(color: context.colors.textMuted, fontSize: 11)),
                      const SizedBox(width: 8),
                      Text('주 ${program.workoutsPerWeek ?? 0}일', style: TextStyle(color: context.colors.textMuted, fontSize: 11)),
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