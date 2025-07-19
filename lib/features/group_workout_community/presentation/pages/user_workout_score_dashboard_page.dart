import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/di/injection_container.dart';
import 'package:jfit/core/widgets/responsive_layout.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import '../bloc/ranking/ranking_bloc.dart';
import '../bloc/ranking/ranking_event.dart';
import '../bloc/ranking/ranking_state.dart';
import '../widgets/ranking/user_score_overview_card.dart';
import '../widgets/ranking/body_part_balance_chart.dart';
import '../widgets/ranking/score_trend_chart.dart';
import '../widgets/ranking/score_breakdown_widget.dart';
import '../widgets/ranking/workout_analysis_widget.dart';
import '../../domain/entities/group_ranking.dart';
import '../../domain/repositories/ranking_repository.dart';

class UserWorkoutScoreDashboardPage extends StatefulWidget {
  final String userId;
  final String? groupId;

  const UserWorkoutScoreDashboardPage({
    super.key,
    required this.userId,
    this.groupId,
  });

  @override
  State<UserWorkoutScoreDashboardPage> createState() => _UserWorkoutScoreDashboardPageState();
}

class _UserWorkoutScoreDashboardPageState extends State<UserWorkoutScoreDashboardPage>
    with TickerProviderStateMixin {
  late RankingBloc _rankingBloc;
  late TabController _tabController;
  RankingPeriod _selectedPeriod = RankingPeriod.weekly;

  @override
  void initState() {
    super.initState();
    _rankingBloc = getIt<RankingBloc>();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  void _loadInitialData() {
    final now = DateTime.now();
    final startDate = _getStartDateForPeriod(now, _selectedPeriod);
    
    _rankingBloc.add(LoadUserScores(
      userId: widget.userId,
      groupId: widget.groupId,
      period: RankingPeriodRequest(period: _selectedPeriod),
    ));
    
    _rankingBloc.add(LoadScoreBreakdown(
      userId: widget.userId,
      startDate: startDate,
      endDate: now,
    ));
    
    _rankingBloc.add(LoadUserScoreTrends(
      userId: widget.userId,
      groupId: widget.groupId,
      period: _selectedPeriod,
    ));
    
    _rankingBloc.add(LoadBodyPartDistribution(
      userId: widget.userId,
      startDate: startDate,
      endDate: now,
    ));
    
    _rankingBloc.add(LoadWorkoutAnalysis(
      userId: widget.userId,
      startDate: startDate,
      endDate: now,
    ));
  }

  DateTime _getStartDateForPeriod(DateTime endDate, RankingPeriod period) {
    switch (period) {
      case RankingPeriod.daily:
        return DateTime(endDate.year, endDate.month, endDate.day);
      case RankingPeriod.weekly:
        return endDate.subtract(const Duration(days: 7));
      case RankingPeriod.monthly:
        return DateTime(endDate.year, endDate.month - 1, endDate.day);
    }
  }

  void _onPeriodChanged(RankingPeriod period) {
    setState(() {
      _selectedPeriod = period;
    });
    _loadInitialData();
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
          title: const Text('내 운동 점수'),
          actions: [
            PopupMenuButton<RankingPeriod>(
              icon: const Icon(Icons.date_range),
              onSelected: _onPeriodChanged,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: RankingPeriod.daily,
                  child: Text('일간'),
                ),
                const PopupMenuItem(
                  value: RankingPeriod.weekly,
                  child: Text('주간'),
                ),
                const PopupMenuItem(
                  value: RankingPeriod.monthly,
                  child: Text('월간'),
                ),
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
                    Tab(text: '개요', icon: Icon(Icons.dashboard)),
                    Tab(text: '분석', icon: Icon(Icons.analytics)),
                    Tab(text: '트렌드', icon: Icon(Icons.trending_up)),
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
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(state),
              _buildAnalysisTab(state),
              _buildTrendsTab(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabletLayout() {
    return BlocBuilder<RankingBloc, RankingState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async => _onRefresh(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Top row - Overview cards
                Row(
                  children: [
                    Expanded(child: _buildScoreOverviewCard(state)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildBodyPartBalanceCard(state)),
                  ],
                ),
                const SizedBox(height: 16),
                // Middle row - Charts
                Row(
                  children: [
                    Expanded(child: _buildScoreTrendCard(state)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildScoreBreakdownCard(state)),
                  ],
                ),
                const SizedBox(height: 16),
                // Bottom row - Analysis
                _buildWorkoutAnalysisCard(state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    return BlocBuilder<RankingBloc, RankingState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async => _onRefresh(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Top row - Overview cards (3 columns)
                Row(
                  children: [
                    Expanded(child: _buildScoreOverviewCard(state)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildBodyPartBalanceCard(state)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildQuickStatsCard(state)),
                  ],
                ),
                const SizedBox(height: 24),
                // Middle row - Charts (2 columns)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildScoreTrendCard(state),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _buildScoreBreakdownCard(state)),
                  ],
                ),
                const SizedBox(height: 24),
                // Bottom row - Detailed analysis
                _buildWorkoutAnalysisCard(state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(RankingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildScoreOverviewCard(state),
          const SizedBox(height: 16),
          _buildBodyPartBalanceCard(state),
          const SizedBox(height: 16),
          _buildQuickStatsCard(state),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab(RankingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildScoreBreakdownCard(state),
          const SizedBox(height: 16),
          _buildWorkoutAnalysisCard(state),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(RankingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildScoreTrendCard(state),
          const SizedBox(height: 16),
          _buildPerformanceHistoryCard(state),
        ],
      ),
    );
  }

  Widget _buildScoreOverviewCard(RankingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '점수 개요',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (state is RankingLoaded && state.hasUserScores)
              UserScoreOverviewCard(
                userScore: state.latestUserScore!,
                period: _selectedPeriod,
              )
            else
              const Center(
                child: Text('점수 데이터가 없습니다'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyPartBalanceCard(RankingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '부위별 균형',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (state is RankingLoaded && state.hasBodyPartDistribution)
              BodyPartBalanceChart(
                bodyPartDistribution: state.bodyPartDistribution!,
                height: BreakpointUtils.isMobile(MediaQuery.of(context).size.width) ? 200 : 250,
              )
            else
              const Center(
                child: Text('부위별 데이터가 없습니다'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreTrendCard(RankingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '점수 변화 추이',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (state is RankingLoaded && state.userScoreTrends.isNotEmpty)
              ScoreTrendChart(
                scoreTrends: state.userScoreTrends,
                height: BreakpointUtils.isMobile(MediaQuery.of(context).size.width) ? 200 : 300,
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

  Widget _buildScoreBreakdownCard(RankingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '점수 세부 분석',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (state is RankingLoaded && state.hasScoreBreakdown)
              ScoreBreakdownWidget(
                scoreBreakdown: state.scoreBreakdown!,
                isCompact: BreakpointUtils.isMobile(MediaQuery.of(context).size.width),
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

  Widget _buildWorkoutAnalysisCard(RankingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '운동 분석',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (state is RankingLoaded && state.hasWorkoutAnalysis)
              WorkoutAnalysisWidget(
                workoutAnalysis: state.workoutAnalysis!,
                isDetailed: !BreakpointUtils.isMobile(MediaQuery.of(context).size.width),
              )
            else
              const Center(
                child: Text('운동 분석 데이터가 없습니다'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard(RankingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '빠른 통계',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (state is RankingLoaded && state.hasUserScores) ...[
              _buildStatItem(
                '현재 등급',
                state.userScoreGrade ?? 'N/A',
                Icons.grade,
              ),
              _buildStatItem(
                '운동 균형',
                state.isUserWorkoutBalanced ? '균형잡힘' : '불균형',
                Icons.balance,
              ),
              _buildStatItem(
                '점수 추세',
                _getScoreTrendText(state.userScoreTrend),
                _getScoreTrendIcon(state.userScoreTrend),
              ),
              _buildStatItem(
                '강점 부위',
                state.userBestBodyPart?.name ?? 'N/A',
                Icons.fitness_center,
              ),
            ] else
              const Center(
                child: Text('통계 데이터가 없습니다'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceHistoryCard(RankingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '성과 기록',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (state is RankingLoaded && state.hasUserScores) ...[
              ...state.userScores.take(10).map((score) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getScoreColor(score.totalScore),
                  child: Text(
                    score.scoreGrade,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text('${score.totalScore.toStringAsFixed(1)}점'),
                subtitle: Text(_formatDate(score.scoreDate)),
                trailing: Icon(
                  score.isBalanced ? Icons.check_circle : Icons.warning,
                  color: score.isBalanced ? Colors.green : Colors.orange,
                ),
              )),
            ] else
              const Center(
                child: Text('성과 기록이 없습니다'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getScoreTrendText(String trend) {
    switch (trend) {
      case 'improving':
        return '상승 중';
      case 'declining':
        return '하락 중';
      case 'stable':
        return '안정적';
      default:
        return '데이터 부족';
    }
  }

  IconData _getScoreTrendIcon(String trend) {
    switch (trend) {
      case 'improving':
        return Icons.trending_up;
      case 'declining':
        return Icons.trending_down;
      case 'stable':
        return Icons.trending_flat;
      default:
        return Icons.help_outline;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.purple;
    if (score >= 80) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 60) return Colors.orange;
    if (score >= 50) return Colors.red;
    return Colors.grey;
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rankingBloc.close();
    super.dispose();
  }
}