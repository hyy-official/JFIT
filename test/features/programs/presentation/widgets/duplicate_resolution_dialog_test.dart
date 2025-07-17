import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/core/error/workout_program_failures.dart';

// Simple test dialog function
Future<ResolutionOption?> showDuplicateResolutionDialog({
  required BuildContext context,
  required ProgramDuplicateInfo duplicateInfo,
}) {
  return showDialog<ResolutionOption>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('중복된 프로그램'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(duplicateInfo.programName),
          Text('${duplicateInfo.currentWeek}주차 ${duplicateInfo.currentDay}일차'),
          Text('진행률: ${duplicateInfo.progressPercent.toInt()}%'),
          Text(_getStatusText(duplicateInfo.status)),
        ],
      ),
      actions: duplicateInfo.availableOptions.map((option) {
        return TextButton(
          onPressed: () => Navigator.of(context).pop(option),
          child: Text(_getOptionText(option)),
        );
      }).toList()
        ..add(
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('취소'),
          ),
        ),
    ),
  );
}

String _getStatusText(ProgramStatus status) {
  switch (status) {
    case ProgramStatus.active:
      return '진행 중';
    case ProgramStatus.completed:
      return '완료됨';
    case ProgramStatus.paused:
      return '일시정지';
  }
}

String _getOptionText(ResolutionOption option) {
  switch (option) {
    case ResolutionOption.continueExisting:
      return '기존 프로그램 계속하기';
    case ResolutionOption.restartProgram:
      return '프로그램 다시 시작';
    case ResolutionOption.createNewInstance:
      return '새 프로그램으로 저장';
    case ResolutionOption.cancel:
      return '취소';
  }
}

String _getOptionDescription(ResolutionOption option) {
  switch (option) {
    case ResolutionOption.continueExisting:
      return '현재 진행 중인 프로그램을 이어서 진행합니다.';
    case ResolutionOption.restartProgram:
      return '기존 프로그램을 처음부터 다시 시작합니다.';
    case ResolutionOption.createNewInstance:
      return '기존 프로그램과 별도로 새 프로그램을 생성합니다.';
    case ResolutionOption.cancel:
      return '';
  }
}

extension ProgramDuplicateInfoExtension on ProgramDuplicateInfo {
  ProgramDuplicateInfo copyWith({
    String? userProgramId,
    String? programName,
    int? currentWeek,
    int? currentDay,
    int? totalWeeks,
    double? progressPercent,
    bool? isCompleted,
    DateTime? startedAt,
    ProgramStatus? status,
    List<ResolutionOption>? availableOptions,
  }) {
    return ProgramDuplicateInfo(
      userProgramId: userProgramId ?? this.userProgramId,
      programName: programName ?? this.programName,
      currentWeek: currentWeek ?? this.currentWeek,
      currentDay: currentDay ?? this.currentDay,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      progressPercent: progressPercent ?? this.progressPercent,
      isCompleted: isCompleted ?? this.isCompleted,
      startedAt: startedAt ?? this.startedAt,
      status: status ?? this.status,
      availableOptions: availableOptions ?? this.availableOptions,
    );
  }
}

