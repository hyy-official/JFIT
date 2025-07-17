import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/l10n/app_localizations.dart';
import 'package:jfit/features/exercise/presentation/widgets/exercise_stats.dart';
import 'package:jfit/features/exercise/presentation/widgets/exercise_progress_chart.dart';
import 'package:jfit/features/exercise/presentation/widgets/workout_history.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/features/exercise/bloc/exercise_bloc.dart';
import 'package:jfit/features/exercise/bloc/exercise_event.dart';
import 'package:jfit/features/exercise/bloc/exercise_state.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  @override
  void initState() {
    super.initState();
    // Load exercise data - using search with empty query to get all exercises
    context.read<ExerciseBloc>().add(const SearchExercises(query: ''));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return BlocBuilder<ExerciseBloc, ExerciseState>(
      builder: (context, state) {
        if (state is ExerciseLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ExerciseSearchResults) {
          final exercises = state.exercises;
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
                        backgroundColor: context.colors.primary,
                        child: Icon(Icons.fitness_center, color: context.colors.textPrimary),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n?.appTitle ?? 'JFIT', 
                        style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 20, color: context.colors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.workoutManager ?? 'Workout Manager',
                        style: context.textTheme.headlineLarge?.copyWith(fontSize: 36, color: context.colors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n?.trackFitnessJourney ?? 'Track your fitness journey and build consistency',
                        style: context.textTheme.bodyMedium?.copyWith(fontSize: 18, color: context.colors.textSecondary),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 이번 주 통계
                  ExerciseStats(exercises: exercises),
                  
                  const SizedBox(height: 32),
                  
                  // 운동 진행상황 차트
                  ExerciseProgressChart(exercises: exercises),
                  
                  const SizedBox(height: 32),
                  
                  // 운동 기록
                  WorkoutHistory(exercises: exercises),
                ],
              ),
            ),
          );
        } else if (state is ExerciseError) {
          return Center(child: Text('Error: ${state.message}', style: TextStyle(color: context.colors.error)));
        }
        return Center(child: Text('Unknown state', style: TextStyle(color: context.colors.textPrimary)));
      },
    );
  }
} 