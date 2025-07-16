import 'package:flutter/material.dart';
import 'package:jfit/core/theme/theme_system.dart';

/// 커스텀 탭바 - 그레이 버튼 형태로 양옆 마진 적용
class CustomTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;

  const CustomTabBar({
    super.key,
    required this.controller,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: context.colors.surface.withAlpha((255 * 0.3).round()),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.border.withAlpha((255 * 0.5).round()), width: 1),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          gradient: context.colors.gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: context.colors.primary.withAlpha((255 * 0.3).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorPadding: const EdgeInsets.all(4),
        indicatorSize: TabBarIndicatorSize.tab, // 전체 탭 영역을 채우도록 설정
        labelColor: context.colors.textPrimary,
        unselectedLabelColor: context.colors.textSecondary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        tabs: tabs.map((text) => Tab(
          child: Container(
            width: double.infinity, // 전체 너비 사용
            height: double.infinity, // 전체 높이 사용
            alignment: Alignment.center, // 텍스트 중앙 정렬
            child: Text(text),
          ),
        )).toList(),
      ),
    );
  }
} 