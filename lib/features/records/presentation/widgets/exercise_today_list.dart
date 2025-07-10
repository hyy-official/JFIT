import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';

class ExerciseTodayList extends StatelessWidget {
  final List<Map<String, dynamic>> exercises;
  const ExerciseTodayList({super.key, required this.exercises});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: exercises.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final ex = exercises[idx];
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.programCardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(ex['img'], width: 48, height: 48, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ex['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text('x ${ex['sets']}세트   ${ex['reps']}', style: TextStyle(color: AppTheme.textSub, fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.sync, color: AppTheme.textMuted),
            ],
          ),
        );
      },
    );
  }
} 