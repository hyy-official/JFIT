import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/data/repositories/auth_repository.dart';
import 'package:jfit/features/exercise/bloc/exercise_bloc.dart';
import 'package:jfit/features/exercise/data/repositories/exercise_repository.dart';
import 'package:jfit/features/records/bloc/record_bloc.dart';
import 'package:jfit/features/records/data/repositories/record_repository.dart';
import 'package:jfit/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:jfit/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:jfit/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:jfit/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:jfit/features/analytics/data/repositories/supabase_analytics_repository.dart';
import 'core/theme/theme_system.dart';
import 'core/theme/theme_manager.dart';
import 'core/utils/locale_manager.dart';
import 'package:provider/provider.dart';
// import 'core/services/auth_service.dart'; // 주석 처리: 나중에 사용할 예정
// import 'features/auth/presentation/pages/login_page.dart'; // 주석 처리: 나중에 사용할 예정
import 'l10n/app_localizations.dart'; // 추가
import 'core/navigation/main_navigation_page.dart';
import 'core/widgets/auth_gate.dart';
import 'core/navigation/stack_logging_observer.dart';
import 'core/di/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase 프로젝트 초기화
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );
  
  // 의존성 주입 초기화
  setupDependencies();
  
  // 테마 매니저 초기화
  final themeManager = ThemeManager();
  await themeManager.initialize();
  
  runApp(
    ChangeNotifierProvider.value(
      value: themeManager,
      child: const JFitApp(),
    ),
  );
}

class JFitApp extends StatelessWidget {
  const JFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider<ExerciseRepository>(
          create: (context) => ExerciseRepository(),
        ),
        RepositoryProvider<RecordRepository>(
          create: (context) => RecordRepository(),
        ),
        RepositoryProvider<DashboardRepository>(
          create: (context) => DashboardRepository(),
        ),
        RepositoryProvider<AnalyticsRepository>(
          create: (context) => SupabaseAnalyticsRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              RepositoryProvider.of<AuthRepository>(context),
            ),
          ),
          BlocProvider<ExerciseBloc>(
            create: (context) => ExerciseBloc(
              exerciseRepository: RepositoryProvider.of<ExerciseRepository>(context),
            ),
          ),
          BlocProvider<RecordBloc>(
            create: (context) => RecordBloc(
              recordRepository: RepositoryProvider.of<RecordRepository>(context),
            ),
          ),
          BlocProvider<DashboardBloc>(
            create: (context) => DashboardBloc(
              dashboardRepository: RepositoryProvider.of<DashboardRepository>(context),
            ),
          ),
          BlocProvider<AnalyticsBloc>(
            create: (context) => AnalyticsBloc(
              analyticsRepository: RepositoryProvider.of<AnalyticsRepository>(context),
            ),
          ),
        ],
        child: const MyApp(),
      ),
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

  @override
  void initState() {
    super.initState();
    _localeManager.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _localeManager.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return MaterialApp(
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
          navigatorObservers: [StackLoggingObserver()],
          home: const AuthGate(child: MainNavigationPage()),
        );
      },
    );
  }
}
