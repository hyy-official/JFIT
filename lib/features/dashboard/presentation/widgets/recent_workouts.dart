import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';
import 'package:jfit/core/theme/app_theme.dart';

class RecentWorkouts extends StatelessWidget {
  final List<Map<String, dynamic>> workouts;
  const RecentWorkouts({super.key, required this.workouts});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppTheme.cardBackgroundColor,
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
                    gradient: LinearGradient(colors: [AppTheme.workoutIconColor, AppTheme.workoutIconColor.withOpacity(0.7)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.access_time, color: Colors.white, size: 20),
                ),
                SizedBox(width: 10),
                Text(l10n?.recentWorkouts ?? 'Recent Workouts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
              color: Colors.grey[800],
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
                Text(w['name'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${w['duration']}min • ${w['calories']} cal', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.workoutIconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(w['type'], style: TextStyle(color: AppTheme.workoutIconColor, fontWeight: FontWeight.w600, fontSize: 12)),
              ),
              SizedBox(height: 4),
              Text(w['date'], style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
} 