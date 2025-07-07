import 'package:flutter/material.dart';

/// 화면 너비 기준 디바이스 타입 구분 및 편의 메서드들.
/// 데스크톱 ≥ 1024, 태블릿 ≥ 768, 모바일 < 768 로 구분합니다.
/// 필요 시 상수값을 조정해 일관된 반응형 기준을 유지하세요.
enum DeviceType { mobile, tablet, desktop }

class ResponsiveUtil {
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;

  static DeviceType deviceTypeOf(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) return DeviceType.desktop;
    if (width >= tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static bool isMobile(BuildContext context) => deviceTypeOf(context) == DeviceType.mobile;
  static bool isTablet(BuildContext context) => deviceTypeOf(context) == DeviceType.tablet;
  static bool isDesktop(BuildContext context) => deviceTypeOf(context) == DeviceType.desktop;
}

extension ResponsiveContextX on BuildContext {
  DeviceType get deviceType => ResponsiveUtil.deviceTypeOf(this);
  bool get isMobile => ResponsiveUtil.isMobile(this);
  bool get isTablet => ResponsiveUtil.isTablet(this);
  bool get isDesktop => ResponsiveUtil.isDesktop(this);
} 