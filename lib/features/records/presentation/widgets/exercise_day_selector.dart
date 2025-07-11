import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/features/records/bloc/record_state.dart';

class ExerciseDaySelector extends StatelessWidget {
  final UserProgram userProgram;
  final DateTime selectedDate;

  const ExerciseDaySelector({
    super.key,
    required this.userProgram,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final workoutDays = _getWorkoutDays();
    
    if (workoutDays.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${userProgram.currentWeek}주차 운동일',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: workoutDays.map((day) {
              final isActive = day == userProgram.currentDay;
              final isCompleted = day < userProgram.currentDay;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _DayChip(
                  day: day,
                  isActive: isActive,
                  isCompleted: isCompleted,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<int> _getWorkoutDays() {
    try {
      // exercisesJson이나 weeklySchedule에서 운동일 추출
      if (userProgram.exercisesJson.isNotEmpty) {
        final exercises = userProgram.exercisesJson;
        
        // exercises_json에서 days 정보 추출
        if (exercises.containsKey('days')) {
          final days = exercises['days'] as List?;
          if (days != null) {
            return days.map((day) => day['day'] as int).toList()..sort();
          }
        }
        
        // 또는 week별 일정에서 추출
        if (exercises.containsKey('weeks')) {
          final weeks = exercises['weeks'] as List?;
          if (weeks != null && weeks.isNotEmpty) {
            final currentWeekData = weeks.firstWhere(
              (week) => week['week'] == userProgram.currentWeek,
              orElse: () => weeks.first,
            );
            if (currentWeekData != null && currentWeekData.containsKey('days')) {
              final days = currentWeekData['days'] as List?;
              if (days != null) {
                return days.map((day) => day['day'] as int).toList()..sort();
              }
            }
          }
        }
      }
      
      // weeklySchedule에서 운동일 추출
      if (userProgram.weeklySchedule.isNotEmpty) {
        final schedule = userProgram.weeklySchedule;
        if (schedule is List && schedule.isNotEmpty) {
          final weekData = schedule.firstWhere(
            (week) => week['week'] == userProgram.currentWeek,
            orElse: () => schedule.first,
          );
          
          if (weekData != null && weekData.containsKey('days')) {
            final days = weekData['days'] as List?;
            if (days != null) {
              return days.map((day) => day['day'] as int).toList()..sort();
            }
          }
        }
      }
      
      // 기본값: 주당 운동 횟수를 바탕으로 생성
      return _generateDefaultWorkoutDays();
    } catch (e) {
      // 오류 발생 시 기본값 반환
      return _generateDefaultWorkoutDays();
    }
  }

  List<int> _generateDefaultWorkoutDays() {
    final workoutsPerWeek = userProgram.workoutsPerWeek;
    
    // 주당 운동 횟수에 따라 운동일 생성
    switch (workoutsPerWeek) {
      case 1:
        return [1];
      case 2:
        return [1, 4];
      case 3:
        return [1, 3, 5];
      case 4:
        return [1, 2, 4, 5];
      case 5:
        return [1, 2, 3, 4, 5];
      case 6:
        return [1, 2, 3, 4, 5, 6];
      case 7:
        return [1, 2, 3, 4, 5, 6, 7];
      default:
        return [1, 3, 5]; // 기본값
    }
  }
}

class _DayChip extends StatelessWidget {
  final int day;
  final bool isActive;
  final bool isCompleted;

  const _DayChip({
    required this.day,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    
    if (isCompleted) {
      backgroundColor = Colors.green;
      textColor = Colors.white;
    } else if (isActive) {
      backgroundColor = AppTheme.primary;
      textColor = Colors.white;
    } else {
      backgroundColor = Colors.grey[200]!;
      textColor = Colors.grey[600]!;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: isActive
            ? Border.all(color: AppTheme.primary, width: 2)
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'D$day',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            if (isCompleted)
              Icon(
                Icons.check,
                size: 12,
                color: textColor,
              ),
          ],
        ),
      ),
    );
  }
} 