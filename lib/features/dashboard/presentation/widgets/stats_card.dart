import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppTheme.cardBackgroundColor,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 15, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                SizedBox(height: 6),
                  Text(value, style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 15), overflow: TextOverflow.ellipsis),
              ],
              ),
            ),
            SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: gradientColors.last.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4))],
              ),
              padding: const EdgeInsets.all(14),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }
} 