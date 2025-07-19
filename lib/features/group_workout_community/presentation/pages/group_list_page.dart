import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/widgets/responsive_layout.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group/group_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group/group_event.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group/group_state.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/group_card.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/group_search_bar.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/group_filter_chips.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';

/// 그룹 목록 화면 - 내 그룹과 공개 그룹 탐색
class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  GroupFilter _currentFilter = GroupFilter.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
    
    // Load initial data
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final userId = 'current_user_id'; // TODO: Get from auth service
    context.read<GroupBloc>().add(LoadUserGroups(userId: userId));
    context.read<GroupBloc>().add(const LoadPublicGroups());
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more public groups when near bottom
      if (_tabController.index == 1) {
        _loadMorePublicGroups();
      }
    }
  }

  void _loadMorePublicGroups() {
    final state = context.read<GroupBloc>().state;
    if (state is PublicGroupsLoaded && state.hasMore) {
      context.read<GroupBloc>().add(LoadPublicGroups(
        offset: state.groups.length,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      ));
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    
    if (_tabController.index == 1) {
      context.read<GroupBloc>().add(LoadPublicGroups(
        searchQuery: query.isEmpty ? null : query,
      ));
    }
  }

  void _onFilterChanged(GroupFilter filter) {
    setState(() {
      _currentFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('운동 그룹'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '내 그룹'),
            Tab(text: '그룹 찾기'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_tabController.index == 1) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GroupSearchBar(
                onSearchChanged: _onSearchChanged,
                hintText: '그룹 이름으로 검색',
              ),
            ),
            GroupFilterChips(
              currentFilter: _currentFilter,
              onFilterChanged: _onFilterChanged,
            ),
          ],
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMyGroupsList(),
                _buildPublicGroupsList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateGroup(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('운동 그룹'),
      ),
      body: Row(
        children: [
          // Sidebar with tabs
          SizedBox(
            width: 280,
            child: Column(
              children: [
                _buildTabletSidebar(),
                if (_tabController.index == 1) ...[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GroupSearchBar(
                      onSearchChanged: _onSearchChanged,
                      hintText: '그룹 이름으로 검색',
                    ),
                  ),
                  GroupFilterChips(
                    currentFilter: _currentFilter,
                    onFilterChanged: _onFilterChanged,
                  ),
                ],
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Main content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMyGroupsList(),
                _buildPublicGroupsList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateGroup(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('운동 그룹'),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateGroup(),
            icon: const Icon(Icons.add),
            label: const Text('그룹 생성'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          SizedBox(
            width: 320,
            child: Column(
              children: [
                _buildDesktopSidebar(),
                if (_tabController.index == 1) ...[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GroupSearchBar(
                      onSearchChanged: _onSearchChanged,
                      hintText: '그룹 이름으로 검색',
                    ),
                  ),
                  GroupFilterChips(
                    currentFilter: _currentFilter,
                    onFilterChanged: _onFilterChanged,
                  ),
                ],
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Main content with 3-column grid
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMyGroupsGrid(),
                _buildPublicGroupsGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletSidebar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('내 그룹'),
            selected: _tabController.index == 0,
            onTap: () => _tabController.animateTo(0),
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('그룹 찾기'),
            selected: _tabController.index == 1,
            onTap: () => _tabController.animateTo(1),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '그룹 메뉴',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('내 그룹'),
            selected: _tabController.index == 0,
            onTap: () => _tabController.animateTo(0),
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('그룹 찾기'),
            selected: _tabController.index == 1,
            onTap: () => _tabController.animateTo(1),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('그룹 생성'),
            onTap: () => _navigateToCreateGroup(),
          ),
        ],
      ),
    );
  }

  Widget _buildMyGroupsList() {
    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        if (state is GroupLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is GroupErrorState) {
          return _buildErrorWidget(state);
        }

        if (state is UserGroupsLoaded) {
          if (state.groups.isEmpty) {
            return _buildEmptyMyGroups();
          }

          return RefreshIndicator(
            onRefresh: () async {
              final userId = 'current_user_id'; // TODO: Get from auth service
              context.read<GroupBloc>().add(LoadUserGroups(
                userId: userId,
                forceRefresh: true,
              ));
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.groups.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GroupCard(
                    group: state.groups[index],
                    onTap: () => _navigateToGroupDetail(state.groups[index]),
                    showJoinButton: false,
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPublicGroupsList() {
    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        if (state is GroupLoading && state.operationType == 'loading_public_groups') {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is GroupErrorState) {
          return _buildErrorWidget(state);
        }

        if (state is PublicGroupsLoaded) {
          final filteredGroups = _filterGroups(state.groups);
          
          if (filteredGroups.isEmpty) {
            return _buildEmptyPublicGroups();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<GroupBloc>().add(LoadPublicGroups(
                searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
              ));
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: filteredGroups.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == filteredGroups.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GroupCard(
                    group: filteredGroups[index],
                    onTap: () => _navigateToGroupDetail(filteredGroups[index]),
                    showJoinButton: true,
                    onJoinPressed: () => _joinGroup(filteredGroups[index]),
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMyGroupsGrid() {
    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        if (state is UserGroupsLoaded) {
          if (state.groups.isEmpty) {
            return _buildEmptyMyGroups();
          }

          return RefreshIndicator(
            onRefresh: () async {
              final userId = 'current_user_id'; // TODO: Get from auth service
              context.read<GroupBloc>().add(LoadUserGroups(
                userId: userId,
                forceRefresh: true,
              ));
            },
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: state.groups.length,
              itemBuilder: (context, index) {
                return GroupCard(
                  group: state.groups[index],
                  onTap: () => _navigateToGroupDetail(state.groups[index]),
                  showJoinButton: false,
                  isGridView: true,
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPublicGroupsGrid() {
    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        if (state is PublicGroupsLoaded) {
          final filteredGroups = _filterGroups(state.groups);
          
          if (filteredGroups.isEmpty) {
            return _buildEmptyPublicGroups();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<GroupBloc>().add(LoadPublicGroups(
                searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
              ));
            },
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: filteredGroups.length,
              itemBuilder: (context, index) {
                return GroupCard(
                  group: filteredGroups[index],
                  onTap: () => _navigateToGroupDetail(filteredGroups[index]),
                  showJoinButton: true,
                  onJoinPressed: () => _joinGroup(filteredGroups[index]),
                  isGridView: true,
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  List<WorkoutGroup> _filterGroups(List<WorkoutGroup> groups) {
    switch (_currentFilter) {
      case GroupFilter.all:
        return groups;
      case GroupFilter.public:
        return groups.where((g) => g.privacyType == GroupPrivacyType.public).toList();
      case GroupFilter.private:
        return groups.where((g) => g.privacyType == GroupPrivacyType.private).toList();
      case GroupFilter.small:
        return groups.where((g) => g.currentMemberCount <= 10).toList();
      case GroupFilter.large:
        return groups.where((g) => g.currentMemberCount > 10).toList();
    }
  }

  Widget _buildEmptyMyGroups() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_off,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '아직 가입한 그룹이 없습니다',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '새로운 그룹을 만들거나 기존 그룹에 가입해보세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateGroup(),
            icon: const Icon(Icons.add),
            label: const Text('그룹 생성하기'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _tabController.animateTo(1),
            child: const Text('그룹 찾아보기'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPublicGroups() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? '공개 그룹이 없습니다' : '검색 결과가 없습니다',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty 
                ? '첫 번째 공개 그룹을 만들어보세요'
                : '다른 검색어로 시도해보세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateGroup(),
            icon: const Icon(Icons.add),
            label: const Text('그룹 생성하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(GroupErrorState state) {
    return Center(
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
            state.userMessage,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            state.recoveryMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (state.isRetryable && state.retryAction != null)
            ElevatedButton(
              onPressed: state.retryAction,
              child: Text(state.actionButtonText),
            ),
        ],
      ),
    );
  }

  void _navigateToCreateGroup() {
    Navigator.of(context).pushNamed('/group/create');
  }

  void _navigateToGroupDetail(WorkoutGroup group) {
    Navigator.of(context).pushNamed('/group/detail', arguments: group.id);
  }

  void _joinGroup(WorkoutGroup group) {
    // TODO: Implement join group logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${group.name} 그룹 가입 기능 구현 예정')),
    );
  }
}

enum GroupFilter {
  all,
  public,
  private,
  small,
  large,
}