/// 기록 페이지 (RecordPage)
///
/// 모바일/데스크톱 레이아웃을 모두 지원하는 반응형 페이지의 스켈레톤 구현입니다.
/// 추후 데이터 바인딩 및 상세 위젯 기능을 채워주세요.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/core/extensions/context_extensions.dart';
import 'package:jfit/core/widgets/responsive_scaffold.dart';
import 'package:jfit/core/utils/responsive_utils.dart';
import 'package:jfit/features/analytics/presentation/pages/analytics_page.dart';
import 'package:jfit/features/records/bloc/record_bloc.dart';
import 'package:jfit/features/records/bloc/record_event.dart';
import 'package:jfit/features/records/bloc/record_state.dart';
import 'package:jfit/features/records/data/models/meal_record_model.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_state.dart';
import 'package:jfit/features/records/presentation/widgets/diet_add_sheet.dart';
import 'package:jfit/features/records/presentation/widgets/body_add_sheet.dart';
import 'package:jfit/core/services/supabase_service.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> with TickerProviderStateMixin {
  late final TabController _tabController;
  final DateTime _today = DateTime.now();
  late DateTime _selectedDate;
  
  @override
  void initState() {
    super.initState();
    _selectedDate = _today;
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final userId = authState.user.id;
      context.read<RecordBloc>().add(LoadMealRecords(userId: userId, date: _selectedDate));
      context.read<RecordBloc>().add(LoadDailySummary(userId: userId, date: _selectedDate));
    }
  }

  void _loadDataForDate(DateTime date) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final userId = authState.user.id;
      context.read<RecordBloc>().add(LoadMealRecords(userId: userId, date: date));
      context.read<RecordBloc>().add(LoadDailySummary(userId: userId, date: date));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecordBloc, RecordState>(
      builder: (context, state) {
        List<MealRecord> mealRecords = [];
        UserDailySummary? dailySummary;

        if (state is RecordLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MealRecordsLoaded) {
          mealRecords = state.mealRecords;
        } else if (state is DailySummaryLoaded) {
          dailySummary = state.dailySummary;
        } else if (state is RecordError) {
          return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.white)));
        }

        return RecordPageContent(
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
          mealRecords: mealRecords,
          dailySummary: dailySummary,
        );
      },
    );
  }
}

/// 메인 영역(캘린더, 탭, 퀵 액션 등)
class _MainContent extends StatelessWidget {
  final DateTime today;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final TabController tabController;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;
  final List<MealRecord> mealRecords;

  const _MainContent({
    required this.today,
    required this.selectedDate,
    required this.onDateSelected,
    required this.tabController,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onPrevWeek,
    required this.onNextWeek,
    required this.mealRecords,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: _horizontalPadding(context),
        vertical: _verticalSpacing(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardHeader(
            date: selectedDate,
            onPrevMonth: onPrevMonth,
            onNextMonth: onNextMonth,
          ),
          SizedBox(height: _verticalSpacing(context)),
          _WeeklyCalendar(
            baseDate: today,
            selectedDate: selectedDate,
            onSelect: onDateSelected,
            onPrevWeek: onPrevWeek,
            onNextWeek: onNextWeek,
          ),
          SizedBox(height: _verticalSpacing(context)),
          // 탭 바 (커스텀 그레이 버튼 형태)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _horizontalPadding(context)),
            child: _CustomTabBar(
              controller: tabController,
              tabs: const ['식단', '신체 & 운동', '계획'],
            ),
          ),
          SizedBox(height: _verticalSpacing(context)),
          // 광고 배너
          const _AdvertisementBanner(),
          SizedBox(height: _verticalSpacing(context)),
          // 퀵 액션 그리드
          _QuickAddSection(),
          SizedBox(height: _verticalSpacing(context)),
          // 탭별 컨텐츠 (placeholder)
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: tabController,
              children: [
                // ----- 식단 탭 -----
                DietTabContent(
                  selectedDate: selectedDate,
                ),
                // ----- 신체 & 운동 탭 -----
                BodyTabContent(selectedDate: selectedDate),
                // ----- 계획 탭 -----
                const Center(child: Text('계획 컨텐츠', style: TextStyle(color: Colors.white54))),
              ],
            ),
          ),
        ],
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

