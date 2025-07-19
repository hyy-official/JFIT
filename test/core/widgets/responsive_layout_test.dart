import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/core/widgets/responsive_layout.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';

void main() {
  group('ResponsiveLayout', () {
    testWidgets('should show mobile layout on small screens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: const Text('Mobile'),
              tablet: const Text('Tablet'),
              desktop: const Text('Desktop'),
            ),
          ),
        ),
      );

      // Set screen size to mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('should show tablet layout on medium screens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: const Text('Mobile'),
              tablet: const Text('Tablet'),
              desktop: const Text('Desktop'),
            ),
          ),
        ),
      );

      // Set screen size to tablet
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpAndSettle();

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('should show desktop layout on large screens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: const Text('Mobile'),
              tablet: const Text('Tablet'),
              desktop: const Text('Desktop'),
            ),
          ),
        ),
      );

      // Set screen size to desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpAndSettle();

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsOneWidget);
    });

    testWidgets('should fallback to mobile when tablet/desktop not provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: const Text('Mobile'),
            ),
          ),
        ),
      );

      // Test tablet size
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpAndSettle();
      expect(find.text('Mobile'), findsOneWidget);

      // Test desktop size
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpAndSettle();
      expect(find.text('Mobile'), findsOneWidget);
    });
  });

  group('ResponsiveBuilder', () {
    testWidgets('should provide correct device type and screen size', (tester) async {
      DeviceType? capturedDeviceType;
      Size? capturedScreenSize;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveBuilder(
              builder: (context, deviceType, screenSize) {
                capturedDeviceType = deviceType;
                capturedScreenSize = screenSize;
                return Text('Device: ${deviceType.name}');
              },
            ),
          ),
        ),
      );

      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();
      
      expect(capturedDeviceType, equals(DeviceType.mobile));
      expect(capturedScreenSize?.width, equals(400));
      expect(find.text('Device: mobile'), findsOneWidget);

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpAndSettle();
      
      expect(capturedDeviceType, equals(DeviceType.tablet));
      expect(capturedScreenSize?.width, equals(800));
      expect(find.text('Device: tablet'), findsOneWidget);

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpAndSettle();
      
      expect(capturedDeviceType, equals(DeviceType.desktop));
      expect(capturedScreenSize?.width, equals(1200));
      expect(find.text('Device: desktop'), findsOneWidget);
    });
  });

  group('ResponsiveContainer', () {
    testWidgets('should apply correct padding based on screen size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveContainer(
              mobilePadding: const EdgeInsets.all(16),
              tabletPadding: const EdgeInsets.all(24),
              desktopPadding: const EdgeInsets.all(32),
              child: const Text('Content'),
            ),
          ),
        ),
      );

      // Test mobile padding
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();
      
      final mobilePadding = tester.widget<Padding>(find.byType(Padding));
      expect(mobilePadding.padding, equals(const EdgeInsets.all(16)));

      // Test tablet padding
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpAndSettle();
      
      final tabletPadding = tester.widget<Padding>(find.byType(Padding));
      expect(tabletPadding.padding, equals(const EdgeInsets.all(24)));

      // Test desktop padding
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpAndSettle();
      
      final desktopPadding = tester.widget<Padding>(find.byType(Padding));
      expect(desktopPadding.padding, equals(const EdgeInsets.all(32)));
    });
  });

  group('ResponsiveSpacing', () {
    testWidgets('should create spacing widgets correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Before'),
                ResponsiveSpacing.vertical(
                  mobileSpacing: 16,
                  tabletSpacing: 24,
                  desktopSpacing: 32,
                ),
                const Text('After'),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Verify that a SizedBox is created for spacing
      expect(find.byType(SizedBox), findsOneWidget);
      
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.height, isNotNull);
      expect(sizedBox.width, isNull);
    });

    testWidgets('should create horizontal spacing widgets correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                const Text('Before'),
                ResponsiveSpacing.horizontal(
                  mobileSpacing: 8,
                  tabletSpacing: 12,
                  desktopSpacing: 16,
                ),
                const Text('After'),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Verify that a SizedBox is created for horizontal spacing
      expect(find.byType(SizedBox), findsOneWidget);
      
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, isNotNull);
      expect(sizedBox.height, isNull);
    });
  });

  group('ResponsiveText', () {
    testWidgets('should scale text based on screen size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveText(
              'Test Text',
              style: const TextStyle(fontSize: 16),
              mobileScaleFactor: 1.0,
              tabletScaleFactor: 1.2,
              desktopScaleFactor: 1.4,
            ),
          ),
        ),
      );

      // Test mobile text scaling
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();
      
      final mobileText = tester.widget<Text>(find.byType(Text));
      expect(mobileText.style?.fontSize, equals(16.0));

      // Test tablet text scaling
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpAndSettle();
      
      final tabletText = tester.widget<Text>(find.byType(Text));
      expect(tabletText.style?.fontSize, closeTo(19.2, 0.01));

      // Test desktop text scaling
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpAndSettle();
      
      final desktopText = tester.widget<Text>(find.byType(Text));
      expect(desktopText.style?.fontSize, closeTo(22.4, 0.01));
    });
  });
}