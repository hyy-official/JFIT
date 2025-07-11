import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/features/records/bloc/record_state.dart';
import '../widgets/exercise_day_selector.dart';
import '../widgets/exercise_today_list.dart';
import 'package:jfit/features/workout_session/presentation/pages/workout_session_page.dart';

class ExerciseRoutineDetailPage extends StatelessWidget {
  final String routineName;
  final int currentWeek;
  final int currentDay;
  final UserProgram userProgram;
  
  const ExerciseRoutineDetailPage({
    super.key,
    required this.routineName,
    required this.currentWeek,
    required this.currentDay,
    required this.userProgram,
  });

  double _calculateProgress() {
    // 전체 주차 대비 현재 진행률 계산
    final totalWeeks = 12; // 기본값, 실제로는 프로그램에서 가져와야 함
    return (currentWeek / totalWeeks).clamp(0.0, 1.0);
  }

  String _getTargetMuscles() {
    final exercisesList = userProgram.exercisesJson['exercises'] as List?;
    if (exercisesList == null || exercisesList.isEmpty) {
      return '휴식일';
    }
    
    // 운동 목록에서 주요 운동 부위 추출
    final muscles = <String>{'가슴', '등', '어깨', '팔', '하체', '복근'}; // 기본값
    return muscles.join(', ');
  }

  List<Map<String, dynamic>> _getTodayExercises() {
    final exercisesList = userProgram.exercisesJson['exercises'] as List?;
    if (exercisesList == null || exercisesList.isEmpty) {
      return [];
    }
    
    // 운동 목록을 UI 형태로 변환
    return exercisesList.map((exercise) {
      return {
        'name': exercise['exercise_name'] ?? exercise['name'] ?? '운동',
        'sets': exercise['sets'] ?? 3,
        'reps': exercise['reps'] ?? '10회',
        'img': exercise['image_url'] ?? 'https://via.placeholder.com/150x150?text=Exercise',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress();
    final partDesc = _getTargetMuscles();
    final todayExercises = _getTodayExercises();

    return Scaffold(
      backgroundColor: AppTheme.programBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.programBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      routineName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}% 진행 중',
                      style: TextStyle(color: AppTheme.textSub),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ExerciseDaySelector(
                currentWeek: currentWeek,
                currentDay: currentDay,
                userProgram: userProgram,
              ),
              const SizedBox(height: 16),
              Text(
                partDesc,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: todayExercises.isEmpty
                    ? const Center(
                        child: Text(
                          '오늘은 휴식일입니다',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ExerciseTodayList(exercises: todayExercises),
              ),
              const SizedBox(height: 16),
              if (todayExercises.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkoutSessionPage(
                            userProgram: userProgram,
                            exercises: todayExercises,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent1,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '운동 시작하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 