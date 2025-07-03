import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/data/repositories/auth_repository.dart';
import 'package:jfit/features/exercise/bloc/exercise_bloc.dart';
import 'package:jfit/features/exercise/data/repositories/exercise_repository.dart';
import 'package:jfit/features/records/bloc/record_bloc.dart';
import 'package:jfit/features/records/data/repositories/record_repository.dart';
import 'package:jfit/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:jfit/features/dashboard/data/repositories/dashboard_repository.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/locale_manager.dart';
// import 'core/services/auth_service.dart'; // 주석 처리: 나중에 사용할 예정
// import 'features/auth/presentation/pages/login_page.dart'; // 주석 처리: 나중에 사용할 예정
import 'l10n/app_localizations.dart'; // 추가
import 'core/navigation/main_navigation_page.dart';
import 'core/widgets/auth_gate.dart';
import 'core/navigation/stack_logging_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  runApp(
    MultiRepositoryProvider(
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
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
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
        ],
        child: const MyApp(),
      ),
    ),
  );
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JFiT',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
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
  }
}