void main() {
  group('DuplicateResolutionDialog', () {
    late ProgramDuplicateInfo duplicateInfo;

    setUp(() {
      duplicateInfo = const ProgramDuplicateInfo(
        userProgramId: 'test-program-id',
        programName: 'Test Workout Program',
        currentWeek: 2,
        currentDay: 3,
        totalWeeks: 4,
        progressPercent: 50.0,
        isCompleted: false,
        status: ProgramStatus.active,
        availableOptions: [
          ResolutionOption.continueExisting,
          ResolutionOption.restartProgram,
          ResolutionOption.createNewInstance,
          ResolutionOption.cancel,
        ],
      );
    });

    Widget createTestWidget(ProgramDuplicateInfo info) {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDuplicateResolutionDialog(
                context: context,
                duplicateInfo: info,
              ),
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );
    }

    testWidgets('should display program information correctly', (tester) async {
      // arrange
      await tester.pumpWidget(createTestWidget(duplicateInfo));

      // act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('중복된 프로그램'), findsOneWidget);
      expect(find.text('Test Workout Program'), findsOneWidget);
      expect(find.text('2주차 3일차'), findsOneWidget);
      expect(find.text('진행률: 50%'), findsOneWidget);
    });

    testWidgets('should show continue option for active program', (tester) async {
      // arrange
      await tester.pumpWidget(createTestWidget(duplicateInfo));

      // act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('기존 프로그램 계속하기'), findsOneWidget);
      expect(find.text('현재 진행 중인 프로그램을 이어서 진행합니다.'), findsOneWidget);
    });

    testWidgets('should show restart option', (tester) async {
      // arrange
      await tester.pumpWidget(createTestWidget(duplicateInfo));

      // act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('프로그램 다시 시작'), findsOneWidget);
      expect(find.text('기존 프로그램을 처음부터 다시 시작합니다.'), findsOneWidget);
    });

    testWidgets('should show create new option', (tester) async {
      // arrange
      await tester.pumpWidget(createTestWidget(duplicateInfo));

      // act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('새 프로그램으로 저장'), findsOneWidget);
      expect(find.text('기존 프로그램과 별도로 새 프로그램을 생성합니다.'), findsOneWidget);
    });

    testWidgets('should show cancel option', (tester) async {
      // arrange
      await tester.pumpWidget(createTestWidget(duplicateInfo));

      // act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('취소'), findsOneWidget);
    });

    testWidgets('should not show continue option for completed program', (tester) async {
      // arrange
      final completedInfo = duplicateInfo.copyWith(
        isCompleted: true,
        status: ProgramStatus.completed,
        progressPercent: 100.0,
        availableOptions: [
          ResolutionOption.restartProgram,
          ResolutionOption.createNewInstance,
          ResolutionOption.cancel,
        ],
      );
      await tester.pumpWidget(createTestWidget(completedInfo));

      // act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('기존 프로그램 계속하기'), findsNothing);
      expect(find.text('프로그램 다시 시작'), findsOneWidget);
      expect(find.text('새 프로그램으로 저장'), findsOneWidget);
    });

    testWidgets('should return correct option when continue is tapped', (tester) async {
      // arrange
      ResolutionOption? selectedOption;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  selectedOption = await showDuplicateResolutionDialog(
                    context: context,
                    duplicateInfo: duplicateInfo,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('기존 프로그램 계속하기'));
      await tester.pumpAndSettle();

      // assert
      expect(selectedOption, ResolutionOption.continueExisting);
    });

    testWidgets('should return correct option when restart is tapped', (tester) async {
      // arrange
      ResolutionOption? selectedOption;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  selectedOption = await showDuplicateResolutionDialog(
                    context: context,
                    duplicateInfo: duplicateInfo,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('프로그램 다시 시작'));
      await tester.pumpAndSettle();

      // assert
      expect(selectedOption, ResolutionOption.restartProgram);
    });

    testWidgets('should return correct option when create new is tapped', (tester) async {
      // arrange
      ResolutionOption? selectedOption;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  selectedOption = await showDuplicateResolutionDialog(
                    context: context,
                    duplicateInfo: duplicateInfo,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('새 프로그램으로 저장'));
      await tester.pumpAndSettle();

      // assert
      expect(selectedOption, ResolutionOption.createNewInstance);
    });

    testWidgets('should return null when cancel is tapped', (tester) async {
      // arrange
      ResolutionOption? selectedOption;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  selectedOption = await showDuplicateResolutionDialog(
                    context: context,
                    duplicateInfo: duplicateInfo,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      // assert
      expect(selectedOption, isNull);
    });

    testWidgets('should return null when dialog is dismissed', (tester) async {
      // arrange
      ResolutionOption? selectedOption;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  selectedOption = await showDuplicateResolutionDialog(
                    context: context,
                    duplicateInfo: duplicateInfo,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      
      // Dismiss dialog by tapping outside
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // assert
      expect(selectedOption, isNull);
    });

    testWidgets('should display correct status text for different program states', (tester) async {
      // Test active program
      await tester.pumpWidget(createTestWidget(duplicateInfo));
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      expect(find.text('진행 중'), findsOneWidget);
      
      // Dismiss dialog
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      // Test completed program
      final completedInfo = duplicateInfo.copyWith(
        isCompleted: true,
        status: ProgramStatus.completed,
        progressPercent: 100.0,
      );
      await tester.pumpWidget(createTestWidget(completedInfo));
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      expect(find.text('완료됨'), findsOneWidget);
      
      // Dismiss dialog
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      // Test paused program
      final pausedInfo = duplicateInfo.copyWith(
        status: ProgramStatus.paused,
        progressPercent: 25.0,
      );
      await tester.pumpWidget(createTestWidget(pausedInfo));
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      expect(find.text('일시정지'), findsOneWidget);
    });

    testWidgets('should handle edge cases in program information display', (tester) async {
      // arrange - program with minimal information
      final minimalInfo = duplicateInfo.copyWith(
        currentWeek: 1,
        currentDay: 1,
        progressPercent: 0.0,
        startedAt: null,
      );
      await tester.pumpWidget(createTestWidget(minimalInfo));

      // act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('1주차 1일차'), findsOneWidget);
      expect(find.text('진행률: 0%'), findsOneWidget);
    });
  });
}