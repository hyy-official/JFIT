import 'package:flutter/material.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/features/records/presentation/widgets/swipeable_week_view.dart';

/// 주간 캘린더 – 요일 고정, 무한 스와이프 지원
class WeeklyCalendar extends StatelessWidget {
  final DateTime baseDate; // 오늘 포함 날짜 (주 시작 계산)
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;

  const WeeklyCalendar({
    super.key,
    required this.baseDate,
    required this.selectedDate,
    required this.onSelect,
    required this.onPrevWeek,
    required this.onNextWeek,
  });

  // 주의 시작일 계산 (일요일 기준)
  DateTime _getStartOfWeek(DateTime date) {
    final weekday = date.weekday;
    final daysFromSunday = weekday == 7 ? 0 : weekday;
    return date.subtract(Duration(days: daysFromSunday));
  }

  @override
  Widget build(BuildContext context) {
    // 현재 주간 데이터 계산 (실시간)
    final startOfWeek = _getStartOfWeek(selectedDate);
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    const dayNames = ['일', '월', '화', '수', '목', '금', '토'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 700;

        Widget buildDayButton(DateTime day) {
          final isSelected = day.year == selectedDate.year && 
                           day.month == selectedDate.month && 
                           day.day == selectedDate.day;
          final isToday = day.year == DateTime.now().year && 
                         day.month == DateTime.now().month && 
                         day.day == DateTime.now().day;

          return GestureDetector(
            onTap: () => onSelect(day),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? null : Colors.transparent,
                    gradient: isSelected ? context.colors.gradient : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: context.colors.primary.withAlpha((255 * 0.4).round()),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: isSelected
                            ? context.colors.textPrimary
                            : isToday
                                ? context.colors.primary
                                : context.colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (isDesktop) {
          // 데스크톱: 좌우 버튼 고려한 정렬
          return Container(
            padding: EdgeInsets.symmetric(horizontal: _horizontalPadding(context)),
            child: Column(
              children: [
                // 고정된 요일 헤더 (버튼 공간 고려)
                Row(
                  children: [
                    SizedBox(width: 48), // 좌측 버튼 공간
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: dayNames.map((dayName) => Expanded(
                          child: Center(
                            child: Text(
                              dayName,
                              style: TextStyle(
                                color: context.colors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                    SizedBox(width: 48), // 우측 버튼 공간
                  ],
                ),
                const SizedBox(height: 12),
                // 날짜 버튼들
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, color: context.colors.textSecondary, size: 20),
                      splashRadius: 16,
                      onPressed: onPrevWeek,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: days.map((day) => Expanded(
                          child: Center(child: buildDayButton(day)),
                        )).toList(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right, color: context.colors.textSecondary, size: 20),
                      splashRadius: 16,
                      onPressed: onNextWeek,
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          // 모바일: 스와이프 가능한 애니메이션 버전
          return Container(
            padding: EdgeInsets.symmetric(horizontal: _horizontalPadding(context)),
            child: Column(
              children: [
                // 고정된 요일 헤더
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: dayNames.map((dayName) => Expanded(
                    child: Center(
                      child: Text(
                        dayName,
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 12),
                // 스와이프 가능한 애니메이션 날짜 영역
                SizedBox(
                  height: 40,
                  child: SwipeableWeekView(
                    days: days,
                    buildDayButton: buildDayButton,
                    onPrevWeek: onPrevWeek,
                    onNextWeek: onNextWeek,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  double _horizontalPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1024) return 24;
    if (w >= 768) return 20;
    return 16;
  }
} 