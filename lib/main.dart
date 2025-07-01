import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/locale_manager.dart';
import 'core/widgets/responsive_scaffold.dart';
import 'core/services/data_seed_service.dart';
import 'services/exercise_database_service.dart';
// import 'core/services/auth_service.dart'; // 주석 처리: 나중에 사용할 예정
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/programs/presentation/pages/programs_page.dart';
import 'features/exercise/presentation/pages/exercise_page.dart';
import 'features/workout_session/presentation/pages/workout_session_page.dart';
// import 'features/auth/presentation/pages/login_page.dart'; // 주석 처리: 나중에 사용할 예정
import 'l10n/app_localizations.dart'; // 추가
import 'core/navigation/main_navigation_page.dart';
import 'core/widgets/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // SQLite 데이터베이스 초기화
  print('[MAIN] SQLite 데이터베이스 초기화 시작');
  final exerciseDbService = ExerciseDatabaseService();
  await exerciseDbService.database; // 데이터베이스 초기화
  await exerciseDbService.printDatabaseInfo(); // 데이터베이스 정보 출력
  
  // 기존 데이터베이스 초기화 및 샘플 데이터 삽입
  final dataSeedService = DataSeedService();
  await dataSeedService.seedSampleData();
  
  runApp(const MyApp());
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
      theme: AppTheme.lightTheme,
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
      home: const AuthGate(child: MainNavigationPage()),
    );
  }
}

// AuthWrapper 클래스 주석 처리: 나중에 auth 기능 추가할 때 사용할 예정
/*
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool? _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // TODO: 실제 로그인 상태 확인 로직 구현
    // 현재는 false로 설정하여 로그인 페이지를 먼저 보여줌
    final isLoggedIn = await _authService.isLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn == null) {
      // 로딩 상태
      return const Scaffold(
        backgroundColor: Color(0xFF1a1a1a),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF6366f1)),
        ),
      );
    }

    return _isLoggedIn! ? const MainNavigationPage() : const LoginPage();
  }
}
*/
