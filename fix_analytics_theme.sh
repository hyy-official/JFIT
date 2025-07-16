#!/bin/bash

# AnalyticsChartTheme 참조를 새로운 테마 시스템으로 일괄 변경하는 스크립트

echo "AnalyticsChartTheme 참조들을 새로운 테마 시스템으로 마이그레이션 중..."

# 주요 AnalyticsChartTheme 참조들을 context.colors로 변경
find lib -name "*.dart" -type f -exec sed -i '' \
  -e 's/AnalyticsChartTheme\.cardTitleStyle/TextStyle(color: context.colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)/g' \
  -e 's/AnalyticsChartTheme\.cardSubtitleStyle/TextStyle(color: context.colors.textSecondary, fontSize: 14)/g' \
  -e 's/AnalyticsChartTheme\.axisLabelStyle/TextStyle(color: context.colors.textSecondary, fontSize: 12)/g' \
  -e 's/AnalyticsChartTheme\.tooltipTextStyle/TextStyle(color: context.colors.textPrimary, fontSize: 12)/g' \
  -e 's/AnalyticsChartTheme\.tooltipBackground/context.colors.surface/g' \
  -e 's/AnalyticsChartTheme\.scoreBarGradient/context.colors.primary/g' \
  -e 's/AnalyticsChartTheme\.nutritionDataColors\[0\]/context.colors.primary/g' \
  -e 's/AnalyticsChartTheme\.nutritionDataColors\[1\]/context.colors.secondary/g' \
  -e 's/AnalyticsChartTheme\.nutritionDataColors\[2\]/context.colors.accent/g' \
  -e 's/AnalyticsChartTheme\.workoutDataColors\[0\]/context.colors.primary/g' \
  -e 's/AnalyticsChartTheme\.workoutDataColors\[1\]/context.colors.secondary/g' \
  -e 's/AnalyticsChartTheme\.workoutDataColors\[2\]/context.colors.accent/g' \
  -e 's/AnalyticsChartTheme\.bodyDataColors\[0\]/context.colors.primary/g' \
  -e 's/AnalyticsChartTheme\.bodyDataColors\[1\]/context.colors.secondary/g' \
  -e 's/AnalyticsChartTheme\.bodyDataColors\[2\]/context.colors.accent/g' \
  -e 's/AnalyticsChartTheme\.primaryColor/context.colors.primary/g' \
  -e 's/AnalyticsChartTheme\.secondaryColor/context.colors.secondary/g' \
  -e 's/AnalyticsChartTheme\.accentColor/context.colors.accent/g' \
  -e 's/AnalyticsChartTheme\.backgroundColor/context.colors.background/g' \
  -e 's/AnalyticsChartTheme\.surfaceColor/context.colors.surface/g' \
  -e 's/AnalyticsChartTheme\.textColor/context.colors.textPrimary/g' \
  -e 's/AnalyticsChartTheme\.mutedTextColor/context.colors.textMuted/g' \
  {} \;

# import 문 변경
find lib -name "*.dart" -type f -exec sed -i '' \
  -e "s|import 'package:jfit/core/theme/analytics_chart_theme.dart';|import 'package:jfit/core/theme/theme_system.dart';|g" \
  {} \;

echo "AnalyticsChartTheme 마이그레이션 완료!"
echo "변경된 파일들을 확인하고 필요시 수동으로 조정해주세요."