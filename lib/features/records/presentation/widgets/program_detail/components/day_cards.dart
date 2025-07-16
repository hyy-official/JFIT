import 'package:flutter/material.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/features/programs/data/models/user_program_day_model.dart';

/// Day 카드들을 담는 위젯
class DayCards extends StatelessWidget {
  final List<UserProgramDayModel> weekDays;
  final int selectedDay;
  final double horizontalPadding;
  final Function(int, List<UserProgramDayModel>) onDaySelected;

  const DayCards({
    super.key,
    required this.weekDays,
    required this.selectedDay,
    required this.horizontalPadding,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: weekDays.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          return DayCard(
            day: weekDays[idx],
            isSelected: idx == selectedDay,
            onTap: () => onDaySelected(idx, weekDays),
          );
        },
      ),
    );
  }
}

/// 개별 Day 카드 위젯
class DayCard extends StatelessWidget {
  final UserProgramDayModel day;
  final bool isSelected;
  final VoidCallback onTap;

  const DayCard({
    super.key,
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = day.completedAt != null;
    Widget icon;
    Color? bgColor;
    Gradient? gradient;
    Color textColor;
    FontWeight fontWeight = FontWeight.normal;
    Border? border;
    List<BoxShadow>? boxShadow;

    if (isDone) {
      // 완료된 일차 - 초록색 체크 표시
      icon = Icon(Icons.check_circle, color: context.colors.textPrimary, size: 20);
      gradient = LinearGradient(
        colors: [context.colors.success, context.colors.success.withOpacity(0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      textColor = context.colors.textPrimary;
      fontWeight = FontWeight.bold;
      boxShadow = [
        BoxShadow(
          color: context.colors.success.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    } else if (isSelected) {
      // 선택된 일차 - 액센트 색상
      icon = Icon(Icons.fitness_center, color: context.colors.textPrimary, size: 20);
      gradient = context.colors.gradient;
      textColor = context.colors.textPrimary;
      fontWeight = FontWeight.bold;
      boxShadow = [
        BoxShadow(
          color: context.colors.primary.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    } else {
      // 미완료 일차 - 기본 상태
      icon = Icon(Icons.circle_outlined, color: context.colors.textMuted, size: 20);
      bgColor = context.colors.surfaceVariant;
      textColor = context.colors.textSecondary;
      border = Border.all(color: context.colors.border, width: 1);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          border: border,
          boxShadow: boxShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 4),
            Text(
              'Day ${day.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: fontWeight,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}