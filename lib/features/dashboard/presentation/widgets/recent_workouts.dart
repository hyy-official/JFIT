import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/core/extensions/context_extensions.dart';

class RecentWorkouts extends StatelessWidget {
  final List<Map<String, dynamic>> workouts;
  const RecentWorkouts({super.key, required this.workouts});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: context.colors.surface,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppTheme.workoutIconColor.withOpacity(0.8), AppTheme.workoutIconColor]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.access_time, color: Colors.white, size: 20),
                ),
                SizedBox(width: 10),
                Text(l10n?.recentWorkouts ?? 'Recent Workouts', style: context.texts.titleMedium?.copyWith(color: Colors.white)),
              ],
            ),
            SizedBox(height: 16),
            ...workouts.map((w) => _WorkoutTile(w)).toList(),
          ],
        ),
      ),
    );
  }
}

class _WorkoutTile extends StatelessWidget {
  final Map<String, dynamic> w;
  const _WorkoutTile(this.w);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface2,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(Icons.fitness_center, color: Colors.white, size: 22),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(w['name'], style: context.texts.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${w['duration']}min • ${w['calories']} cal', style: context.texts.bodySmall?.copyWith(color: AppTheme.textSub)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.workoutIconColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(w['type'], style: context.texts.bodySmall?.copyWith(color: AppTheme.workoutIconColor, fontWeight: FontWeight.w600)),
              ),
              SizedBox(height: 4),
              Text(w['date'], style: context.texts.bodySmall?.copyWith(color: AppTheme.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
} 