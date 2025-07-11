import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/features/records/bloc/record_state.dart';
import '../../presentation/pages/exercise_routine_detail_page.dart';

class ExerciseRoutineCard extends StatelessWidget {
  final String title;
  final int currentWeek;
  final int currentDay;
  final UserProgram userProgram;
  final DateTime selectedDate;
  
  const ExerciseRoutineCard({
    super.key,
    required this.title,
    required this.currentWeek,
    required this.currentDay,
    required this.userProgram,
    required this.selectedDate,
  });

  String _getRoutineStatus() {
    // 운동 요일 계산 (예: 주 3회 프로그램이라면 1, 3, 5일이 운동일)
    final exercisesList = userProgram.exercisesJson['exercises'] as List?;
    if (exercisesList == null || exercisesList.isEmpty) {
      return 'Day $currentDay 휴식일';
    }
    
    // 오늘이 운동일인지 확인
    final isWorkoutDay = _isWorkoutDay(currentDay);
    if (isWorkoutDay) {
      return 'Day $currentDay 운동일';
    } else {
      return 'Day $currentDay 휴식일';
    }
  }

  String _getRoutineDescription() {
    final exercisesList = userProgram.exercisesJson['exercises'] as List?;
    if (exercisesList == null || exercisesList.isEmpty) {
      return '루틴 쉬는 날입니다.';
    }
    
    final isWorkoutDay = _isWorkoutDay(currentDay);
    if (isWorkoutDay) {
      // 운동 목록에서 주요 운동들 추출
      final exercises = exercisesList.take(3).map((e) => e['exercise_name'] ?? e['name'] ?? '운동').toList();
      return exercises.join(', ');
    } else {
      return '루틴 쉬는 날입니다.';
    }
  }

  bool _isWorkoutDay(int day) {
    // 간단한 로직: 홀수 날을 운동일로 가정 (실제로는 프로그램 스케줄에 따라 달라짐)
    return day % 2 == 1;
  }

  String _getProgressPercentage() {
    // 전체 주차 대비 현재 진행률 계산
    final totalWeeks = 12; // 기본값, 실제로는 프로그램에서 가져와야 함
    final progress = (currentWeek / totalWeeks * 100).clamp(0, 100);
    return '${progress.toStringAsFixed(0)}%';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExerciseRoutineDetailPage(
              routineName: title,
              currentWeek: currentWeek,
              currentDay: currentDay,
              userProgram: userProgram,
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
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getRoutineStatus(),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSub,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getRoutineDescription(),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 진행률 표시
                  Row(
                    children: [
                      Text(
                        '${_getProgressPercentage()} 진행 중',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.accent1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$currentWeek주차',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSub,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // 프로그램 아이콘 (기본 아이콘 사용)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.programBackground,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.fitness_center,
                color: AppTheme.accent1,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 