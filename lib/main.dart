import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

// Essential BLoCs for app startup
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/data/repositories/auth_repository.dart';

// Analytics (needed for dashboard)
import 'package:jfit/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:jfit/features/analytics/data/repositories/supabase_analytics_repository.dart';

// New BLoCs from refactoring
import 'package:jfit/features/meal/bloc/meal_bloc.dart';
import 'package:jfit/features/daily_summary/bloc/daily_summary_bloc.dart';

// Group Workout Community BLoCs
import 'package:jfit/features/group_workout_community/presentation/bloc/group/group_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group_activity/group_activity_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/community/community_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/post_interaction/post_interaction_bloc.dart';

import 'core/theme/theme_system.dart';
import 'core/theme/theme_manager.dart';
import 'core/utils/locale_manager.dart';
import 'core/utils/performance_monitor.dart';
import 'package:provider/provider.dart';
// import 'core/services/auth_service.dart'; // 주석 처리: 나중에 사용할 예정
// import 'features/auth/presentation/pages/login_page.dart'; // 주석 처리: 나중에 사용할 예정
import 'l10n/app_localizations.dart'; // 추가
import 'core/navigation/app_router.dart';
import 'core/widgets/auth_gate.dart';
import 'core/navigation/stack_logging_observer.dart';
import 'core/di/injection_container.dart';
import 'core/utils/deep_link_handler.dart';
import 'package:app_links/app_links.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Start performance monitoring
  PerformanceMonitor.startTiming('app_initialization');

  try {
    // Supabase 프로젝트 초기화 with error handling
    PerformanceMonitor.startTiming('supabase_initialization');
    final supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
    final supabaseKey = const String.fromEnvironment('SUPABASE_SERVICE_KEY', 
        defaultValue: const String.fromEnvironment('SUPABASE_ANON_KEY'));
    
    print('🔑 Supabase URL: $supabaseUrl');
    print('🔑 Supabase Key (first 20 chars): ${supabaseKey.substring(0, 20)}...');
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    PerformanceMonitor.endTiming('supabase_initialization');
    
    // 의존성 주입 초기화 with error handling
    PerformanceMonitor.startTiming('dependency_injection_setup');
    setupDependencies();
    PerformanceMonitor.endTiming('dependency_injection_setup');
    
    // 테마 매니저 초기화 with error handling
    PerformanceMonitor.startTiming('theme_manager_initialization');
    final themeManager = ThemeManager();
    await themeManager.initialize();
    PerformanceMonitor.endTiming('theme_manager_initialization');
    
    PerformanceMonitor.endTiming('app_initialization');
    PerformanceMonitor.logAllDurations();
    
    runApp(
      ChangeNotifierProvider.value(
        value: themeManager,
        child: const JFitApp(),
      ),
    );
  } catch (error, stackTrace) {
    // Log the error for debugging
    debugPrint('❌ App initialization failed: $error');
    debugPrint('Stack trace: $stackTrace');
    
    // Clear performance monitoring on error
    PerformanceMonitor.clear();
    
    // Run app with minimal configuration for error recovery
    runApp(
      MaterialApp(
        title: 'JFiT - Error',
        home: AppInitializationErrorScreen(
          error: error.toString(),
          onRetry: () => main(),
        ),
      ),
    );
  }
}

class JFitApp extends StatelessWidget {
  const JFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Only initialize essential BLoCs at startup for better performance
    return MultiBlocProvider(
      providers: [
        // Essential: Authentication is needed immediately
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(AuthRepository()),
        ),
        // Essential: Analytics for dashboard (but lazy loaded)
        BlocProvider<AnalyticsBloc>(
          lazy: true,
          create: (context) {
            try {
              debugPrint('🔧 Creating AnalyticsBloc...');
              final bloc = GetIt.instance<AnalyticsBloc>();
              debugPrint('✅ AnalyticsBloc created successfully');
              return bloc;
            } catch (e, stackTrace) {
              debugPrint('❌ Failed to create AnalyticsBloc: $e');
              debugPrint('Stack trace: $stackTrace');
              rethrow;
            }
          },
        ),
        // New BLoCs from refactoring - all lazy loaded for performance
        BlocProvider<MealBloc>(
          lazy: true,
          create: (context) => GetIt.instance<MealBloc>(),
        ),
        BlocProvider<DailySummaryBloc>(
          lazy: true,
          create: (context) => GetIt.instance<DailySummaryBloc>(),
        ),
        // Group Workout Community BLoCs - all lazy loaded for performance
        BlocProvider<GroupBloc>(
          lazy: true,
          create: (context) => GetIt.instance<GroupBloc>(),
        ),
        BlocProvider<GroupActivityBloc>(
          lazy: true,
          create: (context) => GetIt.instance<GroupActivityBloc>(),
        ),
        BlocProvider<CommunityBloc>(
          lazy: true,
          create: (context) => GetIt.instance<CommunityBloc>(),
        ),
        BlocProvider<PostInteractionBloc>(
          lazy: true,
          create: (context) => GetIt.instance<PostInteractionBloc>(),
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocaleManager _localeManager = LocaleManager();
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _localeManager.addListener(() {
      setState(() {});
    });
    
    // Initialize deep link handling
    _initDeepLinks();
  }

  @override
  void dispose() {
    _localeManager.removeListener(() {});
    super.dispose();
  }

  /// Initialize deep link handling
  void _initDeepLinks() {
    _appLinks = AppLinks();
    
    // Handle initial link when app is launched from a deep link
    _appLinks.getInitialLink().then((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }).catchError((err) {
      debugPrint('Failed to get initial link: $err');
    });
    
    // Handle incoming links when app is already running
    _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      debugPrint('Failed to handle incoming link: $err');
    });
  }

  /// Handle deep link navigation
  void _handleDeepLink(Uri uri) {
    // Wait for the app to be fully initialized before handling deep links
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = AppRouter.router.routerDelegate.navigatorKey.currentContext;
      if (context != null) {
        DeepLinkHandler.handleDeepLink(context, uri.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return MaterialApp.router(
          title: 'JFiT',
          theme: JFitTheme.lightTheme,
          darkTheme: JFitTheme.darkTheme,
          themeMode: themeManager.themeMode,
          locale: _localeManager.currentLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('ko'), // Korean
          ],
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}

/// Error screen displayed when app initialization fails
/// Provides retry mechanism for recovery
class AppInitializationErrorScreen extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const AppInitializationErrorScreen({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'App Initialization Failed',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'An error occurred while starting the app:\n$error',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}