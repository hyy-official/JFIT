import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/core/widgets/enhanced_error_feedback.dart';
import 'package:jfit/core/error/bloc_errors.dart';

void main() {
  group('EnhancedErrorFeedback Tests', () {
    Widget createTestWidget({
      required BlocError error,
      VoidCallback? onRetry,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ErrorStateWidget(
            error: error,
            onRetry: onRetry,
          ),
        ),
      );
    }

    group('Error Display Tests', () {
      testWidgets('should display workout program error correctly', (tester) async {
        // arrange
        final error = WorkoutProgramError(
          '운동 프로그램을 불러올 수 없습니다.',
          code: 'PROGRAM_LOAD_ERROR',
        );

        // act
        await tester.pumpWidget(createTestWidget(error: error));

        // assert
        expect(find.text('운동 프로그램을 불러올 수 없습니다.'), findsOneWidget);
        expect(find.byType(ErrorStateWidget), findsOneWidget);
      });

      testWidgets('should display meal error correctly', (tester) async {
        // arrange
        final error = MealError(
          '식사 기록을 저장할 수 없습니다.',
          code: 'MEAL_SAVE_ERROR',
        );

        // act
        await tester.pumpWidget(createTestWidget(error: error));

        // assert
        expect(find.text('식사 기록을 저장할 수 없습니다.'), findsOneWidget);
        expect(find.byType(ErrorStateWidget), findsOneWidget);
      });
    });

    group('Action Button Tests', () {
      testWidgets('should call onRetry when retry button is tapped', (tester) async {
        // arrange
        bool retryCallbackCalled = false;
        final error = WorkoutProgramError(
          '네트워크 연결을 확인해주세요.',
          code: BlocErrorCodes.networkError,
        );

        // act
        await tester.pumpWidget(createTestWidget(
          error: error,
          onRetry: () => retryCallbackCalled = true,
        ));

        // Debug: print all text widgets to see what's rendered
        final allText = find.byType(Text);
        for (final element in allText.evaluate()) {
          final widget = element.widget as Text;
          print('Found text: ${widget.data}');
        }

        // Find and tap retry button - should be '다시 연결' for network error
        final retryButton = find.text('다시 연결');
        expect(retryButton, findsOneWidget);
        
        await tester.tap(retryButton);
        await tester.pumpAndSettle();

        // assert
        expect(retryCallbackCalled, true);
      });

      testWidgets('should not show retry button when onRetry is null', (tester) async {
        // arrange
        final error = WorkoutProgramError(
          '네트워크 연결을 확인해주세요.',
          code: 'NETWORK_ERROR',
        );

        // act
        await tester.pumpWidget(createTestWidget(
          error: error,
          onRetry: null,
        ));

        // assert
        expect(find.text('다시 시도'), findsNothing);
      });
    });

    group('Static Methods Tests', () {
      testWidgets('should show error snackbar', (tester) async {
        // arrange
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  EnhancedErrorFeedback.showErrorSnackBar(
                    context,
                    message: '테스트 에러 메시지',
                  );
                },
                child: const Text('Show Error'),
              ),
            ),
          ),
        ));

        // act
        await tester.tap(find.text('Show Error'));
        await tester.pump();

        // assert
        expect(find.text('테스트 에러 메시지'), findsOneWidget);
      });

      testWidgets('should show success snackbar', (tester) async {
        // arrange
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  EnhancedErrorFeedback.showSuccessSnackBar(
                    context,
                    message: '성공 메시지',
                  );
                },
                child: const Text('Show Success'),
              ),
            ),
          ),
        ));

        // act
        await tester.tap(find.text('Show Success'));
        await tester.pump();

        // assert
        expect(find.text('성공 메시지'), findsOneWidget);
      });
    });
  });
}