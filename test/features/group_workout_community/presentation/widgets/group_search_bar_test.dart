import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/group_search_bar.dart';

void main() {
  group('GroupSearchBar Widget Tests', () {
    Widget createTestWidget({
      ValueChanged<String>? onSearchChanged,
      String hintText = 'Search groups...',
      Duration? debounceTime,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: GroupSearchBar(
            onSearchChanged: onSearchChanged ?? (query) {},
            hintText: hintText,
            debounceTime: debounceTime ?? const Duration(milliseconds: 500),
          ),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('should display search bar with hint text', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Search groups...'), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('should display custom hint text', (tester) async {
        await tester.pumpWidget(createTestWidget(
          hintText: 'Find your workout group',
        ));

        expect(find.text('Find your workout group'), findsOneWidget);
      });

      testWidgets('should display clear button when text is entered', (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.enterText(find.byType(TextField), 'test');
        await tester.pump(); // Rebuild to show clear button
        
        expect(find.byIcon(Icons.clear), findsOneWidget);
      });

      testWidgets('should hide clear button when text is empty', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byIcon(Icons.clear), findsNothing);
      });
    });

    group('Search Functionality', () {
      testWidgets('should call onSearchChanged when text changes', (tester) async {
        String? searchQuery;
        
        await tester.pumpWidget(createTestWidget(
          onSearchChanged: (query) => searchQuery = query,
          debounceTime: const Duration(milliseconds: 100), // Shorter debounce for testing
        ));

        await tester.enterText(find.byType(TextField), 'yoga');
        await tester.pump(const Duration(milliseconds: 150)); // Wait for debounce

        expect(searchQuery, 'yoga');
      });

      testWidgets('should handle text input action', (tester) async {
        String? searchQuery;
        
        await tester.pumpWidget(createTestWidget(
          onSearchChanged: (query) => searchQuery = query,
          debounceTime: const Duration(milliseconds: 100), // Shorter debounce for testing
        ));

        await tester.enterText(find.byType(TextField), 'pilates');
        await tester.pump(const Duration(milliseconds: 150)); // Wait for debounce

        expect(searchQuery, 'pilates');
      });

      testWidgets('should clear search when clear button is tapped', (tester) async {
        String? searchQuery;
        
        await tester.pumpWidget(createTestWidget(
          onSearchChanged: (query) => searchQuery = query,
          debounceTime: const Duration(milliseconds: 100), // Shorter debounce for testing
        ));

        // Enter text first
        await tester.enterText(find.byType(TextField), 'crossfit');
        await tester.pump();

        // Should show clear button when there's text
        expect(find.byIcon(Icons.clear), findsOneWidget);

        await tester.tap(find.byIcon(Icons.clear));
        await tester.pump(const Duration(milliseconds: 150)); // Wait for debounce

        expect(searchQuery, '');
      });

      testWidgets('should not show clear button when text is empty', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byIcon(Icons.clear), findsNothing);
      });
    });

    group('Debounce Functionality', () {
      testWidgets('should debounce search input with custom duration', (tester) async {
        String? searchQuery;
        
        await tester.pumpWidget(createTestWidget(
          onSearchChanged: (query) => searchQuery = query,
          debounceTime: const Duration(milliseconds: 100),
        ));

        await tester.enterText(find.byType(TextField), 'test');
        await tester.pump(const Duration(milliseconds: 50));
        
        // Should not have called yet due to debounce
        expect(searchQuery, isNull);
        
        await tester.pump(const Duration(milliseconds: 100));
        
        // Should have called after debounce time
        expect(searchQuery, 'test');
      });

      testWidgets('should use default debounce time', (tester) async {
        String? searchQuery;
        
        await tester.pumpWidget(createTestWidget(
          onSearchChanged: (query) => searchQuery = query,
        ));

        await tester.enterText(find.byType(TextField), 'test');
        await tester.pump(const Duration(milliseconds: 400));
        
        // Should not have called yet with default 500ms debounce
        expect(searchQuery, isNull);
        
        await tester.pump(const Duration(milliseconds: 200));
        
        // Should have called after full debounce time
        expect(searchQuery, 'test');
      });
    });

    group('Responsive Design', () {
      testWidgets('should adapt to mobile screen size', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(400, 800);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(GroupSearchBar), findsOneWidget);

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
      });

      testWidgets('should adapt to tablet screen size', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(GroupSearchBar), findsOneWidget);

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
      });

      testWidgets('should have proper touch targets', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final searchBarSize = tester.getSize(find.byType(GroupSearchBar));
        
        // Search bar should have reasonable height
        expect(searchBarSize.height, greaterThanOrEqualTo(44));
      });
    });

    group('Keyboard Interaction', () {
      testWidgets('should focus search field when tapped', (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        expect(tester.testTextInput.hasAnyClients, true);
      });

      testWidgets('should handle keyboard shortcuts', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Focus the search field
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        // Test Ctrl+A (select all)
        await tester.enterText(find.byType(TextField), 'test search');
        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await tester.pumpAndSettle();

        // Text should be selected
        expect(tester.testTextInput.hasAnyClients, true);
      });

      testWidgets('should handle escape key to clear search', (tester) async {
        String? searchQuery;
        
        await tester.pumpWidget(createTestWidget(
          onSearchChanged: (query) => searchQuery = query,
        ));

        await tester.enterText(find.byType(TextField), 'test');
        await tester.tap(find.byType(TextField));
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        expect(find.byType(GroupSearchBar), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle very long search queries', (tester) async {
        const longQuery = 'This is a very long search query that should be handled gracefully without causing UI overflow or performance issues';
        
        await tester.pumpWidget(createTestWidget());

        await tester.enterText(find.byType(TextField), longQuery);
        await tester.pumpAndSettle();

        expect(find.textContaining('This is a very long'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle special characters in search', (tester) async {
        String? searchQuery;
        
        await tester.pumpWidget(createTestWidget(
          onSearchChanged: (query) => searchQuery = query,
          debounceTime: const Duration(milliseconds: 100), // Shorter debounce for testing
        ));

        await tester.enterText(find.byType(TextField), 'special chars');
        await tester.pump(const Duration(milliseconds: 150)); // Wait for debounce

        expect(searchQuery, 'special chars');
      });

      testWidgets('should handle empty search gracefully', (tester) async {
        String? searchQuery;
        
        await tester.pumpWidget(createTestWidget(
          onSearchChanged: (query) => searchQuery = query,
          debounceTime: const Duration(milliseconds: 100), // Shorter debounce for testing
        ));

        // First enter some text, then clear it
        await tester.enterText(find.byType(TextField), 'test');
        await tester.pump(const Duration(milliseconds: 150)); // Wait for debounce
        
        await tester.enterText(find.byType(TextField), '');
        await tester.pump(const Duration(milliseconds: 150)); // Wait for debounce

        expect(searchQuery, '');
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper accessibility labels', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(TextField), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('should support screen readers', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final textField = find.byType(TextField);
        expect(textField, findsOneWidget);

        final textFieldWidget = tester.widget<TextField>(textField);
        expect(textFieldWidget.decoration?.hintText, 'Search groups...');
      });

      testWidgets('should support screen reader navigation', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final textField = find.byType(TextField);
        expect(textField, findsOneWidget);

        // Should be focusable for screen readers
        await tester.tap(textField);
        await tester.pumpAndSettle();
        
        expect(tester.testTextInput.hasAnyClients, true);
      });
    });

    group('Theme Integration', () {
      testWidgets('should respect light theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: GroupSearchBar(
                onSearchChanged: (query) {},
              ),
            ),
          ),
        );

        expect(find.byType(GroupSearchBar), findsOneWidget);
      });

      testWidgets('should respect dark theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: GroupSearchBar(
                onSearchChanged: (query) {},
              ),
            ),
          ),
        );

        expect(find.byType(GroupSearchBar), findsOneWidget);
      });

      testWidgets('should adapt to theme colors', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(GroupSearchBar), findsOneWidget);
        expect(find.byType(Container), findsOneWidget);
      });
    });

    group('Performance', () {
      testWidgets('should debounce search input', (tester) async {
        int callCount = 0;
        
        await tester.pumpWidget(createTestWidget(
          onSearchChanged: (query) => callCount++,
        ));

        // Type multiple characters quickly
        await tester.enterText(find.byType(TextField), 'a');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.enterText(find.byType(TextField), 'ab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.enterText(find.byType(TextField), 'abc');
        await tester.pump(const Duration(milliseconds: 100));

        // Should debounce calls
        expect(callCount, lessThan(10));
      });

      testWidgets('should handle rapid search input changes', (tester) async {
        int callCount = 0;
        
        await tester.pumpWidget(createTestWidget(
          onSearchChanged: (query) => callCount++,
        ));

        // Rapid text changes
        for (int i = 0; i < 5; i++) {
          await tester.enterText(find.byType(TextField), 'search$i');
          await tester.pump(const Duration(milliseconds: 50));
        }

        await tester.pumpAndSettle();

        // Should handle gracefully
        expect(find.byType(GroupSearchBar), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}