/// 대시보드 헤더 (년/월, 이동 버튼, 액션 아이콘)
class _DashboardHeader extends StatelessWidget {
  final DateTime date;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  const _DashboardHeader({
    required this.date,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    final monthText = '${date.year}년 ${date.month}월';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 햄버거 메뉴 (옵션)

        // 이전 달 버튼
        IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_left, color: Colors.white),
          splashRadius: 20,
          onPressed: onPrevMonth,
        ),

        // 현재 월 텍스트
        Text(
          monthText,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.normal, fontSize: 20, color: Colors.white),
          
        ),

        // 다음 달 버튼
        IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_right, color: Colors.white),
          splashRadius: 20,
          onPressed: onNextMonth,
        ),

        const Spacer(),

        // 액션 아이콘들
        IconButton(
          icon: const Icon(Icons.bar_chart, color: Colors.white),
          onPressed: () {
            // 중앙 Navigator 에서만 페이지를 푸시하여 좌우 패널을 유지합니다.
            Navigator.of(context).pushNamed(AnalyticsPage.routeName);
          },
          splashRadius: 20,
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          splashRadius: 20,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.list, color: Colors.white),
          onPressed: () {},
          splashRadius: 20,
        ),
        IconButton(
          icon: const Icon(Icons.palette, color: Colors.white),
          onPressed: () {},
          splashRadius: 20,
        ),
      ],
    );
  }
}

/// 주간 캘린더 – 요일 고정, 무한 스와이프 지원
class _WeeklyCalendar extends StatelessWidget {
  final DateTime baseDate; // 오늘 포함 날짜 (주 시작 계산)
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;

  const _WeeklyCalendar({
    required this.baseDate,
    required this.selectedDate,
    required this.onSelect,
    required this.onPrevWeek,
    required this.onNextWeek,
  });



  // 주의 시작일 계산 (일요일 기준)
  DateTime _getStartOfWeek(DateTime date) {
    final weekday = date.weekday;
    final daysFromSunday = weekday == 7 ? 0 : weekday;
    return date.subtract(Duration(days: daysFromSunday));
  }

