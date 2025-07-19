import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/di/injection_container.dart';
import 'package:jfit/core/widgets/responsive_layout.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import '../bloc/ranking/ranking_bloc.dart';
import '../bloc/ranking/ranking_event.dart';
import '../bloc/ranking/ranking_state.dart';
import '../widgets/ranking/volume_analysis_chart.dart';
import '../widgets/ranking/consistency_analysis_chart.dart';
import '../widgets/ranking/progress_analysis_chart.dart';
import '../widgets/ranking/detailed_score_metrics.dart';
import '../widgets/ranking/workout_frequency_chart.dart';
import '../widgets/ranking/exercise_variety_analysis.dart';
import '../../domain/entities/group_ranking.dart';
import '../../domain/repositories/ranking_repository.dart';

class ScoreDetailedAnalysisPage extends StatefulWidget {
  final String userId;
  final String? groupId;
  final DateTime? startDate;
  final DateTime? endDate;

  const ScoreDetailedAnalysisPage({
    super.key,
    required this.userId,
    this.groupId,
    this.startDate,
    this.endDate,
  });

  @override
  State<ScoreDetailedAnalysisPage> createState() => _ScoreDetailedAnalysisPageState();
}

class _ScoreDetailedAnalysisPageState extends State<ScoreDetailedAnalysisPage>
    with TickerProviderStateMixin {
  late RankingBloc _rankingBloc;
  late TabController _tabController;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _rankingBloc = getIt<RankingBloc>();
    _tabController = TabController(length: 4, vsync: this);
    
    final now = DateTime.now();
    _startDate = widget.startDate ?? now.subtract(const Duration(days: 30));
    _endDate = widget.endDate ?? now;
    
    _loadInitialData();
  }

  void _loadInitialData() {
    _rankingBloc.add(LoadScoreBreakdown(
      userId: widget.userId,
      startDate: _startDate,
      endDate: _endDate,
    ));
    
    _rankingBloc.add(LoadWorkoutAnalysis(
      userId: widget.userId,
      startDate: _startDate,
      endDate: _endDate,
    ));
    
    _rankingBloc.add(LoadBodyPartDistribution(
      userId: widget.userId,
      startDate: _startDate,
      endDate: _endDate,
    ));
    
    _rankingBloc.add(LoadUserScores(
      userId: widget.userId,
      groupId: widget.groupId,
      period: RankingPeriodRequest(
        period: RankingPeriod.weekly,
        startDate: _startDate,
        endDate: _endDate,
      ),
    ));
  }

  void _onDateRangeChanged(DateTime start, DateTime end) {
    setState(() {
      _startDate = start;
      _endDate = end;
    });
    _loadInitialData();
  }

  void _onRefresh() {
    _loadInitialData();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    
    if (picked != null) {
      _onDateRangeChanged(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _rankingBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('점수 상세 분석'),
          actions: [
            IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: _selectDateRange,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _onRefresh,
            ),
          ],
          bottom: BreakpointUtils.isMobile(MediaQuery.of(context).size.width)
              ? TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: const [
                    Tab(text: '볼륨', icon: Icon(Icons.fitness_center)),
                    Tab(text: '일관성', icon: Icon(Icons.schedule)),
                    Tab(text: '진전도', icon: Icon(Icons.trending_up)),
                    Tab(text: '종합', icon: Icon(Icons.analytics)),
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
              _buildDateRangeHeader(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildVolumeAnalysisTab(state),
                    _buildConsistencyAnalysisTab(state),
                    _buildProgressAnalysisTab(state),
                    _buildComprehensiveAnalysisTab(state),
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
        return RefreshIndicator(
          onRefresh: () async => _onRefresh(),
          child: Column(
            children: [
              _buildDateRangeHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Top row - Volume and Consistency
                      Row(
                        children: [
                          Expanded(child: _buildVolumeAnalysisCard(state)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildConsistencyAnalysisCard(state)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Middle row - Progress and Metrics
                      Row(
                        children: [
                          Expanded(child: _buildProgressAnalysisCard(state)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildDetailedMetricsCard(state)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Bottom row - Comprehensive analysis
                      _buildWorkoutFrequencyCard(state),
                    ],
                  ),
                ),
              ),
            ],
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
          child: Column(
            children: [
              _buildDateRangeHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Top row - 3 columns
                      Row(
                        children: [
                          Expanded(child: _buildVolumeAnalysisCard(state)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildConsistencyAnalysisCard(state)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildProgressAnalysisCard(state)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Middle row - 2 columns
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildWorkoutFrequencyCard(state),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: _buildDetailedMetricsCard(state)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Bottom row - Full width
                      _buildExerciseVarietyCard(state),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateRangeHeader() {
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
      child: Row(
        children: [
          Icon(
            Icons.date_range,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            '분석 기간: ${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.edit),
            label: const Text('변경'),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeAnalysisTab(RankingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildVolumeAnalysisCard(state),
          const SizedBox(height: 16),
          _buildVolumeMetricsCard(state),
        ],
      ),
    );
  }

  Widget _buildConsistencyAnalysisTab(RankingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildConsistencyAnalysisCard(state),
          const SizedBox(height: 16),
          _buildWorkoutFrequencyCard(state),
        ],
      ),
    );
  }

  Widget _buildProgressAnalysisTab(RankingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProgressAnalysisCard(state),
          const SizedBox(height: 16),
          _buildProgressMetricsCard(state),
        ],
      ),
    );
  }

  Widget _buildComprehensiveAnalysisTab(RankingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDetailedMetricsCard(state),
          const SizedBox(height: 16),
          _buildExerciseVarietyCard(state),
        ],
      ),
    );
  }

  Widget _buildVolumeAnalysisCard(RankingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '볼륨 분석',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (state is RankingLoaded && state.hasWorkoutAnalysis)
              VolumeAnalysisChart(
                workoutAnalysis: state.workoutAnalysis!,
                height: BreakpointUtils.isMobile(MediaQuery.of(context).size.width) ? 200 : 250,
              )
            else
              const Center(
                child: Text('볼륨 데이터가 없습니다'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsistencyAnalysisCard(RankingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '일관성 분석',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (state is RankingLoaded && state.hasWorkoutAnalysis)
              ConsistencyAnalysisChart(
                workoutAnalysis: state.workoutAnalysis!,
                height: BreakpointUtils.isMobile(MediaQuery.of(context).size.width) ? 200 : 250,
              )
            else
              const Center(
                child: Text('일관성 데이터가 없습니다'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressAnalysisCard(RankingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '진전도 분석',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (state is RankingLoaded && state.userScoreTrends.isNotEmpty)
              ProgressAnalysisChart(
                scoreTrends: state.userScoreTrends,
                height: BreakpointUtils.isMobile(MediaQuery.of(context).size.width) ? 200 : 250,
              )
            else
              const Center(
                child: Text('진전도 데이터가 없습니다'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedMetricsCard(RankingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '상세 지표',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (state is RankingLoaded && state.hasScoreBreakdown)
              DetailedScoreMetrics(
                scoreBreakdown: state.scoreBreakdown!,
                workoutAnalysis: state.workoutAnalysis,
                isCompact: BreakpointUtils.isMobile(MediaQuery.of(context).size.width),
              )
            else
              const Center(
                child: Text('상세 지표 데이터가 없습니다'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutFrequencyCard(RankingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '운동 빈도',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (state is RankingLoaded && state.hasWorkoutAnalysis)
              WorkoutFrequencyChart(
                workoutAnalysis: state.workoutAnalysis!,
                height: BreakpointUtils.isMobile(MediaQuery.of(context).size.width) ? 200 : 300,
              )
            else
              const Center(
                child: Text('운동 빈도 데이터가 없습니다'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseVarietyCard(RankingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '운동 다양성',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (state is RankingLoaded && state.hasWorkoutAnalysis)
              ExerciseVarietyAnalysis(
                workoutAnalysis: state.workoutAnalysis!,
                bodyPartDistribution: state.bodyPartDistribution,
                isDetailed: !BreakpointUtils.isMobile(MediaQuery.of(context).size.width),
              )
            else
              const Center(
                child: Text('운동 다양성 데이터가 없습니다'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeMetricsCard(RankingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '볼륨 지표',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (state is RankingLoaded && state.hasWorkoutAnalysis) ...[
              _buildMetricRow('총 볼륨', '${state.workoutAnalysis!['totalVolume'] ?? 0} kg'),
              _buildMetricRow('평균 세션 볼륨', '${state.workoutAnalysis!['averageSessionVolume'] ?? 0} kg'),
              _buildMetricRow('최고 세션 볼륨', '${state.workoutAnalysis!['maxSessionVolume'] ?? 0} kg'),
              _buildMetricRow('볼륨 증가율', '${state.workoutAnalysis!['volumeGrowthRate'] ?? 0}%'),
            ] else
              const Text('볼륨 지표 데이터가 없습니다'),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressMetricsCard(RankingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '진전도 지표',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (state is RankingLoaded && state.hasWorkoutAnalysis) ...[
              _buildMetricRow('점수 개선율', '${state.workoutAnalysis!['scoreImprovementRate'] ?? 0}%'),
              _buildMetricRow('강도 증가율', '${state.workoutAnalysis!['intensityGrowthRate'] ?? 0}%'),
              _buildMetricRow('운동 다양성 증가', '${state.workoutAnalysis!['varietyIncrease'] ?? 0}개'),
              _buildMetricRow('목표 달성률', '${state.workoutAnalysis!['goalAchievementRate'] ?? 0}%'),
            ] else
              const Text('진전도 지표 데이터가 없습니다'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
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

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rankingBloc.close();
    super.dispose();
  }
}