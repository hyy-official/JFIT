import 'package:flutter/material.dart';

/// 탄단지 비율 바 – FoodNutritionCalculatorScreen 과 동일한 디자인
class MacroRatioBar extends StatelessWidget {
  final double carbs;
  final double protein;
  final double fat;

  const MacroRatioBar({super.key, required this.carbs, required this.protein, required this.fat});

  @override
  Widget build(BuildContext context) {
    final total = carbs + protein + fat;
    if (total <= 0) {
      return const SizedBox.shrink();
    }

    final carbsRatio = carbs / total;
    final proteinRatio = protein / total;
    final fatRatio = fat / total;

    Widget ratioText(String label, double ratio, Color color) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text('$label ${(ratio * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ratioText('탄수화물', carbsRatio, const Color(0xFF6B73FF)),
            ratioText('단백질', proteinRatio, const Color(0xFFB794F6)),
            ratioText('지방', fatRatio, const Color(0xFFF687B3)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
          child: Row(children: [
            if (carbsRatio > 0)
              Expanded(
                flex: (carbsRatio * 1000).toInt(),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF6B73FF),
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
                  ),
                ),
              ),
            if (proteinRatio > 0)
              Expanded(
                flex: (proteinRatio * 1000).toInt(),
                child: Container(color: const Color(0xFFB794F6)),
              ),
            if (fatRatio > 0)
              Expanded(
                flex: (fatRatio * 1000).toInt(),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF687B3),
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                  ),
                ),
              ),
          ]),
        ),
      ],
    );
  }
} 