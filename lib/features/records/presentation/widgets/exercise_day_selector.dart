import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/features/records/bloc/record_bloc.dart';
import 'package:jfit/features/records/bloc/record_event.dart';

class ExerciseDaySelector extends StatelessWidget {
  final String userProgramId;
  final int currentWeek;
  final int currentDay;
  final List<Map<String, dynamic>> programDays;
  final int totalWeeks;

  const ExerciseDaySelector({
    super.key,
    required this.userProgramId,
    required this.currentWeek,
    required this.currentDay,
    required this.programDays,
    required this.totalWeeks,
  });

  @override
  Widget build(BuildContext context) {
    // 주차 목록 생성
    final weeks = List.generate(totalWeeks, (i) => '${i + 1}주차');

    // 현재 주차의 일차 상태 계산
    List<Map<String, dynamic>> currentWeekDays = _calculateCurrentWeekDays();

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
            itemBuilder: (context, idx) {
              final weekNum = idx + 1;
              final isCurrentWeek = weekNum == currentWeek;
              final isCompletedWeek = weekNum < currentWeek;
              
              return GestureDetector(
                onTap: () {
                  // 주차 변경은 단순히 UI 변경만 - 실제 진행 상황은 업데이트하지 않음
                  // 운동을 완료했을 때만 진행 상황을 업데이트
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCurrentWeek
                        ? AppTheme.programAccentBlue
                        : isCompletedWeek
                            ? AppTheme.programAccentBlue.withOpacity(0.3)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    border: isCurrentWeek
                        ? null
                        : Border.all(color: AppTheme.textMuted),
                  ),
                  child: Text(
                    weeks[idx],
                    style: TextStyle(
                      color: isCurrentWeek
                          ? Colors.white
                          : isCompletedWeek
                              ? AppTheme.textSub
                              : AppTheme.textMuted,
                      fontWeight: isCurrentWeek
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // 일차 상태 표시
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: currentWeekDays.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final dayData = currentWeekDays[idx];
              final dayNum = dayData['day'] as int;
              final dayType = dayData['type'] as String;
              final label = dayData['label'] as String;
              
              return GestureDetector(
                onTap: () {
                  // 일차 변경은 단순히 UI 변경만 - 실제 진행 상황은 업데이트하지 않음
                  // 운동을 완료했을 때만 진행 상황을 업데이트
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getDayBackgroundColor(dayType),
                    borderRadius: BorderRadius.circular(20),
                    border: dayType == 'today'
                        ? Border.all(color: AppTheme.programAccentBlue, width: 2)
                        : null,
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: _getDayTextColor(dayType),
                      fontWeight: dayType == 'today'
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _calculateCurrentWeekDays() {
    List<Map<String, dynamic>> days = [];
    
    // 기본적으로 7일간의 패턴 (월~일)
    for (int day = 1; day <= 7; day++) {
      // 해당 주차-일차가 완료되었는지 확인
      final isCompleted = programDays.any((pd) =>
          pd['week'] == currentWeek &&
          pd['day'] == day &&
          pd['completed_at'] != null);
      
      // 현재 일차인지 확인
      final isToday = day == currentDay;
      
      // 일차 타입 결정
      String dayType;
      String label;
      
      if (isCompleted) {
        dayType = 'done';
        label = 'Day $day';
      } else if (isToday) {
        dayType = 'today';
        label = 'Day $day';
      } else if (day < currentDay) {
        dayType = 'missed';
        label = 'Day $day';
      } else if (day <= 5) { // 주 5일 운동 가정
        dayType = 'available';
        label = 'Day $day';
      } else {
        dayType = 'rest';
        label = '휴식';
      }
      
      days.add({
        'day': day,
        'type': dayType,
        'label': label,
      });
    }
    
    return days;
  }

  Color _getDayBackgroundColor(String dayType) {
    switch (dayType) {
      case 'done':
        return AppTheme.programAccentBlue.withOpacity(0.8);
      case 'today':
        return AppTheme.programAccentBlue.withOpacity(0.2);
      case 'rest':
        return AppTheme.textMuted.withOpacity(0.2);
      case 'missed':
        return Colors.red.withOpacity(0.2);
      case 'available':
        return Colors.transparent;
      default:
        return Colors.transparent;
    }
  }

  Color _getDayTextColor(String dayType) {
    switch (dayType) {
      case 'done':
        return Colors.white;
      case 'today':
        return AppTheme.programAccentBlue;
      case 'rest':
        return AppTheme.textMuted;
      case 'missed':
        return Colors.red;
      case 'available':
        return AppTheme.textSub;
      default:
        return AppTheme.textMuted;
    }
  }
} 