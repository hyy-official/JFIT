import 'package:flutter/material.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/features/workout_session/presentation/widgets/exercise_set.dart';

class ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final int exerciseIndex;
  final VoidCallback onAddSet;
  final VoidCallback onRemove;
  final void Function(int setIndex, Map<String, dynamic> updates) onUpdateSet;
  final void Function(int setIndex) onRemoveSet;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.exerciseIndex,
    required this.onAddSet,
    required this.onRemove,
    required this.onUpdateSet,
    required this.onRemoveSet,
  });

  @override
  Widget build(BuildContext context) {
    final sets = List<Map<String, dynamic>>.from(exercise['sets'] ?? []);
    final exerciseName = exercise['exercise_name'] ?? '운동';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // 운동 번호
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: context.colors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${exerciseIndex + 1}',
                        style: TextStyle(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 운동명
                  Text(
                    exerciseName,
                    style: TextStyle(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              // 더보기 버튼
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, color: context.colors.textMuted),
                color: context.colors.surfaceVariant,
                onSelected: (value) {
                  if (value == 'delete') {
                    onRemove();
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: context.colors.error, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '운동 삭제',
                          style: TextStyle(color: context.colors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 헤더 그리드
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                // 30px: 세트 번호
                SizedBox(
                  width: 30,
                  child: Center(
                    child: Text(
                      'Set',
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 1fr: 타겟 정보
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      'Target',
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // 75px: 무게
                SizedBox(
                  width: 75,
                  child: Center(
                    child: Text(
                      'kg',
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // 75px: 횟수
                SizedBox(
                  width: 75,
                  child: Center(
                    child: Text(
                      'Reps',
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // 40px: 완료 버튼 공간
                const SizedBox(width: 40),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // 세트 목록
          Column(
            children: sets.asMap().entries.map((entry) {
              final setIndex = entry.key;
              final isActive = setIndex == _getActiveSetIndex(sets);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ExerciseSet(
                  key: ObjectKey(entry.value),
                  setData: entry.value,
                  setIndex: entry.key,
                  isActive: isActive,
                  onUpdate: (updates) => onUpdateSet(setIndex, updates),
                  onRemove: () => onRemoveSet(setIndex),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Add Set 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAddSet,
              icon: Icon(Icons.add, color: context.colors.primary, size: 18),
              label: Text(
                'ADD SET',
                style: TextStyle(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(
                  color: context.colors.primary.withOpacity(0.3),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: context.colors.primary.withOpacity(0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 다음에 수행해야 할 세트의 인덱스를 반환 (완료되지 않은 첫 번째 세트)
  int _getActiveSetIndex(List<Map<String, dynamic>> sets) {
    for (int i = 0; i < sets.length; i++) {
      if (sets[i]['completed'] != true) {
        return i;
      }
    }
    return sets.length - 1; // 모든 세트가 완료된 경우 마지막 세트
  }
} 