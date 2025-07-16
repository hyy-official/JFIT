import 'package:flutter/material.dart';
import 'package:jfit/core/theme/theme_system.dart';

class ExerciseEmptyState extends StatelessWidget {
  const ExerciseEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('내 루틴', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.colors.textPrimary)),
          const SizedBox(height: 16),
          Text('+ 새 루틴', style: TextStyle(fontSize: 16, color: context.colors.textSecondary)),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text('자유운동 시작', style: TextStyle(fontSize: 16, color: context.colors.onPrimary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
} 