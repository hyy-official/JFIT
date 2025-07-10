import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';

class ExerciseDaySelector extends StatelessWidget {
  final int currentWeek;
  final int currentDay;
  const ExerciseDaySelector({super.key, required this.currentWeek, required this.currentDay});

  @override
  Widget build(BuildContext context) {
    // 더미: 6주차, 각 주 7일, Day5가 오늘
    final weeks = List.generate(6, (i) => '${i + 1}주차');
    final days = [
      {'type': 'done', 'label': 'Day 3'},
      {'type': 'rest', 'label': '휴식'},
      {'type': 'today', 'label': 'Day 5'},
      {'type': 'rest', 'label': '휴식'},
      {'type': 'rest', 'label': '휴식'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: weeks.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, idx) => Text(
              weeks[idx],
              style: TextStyle(
                color: idx == currentWeek - 1 ? AppTheme.programAccentBlue : AppTheme.textSub,
                fontWeight: idx == currentWeek - 1 ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final d = days[idx];
              Color bg;
              Color fg;
              Widget icon;
              if (d['type'] == 'today') {
                bg = AppTheme.programCardBackground;
                fg = AppTheme.programAccentBlue;
                icon = const Icon(Icons.fitness_center, color: Colors.white, size: 20);
              } else if (d['type'] == 'rest') {
                bg = AppTheme.programCardBackground.withOpacity(0.7);
                fg = AppTheme.textSub;
                icon = const Icon(Icons.nightlight_round, color: Colors.white70, size: 20);
              } else {
                bg = AppTheme.programAccentBlue.withOpacity(0.15);
                fg = AppTheme.programAccentBlue;
                icon = const Icon(Icons.check_circle, color: Colors.white, size: 20);
              }
              return Container(
                width: 64,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                  border: d['type'] == 'today' ? Border.all(color: AppTheme.programAccentBlue, width: 2) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon,
                    const SizedBox(height: 4),
                    Text(d['label']!, style: TextStyle(color: fg, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 