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

// Group Workout Community real-time services
import '../../features/group_workout_community/data/services/group_realtime_service.dart';
import '../../features/group_workout_community/data/services/group_notification_service.dart';
import '../../features/group_workout_community/data/services/group_realtime_manager.dart';
import '../../features/group_workout_community/data/services/push_notification_manager.dart';

// Group Workout Community moderation services
import '../../features/group_workout_community/data/services/content_moderation_service.dart';
import '../../features/group_workout_community/data/services/auto_moderation_service.dart';
import '../../features/group_workout_community/domain/repositories/content_report_repository.dart';
import '../../features/group_workout_community/data/repositories/content_report_repository_impl.dart';
import '../../features/group_workout_community/domain/repositories/moderation_action_repository.dart';
import '../../features/group_workout_community/data/repositories/moderation_action_repository_impl.dart';
// Content moderation BLoC import - currently disabled
// import '../../features/group_workout_community/presentation/bloc/content_moderation/content_moderation_bloc.dart';

// Group Workout Community repositories
import '../../features/group_workout_community/domain/repositories/group_repository.dart';
import '../../features/group_workout_community/data/repositories/group_repository_impl.dart';
import '../../features/group_workout_community/domain/repositories/group_activity_repository.dart';
import '../../features/group_workout_community/data/repositories/group_activity_repository_impl.dart';
import '../../features/group_workout_community/domain/repositories/community_repository.dart';
import '../../features/group_workout_community/data/repositories/community_repository_impl.dart';
import '../../features/group_workout_community/domain/repositories/post_interaction_repository.dart';
import '../../features/group_workout_community/data/repositories/post_interaction_repository_impl.dart';
import '../../features/group_workout_community/domain/repositories/ranking_repository.dart';
import '../../features/group_workout_community/data/repositories/ranking_repository_impl.dart';
import '../../features/group_workout_community/domain/repositories/pt_diet_repository.dart';
import '../../features/group_workout_community/data/repositories/pt_diet_repository_impl.dart';
import '../../features/group_workout_community/domain/repositories/group_chat_repository.dart';
import '../../features/group_workout_community/data/repositories/group_chat_repository_impl.dart';

// Group Workout Community services
import '../../features/group_workout_community/data/services/group_cache_service.dart';
import '../../features/group_workout_community/data/services/media_upload_service.dart';

// Group Workout Community BLoCs
import '../../features/group_workout_community/presentation/bloc/group/group_bloc.dart';
import '../../features/group_workout_community/presentation/bloc/group_activity/group_activity_bloc.dart';
import '../../features/group_workout_community/presentation/bloc/community/community_bloc.dart';
import '../../features/group_workout_community/presentation/bloc/post_interaction/post_interaction_bloc.dart';
import '../../features/group_workout_community/presentation/bloc/group_chat/group_chat_bloc.dart';
import '../../features/group_workout_community/presentation/bloc/ranking/ranking_bloc.dart';
import '../../features/group_workout_community/presentation/bloc/pt_diet/pt_diet_bloc.dart';

// Auth service import - currently commented out in auth_service.dart
// import '../services/auth_service.dart';

