/// Utility class for managing responsive breakpoints and screen size detection
class BreakpointUtils {
  // Breakpoint constants
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;
  
  // Touch target sizes
  static const double minTouchTarget = 44.0;
  static const double recommendedTouchTarget = 48.0;
  
  /// Determines if the current screen width is mobile size
  static bool isMobile(double width) => width < mobileBreakpoint;
  
  /// Determines if the current screen width is tablet size
  static bool isTablet(double width) => 
      width >= mobileBreakpoint && width < tabletBreakpoint;
  
  /// Determines if the current screen width is desktop size
  static bool isDesktop(double width) => width >= tabletBreakpoint;
  
  /// Determines if the current screen width is large desktop size
  static bool isLargeDesktop(double width) => width >= desktopBreakpoint;
  
  /// Returns the device type based on screen width
  static DeviceType getDeviceType(double width) {
    if (isMobile(width)) return DeviceType.mobile;
    if (isTablet(width)) return DeviceType.tablet;
    return DeviceType.desktop;
  }
  
  /// Returns appropriate number of columns for grid layouts
  static int getGridColumns(double width) {
    if (isMobile(width)) return 1;
    if (isTablet(width)) return 2;
    if (isLargeDesktop(width)) return 4;
    return 3; // Regular desktop
  }
  
  /// Returns appropriate padding based on screen size
  static double getScreenPadding(double width) {
    if (isMobile(width)) return 16.0;
    if (isTablet(width)) return 24.0;
    return 32.0; // Desktop
  }
  
  /// Returns appropriate content max width for readability
  static double getContentMaxWidth(double width) {
    if (isMobile(width)) return double.infinity;
    if (isTablet(width)) return 768.0;
    return 1200.0; // Desktop
  }
  
  /// Returns appropriate card width for different screen sizes
  static double getCardWidth(double width) {
    if (isMobile(width)) return width - 32.0; // Full width minus padding
    if (isTablet(width)) return 320.0;
    return 280.0; // Desktop
  }
  
  /// Returns appropriate sidebar width
  static double getSidebarWidth(double width) {
    if (isMobile(width)) return width * 0.8; // 80% of screen width
    if (isTablet(width)) return 280.0;
    return 320.0; // Desktop
  }
  
  /// Determines if sidebar should be persistent (always visible)
  static bool shouldShowPersistentSidebar(double width) => isDesktop(width);
  
  /// Determines if navigation should be bottom-based
  static bool shouldUseBottomNavigation(double width) => !isDesktop(width);
  
  /// Returns appropriate font size scaling factor
  static double getFontScaleFactor(double width) {
    if (isMobile(width)) return 1.0;
    if (isTablet(width)) return 1.1;
    return 1.2; // Desktop
  }
  
  /// Returns appropriate icon size
  static double getIconSize(double width, {double baseSize = 24.0}) {
    final scaleFactor = getFontScaleFactor(width);
    return baseSize * scaleFactor;
  }
  
  /// Returns appropriate button height
  static double getButtonHeight(double width) {
    if (isMobile(width)) return 48.0;
    if (isTablet(width)) return 44.0;
    return 40.0; // Desktop
  }
  
  /// Returns appropriate app bar height
  static double getAppBarHeight(double width) {
    if (isMobile(width)) return 56.0;
    return 64.0; // Tablet and Desktop
  }
  
  /// Determines if touch-friendly spacing should be used
  static bool shouldUseTouchFriendlySpacing(double width) => 
      isMobile(width) || isTablet(width);
  
  /// Returns appropriate spacing between elements
  static double getElementSpacing(double width) {
    if (isMobile(width)) return 16.0;
    if (isTablet(width)) return 20.0;
    return 24.0; // Desktop
  }
  
  /// Returns appropriate dialog width
  static double getDialogWidth(double width) {
    if (isMobile(width)) return width * 0.9;
    if (isTablet(width)) return 480.0;
    return 560.0; // Desktop
  }
  
  /// Determines if modal should be fullscreen
  static bool shouldUseFullscreenModal(double width) => isMobile(width);
}

/// Enum representing different device types
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Extension on DeviceType for convenience methods
extension DeviceTypeExtension on DeviceType {
  bool get isMobile => this == DeviceType.mobile;
  bool get isTablet => this == DeviceType.tablet;
  bool get isDesktop => this == DeviceType.desktop;
  
  bool get isTouchDevice => isMobile || isTablet;
  bool get isPointerDevice => isDesktop;
}