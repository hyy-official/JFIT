import 'package:flutter/material.dart';
import 'package:jfit/features/records/presentation/widgets/diet_tab_content.dart';

/// meal_type 별 요약 카드
class MealTypeSummaryCard extends StatelessWidget {
  final MealTypeSummary summary;

  const MealTypeSummaryCard({super.key, required this.summary});

  String _mealTypeKorean(String type) {
    switch (type) {
      case 'breakfast':
        return '아침';
      case 'lunch':
        return '점심';
      case 'dinner':
        return '저녁';
      case 'snack':
        return '간식';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2B35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A3B45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _mealTypeKorean(summary.mealType),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text('${summary.totalCalories.toStringAsFixed(1)} kcal', style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _macroText('탄수', summary.totalCarbs),
              _macroText('단백질', summary.totalProtein),
              _macroText('지방', summary.totalFat),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroText(String label, double value) {
    return Text('$label ${value.toStringAsFixed(1)}g', style: const TextStyle(color: Colors.white60, fontSize: 12));
  }
} 