/// 기록 페이지 (RecordPage)
///
/// 모바일/데스크톱 레이아웃을 모두 지원하는 반응형 페이지의 스켈레톤 구현입니다.
/// 추후 데이터 바인딩 및 상세 위젯 기능을 채워주세요.
import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/core/extensions/context_extensions.dart';

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 700;
        return Scaffold(
          backgroundColor: context.colors.background,
          body: SafeArea(
            child: Row(
              children: [
                // 메인 콘텐츠 영역
                Expanded(
                  flex: 3,
                  child: _MainContent(
                    today: _today,
                    selectedDate: _selectedDate,
                    onDateSelected: (d) => setState(() => _selectedDate = d),
                    tabController: _tabController,
                    onPrevMonth: () => setState(() => _selectedDate = _selectedDate.subtract(Duration(days: 30))),
                    onNextMonth: () => setState(() => _selectedDate = _selectedDate.add(Duration(days: 30))),
                    onPrevWeek: () => setState(() => _selectedDate = _selectedDate.subtract(Duration(days: 7))),
                    onNextWeek: () => setState(() => _selectedDate = _selectedDate.add(Duration(days: 7))),
                  ),
                ),
                // 데스크톱 전용 사이드 패널
                if (isDesktop) ...[
                  const VerticalDivider(width: 1, color: Color(0xFF1A1A1A)),
                  Expanded(
                    flex: 2,
                    child: _SidePanel(selectedDate: _selectedDate),
                  ),
                ],
              ],
            ),
          ),
        );
      },
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

  const _MainContent({
    required this.today,
    required this.selectedDate,
    required this.onDateSelected,
    required this.tabController,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onPrevWeek,
    required this.onNextWeek,
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
              children: const [
                Center(child: Text('식단 컨텐츠', style: TextStyle(color: Colors.white54))),
                Center(child: Text('신체 & 운동 컨텐츠', style: TextStyle(color: Colors.white54))),
                Center(child: Text('계획 컨텐츠', style: TextStyle(color: Colors.white54))),
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
  final VoidCallback? onMenuTap;

  const _DashboardHeader({
    required this.date,
    required this.onPrevMonth,
    required this.onNextMonth,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final monthText = '${date.year}년 ${date.month}월';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 햄버거 메뉴 (옵션)
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          splashRadius: 20,
          onPressed: onMenuTap ?? () {},
        ),
        const SizedBox(width: 8),

        // 이전 달 버튼
        IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_left, color: Colors.white),
          splashRadius: 20,
          onPressed: onPrevMonth,
        ),

        // 현재 월 텍스트
        Text(
          monthText,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
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
          onPressed: () {},
          splashRadius: 20,
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

/// 주간 캘린더 – 요일 고정, 날짜만 변경되는 구조
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
    // weekday: 1(월) ~ 7(일), 일요일을 0으로 만들기 위해 조정
    final daysFromSunday = weekday == 7 ? 0 : weekday;
    return date.subtract(Duration(days: daysFromSunday));
  }

  @override
  Widget build(BuildContext context) {
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
                              color: AppTheme.accent1.withOpacity(0.4),
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
    return MouseRegion(
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
    );
  }
}

/// 우측 사이드 패널 (데스크톱 전용)
class _SidePanel extends StatelessWidget {
  final DateTime selectedDate;
  const _SidePanel({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.secondaryBackground1,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '오늘의 요약',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _SummaryTile(label: '운동', value: '0분'),
            _SummaryTile(label: '칼로리', value: '0kcal'),
            const SizedBox(height: 24),
            const _PremiumCard(),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryTile({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: AppTheme.accentGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.track_changes, color: Colors.white),
          const SizedBox(height: 12),
          const Text('프리미엄 플랜', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          const Text('더 많은 기능을 경험해보세요', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
            ),
            onPressed: () {},
            child: const Text('업그레이드'),
          ),
        ],
      ),
    );
  }
}

/// 스와이프 가능한 주간 뷰 위젯 (애니메이션 포함)
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

class _SwipeableWeekViewState extends State<_SwipeableWeekView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleSwipe(bool isNext) async {
    if (_isAnimating) return;
    
    setState(() => _isAnimating = true);
    
    // 슬라이드 아웃 애니메이션
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(isNext ? -1.0 : 1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    await _animationController.forward();
    
    // 주간 변경
    if (isNext) {
      widget.onNextWeek();
    } else {
      widget.onPrevWeek();
    }
    
    // 슬라이드 인 애니메이션 준비
    _slideAnimation = Tween<Offset>(
      begin: Offset(isNext ? 1.0 : -1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.reset();
    await _animationController.forward();
    
    setState(() => _isAnimating = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanEnd: (details) {
        if (_isAnimating) return;
        // 스와이프 감지
        if (details.velocity.pixelsPerSecond.dx > 500) {
          // 오른쪽으로 스와이프 -> 이전 주
          _handleSwipe(false);
        } else if (details.velocity.pixelsPerSecond.dx < -500) {
          // 왼쪽으로 스와이프 -> 다음 주
          _handleSwipe(true);
        }
      },
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              _slideAnimation.value.dx * MediaQuery.of(context).size.width,
              0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: widget.days.map((day) => Expanded(
                child: Center(child: widget.buildDayButton(day)),
              )).toList(),
            ),
          );
        },
      ),
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
        color: AppTheme.surface1.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.surface2.withOpacity(0.5), width: 1),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          gradient: AppTheme.accentGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent1.withOpacity(0.3),
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