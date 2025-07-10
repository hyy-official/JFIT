import 'package:flutter/material.dart';

/// 무한 스와이프 가능한 주간 뷰 위젯 (PageView 기반)
class SwipeableWeekView extends StatefulWidget {
  final List<DateTime> days;
  final Widget Function(DateTime) buildDayButton;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;

  const SwipeableWeekView({
    super.key,
    required this.days,
    required this.buildDayButton,
    required this.onPrevWeek,
    required this.onNextWeek,
  });

  @override
  State<SwipeableWeekView> createState() => _SwipeableWeekViewState();
}

class _SwipeableWeekViewState extends State<SwipeableWeekView> {
  late PageController _pageController;
  static const int _initialPage = 1000; // 중간 지점에서 시작
  int _currentPage = _initialPage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 페이지 인덱스를 기반으로 주간 데이터 생성
  List<DateTime> _getWeekDaysForPage(int pageIndex) {
    final weekOffset = pageIndex - _initialPage;
    final baseWeekStart = widget.days.first; // 현재 주의 시작일
    final targetWeekStart = baseWeekStart.add(Duration(days: weekOffset * 7));
    return List.generate(7, (i) => targetWeekStart.add(Duration(days: i)));
  }

  void _onPageChanged(int page) {
    final weekOffset = page - _currentPage;
    _currentPage = page;
    
    if (weekOffset > 0) {
      // 다음 주로 이동
      for (int i = 0; i < weekOffset; i++) {
        widget.onNextWeek();
      }
    } else if (weekOffset < 0) {
      // 이전 주로 이동
      for (int i = 0; i < -weekOffset; i++) {
        widget.onPrevWeek();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, index) {
        final weekDays = _getWeekDaysForPage(index);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: weekDays.map((day) => Expanded(
            child: Center(child: widget.buildDayButton(day)),
          )).toList(),
        );
      },
    );
  }
} 