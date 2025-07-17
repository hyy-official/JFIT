import 'package:jfit/core/services/supabase_service.dart';
import 'package:jfit/core/utils/bloc_performance_monitor.dart';
import 'package:jfit/core/utils/network_request_optimizer.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Program related imports
import '../../features/programs/data/datasources/program_remote_datasource.dart';
import '../../features/programs/data/repositories/program_repository_impl.dart';
import '../../features/programs/domain/repositories/program_repository.dart';
import '../../features/programs/presentation/bloc/programs_bloc.dart';

// Meal related imports
import '../../features/meal/data/repositories/meal_repository.dart';
import '../../features/meal/data/repositories/meal_repository_impl.dart';
import '../../features/meal/bloc/meal_bloc.dart';

// Workout Program related imports
import '../../features/workout_program/data/repositories/workout_program_repository.dart';
import '../../features/workout_program/data/repositories/workout_program_repository_impl.dart';
import '../../features/workout_program/bloc/workout_program_bloc.dart';

// Workout Session related imports
import '../../features/workout_session/data/repositories/workout_session_repository.dart';
import '../../features/workout_session/data/repositories/workout_session_repository_impl.dart';
import '../../features/workout_session/bloc/workout_session_bloc.dart';

// Daily Summary related imports
import '../../features/daily_summary/data/repositories/daily_summary_repository.dart';
import '../../features/daily_summary/data/repositories/daily_summary_repository_impl.dart';
import '../../features/daily_summary/bloc/daily_summary_bloc.dart';

// Exercise related imports
import '../../features/exercise/data/repositories/exercise_repository.dart';
import '../../features/exercise/data/repositories/exercise_repository_impl.dart';
import '../../features/exercise/bloc/exercise_bloc.dart';

// Analytics related imports
import '../../features/analytics/presentation/bloc/analytics_bloc.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import '../../features/analytics/data/repositories/supabase_analytics_repository.dart';

// Record related imports (legacy)
import '../../features/records/data/repositories/record_repository.dart';

// Todo related imports
import '../../features/todo/data/repositories/todo_repository.dart';
import '../../features/todo/data/repositories/todo_repository_impl.dart';
import '../../features/todo/bloc/todo_bloc.dart';



final getIt = GetIt.instance;

void setupDependencies() {
  try {
    _setupCoreDependencies();
    _setupRepositories();
    _setupBlocs();
    _validateCriticalDependencies();
  } catch (e) {
    print('Error during dependency setup: $e');
    // Continue with partial setup to avoid complete app failure
    _setupFallbackDependencies();
  }
}

/// Setup core dependencies like Supabase client and services
void _setupCoreDependencies() {
  // Supabase Client with error handling
  getIt.registerLazySingleton<SupabaseClient>(
    () {
      try {
        return Supabase.instance.client;
      } catch (e) {
        print('Failed to get Supabase client: $e');
        rethrow;
      }
    },
  );

  // Services
  getIt.registerLazySingleton<SupabaseService>(
    () {
      try {
        return SupabaseService(getIt<SupabaseClient>());
      } catch (e) {
        print('Failed to create SupabaseService: $e');
        rethrow;
      }
    },
  );

  // Performance monitoring utilities
  getIt.registerLazySingleton<BlocPerformanceMonitor>(
    () => BlocPerformanceMonitor(),
  );

  getIt.registerLazySingleton<NetworkRequestOptimizer>(
    () => NetworkRequestOptimizer(),
  );
}

