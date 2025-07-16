import 'package:flutter/material.dart';

/// BuildContext 유틸 익스텐션 – 기타 유틸리티 기능
extension AppContextX on BuildContext {
  /// 현재 Theme의 TextTheme 단축 접근자
  TextTheme get texts => Theme.of(this).textTheme;
  
  /// 화면 크기 관련 유틸리티
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
} 