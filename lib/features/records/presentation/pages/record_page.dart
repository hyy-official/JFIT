/// 기록 페이지 (RecordPage)
///
/// 모바일/데스크톱 레이아웃을 모두 지원하는 반응형 페이지의 스켈레톤 구현입니다.
/// 추후 데이터 바인딩 및 상세 위젯 기능을 채워주세요.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/theme/theme_system.dart';

import 'package:jfit/features/meal/bloc/meal_bloc.dart';
import 'package:jfit/features/meal/bloc/meal_event.dart' as meal_events;
import 'package:jfit/features/workout_program/bloc/workout_program_bloc.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_event.dart' as workout_program_events;
import 'package:jfit/features/daily_summary/bloc/daily_summary_bloc.dart';
import 'package:jfit/features/daily_summary/bloc/daily_summary_event.dart' as daily_summary_events;
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_state.dart';
import 'package:get_it/get_it.dart';
import 'package:jfit/features/records/presentation/widgets/dashboard_header.dart';
import 'package:jfit/features/records/presentation/widgets/weekly_calendar.dart';
import 'package:jfit/features/records/presentation/widgets/custom_tab_bar.dart';
import 'package:jfit/features/records/presentation/widgets/advertisement_banner.dart';
import 'package:jfit/features/records/presentation/widgets/quick_add_section.dart';
import 'package:jfit/features/records/presentation/widgets/diet_tab_content.dart';
import 'package:jfit/features/records/presentation/widgets/body_tab_content.dart';
import 'package:jfit/features/records/presentation/widgets/exercise_tab_content.dart';
import 'package:jfit/features/records/presentation/widgets/todo_tab_content.dart';

// 1. 상단 고정 Scaffold 위젯 추가
class RecordPageScaffold extends StatelessWidget {
  final DateTime today;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final TabController tabController;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;
  final Widget child;

  const RecordPageScaffold({
    super.key,
    required this.today,
    required this.selectedDate,
    required this.onDateSelected,
    required this.tabController,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onPrevWeek,
    required this.onNextWeek,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: _horizontalPadding(context),
          vertical: _verticalSpacing(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardHeader(
              date: selectedDate,
              onPrevMonth: onPrevMonth,
              onNextMonth: onNextMonth,
            ),
            SizedBox(height: _verticalSpacing(context)),
            WeeklyCalendar(
              baseDate: today,
              selectedDate: selectedDate,
              onSelect: onDateSelected,
              onPrevWeek: onPrevWeek,
              onNextWeek: onNextWeek,
            ),
            SizedBox(height: _verticalSpacing(context)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _horizontalPadding(context)),
              child: CustomTabBar(
                controller: tabController,
                tabs: const ['신체', '식단', '운동', '계획'],
              ),
            ),
            SizedBox(height: _verticalSpacing(context)),
            const AdvertisementBanner(),
            SizedBox(height: _verticalSpacing(context)),
            const QuickAddSection(),
            SizedBox(height: _verticalSpacing(context)),
            // 컨텐츠 영역
            child,
          ],
        ),
      ),
    );
  }

  double _horizontalPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1024) return 24;
    if (w >= 768) return 20;
    return 16;
  }

  double _verticalSpacing(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1024) return 24;
    if (w >= 768) return 20;
    return 16;
  }
}

// 2. 날짜/탭별 컨텐츠만 리렌더링되는 위젯
class RecordTabContent extends StatefulWidget {
  final DateTime selectedDate;
  final TabController tabController;
  const RecordTabContent({super.key, required this.selectedDate, required this.tabController});

  @override
  State<RecordTabContent> createState() => _RecordTabContentState();
}

class _RecordTabContentState extends State<RecordTabContent> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return SizedBox(
      height: 400,
      child: TabBarView(
        controller: widget.tabController,
        children: [
          // 신체 탭 컨텐츠
          BodyTabContent(
            key: const PageStorageKey('body_tab'),
            selectedDate: widget.selectedDate,
          ),
          // 식단 탭 컨텐츠
          DietTabContent(
            key: const PageStorageKey('diet_tab'),
            selectedDate: widget.selectedDate,
          ),
          // 운동 탭 컨텐츠
          const ExerciseTabContent(
            key: PageStorageKey('exercise_tab'),
          ),
          // 계획 탭 컨텐츠
          TodoTabContent(
            key: const PageStorageKey('todo_tab'),
            selectedDate: widget.selectedDate,
          ),
        ],
      ),
    );
  }
}

// 3. RecordPage에서 구조 변경
class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> 
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabController;
  final DateTime _today = DateTime.now();
  late DateTime _selectedDate;
  
  @override
  void initState() {
    super.initState();
    _selectedDate = _today;
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 포커스를 다시 받을 때 운동 프로그램 새로고침
      _refreshExerciseData();
    }
  }

  void _refreshExerciseData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final workoutProgramBloc = GetIt.instance<WorkoutProgramBloc>();
      workoutProgramBloc.add(workout_program_events.LoadUserPrograms(userId: authState.user.id));
    }
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final userId = authState.user.id;
      // Use MealBloc for meal records
      context.read<MealBloc>().add(meal_events.LoadMealRecords(userId: userId, date: _selectedDate));
      // Use DailySummaryBloc for daily summary
      context.read<DailySummaryBloc>().add(daily_summary_events.LoadDailySummary(userId: userId, date: _selectedDate));
      // 운동 프로그램도 함께 로드
      final workoutProgramBloc = GetIt.instance<WorkoutProgramBloc>();
      workoutProgramBloc.add(workout_program_events.LoadUserPrograms(userId: userId));
    }
  }

  void _loadDataForDate(DateTime date) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final userId = authState.user.id;
      // Use MealBloc for meal records
      context.read<MealBloc>().add(meal_events.LoadMealRecords(userId: userId, date: date));
      // Use DailySummaryBloc for daily summary
      context.read<DailySummaryBloc>().add(daily_summary_events.LoadDailySummary(userId: userId, date: date));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RecordPageScaffold(
          today: _today,
          selectedDate: _selectedDate,
          onDateSelected: (d) {
            setState(() => _selectedDate = d);
            _loadDataForDate(_selectedDate);
          },
          tabController: _tabController,
          onPrevMonth: () {
            setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 30)));
            _loadDataForDate(_selectedDate);
          },
          onNextMonth: () {
            setState(() => _selectedDate = _selectedDate.add(const Duration(days: 30)));
            _loadDataForDate(_selectedDate);
          },
          onPrevWeek: () {
            setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 7)));
            _loadDataForDate(_selectedDate);
          },
          onNextWeek: () {
            setState(() => _selectedDate = _selectedDate.add(const Duration(days: 7)));
            _loadDataForDate(_selectedDate);
          },
      child: RecordTabContent(
        selectedDate: _selectedDate,
        tabController: _tabController,
      ),
    );
  }
}

