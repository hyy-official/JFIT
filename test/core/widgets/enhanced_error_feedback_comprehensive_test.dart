import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:jfit/core/widgets/enhanced_error_feedback.dart';
import 'package:jfit/core/error/workout_program_failures.dart';

@GenerateMocks([])
void main() {
  group('EnhancedErrorFeedback Comprehensive Tests', () {
    Widget createTestWidget({
      required WorkoutProgramFailure failure,
      VoidCallback? onRetry,
      VoidCallback? onDismiss,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: EnhancedErrorFeedback(
            failure: failure,
            onRetry: onRetry,
            onDismiss: onDismiss,
          ),
        ),
      );
    }

    group('Error Type Display Tests', () {
      testWidgets('should display duplicate error correctly', (tester) async {
        // arrange
        const duplicateInfo = ProgramDuplicateInfo(
          userProgramId: 'test-id',
          programName: 'Test Program',
          currentWeek: 2,
          currentDay: 3,
          totalWeeks: 4,
          progressPercent: 50.0,
          isCompleted: false,
          status: ProgramStatus.active,
          availableOptions: [ResolutionOption.continueExisting],
        );
        final failure = ProgramDuplicateFailure(duplicateInfo: duplicateInfo);

        // act
        await tester.pumpWidget(createTestWidget(failure: failure));

        // assert
        expect(find.text('이미 저장된 프로그램입니다.'), findsOneWidget);
        expect(find.text('기존 프로그램을 계속하거나 새로 시작할 수 있습니다.'), findsOneWidget);
        expect(find.text('선택하기'), findsOneWidget);
        expect(find.byIcon(Icons.info_outline), findsOneWidget);
      });

      testWidgets('should display network error correctly', (tester) async {
        // arrange
        const failure = WorkoutProgramNetworkFailure(
          technicalMessage: 'Connection timeout',
        );

        // act
        await tester.pumpWidget(createTestWidget(failure: failure));

        // assert
        expect(find.text('네트워크 연결을 확인해주세요.'), findsOneWidget);
        expect(find.text('네트워크 연결을 확인하고 다시 시도해주세요.'), findsOneWidget);
        expect(find.text('다시 시도'), findsOneWidget);
        expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      });

      testWidgets('should display server error correctly', (tester) async {
        // arrange
        final failure = WorkoutProgramServerFailure(
          statusCode: 500,
          technicalMessage: 'Internal server error',
        );

        // act
        await tester.pumpWidget(createTestWidget(failure: failure));

        // assert
        expect(find.text('서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.'), findsOneWidget);
        expect(find.text('잠시 후 다시 시도해주세요.'), findsOneWidget);
        expect(find.text('다시 시도'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('should display permission error correctly', (tester) async {
        // arrange
        const failure = WorkoutProgramPermissionFailure(
          technicalMessage: 'User not authenticated',
        );

        // act
        await tester.pumpWidget(createTestWidget(failure: failure));

        // assert
        expect(find.text('해당 작업을 수행할 권한이 없습니다.'), findsOneWidget);
        expect(find.text('로그인 상태를 확인하고 다시 시도해주세요.'), findsOneWidget);
        expect(find.text('로그인'), findsOneWidget);
        expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      });

      testWidgets('should display data parsing error correctly', (tester) async {
        // arrange
        final failure = DataParsingFailure(
          message: 'Invalid JSON format',
          dataType: 'exercises_json',
          technicalMessage: 'JSON decode error',
        );

        // act
        await tester.pumpWidget(createTestWidget(failure: failure));

        // assert
        expect(find.text('운동 데이터를 불러오는 중 오류가 발생했습니다.'), findsOneWidget);
        expect(find.text('프로그램을 다시 불러오거나 앱을 재시작해주세요.'), findsOneWidget);
        expect(find.text('새로고침'), findsOneWidget);
        expect(find.byIcon(Icons.data_usage), findsOneWidget);
      });

      testWidgets('should display repository not initialized error correctly', (tester) async {
        // arrange
        const failure = RepositoryNotInitializedFailure(
          technicalMessage: 'Repository is null',
        );

        // act
        await tester.pumpWidget(createTestWidget(failure: failure));

        // assert
        expect(find.text('운동 프로그램 서비스를 초기화할 수 없습니다.'), findsOneWidget);
        expect(find.text('앱을 다시 시작하거나 로그인을 다시 해주세요.'), findsOneWidget);
        expect(find.text('다시 시도'), findsOneWidget);
        expect(find.byIcon(Icons.warning), findsOneWidget);
      });

      testWidgets('should display program not found error correctly', (tester) async {
        // arrange
        final failure = ProgramNotFoundFailure(
          programId: 'missing-program-id',
          technicalMessage: 'Program does not exist',
        );

        // act
        await tester.pumpWidget(createTestWidget(failure: failure));

        // assert
        expect(find.text('운동 프로그램을 찾을 수 없습니다.'), findsOneWidget);
        expect(find.text('프로그램 목록을 새로고침하고 다시 시도해주세요.'), findsOneWidget);
        expect(find.text('새로고침'), findsOneWidget);
        expect(find.byIcon(Icons.search_off), findsOneWidget);
      });

      testWidgets('should display exercise data empty error correctly', (tester) async {
        // arrange
        const failure = ExerciseDataEmptyFailure(
          technicalMessage: 'exercises_json is empty',
        );

        // act
        await tester.pumpWidget(createTestWidget(failure: failure));

        // assert
        expect(find.text('운동 데이터가 없습니다. 프로그램을 다시 확인해주세요.'), findsOneWidget);
        expect(find.text('프로그램을 다시 선택하거나 새로고침해주세요.'), findsOneWidget);
        expect(find.text('새로고침'), findsOneWidget);
        expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      });

      testWidgets('should display validation error correctly', (tester) async {
        // arrange
        final failure = WorkoutProgramValidationFailure(
          validationErrors: ['Invalid program ID', 'Missing user ID'],
          technicalMessage: 'Validation failed',
        );

        // act
        await tester.pumpWidget(createTestWidget(failure: failure));

        // assert
        expect(find.text('입력한 정보를 다시 확인해주세요.'), findsOneWidget);
        expect(find.text('입력한 정보를 확인하고 다시 시도해주세요.'), findsOneWidget);
        expect(find.text('확인'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      });

      testWidgets('should display unknown error correctly', (tester) async {
        // arrange
        const failure = WorkoutProgramUnknownFailure(
          message: 'Something went wrong',
          technicalMessage: 'Unknown error occurred',
        );

        // act
        await tester.pumpWidget(createTestWidget(failure: failure));

        // assert
        expect(find.text('Something went wrong'), findsOneWidget);
        expect(find.text('앱을 다시 시작하거나 고객센터에 문의해주세요.'), findsOneWidget);
        expect(find.text('다시 시도'), findsOneWidget);
        expect(find.byIcon(Icons.help_outline), findsOneWidget);
      });
    });

    group('Action Button Tests', () {
      testWidgets('should call onRetry when retry button is tapped', (tester) async {
        // arrange
        bool retryCallbackCalled = false;
        const failure = WorkoutProgramNetworkFailure();

        // act
        await tester.pumpWidget(createTestWidget(
          failure: failure,
          onRetry: () => retryCallbackCalled = true,
        ));
        await tester.tap(find.text('다시 시도'));
        await tester.pumpAndSettle();

        // assert
        expect(retryCallbackCalled, true);
      });

      testWidgets('should call onDismiss when dismiss button is tapped', (tester) async {
        // arrange
        bool dismissCallbackCalled = false;
        const failure = WorkoutProgramNetworkFailure();

        // act
        await tester.pumpWidget(createTestWidget(
          failure: failure,
          onDismiss: () => dismissCallbackCalled = true,
        ));
        await tester.tap(find.text('닫기'));
        await tester.pumpAndSettle();

        // assert
        expect(dismissCallbackCalled, true);
      });

      testWidgets('should not show retry button when onRetry is null', (tester) async {
        // arrange
        const failure = WorkoutProgramNetworkFailure();

        // act
        await tester.pumpWidget(createTestWidget(
          failure: failure,
          onRetry: null,
        ));

        // assert
        expect(find.text('다시 시도'), findsNothing);
        expect(find.text('닫기'), findsOneWidget);
      });

      testWidgets('should not show dismiss button when onDismiss is null', (tester) async {
        // arrange
        const failure = WorkoutProgramNetworkFailure();

        // act
        await tester.pumpWidget(createTestWidget(
          failure: failure,
          onDismiss: null,
        ));

        // assert
        expect(find.text('닫기'), findsNothing);
        expect(find.text('다시 시도'), findsOneWidget);
      });

      testWidgets('should show both buttons when both callbacks are provided', (tester) async {
        // arrange
        const failure = WorkoutProgramNetworkFailure();

        // act
        await tester.pumpWidget(createTestWidget(
          failure: failure,
          onRetry: () {},
          onDismiss: () {},
        ));

        // assert
        expect(find.text('다시 시도'), findsOneWidget);
        expect(find.text('닫기'), findsOneWidget);
      });
    });

    group('Visual Styling Tests', () {
      testWidgets('should use correct colors for different error severities', (tester) async {
        // arrange
        const networkFailure = WorkoutProgramNetworkFailure();
        const duplicateFailure = ProgramDuplicateFailure(
          duplicateInfo: ProgramDuplicateInfo(
            userProgramId: 'test-id',
            programName: 'Test Program',
            currentWeek: 1,
            currentDay: 1,
            totalWeeks: 4,
            progressPercent: 0.0,
            isCompleted: false,
            status: ProgramStatus.active,
            availableOptions: [ResolutionOption.continueExisting],
          ),
        );

        // Test network error (medium severity)
        await tester.pumpWidget(createTestWidget(failure: networkFailure));
        expect(find.byType(Card), findsOneWidget);

        // Test duplicate error (info severity)
        await tester.pumpWidget(createTestWidget(failure: duplicateFailure));
        expect(find.byType(Card), findsOneWidget);
      });

      testWidgets('should display appropriate icons for different error types', (tester) async {
        // Test various error types and their icons
        final testCases = [
          (const WorkoutProgramNetworkFailure(), Icons.wifi_off),
          (const WorkoutProgramServerFailure(), Icons.error_outline),
          (const WorkoutProgramPermissionFailure(), Icons.lock_outline),
          (const DataParsingFailure(message: 'test'), Icons.data_usage),
          (const RepositoryNotInitializedFailure(), Icons.warning),
          (const ExerciseDataEmptyFailure(), Icons.fitness_center),
          (const WorkoutProgramValidationFailure(validationErrors: []), Icons.check_circle_outline),
          (const WorkoutProgramUnknownFailure(message: 'test'), Icons.help_outline),
        ];

        for (final (failure, expectedIcon) in testCases) {
          await tester.pumpWidget(createTestWidget(failure: failure));
          expect(find.byIcon(expectedIcon), findsOneWidget);
        }
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should have proper semantics for screen readers', (tester) async {
        // arrange
        const failure = WorkoutProgramNetworkFailure();

        // act
        await tester.pumpWidget(createTestWidget(
          failure: failure,
          onRetry: () {},
          onDismiss: () {},
        ));

        // assert
        expect(find.bySemanticsLabel('에러 메시지'), findsOneWidget);
        expect(find.bySemanticsLabel('다시 시도 버튼'), findsOneWidget);
        expect(find.bySemanticsLabel('닫기 버튼'), findsOneWidget);
      });

      testWidgets('should support keyboard navigation', (tester) async {
        // arrange
        const failure = WorkoutProgramNetworkFailure();

        // act
        await tester.pumpWidget(createTestWidget(
          failure: failure,
          onRetry: () {},
          onDismiss: () {},
        ));

        // assert - buttons should be focusable
        final retryButton = find.text('다시 시도');
        final dismissButton = find.text('닫기');
        
        expect(retryButton, findsOneWidget);
        expect(dismissButton, findsOneWidget);
        
        // Verify buttons are tappable (which implies they're focusable)
        await tester.tap(retryButton);
        await tester.tap(dismissButton);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle null technical message gracefully', (tester) async {
        // arrange
        const failure = WorkoutProgramNetworkFailure(technicalMessage: null);

        // act & assert - should not throw
        await tester.pumpWidget(createTestWidget(failure: failure));
        expect(find.text('네트워크 연결을 확인해주세요.'), findsOneWidget);
      });

      testWidgets('should handle empty user message gracefully', (tester) async {
        // arrange
        const failure = WorkoutProgramUnknownFailure(message: '');

        // act & assert - should show fallback message
        await tester.pumpWidget(createTestWidget(failure: failure));
        expect(find.byType(EnhancedErrorFeedback), findsOneWidget);
      });

      testWidgets('should handle very long error messages', (tester) async {
        // arrange
        const longMessage = 'This is a very long error message that should be handled gracefully by the widget without causing overflow or layout issues in the user interface';
        const failure = WorkoutProgramUnknownFailure(message: longMessage);

        // act & assert - should not overflow
        await tester.pumpWidget(createTestWidget(failure: failure));
        expect(find.text(longMessage), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle rapid successive error updates', (tester) async {
        // arrange
        const failure1 = WorkoutProgramNetworkFailure();
        const failure2 = WorkoutProgramServerFailure();

        // act
        await tester.pumpWidget(createTestWidget(failure: failure1));
        expect(find.text('네트워크 연결을 확인해주세요.'), findsOneWidget);

        await tester.pumpWidget(createTestWidget(failure: failure2));
        expect(find.text('서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.'), findsOneWidget);

        // assert - should handle updates without issues
        expect(tester.takeException(), isNull);
      });
    });

    group('Integration with Error Handler', () {
      testWidgets('should display error handler suggestions correctly', (tester) async {
        // arrange
        final failure = DataParsingFailure(
          message: 'Parsing failed',
          dataType: 'exercises_json',
          technicalMessage: 'JSON decode error',
        );

        // act
        await tester.pumpWidget(createTestWidget(failure: failure));

        // assert - should show both user message and recovery suggestion
        expect(find.text('운동 데이터를 불러오는 중 오류가 발생했습니다.'), findsOneWidget);
        expect(find.text('프로그램을 다시 불러오거나 앱을 재시작해주세요.'), findsOneWidget);
      });
    });
  });
}