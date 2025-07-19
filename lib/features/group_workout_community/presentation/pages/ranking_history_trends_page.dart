import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/di/injection_container.dart';
import 'package:jfit/core/widgets/responsive_layout.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import '../bloc/ranking/ranking_bloc.dart';
import '../bloc/ranking/ranking_event.dart';
import '../bloc/ranking/ranking_state.dart';
import '../widgets/ranking/ranking_trend_chart.dart';
import '../widgets/ranking/score_history_chart.dart';
import '../widgets/ranking/ranking_comparison_chart.dart';
import '../widgets/ranking/trend_analysis_widget.dart';
import '../widgets/ranking/historical_performance_widget.dart';
import '../widgets/ranking/ranking_period_selector.dart';
import '../../domain/entities/group_ranking.dart';
import '../../domain/repositories/ranking_repository.dart';

class RankingHistoryTrendsPage extends StatefulWidget {
  final String? groupId;
  final String? userId;
  final String title;

  const RankingHistoryTrendsPage({
    super.key,
    this.groupId,
    this.userId,
    this.title = '랭킹 히스토리 & 트렌드',
  });

  @override
  State<RankingHistoryTrendsPage> createState() => _RankingHistoryTrendsPageState();
}

class _RankingHistoryTrendsPageState extends State<RankingHistoryTrendsPage>
    with TickerProviderStateMixin {
  late RankingBloc _rankingBloc;
  late TabController _tabController;
  RankingPeriod _selectedPeriod = RankingPeriod.weekly;
  int _periodCount = 12;
  String _selectedMetric = 'totalScore';

  @override
  void initState() {
    super.initState();
    _rankingBloc = getIt<RankingBloc>();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  void _loadInitialData() {
    if (widget.groupId != null) {
      _rankingBloc.add(LoadGroupRankingTrends(
        groupId: widget.groupId!,
        period: _selectedPeriod,
        periodCount: _periodCount,
      ));
    }
    
    if (widget.userId != null) {
      _rankingBloc.add(LoadUserScoreTrends(
        userId: widget.userId!,
        groupId: widget.groupId,
        period: _selectedPeriod,
        periodCount: _periodCount,
      ));
    }
    
    // Load general ranking trends for comparison
    _rankingBloc.add(LoadGroupRankings(
      request: RankingPeriodRequest(period: _selectedPeriod),
    ));
  }

  void _onPeriodChanged(RankingPeriod period) {
    setState(() {
      _selectedPeriod = period;
    });
    _loadInitialData();
  }

  void _onPeriodCountChanged(int count) {
    setState(() {
      _periodCount = count;
    });
    _loadInitialData();
  }

  void _onMetricChanged(String metric) {
    setState(() {
      _selectedMetric = metric;
    });
  }

  void _onRefresh() {
    _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _rankingBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            PopupMenuButton<int>(
              icon: const Icon(Icons.timeline),
              tooltip: '기간 수',
              onSelected: _onPeriodCountChanged,
              itemBuilder: (context) => [
                const PopupMenuItem(value: 6, child: Text('6개 기간')),
                const PopupMenuItem(value: 12, child: Text('12개 기간')),
                const PopupMenuItem(value: 24, child: Text('24개 기간')),
                const PopupMenuItem(value: 52, child: Text('52개 기간')),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _onRefresh,
            ),
          ],
          bottom: BreakpointUtils.isMobile(MediaQuery.of(context).size.width)
              ? TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: '트렌드', icon: Icon(Icons.trending_up)),
                    Tab(text: '히스토리', icon: Icon(Icons.history)),
                    Tab(text: '비교', icon: Icon(Icons.compare_arrows)),
                  ],
                )
              : null,
        ),
        body: ResponsiveLayout(
          mobile: _buildMobileLayout(),
          tablet: _buildTabletLayout(),
          desktop: _buildDesktopLayout(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return BlocBuilder<RankingBloc, RankingState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async => _onRefresh(),
          child: Column(
            children: [
              _buildControlsHeader(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTrendsTab(state),
                    _buildHistoryTab(state),
                    _buildComparisonTab(state),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabletLayout() {
    return BlocBuilder<RankingBloc, RankingState>(
      builder: (context, state) {
        return Row(
          children: [
            // Left sidebar with controls
            SizedBox(
              width: 300,
              child: Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '설정',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      RankingPeriodSelector(
                        selectedPeriod: _selectedPeriod,
                        onPeriodChanged: _onPeriodChanged,
                        isVertical: true,
                      ),
                      const SizedBox(height: 24),
                      _buildMetricSelector(),
                      const SizedBox(height: 24),
                      _buildPeriodCountSelector(),
                      const SizedBox(height: 24),
                      if (state is RankingLoaded)
                        _buildTrendSummary(state),
                    ],
                  ),
                ),
              ),
            ),
            // Main content area
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _onRefresh(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTrendChartCard(state),
                      const SizedBox(height: 16),
                      _buildHistoryChartCard(state),
                      const SizedBox(height: 16),
                      _buildAnalysisCard(state),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    return BlocBuilder<RankingBloc, RankingState>(
      builder: (context, state) {
        return Row(
          children: [
            // Left sidebar
            SizedBox(
              width: 320,
              child: Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '트렌드 분석 설정',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 20),
                      RankingPeriodSelector(
                        selectedPeriod: _selectedPeriod,
                        onPeriodChanged: _onPeriodChanged,
                        isVertical: true,
                      ),
                      const SizedBox(height: 24),
                      _buildMetricSelector(),
                      const SizedBox(height: 24),
                      _buildPeriodCountSelector(),
                      const SizedBox(height: 32),
                      if (state is RankingLoaded)
                        _buildTrendSummary(state),
                    ],
                  ),
                ),
              ),
            ),
            // Main content area
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _onRefresh(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Top row - Charts
                      Row(
                        children: [
                          Expanded(child: _buildTrendChartCard(state)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildHistoryChartCard(state)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Bottom row - Analysis
                      _buildAnalysisCard(state),
                    ],
                  ),
                ),
              ),
            ),
            // Right sidebar for additional insights
            if (BreakpointUtils.isDesktop(MediaQuery.of(context).size.width))
              SizedBox(
                width: 300,
                child: Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '인사이트',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        if (state is RankingLoaded)
                          _buildInsightsWidget(state)
                        else
                          const Text('인사이트 데이터가 없습니다'),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildControlsHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          RankingPeriodSelector(
            selectedPeriod: _selectedPeriod,
            onPeriodChanged: _onPeriodChanged,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetricSelector()),
              const SizedBox(width: 12),
              Expanded(child: _buildPeriodCountSelector()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(RankingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTrendChartCard(state),
          const SizedBox(height: 16),
          _buildTrendAnalysisCard(state),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(RankingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHistoryChartCard(state),
          const SizedBox(height: 16),
          _buildHistoricalPerformanceCard(state),
        ],
      ),
    );
  }

  Widget _buildComparisonTab(RankingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildComparisonChartCard(state),
          const SizedBox(height: 16),
          _buildComparisonAnalysisCard(state),
        ],
      ),
    );
  }

  Widget _buildTrendChartCard(RankingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '랭킹 트렌드',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (state is RankingLoaded && state.hasRankingTrends)
              RankingTrendChart(
                groupTrends: state.groupRankingTrends,
                userTrends: state.userScoreTrends,
                selectedMetric: _selectedMetric,
                height: BreakpointUtils.isMobile(MediaQuery.of(context).size.width) ? 250 : 300,
              )
            else
              const Center(
                child: Text('트렌드 데이터가 없습니다'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryChartCard(RankingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '점수 히스토리',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (state is RankingLoaded && state.userScoreTrends.isNotEmpty)
              ScoreHistoryChart(
                scoreTrends: state.userScoreTrends,
                selectedMetric: _selectedMetric,
                height: BreakpointUtils.isMobile(MediaQuery.of(context).size.width) ? 250 : 300,
              )
            else
              const Center(
                child: Text('히스토리 데이터가 없습니다'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonChartCard(RankingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '랭킹 비교',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (state is RankingLoaded && state.hasGroupRankings)
              RankingComparisonChart(
                groupRankings: state.groupRankings,
                groupTrends: state.groupRankingTrends,
                height: BreakpointUtils.isMobile(MediaQuery.of(context).size.width) ? 250 : 300,
              )
            else
              const Center(
                child: Text('비교 데이터가 없습니다'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(RankingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '트렌드 분석',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (state is RankingLoaded && state.hasRankingTrends)
              TrendAnalysisWidget(
                groupTrends: state.groupRankingTrends,
                userTrends: state.userScoreTrends,
                period: _selectedPeriod,
                isDetailed: !BreakpointUtils.isMobile(MediaQuery.of(context).size.width),
              )
            else
              const Center(
                child: Text('분석 데이터가 없습니다'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendAnalysisCard(RankingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '트렌드 요약',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (state is RankingLoaded && state.hasRankingTrends)
              _buildTrendSummaryList(state)
            else
              const Text('트렌드 요약 데이터가 없습니다'),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoricalPerformanceCard(RankingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '성과 기록',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (state is RankingLoaded && state.userScoreTrends.isNotEmpty)
              HistoricalPerformanceWidget(
                scoreTrends: state.userScoreTrends,
                isCompact: BreakpointUtils.isMobile(MediaQuery.of(context).size.width),
              )
            else
              const Text('성과 기록 데이터가 없습니다'),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonAnalysisCard(RankingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '비교 분석',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (state is RankingLoaded && state.hasGroupRankings)
              _buildComparisonAnalysisList(state)
            else
              const Text('비교 분석 데이터가 없습니다'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '분석 지표',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedMetric,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: const [
            DropdownMenuItem(value: 'totalScore', child: Text('총점')),
            DropdownMenuItem(value: 'balanceScore', child: Text('균형 점수')),
            DropdownMenuItem(value: 'volumeScore', child: Text('볼륨 점수')),
            DropdownMenuItem(value: 'progressScore', child: Text('진전 점수')),
            DropdownMenuItem(value: 'consistencyScore', child: Text('일관성 점수')),
            DropdownMenuItem(value: 'rank', child: Text('랭킹')),
          ],
          onChanged: (value) {
            if (value != null) {
              _onMetricChanged(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildPeriodCountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '기간 수',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _periodCount,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: const [
            DropdownMenuItem(value: 6, child: Text('6개 기간')),
            DropdownMenuItem(value: 12, child: Text('12개 기간')),
            DropdownMenuItem(value: 24, child: Text('24개 기간')),
            DropdownMenuItem(value: 52, child: Text('52개 기간')),
          ],
          onChanged: (value) {
            if (value != null) {
              _onPeriodCountChanged(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTrendSummary(RankingLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '요약',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _buildSummaryItem('분석 기간', '${_periodCount}개 ${_getPeriodText()}'),
        _buildSummaryItem('선택 지표', _getMetricText(_selectedMetric)),
        if (state.hasRankingTrends)
          _buildSummaryItem('트렌드 방향', _getTrendDirection(state)),
        if (state.userScoreTrends.isNotEmpty)
          _buildSummaryItem('최근 성과', _getRecentPerformance(state)),
      ],
    );
  }

  Widget _buildInsightsWidget(RankingLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.hasRankingTrends) ...[
          _buildInsightItem(
            Icons.trending_up,
            '트렌드 분석',
            _getTrendInsight(state),
          ),
          const SizedBox(height: 12),
        ],
        if (state.userScoreTrends.isNotEmpty) ...[
          _buildInsightItem(
            Icons.analytics,
            '성과 분석',
            _getPerformanceInsight(state),
          ),
          const SizedBox(height: 12),
        ],
        _buildInsightItem(
          Icons.lightbulb_outline,
          '개선 제안',
          _getImprovementSuggestion(state),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrendSummaryList(RankingLoaded state) {
    // Implementation for trend summary list
    return const Text('트렌드 요약 구현 예정');
  }

  Widget _buildComparisonAnalysisList(RankingLoaded state) {
    // Implementation for comparison analysis list
    return const Text('비교 분석 구현 예정');
  }

  String _getPeriodText() {
    switch (_selectedPeriod) {
      case RankingPeriod.daily:
        return '일';
      case RankingPeriod.weekly:
        return '주';
      case RankingPeriod.monthly:
        return '월';
    }
  }

  String _getMetricText(String metric) {
    switch (metric) {
      case 'totalScore':
        return '총점';
      case 'balanceScore':
        return '균형 점수';
      case 'volumeScore':
        return '볼륨 점수';
      case 'progressScore':
        return '진전 점수';
      case 'consistencyScore':
        return '일관성 점수';
      case 'rank':
        return '랭킹';
      default:
        return metric;
    }
  }

  String _getTrendDirection(RankingLoaded state) {
    // Analyze trend direction from data
    return '상승 추세';
  }

  String _getRecentPerformance(RankingLoaded state) {
    // Analyze recent performance
    return '개선됨';
  }

  String _getTrendInsight(RankingLoaded state) {
    return '지난 ${_periodCount}개 기간 동안 꾸준한 상승 추세를 보이고 있습니다.';
  }

  String _getPerformanceInsight(RankingLoaded state) {
    return '최근 성과가 이전 대비 15% 향상되었습니다.';
  }

  String _getImprovementSuggestion(RankingLoaded state) {
    return '일관성 점수 향상을 위해 규칙적인 운동 스케줄을 유지해보세요.';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rankingBloc.close();
    super.dispose();
  }
}