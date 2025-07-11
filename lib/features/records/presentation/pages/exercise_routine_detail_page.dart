import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/features/records/bloc/record_bloc.dart';
import 'package:jfit/features/records/bloc/record_event.dart';
import 'package:jfit/features/records/bloc/record_state.dart';
import 'package:jfit/features/workout_session/presentation/pages/workout_session_page.dart';
import 'package:jfit/models/exercise.dart';

class ExerciseRoutineDetailPage extends StatelessWidget {
  final UserProgram userProgram;

  const ExerciseRoutineDetailPage({
    super.key,
    required this.userProgram,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userProgram.name),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로그램 정보 헤더
            _buildProgramHeader(),
            
            // 진행 상황
            _buildProgressSection(),
            
            // 운동 목록
            _buildExerciseList(),
            
            // 운동 시작 버튼
            _buildStartWorkoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 프로그램 이미지 또는 아이콘
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: userProgram.imageUrl != null && userProgram.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          userProgram.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.fitness_center,
                              color: AppTheme.primary,
                              size: 40,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.fitness_center,
                        color: AppTheme.primary,
                        size: 40,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProgram.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userProgram.creator,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userProgram.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '진행 상황',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '현재 주차',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${userProgram.currentWeek}주차',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '현재 일차',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${userProgram.currentDay}일차',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '총 기간',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${userProgram.totalWeeks}주',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
              ),
              const SizedBox(height: 16),
          LinearProgressIndicator(
            value: userProgram.currentWeek / userProgram.totalWeeks,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
              const SizedBox(height: 8),
          Text(
            '${((userProgram.currentWeek / userProgram.totalWeeks) * 100).toStringAsFixed(0)}% 완료',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    final exercises = _getExercisesForCurrentDay();
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${userProgram.currentDay}일차 운동',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (exercises.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  '오늘은 휴식일입니다.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return _buildExerciseCard(exercise);
              },
            ),
        ],
      ),
                    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // 운동 아이콘
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
                  ),
            child: Icon(
              Icons.fitness_center,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise['name'] ?? '운동',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${exercise['sets'] ?? 0}세트 × ${exercise['reps'] ?? 0}회',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildStartWorkoutButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _startWorkout(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
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
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getExercisesForCurrentDay() {
    try {
      final exercisesJson = userProgram.exercisesJson;
      
      // exercises_json에서 현재 일차의 운동 목록 추출
      if (exercisesJson.isNotEmpty) {
        // 배열 형태의 exercises_json 처리
        if (exercisesJson is List) {
          for (var weekData in exercisesJson) {
            if (weekData['week'] == userProgram.currentWeek) {
              final days = weekData['days'] as List?;
              if (days != null) {
                for (var dayData in days) {
                  if (dayData['day'] == userProgram.currentDay) {
                    return List<Map<String, dynamic>>.from(dayData['exercises'] ?? []);
                  }
                }
              }
            }
          }
        }
        
        // 객체 형태의 exercises_json 처리
        if (exercisesJson.containsKey('exercises')) {
          return List<Map<String, dynamic>>.from(exercisesJson['exercises'] ?? []);
        }
      }
      
      // weeklySchedule에서 추출
      if (userProgram.weeklySchedule.isNotEmpty) {
        for (var weekData in userProgram.weeklySchedule) {
          if (weekData['week'] == userProgram.currentWeek) {
            final days = weekData['days'] as List?;
            if (days != null) {
              for (var dayData in days) {
                if (dayData['day'] == userProgram.currentDay) {
                  return List<Map<String, dynamic>>.from(dayData['exercises'] ?? []);
                }
              }
            }
          }
        }
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  void _startWorkout(BuildContext context) {
    final exercises = _getExercisesForCurrentDay();
    
    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오늘은 운동이 없습니다.')),
      );
      return;
    }

    // 운동 세션 시작
    context.read<RecordBloc>().add(
      StartWorkoutSession(
        userProgram.id,
        DateTime.now(),
        {
          'week': userProgram.currentWeek,
          'day': userProgram.currentDay,
          'exercises': exercises,
        },
      ),
    );

    // 운동 세션 페이지로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutSessionPage(
          userProgram: userProgram,
          exercises: exercises.map((e) => Exercise.fromJson(e)).toList(),
        ),
      ),
    );
  }
} 