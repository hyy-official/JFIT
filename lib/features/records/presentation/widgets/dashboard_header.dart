import 'package:flutter/material.dart';
import 'package:jfit/features/analytics/presentation/pages/analytics_page.dart';
import 'package:jfit/core/theme/theme_system.dart';

/// 대시보드 헤더 (년/월, 이동 버튼, 액션 아이콘)
class DashboardHeader extends StatelessWidget {
  final DateTime date;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  
  const DashboardHeader({
    super.key,
    required this.date,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    final monthText = '${date.year}년 ${date.month}월';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 햄버거 메뉴 (옵션)

        // 이전 달 버튼
        IconButton(
          icon: Icon(Icons.keyboard_double_arrow_left, color: context.colors.textPrimary),
          splashRadius: 20,
          onPressed: onPrevMonth,
        ),

        // 현재 월 텍스트
        Text(
          monthText,
          style: context.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.normal, 
            fontSize: 20, 
            color: context.colors.textPrimary,
          ),
        ),

        // 다음 달 버튼
        IconButton(
          icon: Icon(Icons.keyboard_double_arrow_right, color: context.colors.textPrimary),
          splashRadius: 20,
          onPressed: onNextMonth,
        ),

        const Spacer(),

        // 액션 아이콘들
        IconButton(
          icon: Icon(Icons.bar_chart, color: context.colors.textPrimary),
          onPressed: () {
            // 중앙 Navigator 에서만 페이지를 푸시하여 좌우 패널을 유지합니다.
            Navigator.of(context).pushNamed(AnalyticsPage.routeName);
          },
          splashRadius: 20,
        ),
        IconButton(
          icon: Icon(Icons.notifications_none, color: context.colors.textPrimary),
          splashRadius: 20,
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.list, color: context.colors.textPrimary),
          onPressed: () {},
          splashRadius: 20,
        ),
        IconButton(
          icon: Icon(Icons.palette, color: context.colors.textPrimary),
          onPressed: () {},
          splashRadius: 20,
        ),
      ],
    );
  }
} 