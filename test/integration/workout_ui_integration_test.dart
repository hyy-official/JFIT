import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';

import 'package:jfit/features/workout_program/bloc/workout_program_bloc.dart';
import 'package:jfit/features/workout_session/bloc/workout_session_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_state.dart';
import 'package:jfit/features/records/presentation/widgets/quick_add_section.dart';
import 'package:jfit/features/records/presentation/widgets/exercise_tab_content.dart';

// Mock classes
class MockWorkoutProgramBloc extends Mock implements WorkoutProgramBloc {}
class MockWorkoutSessionBloc extends Mock implements WorkoutSessionBloc {}
class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  group('Workout UI Integration Tests', () {
    late MockWorkoutProgramBloc mockWorkoutProgramBloc;
    late MockWorkoutSessionBloc mockWorkoutSessionBloc;
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockWorkoutProgramBloc = MockWorkoutProgramBloc();
      mockWorkoutSessionBloc = MockWorkoutSessionBloc();
      mockAuthBloc = MockAuthBloc();

      // Setup GetIt
      if (GetIt.instance.isRegistered<WorkoutProgramBloc>()) {
        GetIt.instance.unregister<WorkoutProgramBloc>();
      }
      if (GetIt.instance.isRegistered<WorkoutSessionBloc>()) {
        GetIt.instance.unregister<WorkoutSessionBloc>();
      }
      
      GetIt.instance.registerFactory<WorkoutProgramBloc>(() => mockWorkoutProgramBloc);
      GetIt.instance.registerFactory<WorkoutSessionBloc>(() => mockWorkoutSessionBloc);

      // Setup mock states
      when(mockAuthBloc.state).thenReturn(const AuthInitial());
      when(mockWorkoutProgramBloc.stream).thenAnswer((_) => const Stream.empty());
      when(mockWorkoutSessionBloc.stream).thenAnswer((_) => const Stream.empty());
    });

    tearDown(() {
      GetIt.instance.reset();
    });

    testWidgets('QuickAddSection can be instantiated with new BLoCs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<AuthBloc>(
              create: (_) => mockAuthBloc,
              child: const QuickAddSection(),
            ),
          ),
        ),
      );

      expect(find.byType(QuickAddSection), findsOneWidget);
      expect(find.text('빠른 추가'), findsOneWidget);
      expect(find.text('운동'), findsOneWidget);
    });

    testWidgets('ExerciseTabContent can be instantiated with new BLoCs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<AuthBloc>(
              create: (_) => mockAuthBloc,
              child: const ExerciseTabContent(),
            ),
          ),
        ),
      );

      expect(find.byType(ExerciseTabContent), findsOneWidget);
    });
  });
}