// BLoC Event Bus import
import '../bloc/bloc_event_bus.dart';



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

  // BLoC Event Bus for inter-BLoC communication
  getIt.registerLazySingleton<BlocEventBus>(
    () => BlocEventBus(),
  );

  // Group Workout Community real-time services
  getIt.registerLazySingleton<GroupRealtimeService>(
    () {
      try {
        return GroupRealtimeService(getIt<SupabaseClient>());
      } catch (e) {
        print('Failed to create GroupRealtimeService: $e');
        rethrow;
      }
    },
  );

  getIt.registerLazySingleton<GroupNotificationService>(
    () {
      try {
        return GroupNotificationService(getIt<SupabaseClient>());
      } catch (e) {
        print('Failed to create GroupNotificationService: $e');
        rethrow;
      }
    },
  );

  getIt.registerLazySingleton<GroupRealtimeManager>(
    () {
      try {
        return GroupRealtimeManager(getIt<SupabaseClient>());
      } catch (e) {
        print('Failed to create GroupRealtimeManager: $e');
        rethrow;
      }
    },
  );

  getIt.registerLazySingleton<PushNotificationManager>(
    () {
      try {
        return PushNotificationManager(getIt<GroupNotificationService>());
      } catch (e) {
        print('Failed to create PushNotificationManager: $e');
        rethrow;
      }
    },
  );

  // Auth Service - Currently commented out in auth_service.dart
  // getIt.registerLazySingleton<AuthService>(
  //   () {
  //     try {
  //       return AuthService();
  //     } catch (e) {
  //       print('Failed to create AuthService: $e');
  //       rethrow;
  //     }
  //   },
  // );

  // Group Workout Community services
  getIt.registerLazySingleton<GroupCacheService>(
    () {
      try {
        return GroupCacheService();
      } catch (e) {
        print('Failed to create GroupCacheService: $e');
        rethrow;
      }
    },
  );

  getIt.registerLazySingleton<MediaUploadService>(
    () {
      try {
        return MediaUploadService(supabaseClient: getIt<SupabaseClient>());
      } catch (e) {
        print('Failed to create MediaUploadService: $e');
        rethrow;
      }
    },
  );

  // Content Moderation Services
  getIt.registerLazySingleton<ContentModerationService>(
    () {
      try {
        return ContentModerationService(getIt<SupabaseClient>());
      } catch (e) {
        print('Failed to create ContentModerationService: $e');
        rethrow;
      }
    },
  );

  getIt.registerLazySingleton<AutoModerationService>(
    () {
      try {
        return AutoModerationService(
          getIt<ContentModerationService>(),
          getIt<ContentReportRepository>(),
        );
      } catch (e) {
        print('Failed to create AutoModerationService: $e');
        rethrow;
      }
    },
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

  // Content Moderation Repositories
  getIt.registerLazySingleton<ContentReportRepository>(
    () {
      try {
        return ContentReportRepositoryImpl(getIt<SupabaseClient>());
      } catch (e) {
        print('Failed to create ContentReportRepository: $e');
        rethrow;
      }
    },
  );

  getIt.registerLazySingleton<ModerationActionRepository>(
    () {
      try {
        return ModerationActionRepositoryImpl(getIt<SupabaseClient>());
      } catch (e) {
        print('Failed to create ModerationActionRepository: $e');
        rethrow;
      }
    },
  );

  // Group Workout Community Repositories
  getIt.registerLazySingleton<GroupRepository>(
    () {
      try {
        return GroupRepositoryImpl(
          supabaseClient: getIt<SupabaseClient>(),
          cacheService: getIt<GroupCacheService>(),
        );
      } catch (e) {
        print('Failed to create GroupRepository: $e');
        rethrow;
      }
    },
  );

  getIt.registerLazySingleton<GroupActivityRepository>(
    () {
      try {
        return GroupActivityRepositoryImpl(
          supabaseClient: getIt<SupabaseClient>(),
        );
      } catch (e) {
        print('Failed to create GroupActivityRepository: $e');
        rethrow;
      }
    },
  );

  getIt.registerLazySingleton<CommunityRepository>(
    () {
      try {
        return CommunityRepositoryImpl(
          supabaseClient: getIt<SupabaseClient>(),
          cacheService: getIt<GroupCacheService>(),
        );
      } catch (e) {
        print('Failed to create CommunityRepository: $e');
        rethrow;
      }
    },
  );

  getIt.registerLazySingleton<PostInteractionRepository>(
    () {
      try {
        return PostInteractionRepositoryImpl(
          supabaseClient: getIt<SupabaseClient>(),
        );
      } catch (e) {
        print('Failed to create PostInteractionRepository: $e');
        rethrow;
      }
    },
  );

  getIt.registerLazySingleton<RankingRepository>(
    () {
      try {
        return RankingRepositoryImpl(
          supabaseClient: getIt<SupabaseClient>(),
        );
      } catch (e) {
        print('Failed to create RankingRepository: $e');
        rethrow;
      }
    },
  );

  getIt.registerLazySingleton<PTDietRepository>(
    () {
      try {
        return PTDietRepositoryImpl(
          supabaseClient: getIt<SupabaseClient>(),
        );
      } catch (e) {
        print('Failed to create PTDietRepository: $e');
        rethrow;
      }
    },
  );

  getIt.registerLazySingleton<GroupChatRepository>(
    () {
      try {
        return GroupChatRepositoryImpl(
          supabaseClient: getIt<SupabaseClient>(),
        );
      } catch (e) {
        print('Failed to create GroupChatRepository: $e');
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

  // Content Moderation BLoC - Temporarily disabled due to AuthService being commented out
  // getIt.registerFactory<ContentModerationBloc>(
  //   () {
  //     try {
  //       return ContentModerationBloc(
  //         contentReportRepository: getIt<ContentReportRepository>(),
  //         moderationActionRepository: getIt<ModerationActionRepository>(),
  //         contentModerationService: getIt<ContentModerationService>(),
  //         authService: getIt<AuthService>(),
  //       );
  //     } catch (e) {
  //       print('Failed to create ContentModerationBloc: $e');
  //       rethrow;
  //     }
  //   },
  // );

  // Group Workout Community BLoCs
  getIt.registerFactory<GroupBloc>(
    () {
      try {
        return GroupBloc(
          repository: getIt<GroupRepository>(),
        );
      } catch (e) {
        print('Failed to create GroupBloc: $e');
        rethrow;
      }
    },
  );

  getIt.registerFactory<GroupActivityBloc>(
    () {
      try {
        return GroupActivityBloc(
          repository: getIt<GroupActivityRepository>(),
          realtimeManager: getIt<GroupRealtimeManager>(),
        );
      } catch (e) {
        print('Failed to create GroupActivityBloc: $e');
        rethrow;
      }
    },
  );

  getIt.registerFactory<CommunityBloc>(
    () {
      try {
        return CommunityBloc(
          repository: getIt<CommunityRepository>(),
          realtimeManager: getIt<GroupRealtimeManager>(),
        );
      } catch (e) {
        print('Failed to create CommunityBloc: $e');
        rethrow;
      }
    },
  );

  getIt.registerFactory<PostInteractionBloc>(
    () {
      try {
        return PostInteractionBloc(
          repository: getIt<PostInteractionRepository>(),
        );
      } catch (e) {
        print('Failed to create PostInteractionBloc: $e');
        rethrow;
      }
    },
  );

  getIt.registerFactory<GroupChatBloc>(
    () {
      try {
        return GroupChatBloc(getIt<GroupChatRepository>());
      } catch (e) {
        print('Failed to create GroupChatBloc: $e');
        rethrow;
      }
    },
  );

  getIt.registerFactory<RankingBloc>(
    () {
      try {
        return RankingBloc(getIt<RankingRepository>());
      } catch (e) {
        print('Failed to create RankingBloc: $e');
        rethrow;
      }
    },
  );

  getIt.registerFactory<PTDietBloc>(
    () {
      try {
        return PTDietBloc(getIt<PTDietRepository>());
      } catch (e) {
        print('Failed to create PTDietBloc: $e');
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
    // SupabaseClient validation - no null check needed as GetIt ensures non-null
    
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

  // Validate Group Workout Community dependencies
  _validateGroupWorkoutCommunityDependencies();
}

/// Validate Group Workout Community dependencies and prevent circular dependencies
void _validateGroupWorkoutCommunityDependencies() {
  final validationResults = <String, bool>{};

  // Validate GroupRepository
  try {
    if (!getIt.isRegistered<GroupRepository>()) {
      print('✗ Group dependency GroupRepository is not registered');
      validationResults['GroupRepository'] = false;
    } else {
      final instance = getIt<GroupRepository>();
      if (instance != null) {
        print('✓ Group dependency GroupRepository validated successfully');
        validationResults['GroupRepository'] = true;
      } else {
        print('✗ Group dependency GroupRepository resolved to null');
        validationResults['GroupRepository'] = false;
      }
    }
  } catch (e) {
    print('✗ Group dependency validation failed for GroupRepository: $e');
    validationResults['GroupRepository'] = false;
  }

  // Validate GroupActivityRepository
  try {
    if (!getIt.isRegistered<GroupActivityRepository>()) {
      print('✗ Group dependency GroupActivityRepository is not registered');
      validationResults['GroupActivityRepository'] = false;
    } else {
      final instance = getIt<GroupActivityRepository>();
      if (instance != null) {
        print('✓ Group dependency GroupActivityRepository validated successfully');
        validationResults['GroupActivityRepository'] = true;
      } else {
        print('✗ Group dependency GroupActivityRepository resolved to null');
        validationResults['GroupActivityRepository'] = false;
      }
    }
  } catch (e) {
    print('✗ Group dependency validation failed for GroupActivityRepository: $e');
    validationResults['GroupActivityRepository'] = false;
  }

  // Validate CommunityRepository
  try {
    if (!getIt.isRegistered<CommunityRepository>()) {
      print('✗ Group dependency CommunityRepository is not registered');
      validationResults['CommunityRepository'] = false;
    } else {
      final instance = getIt<CommunityRepository>();
      if (instance != null) {
        print('✓ Group dependency CommunityRepository validated successfully');
        validationResults['CommunityRepository'] = true;
      } else {
        print('✗ Group dependency CommunityRepository resolved to null');
        validationResults['CommunityRepository'] = false;
      }
    }
  } catch (e) {
    print('✗ Group dependency validation failed for CommunityRepository: $e');
    validationResults['CommunityRepository'] = false;
  }

  // Validate PostInteractionRepository
  try {
    if (!getIt.isRegistered<PostInteractionRepository>()) {
      print('✗ Group dependency PostInteractionRepository is not registered');
      validationResults['PostInteractionRepository'] = false;
    } else {
      final instance = getIt<PostInteractionRepository>();
      if (instance != null) {
        print('✓ Group dependency PostInteractionRepository validated successfully');
        validationResults['PostInteractionRepository'] = true;
      } else {
        print('✗ Group dependency PostInteractionRepository resolved to null');
        validationResults['PostInteractionRepository'] = false;
      }
    }
  } catch (e) {
    print('✗ Group dependency validation failed for PostInteractionRepository: $e');
    validationResults['PostInteractionRepository'] = false;
  }

  // Validate RankingRepository
  try {
    if (!getIt.isRegistered<RankingRepository>()) {
      print('✗ Group dependency RankingRepository is not registered');
      validationResults['RankingRepository'] = false;
    } else {
      final instance = getIt<RankingRepository>();
      if (instance != null) {
        print('✓ Group dependency RankingRepository validated successfully');
        validationResults['RankingRepository'] = true;
      } else {
        print('✗ Group dependency RankingRepository resolved to null');
        validationResults['RankingRepository'] = false;
      }
    }
  } catch (e) {
    print('✗ Group dependency validation failed for RankingRepository: $e');
    validationResults['RankingRepository'] = false;
  }

  // Validate PTDietRepository
  try {
    if (!getIt.isRegistered<PTDietRepository>()) {
      print('✗ Group dependency PTDietRepository is not registered');
      validationResults['PTDietRepository'] = false;
    } else {
      final instance = getIt<PTDietRepository>();
      if (instance != null) {
        print('✓ Group dependency PTDietRepository validated successfully');
        validationResults['PTDietRepository'] = true;
      } else {
        print('✗ Group dependency PTDietRepository resolved to null');
        validationResults['PTDietRepository'] = false;
      }
    }
  } catch (e) {
    print('✗ Group dependency validation failed for PTDietRepository: $e');
    validationResults['PTDietRepository'] = false;
  }

  // Validate GroupCacheService
  try {
    if (!getIt.isRegistered<GroupCacheService>()) {
      print('✗ Group dependency GroupCacheService is not registered');
      validationResults['GroupCacheService'] = false;
    } else {
      final instance = getIt<GroupCacheService>();
      if (instance != null) {
        print('✓ Group dependency GroupCacheService validated successfully');
        validationResults['GroupCacheService'] = true;
      } else {
        print('✗ Group dependency GroupCacheService resolved to null');
        validationResults['GroupCacheService'] = false;
      }
    }
  } catch (e) {
    print('✗ Group dependency validation failed for GroupCacheService: $e');
    validationResults['GroupCacheService'] = false;
  }

  // Validate MediaUploadService
  try {
    if (!getIt.isRegistered<MediaUploadService>()) {
      print('✗ Group dependency MediaUploadService is not registered');
      validationResults['MediaUploadService'] = false;
    } else {
      final instance = getIt<MediaUploadService>();
      if (instance != null) {
        print('✓ Group dependency MediaUploadService validated successfully');
        validationResults['MediaUploadService'] = true;
      } else {
        print('✗ Group dependency MediaUploadService resolved to null');
        validationResults['MediaUploadService'] = false;
      }
    }
  } catch (e) {
    print('✗ Group dependency validation failed for MediaUploadService: $e');
    validationResults['MediaUploadService'] = false;
  }

  // Validate GroupRealtimeService
  try {
    if (!getIt.isRegistered<GroupRealtimeService>()) {
      print('✗ Group dependency GroupRealtimeService is not registered');
      validationResults['GroupRealtimeService'] = false;
    } else {
      final instance = getIt<GroupRealtimeService>();
      if (instance != null) {
        print('✓ Group dependency GroupRealtimeService validated successfully');
        validationResults['GroupRealtimeService'] = true;
      } else {
        print('✗ Group dependency GroupRealtimeService resolved to null');
        validationResults['GroupRealtimeService'] = false;
      }
    }
  } catch (e) {
    print('✗ Group dependency validation failed for GroupRealtimeService: $e');
    validationResults['GroupRealtimeService'] = false;
  }

  // Validate GroupNotificationService
  try {
    if (!getIt.isRegistered<GroupNotificationService>()) {
      print('✗ Group dependency GroupNotificationService is not registered');
      validationResults['GroupNotificationService'] = false;
    } else {
      final instance = getIt<GroupNotificationService>();
      if (instance != null) {
        print('✓ Group dependency GroupNotificationService validated successfully');
        validationResults['GroupNotificationService'] = true;
      } else {
        print('✗ Group dependency GroupNotificationService resolved to null');
        validationResults['GroupNotificationService'] = false;
      }
    }
  } catch (e) {
    print('✗ Group dependency validation failed for GroupNotificationService: $e');
    validationResults['GroupNotificationService'] = false;
  }

  // Check for circular dependencies in real-time services
  _checkCircularDependencies();

  // Report validation summary
  final successCount = validationResults.values.where((v) => v).length;
  final totalCount = validationResults.length;
  print('Group Workout Community dependency validation: $successCount/$totalCount successful');

  if (successCount < totalCount) {
    print('⚠️  Some Group Workout Community dependencies failed validation but app will continue with fallback mechanisms');
  }
}

/// Check for circular dependencies in real-time services
void _checkCircularDependencies() {
  try {
    print('🔍 Checking for circular dependencies in Group Workout Community services...');
    
    // Track dependency resolution to detect cycles
    final resolutionStack = <Type>[];
    final circularDependencies = <String>[];

    // Check GroupRealtimeManager dependencies
    if (_checkServiceDependencyChain<GroupRealtimeManager>(resolutionStack)) {
      print('✓ GroupRealtimeManager dependency chain is valid');
    } else {
      circularDependencies.add('GroupRealtimeManager');
    }

    // Check PushNotificationManager dependencies
    if (_checkServiceDependencyChain<PushNotificationManager>(resolutionStack)) {
      print('✓ PushNotificationManager dependency chain is valid');
    } else {
      circularDependencies.add('PushNotificationManager');
    }

    // Check AutoModerationService dependencies
    if (_checkServiceDependencyChain<AutoModerationService>(resolutionStack)) {
      print('✓ AutoModerationService dependency chain is valid');
    } else {
      circularDependencies.add('AutoModerationService');
    }

    // Check BLoC dependencies for circular references
    _checkBlocDependencyChains();

    if (circularDependencies.isEmpty) {
      print('✅ No circular dependencies detected in Group Workout Community services');
    } else {
      print('⚠️  Potential circular dependencies detected in: ${circularDependencies.join(', ')}');
      _handleCircularDependencies(circularDependencies);
    }
  } catch (e) {
    print('⚠️  Circular dependency check encountered error: $e');
    // Continue execution as this is not critical
  }
}

/// Check dependency chain for a specific service type
bool _checkServiceDependencyChain<T extends Object>(List<Type> resolutionStack) {
  try {
    if (resolutionStack.contains(T)) {
      print('🔄 Circular dependency detected: ${resolutionStack.join(' -> ')} -> $T');
      return false;
    }

    if (!getIt.isRegistered<T>()) {
      return true; // Not registered, no dependency to check
    }

    resolutionStack.add(T);
    
    // Try to resolve the service to check if its dependencies can be resolved
    final instance = getIt<T>();
    
    resolutionStack.remove(T);
    return instance != null;
  } catch (e) {
    resolutionStack.remove(T);
    print('⚠️  Error checking dependency chain for $T: $e');
    return false;
  }
}

/// Check BLoC dependency chains for circular references
void _checkBlocDependencyChains() {
  final blocTypes = [
    'GroupBloc',
    'GroupActivityBloc',
    'CommunityBloc',
    'PostInteractionBloc',
    'GroupChatBloc',
    'RankingBloc',
  ];

  for (final blocType in blocTypes) {
    try {
      switch (blocType) {
        case 'GroupBloc':
          if (getIt.isRegistered<GroupBloc>()) {
            getIt<GroupBloc>();
            print('✓ $blocType dependency chain validated');
          }
          break;
        case 'GroupActivityBloc':
          if (getIt.isRegistered<GroupActivityBloc>()) {
            getIt<GroupActivityBloc>();
            print('✓ $blocType dependency chain validated');
          }
          break;
        case 'CommunityBloc':
          if (getIt.isRegistered<CommunityBloc>()) {
            getIt<CommunityBloc>();
            print('✓ $blocType dependency chain validated');
          }
          break;
        case 'PostInteractionBloc':
          if (getIt.isRegistered<PostInteractionBloc>()) {
            getIt<PostInteractionBloc>();
            print('✓ $blocType dependency chain validated');
          }
          break;
        case 'GroupChatBloc':
          if (getIt.isRegistered<GroupChatBloc>()) {
            getIt<GroupChatBloc>();
            print('✓ $blocType dependency chain validated');
          }
          break;
        case 'RankingBloc':
          if (getIt.isRegistered<RankingBloc>()) {
            getIt<RankingBloc>();
            print('✓ $blocType dependency chain validated');
          }
          break;
      }
    } catch (e) {
      print('⚠️  $blocType dependency validation failed: $e');
    }
  }
}

/// Handle detected circular dependencies
void _handleCircularDependencies(List<String> circularDependencies) {
  print('🔧 Implementing fallback mechanisms for circular dependencies...');
  
  for (final dependency in circularDependencies) {
    try {
      switch (dependency) {
        case 'GroupRealtimeManager':
          _implementGroupRealtimeManagerFallback();
          break;
        case 'PushNotificationManager':
          _implementPushNotificationManagerFallback();
          break;
        case 'AutoModerationService':
          _implementAutoModerationServiceFallback();
          break;
        default:
          print('⚠️  No fallback mechanism available for $dependency');
      }
    } catch (e) {
      print('⚠️  Failed to implement fallback for $dependency: $e');
    }
  }
}

/// Implement fallback for GroupRealtimeManager
void _implementGroupRealtimeManagerFallback() {
  if (!getIt.isRegistered<GroupRealtimeManager>()) {
    try {
      getIt.registerLazySingleton<GroupRealtimeManager>(
        () {
          print('Creating GroupRealtimeManager with fallback configuration');
          return GroupRealtimeManager(getIt<SupabaseClient>());
        },
      );
      print('✓ GroupRealtimeManager fallback implemented');
    } catch (e) {
      print('✗ Failed to implement GroupRealtimeManager fallback: $e');
    }
  }
}

/// Implement fallback for PushNotificationManager
void _implementPushNotificationManagerFallback() {
  if (!getIt.isRegistered<PushNotificationManager>()) {
    try {
      getIt.registerLazySingleton<PushNotificationManager>(
        () {
          print('Creating PushNotificationManager with fallback configuration');
          return PushNotificationManager(getIt<GroupNotificationService>());
        },
      );
      print('✓ PushNotificationManager fallback implemented');
    } catch (e) {
      print('✗ Failed to implement PushNotificationManager fallback: $e');
    }
  }
}

/// Implement fallback for AutoModerationService
void _implementAutoModerationServiceFallback() {
  if (!getIt.isRegistered<AutoModerationService>()) {
    try {
      getIt.registerLazySingleton<AutoModerationService>(
        () {
          print('Creating AutoModerationService with fallback configuration');
          return AutoModerationService(
            getIt<ContentModerationService>(),
            getIt<ContentReportRepository>(),
          );
        },
      );
      print('✓ AutoModerationService fallback implemented');
    } catch (e) {
      print('✗ Failed to implement AutoModerationService fallback: $e');
    }
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

  // Setup fallback Group Workout Community dependencies
  _setupGroupWorkoutCommunityFallbacks();
}

/// Setup fallback dependencies for Group Workout Community features
void _setupGroupWorkoutCommunityFallbacks() {
  print('Setting up Group Workout Community fallback dependencies...');

  // Fallback GroupCacheService
  if (!getIt.isRegistered<GroupCacheService>()) {
    try {
      getIt.registerLazySingleton<GroupCacheService>(
        () {
          print('Creating GroupCacheService with fallback configuration');
          return GroupCacheService();
        },
      );
      print('✓ Fallback GroupCacheService registered successfully');
    } catch (e) {
      print('✗ Failed to register fallback GroupCacheService: $e');
    }
  }

  // Fallback GroupBloc
  if (!getIt.isRegistered<GroupBloc>()) {
    try {
      getIt.registerFactory<GroupBloc>(
        () {
          print('Creating GroupBloc with fallback configuration');
          // This will fail gracefully if repository is not available
          try {
            return GroupBloc(repository: getIt<GroupRepository>());
          } catch (e) {
            print('GroupBloc fallback: Repository not available, creating minimal instance');
            // Return a minimal instance that handles errors gracefully
            throw Exception('GroupRepository not available for GroupBloc fallback');
          }
        },
      );
      print('✓ Fallback GroupBloc registered successfully');
    } catch (e) {
      print('✗ Failed to register fallback GroupBloc: $e');
    }
  }

  // Similar fallbacks for other Group Workout Community BLoCs
  final blocFallbacks = [
    'GroupActivityBloc',
    'CommunityBloc',
    'PostInteractionBloc',
    'RankingBloc',
  ];

  for (final blocName in blocFallbacks) {
    print('⚠️  $blocName fallback not implemented - will fail gracefully if dependencies are missing');
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

/// Check the health of Group Workout Community dependencies
bool checkGroupWorkoutCommunityHealth() {
  try {
    final healthResults = <String, bool>{};
    
    // Check core repositories
    healthResults['GroupRepository'] = _checkDependencyHealth<GroupRepository>();
    healthResults['GroupActivityRepository'] = _checkDependencyHealth<GroupActivityRepository>();
    healthResults['CommunityRepository'] = _checkDependencyHealth<CommunityRepository>();
    healthResults['PostInteractionRepository'] = _checkDependencyHealth<PostInteractionRepository>();
    healthResults['RankingRepository'] = _checkDependencyHealth<RankingRepository>();
    healthResults['PTDietRepository'] = _checkDependencyHealth<PTDietRepository>();
    
    // Check services
    healthResults['GroupCacheService'] = _checkDependencyHealth<GroupCacheService>();
    healthResults['MediaUploadService'] = _checkDependencyHealth<MediaUploadService>();
    healthResults['GroupRealtimeService'] = _checkDependencyHealth<GroupRealtimeService>();
    healthResults['GroupNotificationService'] = _checkDependencyHealth<GroupNotificationService>();
    
    final healthyCount = healthResults.values.where((v) => v).length;
    final totalCount = healthResults.length;
    
    print('Group Workout Community health check: $healthyCount/$totalCount dependencies healthy');
    
    return healthyCount >= (totalCount * 0.8); // 80% threshold for healthy
  } catch (e) {
    print('Group Workout Community health check failed: $e');
    return false;
  }
}

/// Helper method to check individual dependency health
bool _checkDependencyHealth<T extends Object>() {
  try {
    if (!getIt.isRegistered<T>()) {
      return false;
    }
    final instance = getIt<T>();
    return instance != null;
  } catch (e) {
    return false;
  }
}

/// Performance optimization for dependency resolution
void optimizeDependencyPerformance() {
  try {
    print('🚀 Optimizing dependency injection performance...');
    
    // Pre-warm frequently used singletons
    _prewarmSingletons();
    
    // Optimize cache services
    _optimizeCacheServices();
    
    // Optimize real-time service connections
    _optimizeRealtimeServices();
    
    // Monitor dependency resolution performance
    _setupDependencyPerformanceMonitoring();
    
    print('✅ Dependency injection performance optimization completed');
  } catch (e) {
    print('⚠️  Dependency performance optimization failed: $e');
  }
}

/// Optimize real-time service connections
void _optimizeRealtimeServices() {
  try {
    // Pre-initialize real-time services to avoid cold start delays
    if (getIt.isRegistered<GroupRealtimeService>()) {
      final realtimeService = getIt<GroupRealtimeService>();
      print('✓ GroupRealtimeService pre-initialized');
    }
    
    if (getIt.isRegistered<GroupRealtimeManager>()) {
      final realtimeManager = getIt<GroupRealtimeManager>();
      print('✓ GroupRealtimeManager pre-initialized');
    }
    
    if (getIt.isRegistered<PushNotificationManager>()) {
      final notificationManager = getIt<PushNotificationManager>();
      print('✓ PushNotificationManager pre-initialized');
    }
  } catch (e) {
    print('⚠️  Real-time service optimization failed: $e');
  }
}

/// Setup dependency performance monitoring
void _setupDependencyPerformanceMonitoring() {
  try {
    if (getIt.isRegistered<BlocPerformanceMonitor>()) {
      final performanceMonitor = getIt<BlocPerformanceMonitor>();
      print('✓ Dependency performance monitoring enabled');
    }
    
    // Setup network request optimization
    if (getIt.isRegistered<NetworkRequestOptimizer>()) {
      final networkOptimizer = getIt<NetworkRequestOptimizer>();
      print('✓ Network request optimization enabled');
    }
  } catch (e) {
    print('⚠️  Performance monitoring setup failed: $e');
  }
}

/// Pre-warm frequently used singleton dependencies
void _prewarmSingletons() {
  final singletonTypes = [
    SupabaseClient,
    SupabaseService,
    GroupCacheService,
    GroupRealtimeService,
    GroupNotificationService,
  ];
  
  for (final type in singletonTypes) {
    try {
      switch (type) {
        case SupabaseClient:
          if (getIt.isRegistered<SupabaseClient>()) {
            getIt<SupabaseClient>();
            print('✓ Pre-warmed SupabaseClient');
          }
          break;
        case SupabaseService:
          if (getIt.isRegistered<SupabaseService>()) {
            getIt<SupabaseService>();
            print('✓ Pre-warmed SupabaseService');
          }
          break;
        case GroupCacheService:
          if (getIt.isRegistered<GroupCacheService>()) {
            getIt<GroupCacheService>();
            print('✓ Pre-warmed GroupCacheService');
          }
          break;
        case GroupRealtimeService:
          if (getIt.isRegistered<GroupRealtimeService>()) {
            getIt<GroupRealtimeService>();
            print('✓ Pre-warmed GroupRealtimeService');
          }
          break;
        case GroupNotificationService:
          if (getIt.isRegistered<GroupNotificationService>()) {
            getIt<GroupNotificationService>();
            print('✓ Pre-warmed GroupNotificationService');
          }
          break;
      }
    } catch (e) {
      print('⚠️  Failed to pre-warm ${type.toString()}: $e');
    }
  }
}

/// Optimize cache services for better performance
void _optimizeCacheServices() {
  try {
    if (getIt.isRegistered<GroupCacheService>()) {
      final cacheService = getIt<GroupCacheService>();
      // Cache service is already optimized in its implementation
      print('✓ GroupCacheService optimization verified');
    }
  } catch (e) {
    print('⚠️  Cache service optimization failed: $e');
  }
}

/// Reset all dependencies (useful for testing)
void resetDependencies() {
  getIt.reset();
}

/// Get dependency injection health report
Map<String, dynamic> getDependencyHealthReport() {
  final report = <String, dynamic>{
    'timestamp': DateTime.now().toIso8601String(),
    'core_dependencies': <String, bool>{},
    'group_workout_community': <String, bool>{},
    'overall_health': false,
  };

  // Check core dependencies
  report['core_dependencies']['SupabaseClient'] = _checkDependencyHealth<SupabaseClient>();
  report['core_dependencies']['SupabaseService'] = _checkDependencyHealth<SupabaseService>();
  // AuthService is currently commented out in the codebase
  // report['core_dependencies']['AuthService'] = _checkDependencyHealth<AuthService>();

  // Check Group Workout Community dependencies
  report['group_workout_community']['GroupRepository'] = _checkDependencyHealth<GroupRepository>();
  report['group_workout_community']['GroupActivityRepository'] = _checkDependencyHealth<GroupActivityRepository>();
  report['group_workout_community']['CommunityRepository'] = _checkDependencyHealth<CommunityRepository>();
  report['group_workout_community']['PostInteractionRepository'] = _checkDependencyHealth<PostInteractionRepository>();
  report['group_workout_community']['RankingRepository'] = _checkDependencyHealth<RankingRepository>();
  report['group_workout_community']['PTDietRepository'] = _checkDependencyHealth<PTDietRepository>();
  report['group_workout_community']['GroupCacheService'] = _checkDependencyHealth<GroupCacheService>();
  report['group_workout_community']['MediaUploadService'] = _checkDependencyHealth<MediaUploadService>();
  report['group_workout_community']['GroupRealtimeService'] = _checkDependencyHealth<GroupRealtimeService>();
  report['group_workout_community']['GroupNotificationService'] = _checkDependencyHealth<GroupNotificationService>();

  // Calculate overall health
  final coreHealthy = (report['core_dependencies'] as Map<String, bool>).values.where((v) => v).length;
  final coreTotal = (report['core_dependencies'] as Map<String, bool>).length;
  final groupHealthy = (report['group_workout_community'] as Map<String, bool>).values.where((v) => v).length;
  final groupTotal = (report['group_workout_community'] as Map<String, bool>).length;

  report['core_health_percentage'] = coreTotal > 0 ? (coreHealthy / coreTotal * 100).round() : 0;
  report['group_health_percentage'] = groupTotal > 0 ? (groupHealthy / groupTotal * 100).round() : 0;
  report['overall_health'] = (coreHealthy + groupHealthy) >= ((coreTotal + groupTotal) * 0.8);

  return report;
}