/// Setup repositories with enhanced error handling
void _setupRepositories() {
  // Data Sources
  getIt.registerLazySingleton<ProgramRemoteDataSource>(
    () {
      try {
        return ProgramRemoteDataSourceImpl(supabaseClient: getIt<SupabaseClient>());
      } catch (e) {
        print('Failed to create ProgramRemoteDataSource: $e');
        rethrow;
      }
    },
  );

  // Repositories with enhanced error handling
  getIt.registerLazySingleton<ProgramRepository>(
    () {
      try {
        return ProgramRepositoryImpl(
          remoteDataSource: getIt<ProgramRemoteDataSource>(),
          supabaseClient: getIt<SupabaseClient>(),
        );
      } catch (e) {
        print('Failed to create ProgramRepository: $e');
        rethrow;
      }
    },
  );

  getIt.registerLazySingleton<MealRepository>(
    () {
      try {
        return MealRepositoryImpl(supabaseClient: getIt<SupabaseClient>());
      } catch (e) {
        print('Failed to create MealRepository: $e');
        rethrow;
      }
    },
  );

  getIt.registerLazySingleton<WorkoutProgramRepository>(
    () {
      try {
        final supabaseClient = getIt<SupabaseClient>();
        return WorkoutProgramRepositoryImpl(supabaseClient: supabaseClient);
      } catch (e) {
        print('Failed to inject SupabaseClient for WorkoutProgramRepository: $e');
        // Try to use Supabase.instance.client as fallback
        try {
          return WorkoutProgramRepositoryImpl(supabaseClient: Supabase.instance.client);
        } catch (fallbackError) {
          print('Fallback WorkoutProgramRepository creation also failed: $fallbackError');
          rethrow;
        }
      }
    },
  );

  getIt.registerLazySingleton<WorkoutSessionRepository>(
    () {
      try {
        return WorkoutSessionRepositoryImpl(supabaseClient: getIt<SupabaseClient>());
      } catch (e) {
        print('Failed to create WorkoutSessionRepository: $e');
        rethrow;
      }
    },
  );

  getIt.registerLazySingleton<DailySummaryRepository>(
    () {
      try {
        return DailySummaryRepositoryImpl(supabaseClient: getIt<SupabaseClient>());
      } catch (e) {
        print('Failed to create DailySummaryRepository: $e');
        rethrow;
      }
    },
  );

  getIt.registerLazySingleton<ExerciseRepository>(
    () {
      try {
        return ExerciseRepositoryImpl(supabaseClient: getIt<SupabaseClient>());
      } catch (e) {
        print('Failed to create ExerciseRepository: $e');
        rethrow;
      }
    },
  );

  getIt.registerLazySingleton<AnalyticsRepository>(
    () {
      try {
        return SupabaseAnalyticsRepository();
      } catch (e) {
        print('Failed to create AnalyticsRepository: $e');
        rethrow;
      }
    },
  );

  // Legacy RecordRepository for backward compatibility
  getIt.registerLazySingleton<RecordRepository>(
    () {
      try {
        return RecordRepository();
      } catch (e) {
        print('Failed to create RecordRepository: $e');
        rethrow;
      }
    },
  );

  getIt.registerLazySingleton<TodoRepository>(
    () {
      try {
        return TodoRepositoryImpl(supabaseClient: getIt<SupabaseClient>());
      } catch (e) {
        print('Failed to create TodoRepository: $e');
        rethrow;
      }
    },
  );
}

