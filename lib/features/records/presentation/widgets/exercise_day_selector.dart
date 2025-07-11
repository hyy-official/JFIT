import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/features/records/bloc/record_state.dart';

class ExerciseDaySelector extends StatelessWidget {
  final int currentWeek;
  final int currentDay;
  final UserProgram userProgram;
  
  const ExerciseDaySelector({
    super.key,
    required this.currentWeek,
    required this.currentDay,
    required this.userProgram,
  });

  List<String> _generateWeeks() {
    final totalWeeks = 12; // 기본값, 실제로는 프로그램에서 가져와야 함
    return List.generate(totalWeeks, (index) => '${index + 1}주차');
  }

  List<Map<String, String>> _generateDays() {
    // 주 7일 스케줄 생성
    final days = <Map<String, String>>[];
    
    for (int i = 1; i <= 7; i++) {
      final isWorkoutDay = _isWorkoutDay(i);
      final isCurrent = i == currentDay;
      final isCompleted = i < currentDay;
      
      String type;
      String label;
      
      if (isCompleted) {
        type = 'done';
        label = isWorkoutDay ? 'Day $i' : '휴식';
      } else if (isCurrent) {
        type = 'today';
        label = isWorkoutDay ? 'Day $i' : '휴식';
      } else {
        type = 'rest';
        label = isWorkoutDay ? 'Day $i' : '휴식';
      }
      
      days.add({
        'type': type,
        'label': label,
      });
    }
    
    return days;
  }

  bool _isWorkoutDay(int day) {
    // 간단한 로직: 홀수 날을 운동일로 가정
    // 실제로는 프로그램의 weekly_schedule에 따라 결정되어야 함
    return day % 2 == 1;
  }

  Color _getDayColor(String type) {
    switch (type) {
      case 'done':
        return AppTheme.accent1;
      case 'today':
        return AppTheme.programAccentBlue;
      case 'rest':
      default:
        return AppTheme.textSub;
    }
  }

  @override
  Widget build(BuildContext context) {
    final weeks = _generateWeeks();
    final days = _generateDays();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 주차 선택기
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: weeks.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                // 주차 변경 기능 (나중에 구현)
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: index == currentWeek - 1 
                      ? AppTheme.programAccentBlue.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: index == currentWeek - 1
                        ? AppTheme.programAccentBlue
                        : AppTheme.textSub.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  weeks[index],
                  style: TextStyle(
                    color: index == currentWeek - 1 
                        ? AppTheme.programAccentBlue 
                        : AppTheme.textSub,
                    fontWeight: index == currentWeek - 1 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 일차 선택기
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final day = days[index];
              final color = _getDayColor(day['type']!);
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: day['type'] == 'today' 
                      ? color.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: color.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  day['label']!,
                  style: TextStyle(
                    color: color,
                    fontWeight: day['type'] == 'today' 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 