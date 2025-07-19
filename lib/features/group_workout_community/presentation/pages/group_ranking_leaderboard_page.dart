import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/di/injection_container.dart';
import 'package:jfit/core/widgets/responsive_layout.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import '../bloc/ranking/ranking_bloc.dart';
import '../bloc/ranking/ranking_event.dart';
import '../bloc/ranking/ranking_state.dart';
import '../widgets/ranking/ranking_leaderboard_widget.dart';
import '../widgets/ranking/ranking_period_selector.dart';
import '../widgets/ranking/ranking_stats_summary.dart';
import '../../domain/entities/group_ranking.dart';
import '../../domain/repositories/ranking_repository.dart';

class GroupRankingLeaderboardPage extends StatefulWidget {
  final String groupId;
  
  const GroupRankingLeaderboardPage({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupRankingLeaderboardPage> createState() => _GroupRankingLeaderboardPageState();
}

class _GroupRankingLeaderboardPageState extends State<GroupRankingLeaderboardPage> {
  late RankingBloc _rankingBloc;
  RankingPeriod _selectedPeriod = RankingPeriod.weekly;

  @override
  void initState() {
    super.initState();
    _rankingBloc = getIt<RankingBloc>();
    _loadInitialData();
  }

  void _loadInitialData() {
    _rankingBloc.add(LoadGroupRankings(
      request: RankingPeriodRequest(period: _selectedPeriod),
    ));
  }

  void _onPeriodChanged(RankingPeriod period) {
    setState(() {
      _selectedPeriod = period;
    });
    _rankingBloc.add(ChangeRankingPeriod(period: period));
  }

  void _onRefresh() {
    _rankingBloc.add(const RefreshRankings());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _rankingBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('그룹 랭킹'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _onRefresh,
            ),
          ],
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
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      RankingPeriodSelector(
                        selectedPeriod: _selectedPeriod,
                        onPeriodChanged: _onPeriodChanged,
                      ),
                      const SizedBox(height: 16),
                      if (state is RankingLoaded && state.hasGroupRankings)
                        RankingStatsSummary(
                          rankings: state.groupRankings,
                          period: _selectedPeriod,
                        ),
                    ],
                  ),
                ),
              ),
              _buildRankingContent(state),
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
            // Left sidebar with controls and stats
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
                        '랭킹 설정',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      RankingPeriodSelector(
                        selectedPeriod: _selectedPeriod,
                        onPeriodChanged: _onPeriodChanged,
                        isVertical: true,
                      ),
                      const SizedBox(height: 24),
                      if (state is RankingLoaded && state.hasGroupRankings) ...[
                        Text(
                          '통계 요약',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        RankingStatsSummary(
                          rankings: state.groupRankings,
                          period: _selectedPeriod,
                          isCompact: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Main content area
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _onRefresh(),
                child: CustomScrollView(
                  slivers: [_buildRankingContent(state)],
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
                        '랭킹 대시보드',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 20),
                      RankingPeriodSelector(
                        selectedPeriod: _selectedPeriod,
                        onPeriodChanged: _onPeriodChanged,
                        isVertical: true,
                      ),
                      const SizedBox(height: 32),
                      if (state is RankingLoaded && state.hasGroupRankings) ...[
                        Text(
                          '전체 통계',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        RankingStatsSummary(
                          rankings: state.groupRankings,
                          period: _selectedPeriod,
                          showDetailedStats: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Main content area
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _onRefresh(),
                child: CustomScrollView(
                  slivers: [_buildRankingContent(state)],
                ),
              ),
            ),
            // Right sidebar for additional info (desktop only)
            if (BreakpointUtils.isDesktop(MediaQuery.of(context).size.width))
              SizedBox(
                width: 280,
                child: Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '랭킹 정보',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        _buildRankingInfo(state),
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

  Widget _buildRankingContent(RankingState state) {
    if (state is RankingLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is RankingError) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                '랭킹을 불러올 수 없습니다',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _onRefresh,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is RankingLoaded) {
      if (!state.hasGroupRankings) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.leaderboard_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  '랭킹 데이터가 없습니다',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '아직 랭킹이 계산되지 않았습니다.\n잠시 후 다시 확인해주세요.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: RankingLeaderboardWidget(
            rankings: state.groupRankings,
            period: _selectedPeriod,
            onGroupTap: (groupId) {
              // Navigate to group detail page
              Navigator.pushNamed(
                context,
                '/group-detail',
                arguments: {'groupId': groupId},
              );
            },
          ),
        ),
      );
    }

    return const SliverFillRemaining(
      child: Center(child: Text('알 수 없는 상태입니다')),
    );
  }

  Widget _buildRankingInfo(RankingState state) {
    if (state is! RankingLoaded || !state.hasGroupRankings) {
      return const Text('랭킹 정보가 없습니다');
    }

    final topGroups = state.topRankingGroups;
    final totalGroups = state.groupRankings.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoItem('전체 그룹', '$totalGroups개'),
        _buildInfoItem('상위 그룹', '${topGroups.length}개'),
        _buildInfoItem('기간', state.periodDisplayString),
        _buildInfoItem('마지막 업데이트', _formatLastUpdate(state.lastUpdated)),
        const SizedBox(height: 16),
        if (topGroups.isNotEmpty) ...[
          Text(
            '상위 3개 그룹',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ...topGroups.take(3).map((group) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _getRankColor(group.rankPosition),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${group.rankPosition}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    group.groupName,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
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

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[400]!;
      default:
        return Colors.blue;
    }
  }

  String _formatLastUpdate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }

  @override
  void dispose() {
    _rankingBloc.close();
    super.dispose();
  }
}