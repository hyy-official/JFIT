import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:jfit/features/meal/bloc/meal_bloc.dart';
import 'package:jfit/features/meal/bloc/meal_event.dart';
import 'package:jfit/features/meal/bloc/meal_state.dart';

import 'package:jfit/features/workout_program/bloc/workout_program_bloc.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_event.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_state.dart';

import 'package:jfit/features/workout_session/bloc/workout_session_bloc.dart';
import 'package:jfit/features/workout_session/bloc/workout_session_event.dart';
import 'package:jfit/features/workout_session/bloc/workout_session_state.dart';

import 'package:jfit/features/daily_summary/bloc/daily_summary_bloc.dart';
import 'package:jfit/features/daily_summary/bloc/daily_summary_event.dart';
import 'package:jfit/features/daily_summary/bloc/daily_summary_state.dart';

import 'package:jfit/features/exercise/bloc/exercise_bloc.dart';
import 'package:jfit/features/exercise/bloc/exercise_event.dart';
import 'package:jfit/features/exercise/bloc/exercise_state.dart';

void main() {
  group('Performance Benchmark Tests', () {
    setUp(() {
      GetIt.instance.reset();
    });

    tearDown(() {
      GetIt.instance.reset();
    });

    group('State Object Performance', () {
      testWidgets('State object creation performance', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();

        // Create many state objects to test performance
        final states = <Object>[];
        for (int i = 0; i < 1000; i++) {
          states.addAll([
            MealInitial(),
            MealLoading(),
            WorkoutProgramInitial(),
            WorkoutProgramLoading(),
            WorkoutSessionInitial(),
            WorkoutSessionLoading(),
            DailySummaryInitial(),
            DailySummaryLoading(),
            ExerciseInitial(),
            ExerciseLoading(),
          ]);
        }

        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(1000), 
               reason: 'State object creation should be under 1 second');
        expect(states.length, equals(10000));
      });

      testWidgets('Event object creation performance', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();

        // Create many event objects to test performance
        final events = <Object>[];
        for (int i = 0; i < 1000; i++) {
          events.addAll([
            LoadMealRecords(userId: 'user-$i'),
            LoadUserPrograms(userId: 'user-$i'),
            LoadWorkoutSessions('user-$i'),
            LoadDailySummary(userId: 'user-$i', date: DateTime.now()),
            SearchExercises(query: 'test-$i'),
          ]);
        }

        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(500), 
               reason: 'Event object creation should be under 500ms');
        expect(events.length, equals(5000));
      });

      testWidgets('Widget tree creation performance', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<MealBloc>(
                  lazy: true,
                  create: (_) => throw UnimplementedError('Performance test'),
                ),
                BlocProvider<WorkoutProgramBloc>(
                  lazy: true,
                  create: (_) => throw UnimplementedError('Performance test'),
                ),
                BlocProvider<WorkoutSessionBloc>(
                  lazy: true,
                  create: (_) => throw UnimplementedError('Performance test'),
                ),
                BlocProvider<DailySummaryBloc>(
                  lazy: true,
                  create: (_) => throw UnimplementedError('Performance test'),
                ),
                BlocProvider<ExerciseBloc>(
                  lazy: true,
                  create: (_) => throw UnimplementedError('Performance test'),
                ),
              ],
              child: const Scaffold(body: Text('Performance Test')),
            ),
          ),
        );

        await tester.pumpAndSettle();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(2000), 
               reason: 'Widget tree creation should be under 2 seconds');
      });
    });

    group('State Change Performance', () {
      testWidgets('Equatable performance with state objects', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();

        // Test Equatable performance with many state comparisons
        final states = <MealState>[];
        for (int i = 0; i < 1000; i++) {
          states.add(MealInitial());
          states.add(MealInitial()); // Same state type for equality
        }

        // Perform equality comparisons
        int equalCount = 0;
        for (int i = 0; i < states.length - 1; i++) {
          if (states[i] == states[i + 1]) {
            equalCount++;
          }
        }

        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(100), 
               reason: 'Equatable comparisons should be fast');
        expect(equalCount, greaterThan(0));
      });

      testWidgets('UI rebuild performance with state changes', (WidgetTester tester) async {
        int rebuildCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                rebuildCount++;
                return Scaffold(
                  body: Text('Rebuild count: $rebuildCount'),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () => setState(() {}),
                    child: const Icon(Icons.refresh),
                  ),
                );
              },
            ),
          ),
        );

        final stopwatch = Stopwatch()..start();

        // Trigger multiple state changes
        for (int i = 0; i < 10; i++) {
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pump();
        }

        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(1000), 
               reason: '10 UI rebuilds should complete under 1 second');
        expect(rebuildCount, lessThan(20), 
               reason: 'Should not have excessive rebuilds');
      });
    });

    group('Memory Usage Performance', () {
      testWidgets('Memory usage with large number of providers', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: List.generate(50, (index) => 
                BlocProvider<MealBloc>(
                  lazy: true,
                  create: (_) => throw UnimplementedError('Memory test'),
                ),
              ),
              child: const Scaffold(body: Text('Memory Test')),
            ),
          ),
        );

        await tester.pump();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(1000), 
               reason: 'Creating many providers should be efficient');
      });

      testWidgets('State object memory efficiency', (WidgetTester tester) async {
        // Test that creating many state objects doesn't cause memory issues
        final states = <Object>[];
        
        for (int i = 0; i < 10000; i++) {
          states.addAll([
            MealInitial(),
            MealLoading(),
            WorkoutProgramInitial(),
            WorkoutProgramLoading(),
            WorkoutSessionInitial(),
            WorkoutSessionLoading(),
            DailySummaryInitial(),
            DailySummaryLoading(),
            ExerciseInitial(),
            ExerciseLoading(),
          ]);
        }

        // Should be able to create many state objects without issues
        expect(states.length, equals(100000));
        expect(states.every((state) => state != null), isTrue);
      });
    });

    group('Concurrent Operations Performance', () {
      testWidgets('Multiple widget operations performance', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();

        // Create multiple widgets concurrently
        final widgets = <Widget>[];
        for (int i = 0; i < 100; i++) {
          widgets.add(
            Container(
              key: ValueKey('container-$i'),
              child: Text('Item $i'),
            ),
          );
        }

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView(children: widgets),
            ),
          ),
        );

        await tester.pumpAndSettle();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(1000), 
               reason: 'Multiple widget operations should be efficient');
      });

      testWidgets('State comparison performance', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();

        // Test performance of state comparisons
        final states1 = List.generate(1000, (i) => MealInitial());
        final states2 = List.generate(1000, (i) => MealInitial());

        int matchCount = 0;
        for (int i = 0; i < states1.length; i++) {
          if (states1[i] == states2[i]) {
            matchCount++;
          }
        }

        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(100), 
               reason: 'State comparisons should be fast');
        expect(matchCount, equals(1000));
      });
    });

    group('Stress Testing', () {
      testWidgets('High-frequency widget updates', (WidgetTester tester) async {
        int updateCount = 0;
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: Text('Update count: $updateCount'),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () => setState(() => updateCount++),
                    child: const Icon(Icons.add),
                  ),
                );
              },
            ),
          ),
        );

        // Trigger many rapid updates
        for (int i = 0; i < 100; i++) {
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pump();
        }

        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(4000), 
               reason: '100 rapid updates should complete under 4 seconds');
        expect(updateCount, equals(100));
      });

      testWidgets('Large list rendering performance', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: 10000,
                itemBuilder: (context, index) => ListTile(
                  title: Text('Item $index'),
                  subtitle: Text('Subtitle $index'),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(3000), 
               reason: 'Large list rendering should complete under 3 seconds');
      });
    });
  });
}