  @override
  Widget build(BuildContext context) {
    // 현재 주간 데이터 계산 (실시간)
    final startOfWeek = _getStartOfWeek(selectedDate);
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    const dayNames = ['일', '월', '화', '수', '목', '금', '토'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 700;

        Widget buildDayButton(DateTime day) {
          final isSelected = day.year == selectedDate.year && 
                           day.month == selectedDate.month && 
                           day.day == selectedDate.day;
          final isToday = day.year == DateTime.now().year && 
                         day.month == DateTime.now().month && 
                         day.day == DateTime.now().day;

          return GestureDetector(
            onTap: () => onSelect(day),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? null : Colors.transparent,
                    gradient: isSelected ? AppTheme.accentGradient : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.accent1.withAlpha((255 * 0.4).round()),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isToday
                                ? AppTheme.accent1
                                : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (isDesktop) {
          // 데스크톱: 좌우 버튼 고려한 정렬
          return Container(
            padding: EdgeInsets.symmetric(horizontal: _horizontalPadding(context)),
            child: Column(
              children: [
                // 고정된 요일 헤더 (버튼 공간 고려)
                Row(
                  children: [
                    SizedBox(width: 48), // 좌측 버튼 공간
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: dayNames.map((dayName) => Expanded(
                          child: Center(
                            child: Text(
                              dayName,
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                    SizedBox(width: 48), // 우측 버튼 공간
                  ],
                ),
                const SizedBox(height: 12),
                // 날짜 버튼들
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white70, size: 20),
                      splashRadius: 16,
                      onPressed: onPrevWeek,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: days.map((day) => Expanded(
                          child: Center(child: buildDayButton(day)),
                        )).toList(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
                      splashRadius: 16,
                      onPressed: onNextWeek,
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          // 모바일: 스와이프 가능한 애니메이션 버전
          return Container(
            padding: EdgeInsets.symmetric(horizontal: _horizontalPadding(context)),
            child: Column(
              children: [
                // 고정된 요일 헤더
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: dayNames.map((dayName) => Expanded(
                    child: Center(
                      child: Text(
                        dayName,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 12),
                // 스와이프 가능한 애니메이션 날짜 영역
                SizedBox(
                  height: 40,
                  child: _SwipeableWeekView(
                    days: days,
                    buildDayButton: buildDayButton,
                    onPrevWeek: onPrevWeek,
                    onNextWeek: onNextWeek,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  double _horizontalPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1024) return 24;
    if (w >= 768) return 20;
    return 16;
  }
}

/// 광고/프로그램 배너 (간단한 그래디언트 카드)
class _AdvertisementBanner extends StatelessWidget {
  const _AdvertisementBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: AppTheme.accentGradient,
      ),
      child: Row(
        children: const [
          Icon(Icons.track_changes, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '프리미엄 운동 프로그램',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Icon(Icons.open_in_new, color: Colors.white),
        ],
      ),
    );
  }
}

/// Quick Add Section with Workout card spanning 2 columns
class _QuickAddSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spacing = (MediaQuery.of(context).size.width >= 1024) ? 16.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 추가',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: spacing / 2),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardHeight = constraints.maxWidth >= 768 ? 120.0 : 100.0;

            return Column(
              children: [
                // Workout card full width
                _WorkoutCard(height: cardHeight),
                SizedBox(height: spacing),
                Row(
                  children: [
                    Expanded(child: _QuickCard(icon: Icons.restaurant, label: '식단', accent: const Color(0xFF34D399))),
                    SizedBox(width: spacing),
                    Expanded(child: _QuickCard(icon: Icons.person, label: '신체', accent: const Color(0xFFFBBF24))),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final double height;
  const _WorkoutCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface1.withOpacity(0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surface2, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.accent1, AppTheme.accent2]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fitness_center, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('운동', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('0/1 완료', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSub)),
              ],
            ),
          ),
          const Icon(Icons.add, color: Colors.white),
        ],
      ),
    );
  }
}

class _QuickCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color accent;
  const _QuickCard({required this.icon, required this.label, required this.accent});

  @override
  State<_QuickCard> createState() => _QuickCardState();
}

class _QuickCardState extends State<_QuickCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    void _handleTap() {
      if (widget.label == '식단') {
        _showAddDietSheet(context);
      } else if (widget.label == '신체') {
        _showAddBodySheet(context);
      }
    }

    return GestureDetector(
      onTap: _handleTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: AnimatedScale(
          scale: _hovering ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface1.withOpacity(0.75),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _hovering ? widget.accent : AppTheme.surface2, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_hovering ? 0.25 : 0.15),
                  blurRadius: _hovering ? 16 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [widget.accent.withOpacity(0.8), widget.accent]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 무한 스와이프 가능한 주간 뷰 위젯 (PageView 기반)
class _SwipeableWeekView extends StatefulWidget {
  final List<DateTime> days;
  final Widget Function(DateTime) buildDayButton;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;

  const _SwipeableWeekView({
    required this.days,
    required this.buildDayButton,
    required this.onPrevWeek,
    required this.onNextWeek,
  });

  @override
  State<_SwipeableWeekView> createState() => _SwipeableWeekViewState();
}

class _SwipeableWeekViewState extends State<_SwipeableWeekView> {
  late PageController _pageController;
  static const int _initialPage = 1000; // 중간 지점에서 시작
  int _currentPage = _initialPage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 페이지 인덱스를 기반으로 주간 데이터 생성
  List<DateTime> _getWeekDaysForPage(int pageIndex) {
    final weekOffset = pageIndex - _initialPage;
    final baseWeekStart = widget.days.first; // 현재 주의 시작일
    final targetWeekStart = baseWeekStart.add(Duration(days: weekOffset * 7));
    return List.generate(7, (i) => targetWeekStart.add(Duration(days: i)));
  }

  void _onPageChanged(int page) {
    final weekOffset = page - _currentPage;
    _currentPage = page;
    
    if (weekOffset > 0) {
      // 다음 주로 이동
      for (int i = 0; i < weekOffset; i++) {
        widget.onNextWeek();
      }
    } else if (weekOffset < 0) {
      // 이전 주로 이동
      for (int i = 0; i < -weekOffset; i++) {
        widget.onPrevWeek();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, index) {
        final weekDays = _getWeekDaysForPage(index);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: weekDays.map((day) => Expanded(
            child: Center(child: widget.buildDayButton(day)),
          )).toList(),
        );
      },
    );
  }
}

/// 커스텀 탭바 - 그레이 버튼 형태로 양옆 마진 적용
class _CustomTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;

  const _CustomTabBar({
    required this.controller,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.surface1.withAlpha((255 * 0.3).round()),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.surface2.withAlpha((255 * 0.5).round()), width: 1),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          gradient: AppTheme.accentGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent1.withAlpha((255 * 0.3).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorPadding: const EdgeInsets.all(4),
        indicatorSize: TabBarIndicatorSize.tab, // 전체 탭 영역을 채우도록 설정
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        dividerColor: Colors.transparent,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        tabs: tabs.map((text) => Tab(
          child: Container(
            width: double.infinity, // 전체 너비 사용
            height: double.infinity, // 전체 높이 사용
            alignment: Alignment.center, // 텍스트 중앙 정렬
            child: Text(text),
          ),
        )).toList(),
      ),
    );
  }
}

class RecordPageContent extends StatelessWidget {
  final DateTime today;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final TabController tabController;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;
  final List<MealRecord> mealRecords;
  final UserDailySummary? dailySummary;

  const RecordPageContent({
    super.key,
    required this.today,
    required this.selectedDate,
    required this.onDateSelected,
    required this.tabController,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onPrevWeek,
    required this.onNextWeek,
    required this.mealRecords,
    this.dailySummary,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _MainContent(
        today: today,
        selectedDate: selectedDate,
        onDateSelected: onDateSelected,
        tabController: tabController,
        onPrevMonth: onPrevMonth,
        onNextMonth: onNextMonth,
        onPrevWeek: onPrevWeek,
        onNextWeek: onNextWeek,
        mealRecords: mealRecords,
      ),
    );
  }
}

void _showAddDietSheet(BuildContext context, {DateTime? date}) {
  final isDesktop = context.isDesktop;
  if (isDesktop) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(32),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: DietAddSheetContent(selectedDate: date ?? DateTime.now()),
          ),
        ),
      ),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.9,
        child: DietAddSheetContent(selectedDate: date ?? DateTime.now()),
      ),
    );
  }
}

void _showAddBodySheet(BuildContext context, {DateTime? date}) {
  final isDesktop = context.isDesktop;
  if (isDesktop) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(32),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BodyAddSheetContent(selectedDate: date ?? DateTime.now()),
          ),
        ),
      ),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.9,
        child: BodyAddSheetContent(selectedDate: date ?? DateTime.now()),
      ),
    );
  }
}

