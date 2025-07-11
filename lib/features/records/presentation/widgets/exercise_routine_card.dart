import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/features/records/bloc/record_state.dart';
import 'package:jfit/features/records/presentation/widgets/exercise_day_selector.dart';

class ExerciseRoutineCard extends StatelessWidget {
  final UserProgram userProgram;
  final DateTime selectedDate;
  final VoidCallback onTap;

  const ExerciseRoutineCard({
    super.key,
    required this.userProgram,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 프로그램 이미지 또는 아이콘
                  Container(
                    width: 60,
                    height: 60,
        decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
        ),
                    child: userProgram.imageUrl != null && userProgram.imageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              userProgram.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.fitness_center,
                                  color: AppTheme.primary,
                                  size: 32,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.fitness_center,
                            color: AppTheme.primary,
                            size: 32,
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  const SizedBox(height: 4),
                        Text(
                          userProgram.creator,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                  const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(userProgram.difficulty),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getDifficultyText(userProgram.difficulty),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getProgramTypeText(userProgram.programType),
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                ],
              ),
                      ],
                    ),
                  ),
                ],
            ),
              const SizedBox(height: 16),
              
              // 진행 상황
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${userProgram.currentWeek}주차 ${userProgram.currentDay}일차',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${userProgram.totalWeeks}주 프로그램',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 진행률 바
              LinearProgressIndicator(
                value: userProgram.currentWeek / userProgram.totalWeeks,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
              
              const SizedBox(height: 16),
              
              // 일차 선택기
              ExerciseDaySelector(
                userProgram: userProgram,
                selectedDate: selectedDate,
            ),
          ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return '초급';
      case 'intermediate':
        return '중급';
      case 'advanced':
        return '고급';
      default:
        return '기타';
    }
  }

  String _getProgramTypeText(String programType) {
    switch (programType.toLowerCase()) {
      case 'strength':
        return '근력';
      case 'hypertrophy':
        return '근비대';
      case 'powerlifting':
        return '파워리프팅';
      case 'bodybuilding':
        return '보디빌딩';
      case 'cardio':
        return '유산소';
      default:
        return '기타';
    }
  }
} 