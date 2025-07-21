import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jfit/core/widgets/responsive_scaffold.dart';
import 'package:jfit/features/programs/presentation/pages/programs_page.dart';
import 'package:jfit/features/workout_session/presentation/pages/workout_session_page.dart';
import 'package:jfit/features/records/presentation/pages/record_page.dart';

import 'package:jfit/features/daily_summary/bloc/daily_summary_bloc.dart';
import 'package:jfit/features/daily_summary/bloc/daily_summary_event.dart' as daily_summary_events;
import 'package:jfit/features/daily_summary/bloc/daily_summary_state.dart' as daily_summary_states;
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_state.dart';
import 'package:jfit/features/analytics/presentation/pages/analytics_page.dart';
import 'package:jfit/core/widgets/theme_toggle_button.dart';
import 'package:jfit/core/theme/theme_system.dart';

// Group Workout Community Pages
import 'package:jfit/features/group_workout_community/presentation/pages/group_list_page.dart';
import 'package:jfit/features/group_workout_community/presentation/pages/community_board_page.dart';

import 'package:jfit/core/constants/navigation_constants.dart';

/// 앱 하단 내비게이션(ResponsiveScaffold)을 담당하는 메인 페이지.
///
/// 추후 auth 완료 후 로그인 상태에서만 접근하도록 변경할 수 있다.
class MainNavigationPage extends StatefulWidget {
  final int initialIndex;
  final Map<String, dynamic>? workoutSessionArgs;
  final Widget? child; // For GoRouter shell integration

  const MainNavigationPage({
    super.key,
    this.initialIndex = 0,
    this.workoutSessionArgs,
    this.child,
  });

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  late List<Widget> _pages;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pages = _buildPages();
    
    // 초기 로드 시 RecordPage 데이터 로드
    if (_currentIndex == NavigationConstants.homeIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadRecordData();
      });
    }
  }

  /// 페이지 리스트 생성
  List<Widget> _buildPages() {
    return [
      const RecordPage(),
      WorkoutSessionPage(
        sessionId: widget.workoutSessionArgs?['sessionId'],
        programId: widget.workoutSessionArgs?['programId'],
        programDay: widget.workoutSessionArgs?['programDay'],
        targetWeek: widget.workoutSessionArgs?['targetWeek'],
        targetDay: widget.workoutSessionArgs?['targetDay'],
        showNavigation: widget.workoutSessionArgs?['showNavigation'] ?? false,
      ),
      const ProgramsPage(),
      const GroupListPage(),
      const CommunityBoardPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // 데스크톱에서는 항상 우측 패널을 표시
    return BlocBuilder<DailySummaryBloc, daily_summary_states.DailySummaryState>(
      builder: (context, state) {
        UserDailySummary? dailySummary;
        if (_currentIndex == NavigationConstants.homeIndex) {
          if (state is daily_summary_states.DailySummaryLoaded) {
            dailySummary = state.summary;
          } else if (state is daily_summary_states.DailySummaryUpdated) {
            dailySummary = state.summary;
          }
        }
        
        return ResponsiveScaffold(
          // appBar: _buildAppBar(context), // 앱 바 제거
          currentIndex: _currentIndex,
          navigationItems: NavigationConstants.defaultNavigationItems,
          onNavTap: (index) {
            setState(() => _currentIndex = index);

            // Navigate using GoRouter based on the selected tab
            switch (index) {
              case NavigationConstants.homeIndex:
                context.go('/');
                _loadRecordData();
                break;
              case NavigationConstants.workoutIndex:
                // Stay on current page for workout session
                break;
              case NavigationConstants.programsIndex:
                // Stay on current page for programs
                break;
              case NavigationConstants.groupsIndex:
                context.go('/groups');
                break;
              case NavigationConstants.communityIndex:
                context.go('/community');
                break;
            }
          },
          onAiTap: () {
            // TODO: AI 기능 연결
          },
          // GoRouter shell에서 제공하는 child 사용
          body: widget.child ?? _pages[_currentIndex],
          // 데스크톱에서 항상 우측 패널 표시를 위해 selectedDate는 항상 제공
          selectedDate: DateTime.now(),
          // RecordPage일 때만 실제 데이터 제공, 다른 페이지에서는 null
          dailySummary: _currentIndex == NavigationConstants.homeIndex ? dailySummary : null,
        );
      },
    );
  }

  void _loadRecordData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final userId = authState.user.id;
      final today = DateTime.now();
      context.read<DailySummaryBloc>().add(daily_summary_events.LoadDailySummary(userId: userId, date: today));
    }
  }

  /// AppBar 생성 (테마 전환 버튼 포함)
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    // navigationItems에서 동적으로 탭 이름 가져오기 (안전한 인덱스 접근)
    final safeIndex = _currentIndex.clamp(0, NavigationConstants.defaultNavigationItems.length - 1);
    final currentTabName = NavigationConstants.defaultNavigationItems[safeIndex].label;
    
    return AppBar(
      title: Text(
        currentTabName,
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