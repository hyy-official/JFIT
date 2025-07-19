import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/di/injection_container.dart';
import 'package:jfit/core/widgets/responsive_layout.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import '../bloc/ranking/ranking_bloc.dart';
import '../bloc/ranking/ranking_event.dart';
import '../bloc/ranking/ranking_state.dart';
import '../widgets/ranking/member_score_table.dart';
import '../widgets/ranking/member_score_card_grid.dart';
import '../widgets/ranking/score_comparison_chart.dart';
import '../widgets/ranking/ranking_period_selector.dart';
import '../../domain/entities/group_ranking.dart';
import '../../domain/repositories/ranking_repository.dart';

class GroupMemberScoreComparisonPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupMemberScoreComparisonPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupMemberScoreComparisonPage> createState() => _GroupMemberScoreComparisonPageState();
}

class _GroupMemberScoreComparisonPageState extends State<GroupMemberScoreComparisonPage> {
  late RankingBloc _rankingBloc;
  RankingPeriod _selectedPeriod = RankingPeriod.weekly;
  bool _isTableView = true;
  String _sortBy = 'totalScore';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _rankingBloc = getIt<RankingBloc>();
    _loadInitialData();
  }

  void _loadInitialData() {
    _rankingBloc.add(LoadGroupMemberScores(
      groupId: widget.groupId,
      request: RankingPeriodRequest(period: _selectedPeriod),
    ));
    
    _rankingBloc.add(LoadGroupTopPerformers(
      groupId: widget.groupId,
      request: RankingPeriodRequest(period: _selectedPeriod),
    ));
  }

  void _onPeriodChanged(RankingPeriod period) {
    setState(() {
      _selectedPeriod = period;
    });
    _loadInitialData();
  }

  void _onViewModeChanged(bool isTableView) {
    setState(() {
      _isTableView = isTableView;
    });
  }

  void _onSortChanged(String sortBy, bool ascending) {
    setState(() {
      _sortBy = sortBy;
      _sortAscending = ascending;
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
          title: Text('${widget.groupName} 멤버 점수'),
          actions: [
            if (!BreakpointUtils.isMobile(MediaQuery.of(context).size.width))
              ToggleButtons(
                isSelected: [_isTableView, !_isTableView],
                onPressed: (index) => _onViewModeChanged(index == 0),
                children: const [
                  Icon(Icons.table_chart),
                  Icon(Icons.grid_view),
                ],
              ),
            const SizedBox(width: 8),
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
                      Row(
                        children: [
                          Expanded(
                            child: SegmentedButton<bool>(
                              segments: const [
                                ButtonSegment(
                                  value: false,
                                  label: Text('카드'),
                                  icon: Icon(Icons.grid_view),
                                ),
                                ButtonSegment(
                                  value: true,
                                  label: Text('테이블'),
                                  icon: Icon(Icons.table_chart),
                                ),
                              ],
                              selected: {_isTableView},
                              onSelectionChanged: (Set<bool> selection) {
                                _onViewModeChanged(selection.first);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _buildMemberScoreContent(state),
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
              width: 280,
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
                      Text(
                        '보기 방식',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: false,
                            label: Text('카드'),
                            icon: Icon(Icons.grid_view),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text('테이블'),
                            icon: Icon(Icons.table_chart),
                          ),
                        ],
                        selected: {_isTableView},
                        onSelectionChanged: (Set<bool> selection) {
                          _onViewModeChanged(selection.first);
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSortControls(),
                      const SizedBox(height: 24),
                      if (state is RankingLoaded && state.groupTopPerformers.isNotEmpty)
                        _buildTopPerformersWidget(state),
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
                  slivers: [_buildMemberScoreContent(state)],
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
                        '멤버 점수 비교',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 20),
                      RankingPeriodSelector(
                        selectedPeriod: _selectedPeriod,
                        onPeriodChanged: _onPeriodChanged,
                        isVertical: true,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '보기 방식',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: false,
                            label: Text('카드'),
                            icon: Icon(Icons.grid_view),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text('테이블'),
                            icon: Icon(Icons.table_chart),
                          ),
                        ],
                        selected: {_isTableView},
                        onSelectionChanged: (Set<bool> selection) {
                          _onViewModeChanged(selection.first);
                        },
                      ),
                      const SizedBox(height: 32),
                      _buildSortControls(),
                      const SizedBox(height: 32),
                      if (state is RankingLoaded && state.groupTopPerformers.isNotEmpty)
                        _buildTopPerformersWidget(state),
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
                  slivers: [_buildMemberScoreContent(state)],
                ),
              ),
            ),
            // Right sidebar for comparison chart (desktop only)
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
                          '점수 분포',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        if (state is RankingLoaded && state.hasGroupMemberScores)
                          Expanded(
                            child: ScoreComparisonChart(
                              memberScores: state.groupMemberScores,
                              height: 400,
                            ),
                          )
                        else
                          const Center(
                            child: Text('점수 데이터가 없습니다'),
                          ),
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

  Widget _buildMemberScoreContent(RankingState state) {
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
                '멤버 점수를 불러올 수 없습니다',
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
      if (!state.hasGroupMemberScores) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  '멤버 점수 데이터가 없습니다',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '아직 그룹 멤버들의 점수가 계산되지 않았습니다.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      final sortedScores = _sortMemberScores(state.groupMemberScores);

      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isTableView
              ? MemberScoreTable(
                  memberScores: sortedScores,
                  sortBy: _sortBy,
                  sortAscending: _sortAscending,
                  onSort: _onSortChanged,
                  onMemberTap: (memberId) {
                    // Navigate to member detail page
                    Navigator.pushNamed(
                      context,
                      '/user-score-dashboard',
                      arguments: {
                        'userId': memberId,
                        'groupId': widget.groupId,
                      },
                    );
                  },
                )
              : MemberScoreCardGrid(
                  memberScores: sortedScores,
                  onMemberTap: (memberId) {
                    Navigator.pushNamed(
                      context,
                      '/user-score-dashboard',
                      arguments: {
                        'userId': memberId,
                        'groupId': widget.groupId,
                      },
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

  Widget _buildSortControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '정렬',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _sortBy,
          decoration: const InputDecoration(
            labelText: '정렬 기준',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'totalScore', child: Text('총점')),
            DropdownMenuItem(value: 'balanceScore', child: Text('균형 점수')),
            DropdownMenuItem(value: 'volumeScore', child: Text('볼륨 점수')),
            DropdownMenuItem(value: 'progressScore', child: Text('진전 점수')),
            DropdownMenuItem(value: 'consistencyScore', child: Text('일관성 점수')),
            DropdownMenuItem(value: 'memberName', child: Text('이름')),
          ],
          onChanged: (value) {
            if (value != null) {
              _onSortChanged(value, _sortAscending);
            }
          },
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('오름차순'),
          value: _sortAscending,
          onChanged: (value) {
            _onSortChanged(_sortBy, value);
          },
        ),
      ],
    );
  }

  Widget _buildTopPerformersWidget(RankingLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상위 멤버',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...state.groupTopPerformers.take(5).map((performer) {
          final rank = performer['rank'] as int? ?? 0;
          final name = performer['memberName'] as String? ?? 'Unknown';
          final score = performer['totalScore'] as double? ?? 0.0;
          
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: _getRankColor(rank),
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            subtitle: Text(
              '${score.toStringAsFixed(1)}점',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }),
      ],
    );
  }

  List<Map<String, dynamic>> _sortMemberScores(List<Map<String, dynamic>> scores) {
    final sortedScores = List<Map<String, dynamic>>.from(scores);
    
    sortedScores.sort((a, b) {
      dynamic aValue = a[_sortBy];
      dynamic bValue = b[_sortBy];
      
      if (aValue == null && bValue == null) return 0;
      if (aValue == null) return _sortAscending ? -1 : 1;
      if (bValue == null) return _sortAscending ? 1 : -1;
      
      int comparison;
      if (aValue is String && bValue is String) {
        comparison = aValue.compareTo(bValue);
      } else if (aValue is num && bValue is num) {
        comparison = aValue.compareTo(bValue);
      } else {
        comparison = aValue.toString().compareTo(bValue.toString());
      }
      
      return _sortAscending ? comparison : -comparison;
    });
    
    return sortedScores;
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

  @override
  void dispose() {
    _rankingBloc.close();
    super.dispose();
  }
}