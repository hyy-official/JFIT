import 'package:flutter/material.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'exercise_routine_card.dart';

class ExerciseRoutineList extends StatelessWidget {
  final List<Map<String, dynamic>> userPrograms;
  final VoidCallback? onReturnFromDetail; // 상세 페이지에서 돌아올 때 콜백

  const ExerciseRoutineList({
    super.key, 
    required this.userPrograms,
    this.onReturnFromDetail,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: userPrograms.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, idx) {
        final userProgram = userPrograms[idx];
        final workoutProgram = userProgram['workout_programs'];
        
        // 현재 진행 상황 정보
        final currentWeek = userProgram['current_week'] ?? 1;
        final currentDay = userProgram['current_day'] ?? 1;
        
        // 진행률 계산 (현재 주차 / 총 주차)
        final totalWeeks = workoutProgram['duration_weeks'] ?? 1;
        final progress = (currentWeek - 1) / totalWeeks;
        
        // 오늘이 휴식일인지 확인 (간단한 로직: 주 운동 횟수 기준)
        final workoutsPerWeek = workoutProgram['workouts_per_week'] ?? 3;
        final isRestDay = currentDay > workoutsPerWeek;
        
        // 상태 텍스트 생성
        String statusText;
        String descText;
        
        if (isRestDay) {
          statusText = 'Day ${currentDay} 휴식일';
          descText = '루틴 쉬는 날입니다.';
        } else {
          statusText = 'Day ${currentDay} 운동일';
          
          // exercises_json에서 오늘의 운동 정보 추출 (새로운 구조 지원)
          final exercisesJson = userProgram['exercises_json'];
          List<dynamic>? exercises;
          
          if (exercisesJson is List) {
            // 새로운 구조: [{"week": 1, "days": [{"day": 1, "exercises": [...]}]}]
            for (final weekItem in exercisesJson) {
              if (weekItem is Map<String, dynamic> && weekItem['week'] == currentWeek) {
                final days = weekItem['days'] as List<dynamic>?;
                if (days != null) {
                  for (final dayItem in days) {
                    if (dayItem is Map<String, dynamic> && dayItem['day'] == currentDay) {
                      exercises = dayItem['exercises'] as List<dynamic>?;
                      break;
                    }
                  }
                }
                break;
              }
            }
          } else if (exercisesJson is Map<String, dynamic>) {
            // 기존 구조: {"week_1": {"day_1": {"exercises": [...]}}}
            if (exercisesJson.containsKey('week_$currentWeek')) {
              final weekData = exercisesJson['week_$currentWeek'] as Map<String, dynamic>?;
              if (weekData != null && weekData.containsKey('day_$currentDay')) {
                final dayData = weekData['day_$currentDay'] as Map<String, dynamic>?;
                if (dayData != null && dayData.containsKey('exercises')) {
                  exercises = dayData['exercises'] as List<dynamic>?;
                }
              }
            }
          }
          
          if (exercises != null && exercises.isNotEmpty) {
            // 첫 번째 몇 개의 운동 이름을 표시 (새로운 구조 지원)
            final exerciseNames = exercises.take(2).map((e) {
              // 새로운 구조: exercise_name 또는 custom_name
              // 기존 구조: name
              return e['exercise_name'] ?? e['custom_name'] ?? e['name'] ?? '운동';
            }).toList();
            descText = exerciseNames.join(', ');
            if (exercises.length > 2) {
              descText += ' 외 ${exercises.length - 2}개';
            }
          } else {
            descText = '오늘의 운동 정보가 없습니다.';
          }
        }
        
        return ExerciseRoutineCard(
          title: workoutProgram['name'] ?? '운동 프로그램',
          subtitle: statusText,
          desc: descText,
          imageUrl: workoutProgram['image_url'] ?? '',
          userProgramId: userProgram['id'],
          currentWeek: currentWeek,
          currentDay: currentDay,
          progress: progress,
          isRestDay: isRestDay,
          onReturn: onReturnFromDetail, // 콜백 전달
        );
      },
    );
  }
} 