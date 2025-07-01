import 'package:flutter/material.dart';
import 'package:jfit/core/widgets/responsive_scaffold.dart';
import 'package:jfit/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:jfit/features/exercise/presentation/pages/exercise_page.dart';
import 'package:jfit/features/programs/presentation/pages/programs_page.dart';
import 'package:jfit/features/workout_session/presentation/pages/workout_session_page.dart';

/// 앱 하단 내비게이션(ResponsiveScaffold)을 담당하는 메인 페이지.
///
/// 추후 auth 완료 후 로그인 상태에서만 접근하도록 변경할 수 있다.
class MainNavigationPage extends StatefulWidget {
  final int initialIndex;
  const MainNavigationPage({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late int _currentIndex;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pages = [
      // 0: 대시보드
      const DashboardPage(),
      // 1: 운동 기록(ExercisePage)
      const ExercisePage(),
      // 2: 내 운동(현재 진행 중인 워크아웃 또는 프리스타일 세션)
      const WorkoutSessionPage(),
      // 3: 루틴(프로그램 목록)
      const ProgramsPage(),
      // 4: 식단(추후 구현) – 임시로 ExercisePage 사용하거나 빈 Container
      const ExercisePage(), // TODO: DietPage 구현 후 교체
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      currentIndex: _currentIndex,
      onNavTap: (index) {
        setState(() => _currentIndex = index);
      },
      onAiTap: () {
        // TODO: AI 기능 연결
      },
      body: _pages[_currentIndex],
    );
  }
} 