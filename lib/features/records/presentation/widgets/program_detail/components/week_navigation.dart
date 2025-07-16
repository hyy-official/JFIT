import 'package:flutter/material.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/features/programs/data/models/user_program_day_model.dart';

/// 주차 네비게이션 위젯
class WeekNavigation extends StatelessWidget {
  final List<UserProgramDayModel> days;
  final int selectedWeek;
  final double horizontalPadding;
  final ValueChanged<int> onWeekSelected;

  const WeekNavigation({
    super.key,
    required this.days,
    required this.selectedWeek,
    required this.horizontalPadding,
    required this.onWeekSelected,
  });

  @override
  Widget build(BuildContext context) {
    List<int> weeks;
    if (days.isNotEmpty) {
      weeks = days.map((d) => d.week).toSet().toList();
      weeks.sort();
    } else {
      weeks = <int>[];
    }

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: weeks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final week = weeks[idx];
          return WeekTab(
            week: week,
            isSelected: week == selectedWeek,
            onTap: () => onWeekSelected(week),
          );
        },
      ),
    );
  }
}

/// 개별 주차 탭 위젯
class WeekTab extends StatefulWidget {
  final int week;
  final bool isSelected;
  final VoidCallback onTap;

  const WeekTab({
    super.key,
    required this.week,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<WeekTab> createState() => _WeekTabState();
}

class _WeekTabState extends State<WeekTab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: widget.isSelected ? context.colors.gradient : null,
            color: widget.isSelected ? null : context.colors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: widget.isSelected
                ? null
                : Border.all(
                    color: context.colors.border,
                    width: 1,
                  ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: context.colors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: widget.isSelected ? context.colors.textPrimary : context.colors.textSecondary,
              fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            child: Text('${widget.week}주차'),
          ),
            ),
          ),
        );
      },
    );
  }
}