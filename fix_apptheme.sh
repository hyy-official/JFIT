#!/bin/bash

# AppTheme 참조를 새로운 테마 시스템으로 일괄 변경하는 스크립트

echo "AppTheme 참조들을 새로운 테마 시스템으로 마이그레이션 중..."

# 주요 AppTheme 참조들을 context.colors로 변경
find lib -name "*.dart" -type f -exec sed -i '' \
  -e 's/AppTheme\.accent1/context.colors.primary/g' \
  -e 's/AppTheme\.accent2/context.colors.secondary/g' \
  -e 's/AppTheme\.textSub/context.colors.textSecondary/g' \
  -e 's/AppTheme\.textMuted/context.colors.textMuted/g' \
  -e 's/AppTheme\.programBackground/context.colors.background/g' \
  -e 's/AppTheme\.programCardBackground/context.colors.surface/g' \
  -e 's/AppTheme\.programAccentBlue/context.colors.primary/g' \
  -e 's/AppTheme\.accentGradient/LinearGradient(colors: [context.colors.primary, context.colors.secondary])/g' \
  -e 's/AppTheme\.surface1/context.colors.surface/g' \
  -e 's/AppTheme\.surface2/context.colors.surfaceVariant/g' \
  -e 's/AppTheme\.bgPrimary/context.colors.background/g' \
  -e 's/AppTheme\.bgSecondary/context.colors.surface/g' \
  -e 's/AppTheme\.bgTertiary/context.colors.surfaceVariant/g' \
  -e 's/AppTheme\.border/context.colors.border/g' \
  -e 's/AppTheme\.textPrimary/context.colors.textPrimary/g' \
  -e 's/AppTheme\.textSecondary/context.colors.textSecondary/g' \
  -e 's/AppTheme\.primary/context.colors.primary/g' \
  -e 's/AppTheme\.secondary/context.colors.secondary/g' \
  -e 's/AppTheme\.success/context.colors.success/g' \
  -e 's/AppTheme\.warning/context.colors.warning/g' \
  -e 's/AppTheme\.error/context.colors.error/g' \
  {} \;

# import 문 변경
find lib -name "*.dart" -type f -exec sed -i '' \
  -e "s|import 'package:jfit/core/theme/app_theme.dart';|import 'package:jfit/core/theme/theme_system.dart';|g" \
  {} \;

echo "AppTheme 마이그레이션 완료!"
echo "변경된 파일들을 확인하고 필요시 수동으로 조정해주세요."