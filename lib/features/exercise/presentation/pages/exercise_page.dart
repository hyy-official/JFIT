import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';
import 'package:jfit/features/exercise/presentation/widgets/exercise_stats.dart';
import 'package:jfit/features/exercise/presentation/widgets/exercise_progress_chart.dart';
import 'package:jfit/features/exercise/presentation/widgets/workout_history.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/core/extensions/context_extensions.dart';


class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  // 더미 데이터 - 운동 기록
  final List<Map<String, dynamic>> mockExercises = [
    {
      'id': 1,
      'exerciseName': 'squat',
      'exerciseType': 'strength',
      'duration': 40,
      'caloriesBurned': 270,
      'exerciseDate': '2024-12-06',
      'weight': 80,
      'sets': 3,
      'reps': 12,
    },
    {
      'id': 2,
      'exerciseName': 'benchPress',
      'exerciseType': 'strength',
      'duration': 45,
      'caloriesBurned': 220,
      'exerciseDate': '2024-12-05',
      'weight': 70,
      'sets': 4,
      'reps': 10,
    },
    {
      'id': 3,
      'exerciseName': 'squat',
      'exerciseType': 'strength',
      'duration': 40,
      'caloriesBurned': 260,
      'exerciseDate': '2024-12-04',
      'weight': 75,
      'sets': 3,
      'reps': 10,
    },
    {
      'id': 4,
      'exerciseName': 'deadlift',
      'exerciseType': 'strength',
      'duration': 50,
      'caloriesBurned': 310,
      'exerciseDate': '2024-12-04',
      'weight': 100,
      'sets': 4,
      'reps': 8,
    },
    {
      'id': 5,
      'exerciseName': 'benchPress',
      'exerciseType': 'strength',
      'duration': 45,
      'caloriesBurned': 270,
      'exerciseDate': '2024-12-03',
      'weight': 75,
      'sets': 4,
      'reps': 8,
    },
    {
      'id': 6,
      'exerciseName': 'squat',
      'exerciseType': 'strength',
      'duration': 40,
      'caloriesBurned': 250,
      'exerciseDate': '2024-12-02',
      'weight': 70,
      'sets': 3,
      'reps': 12,
    },
    {
      'id': 7,
      'exerciseName': 'deadlift',
      'exerciseType': 'strength',
      'duration': 50,
      'caloriesBurned': 300,
      'exerciseDate': '2024-12-01',
      'weight': 95,
      'sets': 4,
      'reps': 8,
    },
    {
      'id': 8,
      'exerciseName': 'benchPress',
      'exerciseType': 'strength',
      'duration': 45,
      'caloriesBurned': 270,
      'exerciseDate': '2024-12-01',
      'weight': 75,
      'sets': 4,
      'reps': 8,
    },
    {
      'id': 9,
      'exerciseName': 'running',
      'exerciseType': 'cardio',
      'duration': 30,
      'caloriesBurned': 250,
      'exerciseDate': '2024-01-15',
      'distance': 5.0,
    },
    {
      'id': 10,
      'exerciseName': 'yoga',
      'exerciseType': 'flexibility',
      'duration': 45,
      'caloriesBurned': 150,
      'exerciseDate': '2024-01-14',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      color: context.colors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 섹션
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.accent1,
                  child: const Icon(Icons.fitness_center, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n?.appTitle ?? 'JFIT', 
                  style: context.texts.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.workoutManager ?? 'Workout Manager',
                  style: context.texts.headlineLarge?.copyWith(fontSize: 36, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n?.trackFitnessJourney ?? 'Track your fitness journey and build consistency',
                  style: context.texts.bodyMedium?.copyWith(fontSize: 18, color: AppTheme.textSub),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // 이번 주 통계
            ExerciseStats(exercises: mockExercises),
            
            const SizedBox(height: 32),
            
            // 운동 진행상황 차트
            ExerciseProgressChart(exercises: mockExercises),
            
            const SizedBox(height: 32),
            
            // 운동 기록
            WorkoutHistory(exercises: mockExercises),
          ],
        ),
      ),
    );
  }
} 