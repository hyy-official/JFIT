import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/widgets/responsive_layout.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import 'package:jfit/l10n/app_localizations.dart';
import '../bloc/pt_diet/pt_diet_bloc.dart';
import '../bloc/pt_diet/pt_diet_event.dart';
import '../bloc/pt_diet/pt_diet_state.dart';
import '../widgets/diet_dashboard/diet_dashboard_header.dart';
import '../widgets/diet_dashboard/group_diet_overview_card.dart';
import '../widgets/diet_dashboard/member_diet_grid.dart';
import '../widgets/diet_dashboard/diet_analytics_summary.dart';
import '../widgets/diet_dashboard/recent_diet_activity.dart';
import '../widgets/diet_dashboard/diet_alerts_panel.dart';

/// PT 그룹 식단 대시보드 화면
/// 전체 회원 식단 요약, 목표 달성률을 반응형으로 표시
class PTGroupDietDashboardPage extends StatefulWidget {
  final String groupId;
  final String trainerId;

  const PTGroupDietDashboardPage({
    super.key,
    required this.groupId,
    required this.trainerId,
  });

  @override
  State<PTGroupDietDashboardPage> createState() => _PTGroupDietDashboardPageState();
}

class _PTGroupDietDashboardPageState extends State<PTGroupDietDashboardPage> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    context.read<PTDietBloc>().add(LoadGroupDietSummaries(
      groupId: widget.groupId,
      date: selectedDate,
    ));
    
    // Also load recent diet activity
    context.read<PTDietBloc>().add(LoadRecentDietActivity(
      groupId: widget.groupId,
      hours: 24,
    ));
    
    // Load nutrition alerts
    context.read<PTDietBloc>().add(LoadNutritionAlerts(
      groupId: widget.groupId,
      date: selectedDate,
    ));
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
    });
    _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ptDietDashboard ?? 'PT 식단 대시보드'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: l10n.refresh ?? '새로고침',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showDashboardSettings(context),
            tooltip: '설정',
          ),
        ],
      ),
      body: BlocConsumer<PTDietBloc, PTDietState>(
        listener: (context, state) {
          if (state is PTDietError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is PTDietOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PTDietLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return ResponsiveLayout(
            mobile: _buildMobileLayout(context),
            tablet: _buildTabletLayout(context),
            desktop: _buildDesktopLayout(context),
          );
        },
      ),
    );
  }

  /// 모바일 레이아웃 - 세로 스크롤
  Widget _buildMobileLayout(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _loadDashboardData(),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(BreakpointUtils.getScreenPadding(
          MediaQuery.of(context).size.width,
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DietDashboardHeader(
              selectedDate: selectedDate,
              onDateChanged: _onDateChanged,
            ),
            const ResponsiveSpacing.vertical(mobileSpacing: 16),
            GroupDietOverviewCard(
              groupId: widget.groupId,
              date: selectedDate,
            ),
            const ResponsiveSpacing.vertical(mobileSpacing: 16),
            DietAnalyticsSummary(
              groupId: widget.groupId,
              date: selectedDate,
            ),
            const ResponsiveSpacing.vertical(mobileSpacing: 16),
            MemberDietGrid(
              groupId: widget.groupId,
              trainerId: widget.trainerId,
              date: selectedDate,
              crossAxisCount: 1, // 모바일에서는 단일 컬럼
            ),
            const ResponsiveSpacing.vertical(mobileSpacing: 16),
            RecentDietActivity(
              groupId: widget.groupId,
              maxItems: 5,
            ),
            const ResponsiveSpacing.vertical(mobileSpacing: 16),
            DietAlertsPanel(
              groupId: widget.groupId,
              date: selectedDate,
            ),
          ],
        ),
      ),
    );
  }

  /// 태블릿 레이아웃 - 그리드 레이아웃
  Widget _buildTabletLayout(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _loadDashboardData(),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(BreakpointUtils.getScreenPadding(
          MediaQuery.of(context).size.width,
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DietDashboardHeader(
              selectedDate: selectedDate,
              onDateChanged: _onDateChanged,
            ),
            const ResponsiveSpacing.vertical(tabletSpacing: 20),
            // 상단 요약 카드들을 2x1 그리드로 배치
            Row(
              children: [
                Expanded(
                  child: GroupDietOverviewCard(
                    groupId: widget.groupId,
                    date: selectedDate,
                  ),
                ),
                const ResponsiveSpacing.horizontal(tabletSpacing: 20),
                Expanded(
                  child: DietAnalyticsSummary(
                    groupId: widget.groupId,
                    date: selectedDate,
                  ),
                ),
              ],
            ),
            const ResponsiveSpacing.vertical(tabletSpacing: 20),
            // 메인 콘텐츠 영역
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 왼쪽: 멤버 식단 그리드 (2/3)
                Expanded(
                  flex: 2,
                  child: MemberDietGrid(
                    groupId: widget.groupId,
                    trainerId: widget.trainerId,
                    date: selectedDate,
                    crossAxisCount: 2, // 태블릿에서는 2컬럼
                  ),
                ),
                const ResponsiveSpacing.horizontal(tabletSpacing: 20),
                // 오른쪽: 활동 및 알림 (1/3)
                Expanded(
                  child: Column(
                    children: [
                      RecentDietActivity(
                        groupId: widget.groupId,
                        maxItems: 8,
                      ),
                      const ResponsiveSpacing.vertical(tabletSpacing: 20),
                      DietAlertsPanel(
                        groupId: widget.groupId,
                        date: selectedDate,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 데스크탑 레이아웃 - 다중 컬럼 그리드
  Widget _buildDesktopLayout(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _loadDashboardData(),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(BreakpointUtils.getScreenPadding(
          MediaQuery.of(context).size.width,
        )),
        child: ResponsiveContainer(
          desktopMaxWidth: 1400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DietDashboardHeader(
                selectedDate: selectedDate,
                onDateChanged: _onDateChanged,
              ),
              const ResponsiveSpacing.vertical(desktopSpacing: 24),
              // 상단 요약 카드들을 3x1 그리드로 배치
              Row(
                children: [
                  Expanded(
                    child: GroupDietOverviewCard(
                      groupId: widget.groupId,
                      date: selectedDate,
                    ),
                  ),
                  const ResponsiveSpacing.horizontal(desktopSpacing: 24),
                  Expanded(
                    child: DietAnalyticsSummary(
                      groupId: widget.groupId,
                      date: selectedDate,
                    ),
                  ),
                  const ResponsiveSpacing.horizontal(desktopSpacing: 24),
                  Expanded(
                    child: DietAlertsPanel(
                      groupId: widget.groupId,
                      date: selectedDate,
                      isCompact: true,
                    ),
                  ),
                ],
              ),
              const ResponsiveSpacing.vertical(desktopSpacing: 24),
              // 메인 콘텐츠 영역
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 왼쪽: 멤버 식단 그리드 (3/4)
                  Expanded(
                    flex: 3,
                    child: MemberDietGrid(
                      groupId: widget.groupId,
                      trainerId: widget.trainerId,
                      date: selectedDate,
                      crossAxisCount: 3, // 데스크탑에서는 3컬럼
                    ),
                  ),
                  const ResponsiveSpacing.horizontal(desktopSpacing: 24),
                  // 오른쪽: 최근 활동 (1/4)
                  Expanded(
                    child: RecentDietActivity(
                      groupId: widget.groupId,
                      maxItems: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDashboardSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('대시보드 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('알림 설정'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to notification settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('분석 설정'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to analytics settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('데이터 내보내기'),
              onTap: () {
                Navigator.pop(context);
                _exportDashboardData();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close ?? '닫기'),
          ),
        ],
      ),
    );
  }

  void _exportDashboardData() {
    // TODO: Implement data export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.exportStarted ?? '데이터 내보내기가 시작되었습니다'),
      ),
    );
  }
}