/// Setup BLoCs with enhanced error handling
void _setupBlocs() {
  getIt.registerFactory<ProgramsBloc>(
    () {
      try {
        return ProgramsBloc(repository: getIt<ProgramRepository>());
      } catch (e) {
        print('Failed to create ProgramsBloc: $e');
        rethrow;
      }
    },
  );

  getIt.registerFactory<MealBloc>(
    () {
      try {
        return MealBloc(mealRepository: getIt<MealRepository>());
      } catch (e) {
        print('Failed to create MealBloc: $e');
        rethrow;
      }
    },
  );

  getIt.registerFactory<WorkoutProgramBloc>(
    () {
      try {
        final repository = getIt<WorkoutProgramRepository>();
        return WorkoutProgramBloc(workoutProgramRepository: repository);
      } catch (e) {
        // Log the error and create BLoC without repository
        // The BLoC will use the repository manager to get the repository
        print('Failed to inject WorkoutProgramRepository for WorkoutProgramBloc: $e');
        return WorkoutProgramBloc();
      }
    },
  );

  getIt.registerFactory<WorkoutSessionBloc>(
    () {
      try {
        return WorkoutSessionBloc(repository: getIt<WorkoutSessionRepository>());
      } catch (e) {
        print('Failed to create WorkoutSessionBloc: $e');
        rethrow;
      }
    },
  );

  getIt.registerFactory<DailySummaryBloc>(
    () {
      try {
        return DailySummaryBloc(repository: getIt<DailySummaryRepository>());
      } catch (e) {
        print('Failed to create DailySummaryBloc: $e');
        rethrow;
      }
    },
  );

  getIt.registerFactory<ExerciseBloc>(
    () {
      try {
        return ExerciseBloc(repository: getIt<ExerciseRepository>());
      } catch (e) {
        print('Failed to create ExerciseBloc: $e');
        rethrow;
      }
    },
  );

  getIt.registerFactory<AnalyticsBloc>(
    () {
      try {
        return AnalyticsBloc(analyticsRepository: getIt<AnalyticsRepository>());
      } catch (e) {
        print('Failed to create AnalyticsBloc: $e');
        rethrow;
      }
    },
  );

  getIt.registerFactory<TodoBloc>(
    () {
      try {
        return TodoBloc(repository: getIt<TodoRepository>());
      } catch (e) {
        print('Failed to create TodoBloc: $e');
        rethrow;
      }
    },
  );
}

/// Validate that critical dependencies are properly registered and functional
void _validateCriticalDependencies() {
  final criticalDependencies = [
    SupabaseClient,
    WorkoutProgramRepository,
  ];

  // Validate SupabaseClient
  try {
    if (!getIt.isRegistered<SupabaseClient>()) {
      throw Exception('Critical dependency SupabaseClient is not registered');
    }
    
    final supabaseClient = getIt<SupabaseClient>();
    if (supabaseClient == null) {
      throw Exception('Critical dependency SupabaseClient resolved to null');
    }
    
    print('✓ Critical dependency SupabaseClient validated successfully');
  } catch (e) {
    print('✗ Critical dependency validation failed for SupabaseClient: $e');
    rethrow;
  }

  // Validate WorkoutProgramRepository (with fallback tolerance)
  try {
    if (!getIt.isRegistered<WorkoutProgramRepository>()) {
      throw Exception('Critical dependency WorkoutProgramRepository is not registered');
    }
    
    final repository = getIt<WorkoutProgramRepository>();
    if (repository == null) {
      throw Exception('Critical dependency WorkoutProgramRepository resolved to null');
    }
    
    print('✓ Critical dependency WorkoutProgramRepository validated successfully');
  } catch (e) {
    print('✗ Critical dependency validation failed for WorkoutProgramRepository: $e');
    print('  → WorkoutProgramRepository validation failed, but BLoC has fallback mechanisms');
    // Continue execution as BLoC has fallback mechanisms
  }
}

/// Setup fallback dependencies when main setup fails
void _setupFallbackDependencies() {
  print('Setting up fallback dependencies...');
  
  // Ensure at least WorkoutProgramBloc can be created even if repository setup fails
  if (!getIt.isRegistered<WorkoutProgramBloc>()) {
    try {
      getIt.registerFactory<WorkoutProgramBloc>(
        () {
          print('Creating WorkoutProgramBloc with fallback configuration');
          return WorkoutProgramBloc(); // Will use repository manager
        },
      );
      print('✓ Fallback WorkoutProgramBloc registered successfully');
    } catch (e) {
      print('✗ Failed to register fallback WorkoutProgramBloc: $e');
    }
  }
}

/// Check the health of repository dependencies
bool checkRepositoryHealth() {
  try {
    // Check if WorkoutProgramRepository is available and functional
    if (getIt.isRegistered<WorkoutProgramRepository>()) {
      final repository = getIt<WorkoutProgramRepository>();
      return repository != null;
    }
    return false;
  } catch (e) {
    print('Repository health check failed: $e');
    return false;
  }
}

/// Reset all dependencies (useful for testing)
void resetDependencies() {
  getIt.reset();
} 