/// 식단 탭 컨텐츠
class DietTabContent extends StatefulWidget {
  final DateTime selectedDate;

  const DietTabContent({super.key, required this.selectedDate});

  @override
  State<DietTabContent> createState() => _DietTabContentState();
}

class _DietTabContentState extends State<DietTabContent> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void didUpdateWidget(covariant DietTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _loadEntries();
    }
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    final data = await _supabaseService.getMealEntriesForDate(widget.selectedDate);
    setState(() {
      _entries = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    double totalCarbs = 0;
    double totalProtein = 0;
    double totalFat = 0;

    for (final e in _entries) {
      totalCarbs += (e['carbohydrates'] as num?)?.toDouble() ?? 0;
      totalProtein += (e['protein'] as num?)?.toDouble() ?? 0;
      totalFat += (e['fat'] as num?)?.toDouble() ?? 0;
    }

    // ----- meal_type 별로 그룹화 -----
    final Map<String, _MealTypeSummary> grouped = {};
    for (final e in _entries) {
      final type = e['meal_type'] as String;
      grouped.putIfAbsent(type, () => _MealTypeSummary(type));
      grouped[type]!.addEntry(e);
    }

    // 정렬 순서 정의
    const order = ['breakfast', 'lunch', 'dinner', 'snack'];
    final summaries = grouped.values.toList()
      ..sort((a, b) => order.indexOf(a.mealType).compareTo(order.indexOf(b.mealType)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MacroRatioBar(carbs: totalCarbs, protein: totalProtein, fat: totalFat),
        const SizedBox(height: 16),
        Expanded(
          child: summaries.isEmpty
              ? const Center(child: Text('오늘 기록된 식단이 없습니다', style: TextStyle(color: Colors.white54)))
              : ListView.separated(
                  itemCount: summaries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return MealTypeSummaryCard(summary: summaries[index]);
                  },
                ),
        ),
      ],
    );
  }
}

