import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/core/widgets/enhanced_error_feedback.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/core/error/bloc_errors.dart';

void main() {
  group('EnhancedErrorFeedback', () {
    late Widget testApp;

    setUp(() {
      testApp = MaterialApp(
        theme: JFitTheme.darkTheme,
        home: const Scaffold(
          body: Center(child: Text('Test App')),
        ),
      );
    });

    testWidgets('showErrorSnackBar displays error message with retry action', (tester) async {
      await tester.pumpWidget(testApp);
      
      final context = tester.element(find.byType(Scaffold));

      EnhancedErrorFeedback.showErrorSnackBar(
        context,
        message: '네트워크 연결을 확인해주세요.',
        actionLabel: '다시 시도',
        onActionPressed: () {},
        isRetryable: true,
      );

      await tester.pump();

      // Verify SnackBar is displayed
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('네트워크 연결을 확인해주세요.'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('showSuccessSnackBar displays success message', (tester) async {
      await tester.pumpWidget(testApp);
      
      final context = tester.element(find.byType(Scaffold));

      EnhancedErrorFeedback.showSuccessSnackBar(
        context,
        message: '프로그램이 저장되었습니다',
      );

      await tester.pump();

      // Verify SnackBar is displayed
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('프로그램이 저장되었습니다'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('showInfoSnackBar displays info message', (tester) async {
      await tester.pumpWidget(testApp);
      
      final context = tester.element(find.byType(Scaffold));

      EnhancedErrorFeedback.showInfoSnackBar(
        context,
        message: '프로그램을 이어서 진행합니다',
      );

      await tester.pump();

      // Verify SnackBar is displayed
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('프로그램을 이어서 진행합니다'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('showErrorDialog displays error dialog with actions', (tester) async {
      await tester.pumpWidget(testApp);
      
      final context = tester.element(find.byType(Scaffold));
      bool actionPressed = false;

      EnhancedErrorFeedback.showErrorDialog(
        context,
        title: '오류 발생',
        message: '프로그램을 불러올 수 없습니다.',
        recoverySuggestion: '네트워크 연결을 확인해주세요.',
        actions: [
          ErrorDialogAction(
            label: '다시 시도',
            onPressed: () {
              actionPressed = true;
              Navigator.of(context).pop();
            },
            type: ErrorDialogActionType.primary,
          ),
        ],
      );

      await tester.pump();

      // Verify dialog is displayed
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('오류 발생'), findsOneWidget);
      expect(find.text('프로그램을 불러올 수 없습니다.'), findsOneWidget);
      expect(find.text('네트워크 연결을 확인해주세요.'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);

      // Tap action button
      await tester.tap(find.text('다시 시도'));
      await tester.pump();

      expect(actionPressed, isTrue);
    });

    testWidgets('ErrorStateWidget displays error with retry button', (tester) async {
      bool retryPressed = false;
      final error = WorkoutProgramError(
        '네트워크 오류가 발생했습니다',
        code: BlocErrorCodes.networkError,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: JFitTheme.darkTheme,
          home: Scaffold(
            body: ErrorStateWidget(
              error: error,
              onRetry: () {
                retryPressed = true;
              },
            ),
          ),
        ),
      );

      // Verify error state widget is displayed
      expect(find.byType(ErrorStateWidget), findsOneWidget);
      expect(find.text('네트워크 연결을 확인해주세요.'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('다시 연결'), findsOneWidget);

      // Tap retry button
      await tester.tap(find.text('다시 연결'));
      await tester.pump();

      expect(retryPressed, isTrue);
    });

    testWidgets('LoadingStateWidget displays loading indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: JFitTheme.darkTheme,
          home: const Scaffold(
            body: LoadingStateWidget(
              message: '프로그램을 불러오는 중...',
            ),
          ),
        ),
      );

      // Verify loading state widget is displayed
      expect(find.byType(LoadingStateWidget), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('프로그램을 불러오는 중...'), findsOneWidget);
    });
  });
}