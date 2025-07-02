import 'package:flutter/material.dart';

/// BuildContext 유틸 익스텐션 – 테마에 쉽게 접근하기 위함.
extension AppContextX on BuildContext {
  /// 현재 Theme의 ColorScheme 단축 접근자
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// 현재 Theme의 TextTheme 단축 접근자
  TextTheme get texts => Theme.of(this).textTheme;
} 