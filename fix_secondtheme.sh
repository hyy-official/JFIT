#!/bin/bash

# SecondTheme 참조를 새로운 테마 시스템으로 일괄 변경하는 스크립트

echo "SecondTheme 참조들을 새로운 테마 시스템으로 마이그레이션 중..."

# 주요 SecondTheme 참조들을 context.colors로 변경
find lib -name "*.dart" -type f -exec sed -i '' \
  -e 's/SecondTheme\.bgPrimary/context.colors.background/g' \
  -e 's/SecondTheme\.bgSecondary/context.colors.surface/g' \
  -e 's/SecondTheme\.bgTertiary/context.colors.surfaceVariant/g' \
  -e 's/SecondTheme\.border/context.colors.border/g' \
  -e 's/SecondTheme\.textPrimary/context.colors.textPrimary/g' \
  -e 's/SecondTheme\.textSecondary/context.colors.textSecondary/g' \
  -e 's/SecondTheme\.textMuted/context.colors.textMuted/g' \
  -e 's/SecondTheme\.primary/context.colors.primary/g' \
  -e 's/SecondTheme\.secondary/context.colors.secondary/g' \
  -e 's/SecondTheme\.success/context.colors.success/g' \
  -e 's/SecondTheme\.warning/context.colors.warning/g' \
  -e 's/SecondTheme\.error/context.colors.error/g' \
  -e 's/SecondTheme\.accent/context.colors.accent/g' \
  {} \;

# import 문 변경
find lib -name "*.dart" -type f -exec sed -i '' \
  -e "s|import 'package:jfit/core/theme/second_theme.dart';|import 'package:jfit/core/theme/theme_system.dart';|g" \
  {} \;

echo "SecondTheme 마이그레이션 완료!"
echo "변경된 파일들을 확인하고 필요시 수동으로 조정해주세요."