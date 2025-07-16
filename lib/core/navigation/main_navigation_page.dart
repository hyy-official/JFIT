import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/widgets/responsive_scaffold.dart';
import 'package:jfit/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:jfit/features/exercise/presentation/pages/exercise_page.dart';
import 'package:jfit/features/programs/presentation/pages/programs_page.dart';
import 'package:jfit/features/workout_session/presentation/pages/workout_session_page.dart';
import 'package:jfit/features/records/presentation/pages/record_page.dart';
import 'package:jfit/features/records/bloc/record_bloc.dart';
import 'package:jfit/features/records/bloc/record_event.dart';
import 'package:jfit/features/records/bloc/record_state.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_state.dart';
import 'package:jfit/features/analytics/presentation/pages/analytics_page.dart';
import 'package:jfit/core/widgets/theme_toggle_button.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/core/models/navigation_item.dart';

/// 앱 하단 내비게이션(ResponsiveScaffold)을 담당하는 메인 페이지.
///
/// 추후 auth 완료 후 로그인 상태에서만 접근하도록 변경할 수 있다.
class MainNavigationPage extends StatefulWidget {
  final int initialIndex;
  final Map<String, dynamic>? workoutSessionArgs;

  const MainNavigationPage({
    super.key,
    this.initialIndex = 0,
    this.workoutSessionArgs,
  });

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  late List<Widget> _pages;
  late List<NavigationItem> _navigationItems;
  // Nested navigator key to manage stack within the body area only.
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    
    // 네비게이션 아이템 정의 (3개로 줄임)
    _navigationItems = [
      const NavigationItem(icon: Icons.restaurant, label: '홈', index: 0),
      const NavigationItem(icon: Icons.timer, label: '내 운동', index: 1),
      const NavigationItem(icon: Icons.extension, label: '루틴', index: 2),
    ];
    
    _pages = [
      // 0: 식단(기록)
      const RecordPage(),
      // 1: 내 운동(현재 진행 중인 워크아웃 또는 프리스타일 세션)
      WorkoutSessionPage(
        sessionId: widget.workoutSessionArgs?['sessionId'],
        programId: widget.workoutSessionArgs?['programId'],
        programDay: widget.workoutSessionArgs?['programDay'],
        targetWeek: widget.workoutSessionArgs?['targetWeek'],
        targetDay: widget.workoutSessionArgs?['targetDay'],
        showNavigation: widget.workoutSessionArgs?['showNavigation'] ?? false,
      ),
      // 2: 루틴(프로그램 목록)
      const ProgramsPage(),
    ];
    
    // 초기 로드 시 RecordPage 데이터 로드
    if (_currentIndex == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadRecordData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 데스크톱에서는 항상 우측 패널을 표시
    return BlocBuilder<RecordBloc, RecordState>(
      builder: (context, state) {
        UserDailySummary? dailySummary;
        if (state is DailySummaryLoaded && _currentIndex == 0) {
          dailySummary = state.dailySummary;
        }
        
        return ResponsiveScaffold(
          appBar: _buildAppBar(context),
          currentIndex: _currentIndex,
          navigationItems: _navigationItems,
          onNavTap: (index) {
            // 중앙 Navigator 스택 초기화 후, 새 탭 페이지로 대체
            _navigatorKey.currentState?.popUntil((route) => route.isFirst);
            _navigatorKey.currentState?.pushReplacement(
              MaterialPageRoute(builder: (_) => _pages[index]),
            );

            setState(() => _currentIndex = index);

            // RecordPage(인덱스 0)로 이동할 때 데이터 로드
            if (index == 0) {
              _loadRecordData();
            }
          },
          onAiTap: () {
            // TODO: AI 기능 연결
          },
          // 중앙 영역에만 적용되는 Navigator
          body: Navigator(
            key: _navigatorKey,
            onGenerateRoute: (settings) {
              // Analytics 전용 라우트
              if (settings.name == AnalyticsPage.routeName) {
                return MaterialPageRoute(
                  builder: (_) => const AnalyticsPage(),
                  settings: settings,
                );
              }



              // 기본: 현재 탭 페이지
              return MaterialPageRoute(
                builder: (_) => _pages[_currentIndex],
                settings: settings,
              );
            },
          ),
          // 데스크톱에서 항상 우측 패널 표시를 위해 selectedDate는 항상 제공
          selectedDate: DateTime.now(),
          // RecordPage일 때만 실제 데이터 제공, 다른 페이지에서는 null
          dailySummary: _currentIndex == 0 ? dailySummary : null,
        );
      },
    );
  }

  void _loadRecordData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final userId = authState.user.id;
      final today = DateTime.now();
      context.read<RecordBloc>().add(LoadDailySummary(userId: userId, date: today));
    }
  }

  /// AppBar 생성 (테마 전환 버튼 포함)
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final tabNames = ['홈', '내  운동', '루틴'];
    
    return AppBar(
      title: Text(
        tabNames[_currentIndex],
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: context.colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: context.colors.background,
      elevation: 0,
      centerTitle: true,
      actions: [
        // 테마 전환 버튼
        const ThemeToggleButton(
          showLabel: false,
          iconSize: 20,
        ),
        const SizedBox(width: 16),
      ],
      // 하단 경계선
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: context.colors.border,
        ),
      ),
    );
  }
} 