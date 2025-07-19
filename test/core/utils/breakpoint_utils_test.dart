import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';

void main() {
  group('BreakpointUtils', () {
    group('Device Type Detection', () {
      test('should detect mobile device correctly', () {
        expect(BreakpointUtils.isMobile(400), isTrue);
        expect(BreakpointUtils.isMobile(599), isTrue);
        expect(BreakpointUtils.isMobile(600), isFalse);
      });

      test('should detect tablet device correctly', () {
        expect(BreakpointUtils.isTablet(600), isTrue);
        expect(BreakpointUtils.isTablet(800), isTrue);
        expect(BreakpointUtils.isTablet(1023), isTrue);
        expect(BreakpointUtils.isTablet(1024), isFalse);
        expect(BreakpointUtils.isTablet(500), isFalse);
      });

      test('should detect desktop device correctly', () {
        expect(BreakpointUtils.isDesktop(1024), isTrue);
        expect(BreakpointUtils.isDesktop(1200), isTrue);
        expect(BreakpointUtils.isDesktop(1023), isFalse);
      });

      test('should return correct device type', () {
        expect(BreakpointUtils.getDeviceType(400), equals(DeviceType.mobile));
        expect(BreakpointUtils.getDeviceType(800), equals(DeviceType.tablet));
        expect(BreakpointUtils.getDeviceType(1200), equals(DeviceType.desktop));
      });
    });

    group('Grid Columns', () {
      test('should return correct grid columns for different screen sizes', () {
        expect(BreakpointUtils.getGridColumns(400), equals(1)); // Mobile
        expect(BreakpointUtils.getGridColumns(800), equals(2)); // Tablet
        expect(BreakpointUtils.getGridColumns(1200), equals(3)); // Desktop
        expect(BreakpointUtils.getGridColumns(1500), equals(4)); // Large Desktop
      });
    });

    group('Spacing and Sizing', () {
      test('should return appropriate screen padding', () {
        expect(BreakpointUtils.getScreenPadding(400), equals(16.0)); // Mobile
        expect(BreakpointUtils.getScreenPadding(800), equals(24.0)); // Tablet
        expect(BreakpointUtils.getScreenPadding(1200), equals(32.0)); // Desktop
      });

      test('should return appropriate element spacing', () {
        expect(BreakpointUtils.getElementSpacing(400), equals(16.0)); // Mobile
        expect(BreakpointUtils.getElementSpacing(800), equals(20.0)); // Tablet
        expect(BreakpointUtils.getElementSpacing(1200), equals(24.0)); // Desktop
      });

      test('should return appropriate button height', () {
        expect(BreakpointUtils.getButtonHeight(400), equals(48.0)); // Mobile
        expect(BreakpointUtils.getButtonHeight(800), equals(44.0)); // Tablet
        expect(BreakpointUtils.getButtonHeight(1200), equals(40.0)); // Desktop
      });
    });

    group('Navigation Behavior', () {
      test('should determine navigation type correctly', () {
        expect(BreakpointUtils.shouldUseBottomNavigation(400), isTrue); // Mobile
        expect(BreakpointUtils.shouldUseBottomNavigation(800), isFalse); // Tablet
        expect(BreakpointUtils.shouldUseBottomNavigation(1200), isFalse); // Desktop
      });

      test('should determine sidebar persistence correctly', () {
        expect(BreakpointUtils.shouldShowPersistentSidebar(400), isFalse); // Mobile
        expect(BreakpointUtils.shouldShowPersistentSidebar(800), isFalse); // Tablet
        expect(BreakpointUtils.shouldShowPersistentSidebar(1200), isTrue); // Desktop
      });
    });

    group('Content Sizing', () {
      test('should return appropriate content max width', () {
        expect(BreakpointUtils.getContentMaxWidth(400), equals(double.infinity)); // Mobile
        expect(BreakpointUtils.getContentMaxWidth(800), equals(768.0)); // Tablet
        expect(BreakpointUtils.getContentMaxWidth(1200), equals(1200.0)); // Desktop
      });

      test('should return appropriate card width', () {
        final mobileWidth = 400.0;
        final tabletWidth = 800.0;
        final desktopWidth = 1200.0;
        
        expect(BreakpointUtils.getCardWidth(mobileWidth), equals(mobileWidth - 32.0)); // Mobile
        expect(BreakpointUtils.getCardWidth(tabletWidth), equals(320.0)); // Tablet
        expect(BreakpointUtils.getCardWidth(desktopWidth), equals(280.0)); // Desktop
      });
    });

    group('Font and Icon Scaling', () {
      test('should return appropriate font scale factor', () {
        expect(BreakpointUtils.getFontScaleFactor(400), equals(1.0)); // Mobile
        expect(BreakpointUtils.getFontScaleFactor(800), equals(1.1)); // Tablet
        expect(BreakpointUtils.getFontScaleFactor(1200), equals(1.2)); // Desktop
      });

      test('should return appropriate icon size', () {
        const baseSize = 24.0;
        expect(BreakpointUtils.getIconSize(400, baseSize: baseSize), equals(24.0)); // Mobile
        expect(BreakpointUtils.getIconSize(800, baseSize: baseSize), closeTo(26.4, 0.01)); // Tablet
        expect(BreakpointUtils.getIconSize(1200, baseSize: baseSize), closeTo(28.8, 0.01)); // Desktop
      });
    });

    group('Touch Interaction', () {
      test('should determine touch-friendly spacing correctly', () {
        expect(BreakpointUtils.shouldUseTouchFriendlySpacing(400), isTrue); // Mobile
        expect(BreakpointUtils.shouldUseTouchFriendlySpacing(800), isTrue); // Tablet
        expect(BreakpointUtils.shouldUseTouchFriendlySpacing(1200), isFalse); // Desktop
      });

      test('should determine fullscreen modal usage correctly', () {
        expect(BreakpointUtils.shouldUseFullscreenModal(400), isTrue); // Mobile
        expect(BreakpointUtils.shouldUseFullscreenModal(800), isFalse); // Tablet
        expect(BreakpointUtils.shouldUseFullscreenModal(1200), isFalse); // Desktop
      });
    });
  });

  group('DeviceType Extension', () {
    test('should provide correct convenience methods', () {
      expect(DeviceType.mobile.isMobile, isTrue);
      expect(DeviceType.mobile.isTablet, isFalse);
      expect(DeviceType.mobile.isDesktop, isFalse);
      expect(DeviceType.mobile.isTouchDevice, isTrue);
      expect(DeviceType.mobile.isPointerDevice, isFalse);

      expect(DeviceType.tablet.isMobile, isFalse);
      expect(DeviceType.tablet.isTablet, isTrue);
      expect(DeviceType.tablet.isDesktop, isFalse);
      expect(DeviceType.tablet.isTouchDevice, isTrue);
      expect(DeviceType.tablet.isPointerDevice, isFalse);

      expect(DeviceType.desktop.isMobile, isFalse);
      expect(DeviceType.desktop.isTablet, isFalse);
      expect(DeviceType.desktop.isDesktop, isTrue);
      expect(DeviceType.desktop.isTouchDevice, isFalse);
      expect(DeviceType.desktop.isPointerDevice, isTrue);
    });
  });
}