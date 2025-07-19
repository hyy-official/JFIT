import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/widgets/responsive_layout.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/community/community_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/community/community_event.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/community/community_state.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/community_post_card.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/community_search_bar.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/community_category_filter.dart';
import 'package:jfit/features/group_workout_community/domain/entities/community_post.dart';
import 'package:jfit/features/group_workout_community/domain/entities/post_category.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/community_repository.dart';

enum PostSortType {
  latest,
  popular,
  mostCommented,
}

/// 커뮤니티 게시판 화면 - 카테고리별 필터링, 검색, 적응형 그리드 레이아웃
class CommunityBoardPage extends StatefulWidget {
  final String? groupId; // null이면 전체 커뮤니티

  const CommunityBoardPage({
    super.key,
    this.groupId,
  });

  @override
  State<CommunityBoardPage> createState() => _CommunityBoardPageState();
}

class _CommunityBoardPageState extends State<CommunityBoardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  
  List<CommunityPost> _posts = [];
  List<PostCategory> _categories = [];
  String? _selectedCategoryId;
  String _searchQuery = '';
  PostSortType _sortType = PostSortType.latest;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    context.read<CommunityBloc>().add(LoadCategories());
    context.read<CommunityBloc>().add(LoadPosts(
      request: PostSearchRequest(),
      forceRefresh: true,
    ));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMorePosts();
    }
  }

  void _loadMorePosts() {
    if (!_isLoadingMore && _hasMore) {
      setState(() {
        _isLoadingMore = true;
      });
      
      context.read<CommunityBloc>().add(LoadMorePosts(
        PostSearchRequest(
          categoryId: _selectedCategoryId,
          query: _searchQuery.isEmpty ? null : _searchQuery,
          orderBy: _getSortOrderBy(_sortType),
          offset: _posts.length,
        ),
      ));
    }
  }

  void _onCategoryChanged(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _posts.clear();
      _hasMore = true;
    });
    
    context.read<CommunityBloc>().add(LoadPosts(
      request: PostSearchRequest(
        categoryId: categoryId,
        query: _searchQuery.isEmpty ? null : _searchQuery,
        orderBy: _getSortOrderBy(_sortType),
      ),
      forceRefresh: true,
    ));
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _posts.clear();
      _hasMore = true;
    });
    
    context.read<CommunityBloc>().add(LoadPosts(
      request: PostSearchRequest(
        categoryId: _selectedCategoryId,
        query: query.isEmpty ? null : query,
        orderBy: _getSortOrderBy(_sortType),
      ),
      forceRefresh: true,
    ));
  }

  void _onSortChanged(PostSortType sortType) {
    setState(() {
      _sortType = sortType;
      _posts.clear();
      _hasMore = true;
    });
    
    context.read<CommunityBloc>().add(LoadPosts(
      request: PostSearchRequest(
        categoryId: _selectedCategoryId,
        query: _searchQuery.isEmpty ? null : _searchQuery,
        orderBy: _getSortOrderBy(sortType),
      ),
      forceRefresh: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupId != null ? '그룹 커뮤니티' : '전체 커뮤니티'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: BlocConsumer<CommunityBloc, CommunityState>(
        listener: (context, state) {
          if (state is CategoriesLoaded) {
            setState(() {
              _categories = state.categories;
            });
          } else if (state is PostsLoaded) {
            setState(() {
              _posts = state.posts;
              _hasMore = state.hasMore;
              _isLoadingMore = false;
            });
          } else if (state is CommunityErrorState) {
            setState(() {
              _isLoadingMore = false;
            });
            _showErrorSnackBar(state.userMessage);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CommunitySearchBar(
                  onSearchChanged: _onSearchChanged,
                  // initialQuery: _searchQuery, // Remove this parameter
                ),
              ),
              
              // Category filter
              if (_categories.isNotEmpty)
                CommunityCategoryFilter(
                  categories: _categories,
                  selectedCategoryId: _selectedCategoryId,
                  onCategoryChanged: _onCategoryChanged,
                ),
              
              // Posts list
              Expanded(
                child: _buildPostsList(state),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePost,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostsList(CommunityState state) {
    if (state is CommunityLoading && _posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is CommunityErrorState && _posts.isEmpty) {
      return _buildErrorWidget(state.userMessage);
    }

    if (_posts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<CommunityBloc>().add(LoadPosts(
          request: PostSearchRequest(
            categoryId: _selectedCategoryId,
            query: _searchQuery.isEmpty ? null : _searchQuery,
            orderBy: _getSortOrderBy(_sortType),
          ),
          forceRefresh: true,
        ));
      },
      child: ResponsiveLayout(
        mobile: _buildMobileList(),
        tablet: _buildTabletGrid(),
        desktop: _buildDesktopGrid(),
      ),
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _posts.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _posts.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        return CommunityPostCard(
          post: _posts[index],
          onTap: () => _navigateToPostDetail(_posts[index]),
        );
      },
    );
  }

  Widget _buildTabletGrid() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: _posts.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _posts.length) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return CommunityPostCard(
          post: _posts[index],
          onTap: () => _navigateToPostDetail(_posts[index]),
        );
      },
    );
  }

  Widget _buildDesktopGrid() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(24.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        crossAxisSpacing: 24.0,
        mainAxisSpacing: 24.0,
      ),
      itemCount: _posts.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _posts.length) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return CommunityPostCard(
          post: _posts[index],
          onTap: () => _navigateToPostDetail(_posts[index]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '게시글이 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '첫 번째 게시글을 작성해보세요!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
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
            '오류가 발생했습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInitialData,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(_getSortIcon(PostSortType.latest)),
            title: Text(_getSortText(PostSortType.latest)),
            trailing: _sortType == PostSortType.latest
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              Navigator.pop(context);
              _onSortChanged(PostSortType.latest);
            },
          ),
          ListTile(
            leading: Icon(_getSortIcon(PostSortType.popular)),
            title: Text(_getSortText(PostSortType.popular)),
            trailing: _sortType == PostSortType.popular
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              Navigator.pop(context);
              _onSortChanged(PostSortType.popular);
            },
          ),
          ListTile(
            leading: Icon(_getSortIcon(PostSortType.mostCommented)),
            title: Text(_getSortText(PostSortType.mostCommented)),
            trailing: _sortType == PostSortType.mostCommented
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              Navigator.pop(context);
              _onSortChanged(PostSortType.mostCommented);
            },
          ),
        ],
      ),
    );
  }

  IconData _getSortIcon(PostSortType sortType) {
    switch (sortType) {
      case PostSortType.latest:
        return Icons.access_time;
      case PostSortType.popular:
        return Icons.trending_up;
      case PostSortType.mostCommented:
        return Icons.comment;
    }
  }

  String _getSortText(PostSortType sortType) {
    switch (sortType) {
      case PostSortType.latest:
        return '최신순';
      case PostSortType.popular:
        return '인기순';
      case PostSortType.mostCommented:
        return '댓글순';
    }
  }

  void _navigateToCreatePost() {
    Navigator.of(context).pushNamed('/community/create');
  }

  void _navigateToPostDetail(CommunityPost post) {
    Navigator.of(context).pushNamed('/community/post/${post.id}');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  String _getSortOrderBy(PostSortType sortType) {
    switch (sortType) {
      case PostSortType.latest:
        return 'recent';
      case PostSortType.popular:
        return 'popular';
      case PostSortType.mostCommented:
        return 'comments';
    }
  }
}