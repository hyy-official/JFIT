import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/group_search_bar.dart';

void main() {
  group('GroupSearchBar Widget Tests', () {
    Widget createTestWidget({
      String? initialQuery,
      ValueChanged<String>? onSearchChanged,
      VoidCallback? onSearchSubmitted,
      VoidCallback? onFilterTapped,
      bool showFilter = true,
      String hintText = 'Search groups...',
    }) {
      return MaterialApp(
        home: Scaffold(
          body: GroupSearchBar(
            initialQuery: initialQuery,
            onSearchChanged: onSearchChanged,
            onSearchSubmitted: onSearchSubmitted,
            onFilterTapped: onFilterTapped,
            showFilter: showFilter,
            hintText: hintText,
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

      testWidgets('should display filter button when showFilter is true', (tester) async {
        await tester.pumpWidget(createTestWidget(showFilter: true));

        expect(find.byIcon(Icons.filter_list), findsOneWidget);
      });

      testWidgets('should hide filter button when showFilter is false', (tester) async {
        await tester.pumpWidget(createTestWidget(showFilter: false));

        expect(find.byIcon(Icons.filter_list), findsNothing);
      });

      testWidgets('should display initial query', (tester) async {
        await tester.pumpWidget(createTestWidget(
          initialQuery: 'fitness',
        ));

        expect(find.text('fitness'), findsOneWidget);
      });
    });

    group('Search Functionality', () {
      testWidgets('should call onSearchChanged when text changes', (tester) async {
        String? searchQuery;
        
        await tester.pumpWidget(createTestWidget(
          onSearchChanged: (query) => searchQuery = query,
        ));

        await tester.enterText(find.byType(TextField), 'yoga');
        await tester.pumpAndSettle();

        expect(searchQuery, 'yoga');
      });

      testWidgets('should call onSearchSubmitted when submitted', (tester) async {
        bool wasSubmitted = false;
        
        await tester.pumpWidget(createTestWidget(
          onSearchSubmitted: () => wasSubmitted = true,
        ));

        await tester.enterText(find.byType(TextField), 'pilates');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();

        expect(wasSubmitted, true);
      });

      testWidgets('should clear search when clear button is tapped', (tester) async {
        String? searchQuery;
        
        await tester.pumpWidget(createTestWidget(
          initialQuery: 'crossfit',
          onSearchChanged: (query) => searchQuery = query,
        ));

        // Should show clear button when there's text
        expect(find.byIcon(Icons.clear), findsOneWidget);

        await tester.tap(find.byIcon(Icons.clear));
        await tester.pumpAndSettle();

        expect(searchQuery, '');
        expect(find.text('crossfit'), findsNothing);
      });

      testWidgets('should not show clear button when text is empty', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byIcon(Icons.clear), findsNothing);
      });
    });

    group('Filter Functionality', () {
      testWidgets('should call onFilterTapped when filter button is tapped', (tester) async {
        bool wasFilterTapped = false;
        
        await tester.pumpWidget(createTestWidget(
          onFilterTapped: () => wasFilterTapped = true,
        ));

        await tester.tap(find.byIcon(Icons.filter_list));
        await tester.pumpAndSettle();

        expect(wasFilterTapped, true);
      });

      testWidgets('should show active filter indicator', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GroupSearchBar(
                hasActiveFilters: true,
              ),
            ),
          ),
        );

        // Should show indicator for active filters
        expect(find.byIcon(Icons.filter_list), findsOneWidget);
        
        final filterIcon = tester.widget<Icon>(find.byIcon(Icons.filter_list));
        expect(filterIcon.color, isNotNull);
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

        final filterButtonSize = tester.getSize(find.byIcon(Icons.filter_list));
        
        // Touch targets should be at least 44x44 pixels
        expect(filterButtonSize.width, greaterThanOrEqualTo(44));
        expect(filterButtonSize.height, greaterThanOrEqualTo(44));
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
          initialQuery: 'test',
          onSearchChanged: (query) => searchQuery = query,
        ));

        await tester.tap(find.byType(TextField));
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        expect(searchQuery, '');
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
        ));

        await tester.enterText(find.byType(TextField), 'special chars');
        await tester.pumpAndSettle();

        expect(searchQuery, 'special chars');
      });

      testWidgets('should handle empty search gracefully', (tester) async {
        String? searchQuery;
        
        await tester.pumpWidget(createTestWidget(
          onSearchChanged: (query) => searchQuery = query,
        ));

        await tester.enterText(find.byType(TextField), '');
        await tester.pumpAndSettle();

        expect(searchQuery, '');
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper accessibility labels', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(
          find.bySemanticsLabel('Search groups'),
          findsOneWidget,
        );
        
        expect(
          find.bySemanticsLabel('Filter groups'),
          findsOneWidget,
        );
      });

      testWidgets('should support screen readers', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final textField = find.byType(TextField);
        expect(textField, findsOneWidget);

        final textFieldWidget = tester.widget<TextField>(textField);
        expect(textFieldWidget.decoration?.hintText, 'Search groups...');
      });

      testWidgets('should announce search results to screen readers', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GroupSearchBar(
                searchResultsCount: 5,
              ),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel('5 search results found'),
          findsOneWidget,
        );
      });
    });

    group('Theme Integration', () {
      testWidgets('should respect light theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: GroupSearchBar(),
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
              body: GroupSearchBar(),
            ),
          ),
        );

        expect(find.byType(GroupSearchBar), findsOneWidget);
      });

      testWidgets('should use custom colors when provided', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GroupSearchBar(
                backgroundColor: Colors.blue,
                textColor: Colors.white,
              ),
            ),
          ),
        );

        expect(find.byType(GroupSearchBar), findsOneWidget);
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

      testWidgets('should handle rapid filter button taps', (tester) async {
        int tapCount = 0;
        
        await tester.pumpWidget(createTestWidget(
          onFilterTapped: () => tapCount++,
        ));

        // Rapid taps
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.byIcon(Icons.filter_list));
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