/// 내부 집계 모델
class _MealTypeSummary {
  final String mealType;
  double totalCalories = 0;
  double totalCarbs = 0;
  double totalProtein = 0;
  double totalFat = 0;

  _MealTypeSummary(this.mealType);

  void addEntry(Map<String, dynamic> e) {
    totalCalories += (e['calories'] as num?)?.toDouble() ?? 0;
    totalCarbs += (e['carbohydrates'] as num?)?.toDouble() ?? 0;
    totalProtein += (e['protein'] as num?)?.toDouble() ?? 0;
    totalFat += (e['fat'] as num?)?.toDouble() ?? 0;
  }
}

/// meal_type 별 요약 카드
class MealTypeSummaryCard extends StatelessWidget {
  final _MealTypeSummary summary;

  const MealTypeSummaryCard({super.key, required this.summary});

  String _mealTypeKorean(String type) {
    switch (type) {
      case 'breakfast':
        return '아침';
      case 'lunch':
        return '점심';
      case 'dinner':
        return '저녁';
      case 'snack':
        return '간식';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2B35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A3B45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _mealTypeKorean(summary.mealType),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text('${summary.totalCalories.toStringAsFixed(1)} kcal', style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _macroText('탄수', summary.totalCarbs),
              _macroText('단백질', summary.totalProtein),
              _macroText('지방', summary.totalFat),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroText(String label, double value) {
    return Text('$label ${value.toStringAsFixed(1)}g', style: const TextStyle(color: Colors.white60, fontSize: 12));
  }
}

/// 탄단지 비율 바 – FoodNutritionCalculatorScreen 과 동일한 디자인
class MacroRatioBar extends StatelessWidget {
  final double carbs;
  final double protein;
  final double fat;

  const MacroRatioBar({super.key, required this.carbs, required this.protein, required this.fat});

  @override
  Widget build(BuildContext context) {
    final total = carbs + protein + fat;
    if (total <= 0) {
      return const SizedBox.shrink();
    }

    final carbsRatio = carbs / total;
    final proteinRatio = protein / total;
    final fatRatio = fat / total;

    Widget _ratioText(String label, double ratio, Color color) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text('$label ${(ratio * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ratioText('탄수화물', carbsRatio, const Color(0xFF6B73FF)),
            _ratioText('단백질', proteinRatio, const Color(0xFFB794F6)),
            _ratioText('지방', fatRatio, const Color(0xFFF687B3)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
          child: Row(children: [
            if (carbsRatio > 0)
              Expanded(
                flex: (carbsRatio * 1000).toInt(),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF6B73FF),
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
                  ),
                ),
              ),
            if (proteinRatio > 0)
              Expanded(
                flex: (proteinRatio * 1000).toInt(),
                child: Container(color: const Color(0xFFB794F6)),
              ),
            if (fatRatio > 0)
              Expanded(
                flex: (fatRatio * 1000).toInt(),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF687B3),
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                  ),
                ),
              ),
          ]),
        ),
      ],
    );
  }
}

/// 신체 & 운동 탭 컨텐츠
class BodyTabContent extends StatefulWidget {
  final DateTime selectedDate;
  const BodyTabContent({super.key, required this.selectedDate});

  @override
  State<BodyTabContent> createState() => _BodyTabContentState();
}

class _BodyTabContentState extends State<BodyTabContent> {
  final SupabaseService _supabaseService = SupabaseService();
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(covariant BodyTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _fetch();
    }
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final res = await _supabaseService.getBodyMeasurementForDate(widget.selectedDate);
    setState(() {
      _data = res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_data == null) {
      return const Center(child: Text('오늘 기록된 신체 정보가 없습니다', style: TextStyle(color: Colors.white54)));
    }

    return _BodyMeasurementCard(data: _data!);
  }
}

class _BodyMeasurementCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _BodyMeasurementCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final weight = (data['weight'] as num?)?.toDouble();
    final muscle = (data['muscle_mass'] as num?)?.toDouble();
    final fat = (data['body_fat_percentage'] as num?)?.toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2B35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A3B45)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _metric('체중', weight, 'kg'),
          _metric('골격근량', muscle, 'kg'),
          _metric('체지방률', fat, '%'),
        ],
      ),
    );
  }

  Widget _metric(String label, double? value, String unit) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value != null ? value.toStringAsFixed(1) : '-',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(unit, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }
}