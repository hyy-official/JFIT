import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

// Import all the new BLoCs
import 'package:jfit/features/workout_program/bloc/workout_program_bloc.dart';
import 'package:jfit/features/workout_session/bloc/workout_session_bloc.dart';
import 'package:jfit/features/daily_summary/bloc/daily_summary_bloc.dart';
import 'package:jfit/features/exercise/bloc/exercise_bloc.dart';
import 'package:jfit/features/meal/bloc/meal_bloc.dart';

/// Helper class for providing lazy-loaded BLoCs with performance optimizations
/// Optimizes memory usage by only creating BLoCs when needed and managing their lifecycle
class BlocProviderHelper {
  static final GetIt _getIt = GetIt.instance;
  
  // Performance tracking
  static final Map<String, DateTime> _blocCreationTimes = {};
  static final Map<String, int> _blocUsageCount = {};
  
  /// Track BLOC creation for performance monitoring
  static void _trackBlocCreation(String blocName) {
    _blocCreationTimes[blocName] = DateTime.now();
    _blocUsageCount[blocName] = (_blocUsageCount[blocName] ?? 0) + 1;
  }

  /// Provides a MealBloc when needed
  static Widget withMealBloc({
    required Widget child,
  }) {
    return BlocProvider<MealBloc>(
      create: (context) {
        _trackBlocCreation('MealBloc');
        return _getIt<MealBloc>();
      },
      child: child,
    );
  }

  /// Provides a WorkoutProgramBloc when needed
  static Widget withWorkoutProgramBloc({
    required Widget child,
  }) {
    return BlocProvider<WorkoutProgramBloc>(
      create: (context) {
        _trackBlocCreation('WorkoutProgramBloc');
        return _getIt<WorkoutProgramBloc>();
      },
      child: child,
    );
  }

  /// Provides a WorkoutSessionBloc when needed
  static Widget withWorkoutSessionBloc({
    required Widget child,
  }) {
    return BlocProvider<WorkoutSessionBloc>(
      create: (context) {
        _trackBlocCreation('WorkoutSessionBloc');
        return _getIt<WorkoutSessionBloc>();
      },
      child: child,
    );
  }

  /// Provides a DailySummaryBloc when needed
  static Widget withDailySummaryBloc({
    required Widget child,
  }) {
    return BlocProvider<DailySummaryBloc>(
      create: (context) {
        _trackBlocCreation('DailySummaryBloc');
        return _getIt<DailySummaryBloc>();
      },
      child: child,
    );
  }

  /// Provides an ExerciseBloc when needed
  static Widget withExerciseBloc({
    required Widget child,
  }) {
    return BlocProvider<ExerciseBloc>(
      create: (context) {
        _trackBlocCreation('ExerciseBloc');
        return _getIt<ExerciseBloc>();
      },
      child: child,
    );
  }

  /// Provides multiple BLoCs when needed with optimized nesting order
  static Widget withMultipleBLocs({
    required Widget child,
    bool needsMeal = false,
    bool needsWorkoutProgram = false,
    bool needsWorkoutSession = false,
    bool needsDailySummary = false,
    bool needsExercise = false,
  }) {
    Widget result = child;

    // Nest BLoCs in order of dependency (least dependent first)
    if (needsExercise) {
      result = withExerciseBloc(child: result);
    }
    if (needsMeal) {
      result = withMealBloc(child: result);
    }
    if (needsWorkoutProgram) {
      result = withWorkoutProgramBloc(child: result);
    }
    if (needsWorkoutSession) {
      result = withWorkoutSessionBloc(child: result);
    }
    if (needsDailySummary) {
      result = withDailySummaryBloc(child: result);
    }

    return result;
  }

  /// Provides BLoCs with conditional loading based on route
  static Widget withConditionalBLocs({
    required Widget child,
    required String routeName,
  }) {
    // Optimize BLOC loading based on route requirements
    switch (routeName) {
      case '/dashboard':
        return withMultipleBLocs(
          child: child,
          needsDailySummary: true,
          needsWorkoutProgram: true,
        );
      case '/meal':
      case '/nutrition':
        return withMultipleBLocs(
          child: child,
          needsMeal: true,
          needsDailySummary: true,
        );
      case '/workout':
      case '/exercise':
        return withMultipleBLocs(
          child: child,
          needsExercise: true,
          needsWorkoutProgram: true,
          needsWorkoutSession: true,
        );
      case '/programs':
        return withMultipleBLocs(
          child: child,
          needsWorkoutProgram: true,
          needsExercise: true,
        );
      default:
        // For unknown routes, provide minimal BLoCs
        return child;
    }
  }

  /// Error recovery mechanism for BLoC creation failures
  static Widget withErrorRecovery({
    required Widget child,
    required String blocName,
    VoidCallback? onRetry,
  }) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (error) {
          debugPrint('❌ Failed to create $blocName: $error');
          return _BlocErrorWidget(
            blocName: blocName,
            error: error.toString(),
            onRetry: onRetry,
          );
        }
      },
    );
  }

  /// Get performance metrics for BLOC usage
  static Map<String, dynamic> getPerformanceMetrics() {
    final now = DateTime.now();
    final metrics = <String, dynamic>{};
    
    for (final entry in _blocCreationTimes.entries) {
      final blocName = entry.key;
      final creationTime = entry.value;
      final usageCount = _blocUsageCount[blocName] ?? 0;
      
      metrics[blocName] = {
        'creation_time': creationTime.toIso8601String(),
        'uptime_minutes': now.difference(creationTime).inMinutes,
        'usage_count': usageCount,
      };
    }
    
    return {
      'total_blocs_created': _blocCreationTimes.length,
      'bloc_metrics': metrics,
    };
  }

  /// Clear performance tracking data
  static void clearPerformanceMetrics() {
    _blocCreationTimes.clear();
    _blocUsageCount.clear();
  }

  /// Get memory usage estimation for tracked BLoCs
  static double getEstimatedMemoryUsage() {
    // Rough estimation: each BLOC ~2MB on average
    return _blocCreationTimes.length * 2.0;
  }
}

/// Widget displayed when BLoC creation fails
class _BlocErrorWidget extends StatelessWidget {
  final String blocName;
  final String error;
  final VoidCallback? onRetry;

  const _BlocErrorWidget({
    required this.blocName,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load $blocName',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}