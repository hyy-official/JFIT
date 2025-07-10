import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';
import '../widgets/exercise_day_selector.dart';
import '../widgets/exercise_today_list.dart';
import 'package:jfit/features/workout_session/presentation/pages/workout_session_page.dart';

class ExerciseRoutineDetailPage extends StatelessWidget {
  final String routineName;
  final int currentWeek;
  final int currentDay;
  const ExerciseRoutineDetailPage({
    super.key,
    required this.routineName,
    required this.currentWeek,
    required this.currentDay,
  });

  @override
  Widget build(BuildContext context) {
    // 더미 진행률, 부위, 운동 리스트
    final progress = 0.06; // 6%
    final partDesc = '가슴, 등, 복근, 어깨, 팔, 하체';
    final todayExercises = [
      {'name': '스쿼트', 'sets': 3, 'reps': '10회', 'img': 'https://wger.de/media/exercise-images/4/Barbell-squat-1.png'},
      {'name': '스쿼트', 'sets': 1, 'reps': 'MAX', 'img': 'https://wger.de/media/exercise-images/4/Barbell-squat-1.png'},
      {'name': '와이드 그립 벤치 프레스', 'sets': 2, 'reps': '10회', 'img': 'https://wger.de/media/exercise-images/14/Wide-grip-bench-press-1.png'},
      {'name': '와이드 그립 벤치 프레스', 'sets': 1, 'reps': 'MAX', 'img': 'https://wger.de/media/exercise-images/14/Wide-grip-bench-press-1.png'},
    ];

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
                    Text(routineName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('${(progress * 100).toStringAsFixed(0)}% 진행 중', style: TextStyle(color: AppTheme.textSub)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ExerciseDaySelector(currentWeek: currentWeek, currentDay: currentDay),
              const SizedBox(height: 16),
              Text(partDesc, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 8),
              Expanded(child: ExerciseTodayList(exercises: todayExercises)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => WorkoutSessionPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.programAccentBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Day$currentDay 시작하기', style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 