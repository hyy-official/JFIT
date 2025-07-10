import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';
import '../../presentation/pages/exercise_routine_detail_page.dart';

class ExerciseRoutineCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String desc;
  final String imageUrl;
  const ExerciseRoutineCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.desc,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExerciseRoutineDetailPage(
              routineName: title,
              currentWeek: 1,
              currentDay: 5,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.programCardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 14, color: AppTheme.textSub, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.programBackground,
              backgroundImage: NetworkImage(imageUrl),
            ),
          ],
        ),
      ),
    );
  }
} 