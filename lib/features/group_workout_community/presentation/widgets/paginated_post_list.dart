import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/community/community_bloc.dart';
import '../bloc/community/community_event.dart';
import '../bloc/community/community_state.dart';
import '../../domain/entities/community_post.dart';
import '../../domain/entities/post_category.dart';
import 'infinite_scroll_list.dart';
import 'community_post_card.dart';

/// Widget for displaying paginated community posts with infinite scroll
class PaginatedPostList extends StatefulWidget {
  final String? categoryId;
  final String? groupId;
  final String? searchQuery;
  final List<String>? tags;
  final PostType? postType;
  final String orderBy;
  final EdgeInsetsGeometry? padding;
  final bool enablePullToRefresh;
  final Function(CommunityPost)? onPostTap;
  final Widget? header;
  final Widget? emptyWidget;
  final bool showFilters;

  const PaginatedPostList({
    Key? key,
    this.categoryId,
    this.groupId,
    this.searchQuery,
    this.tags,
    this.postType,
    this.orderBy = 'recent',
    this.padding,
    this.enablePullToRefresh = true,
    this.onPostTap,
    this.header,
    this.emptyWidget,
    this.showFilters = false,
  }) : super(key: key);

  @override
  State<PaginatedPostList> createState() => _PaginatedPostListState();
}

class _PaginatedPostListState extends State<PaginatedPostList> {
  @override
  void initState() {
    super.initState();
    _loadInitialPosts();
  }

  @override
  void didUpdateWidget(PaginatedPostList oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reload if filters changed
    if (oldWidget.categoryId != widget.categoryId ||
        oldWidget.groupId != widget.groupId ||
        oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.postType != widget.postType ||
        oldWidget.orderBy != widget.orderBy) {
      _loadInitialPosts();
    }
  }

  void _loadInitialPosts() {
    final request = PostSearchRequest(
      categoryId: widget.categoryId,
      groupId: widget.groupId,
      query: widget.searchQuery,
      tags: widget.tags,
      postType: widget.postType,
      orderBy: widget.orderBy,
      limit: 20,
      offset: 0,
    );

    context.read<CommunityBloc>().add(LoadPosts(request: request));
  }

  void _loadMorePosts() {
    final request = PostSearchRequest(
      categoryId: widget.categoryId,
      groupId: widget.groupId,
      query: widget.searchQuery,
      tags: widget.tags,
      postType: widget.postType,
      orderBy: widget.orderBy,
      limit: 20,
      offset: 0, // Offset will be managed by the bloc
    );

    context.read<CommunityBloc>().add(LoadMorePosts(request: request));
  }

  void _refreshPosts() {
    final request = PostSearchRequest(
      categoryId: widget.categoryId,
      groupId: widget.groupId,
      query: widget.searchQuery,
      tags: widget.tags,
      postType: widget.postType,
      orderBy: widget.orderBy,
      limit: 20,
      offset: 0,
    );

    context.read<CommunityBloc>().add(LoadPosts(
      request: request,
      forceRefresh: true,
    ));
  }

  Widget _buildPostItem(BuildContext context, CommunityPost post, int index) {
    return CommunityPostCard(
      post: post,
      onTap: widget.onPostTap != null 
          ? () => widget.onPostTap!(post)
          : null,
    );
  }

  Widget _buildEmptyState() {
    if (widget.emptyWidget != null) {
      return widget.emptyWidget!;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyStateTitle(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStateSubtitle(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshPosts,
              icon: const Icon(Icons.refresh),
              label: const Text('새로고침'),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmptyStateTitle() {
    if (widget.searchQuery?.isNotEmpty == true) {
      return '검색 결과가 없습니다';
    }
    if (widget.categoryId != null) {
      return '이 카테고리에 게시글이 없습니다';
    }
    if (widget.groupId != null) {
      return '그룹에 게시글이 없습니다';
    }
    return '게시글이 없습니다';
  }

  String _getEmptyStateSubtitle() {
    if (widget.searchQuery?.isNotEmpty == true) {
      return '다른 검색어로 시도해보세요';
    }
    return '첫 번째 게시글을 작성해보세요!';
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              '게시글을 불러올 수 없습니다',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshPosts,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('게시글을 불러오는 중...'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityBloc, CommunityState>(
      builder: (context, state) {
        if (state is PostsLoaded) {
          Widget content = InfiniteScrollList<CommunityPost>(
            items: state.posts,
            hasMore: state.hasMore,
            isLoading: false,
            itemBuilder: _buildPostItem,
            onLoadMore: _loadMorePosts,
            onRefresh: _refreshPosts,
            padding: widget.padding,
            enablePullToRefresh: widget.enablePullToRefresh,
            emptyWidget: _buildEmptyState(),
            separator: const SizedBox(height: 12),
          );

          if (widget.header != null) {
            content = Column(
              children: [
                widget.header!,
                Expanded(child: content),
              ],
            );
          }

          return content;
        }

        if (state is CommunityLoading) {
          return _buildLoadingState();
        }

        if (state is CommunityErrorState) {
          return _buildErrorState(state.message);
        }

        // Initial state - load posts
        if (state is CommunityInitial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadInitialPosts();
          });
          return _buildLoadingState();
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Grid version of paginated post list
class PaginatedPostGrid extends StatefulWidget {
  final String? categoryId;
  final String? groupId;
  final String? searchQuery;
  final PostType? postType;
  final String orderBy;
  final int crossAxisCount;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final Function(CommunityPost)? onPostTap;

  const PaginatedPostGrid({
    Key? key,
    this.categoryId,
    this.groupId,
    this.searchQuery,
    this.postType,
    this.orderBy = 'recent',
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.8,
    this.padding,
    this.onPostTap,
  }) : super(key: key);

  @override
  State<PaginatedPostGrid> createState() => _PaginatedPostGridState();
}

class _PaginatedPostGridState extends State<PaginatedPostGrid> {
  void _loadInitialPosts() {
    final request = PostSearchRequest(
      categoryId: widget.categoryId,
      groupId: widget.groupId,
      query: widget.searchQuery,
      postType: widget.postType,
      orderBy: widget.orderBy,
      limit: 20,
      offset: 0,
    );

    context.read<CommunityBloc>().add(LoadPosts(request: request));
  }

  void _loadMorePosts() {
    final request = PostSearchRequest(
      categoryId: widget.categoryId,
      groupId: widget.groupId,
      query: widget.searchQuery,
      postType: widget.postType,
      orderBy: widget.orderBy,
      limit: 20,
      offset: 0,
    );

    context.read<CommunityBloc>().add(LoadMorePosts(request: request));
  }

  void _refreshPosts() {
    final request = PostSearchRequest(
      categoryId: widget.categoryId,
      groupId: widget.groupId,
      query: widget.searchQuery,
      postType: widget.postType,
      orderBy: widget.orderBy,
      limit: 20,
      offset: 0,
    );

    context.read<CommunityBloc>().add(LoadPosts(
      request: request,
      forceRefresh: true,
    ));
  }

  Widget _buildPostItem(BuildContext context, CommunityPost post, int index) {
    return CommunityPostCard(
      post: post,
      isCompact: true,
      onTap: widget.onPostTap != null 
          ? () => widget.onPostTap!(post)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityBloc, CommunityState>(
      builder: (context, state) {
        if (state is PostsLoaded) {
          return InfiniteScrollGrid<CommunityPost>(
            items: state.posts,
            hasMore: state.hasMore,
            isLoading: false,
            itemBuilder: _buildPostItem,
            onLoadMore: _loadMorePosts,
            onRefresh: _refreshPosts,
            crossAxisCount: widget.crossAxisCount,
            childAspectRatio: widget.childAspectRatio,
            padding: widget.padding,
          );
        }

        if (state is CommunityLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CommunityErrorState) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshPosts,
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          );
        }

        // Initial state
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadInitialPosts();
        });
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

/// Compact post list for smaller spaces
class CompactPostList extends StatelessWidget {
  final String? categoryId;
  final String? groupId;
  final int maxItems;
  final Function(CommunityPost)? onPostTap;
  final VoidCallback? onViewAll;

  const CompactPostList({
    Key? key,
    this.categoryId,
    this.groupId,
    this.maxItems = 5,
    this.onPostTap,
    this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityBloc, CommunityState>(
      builder: (context, state) {
        if (state is PostsLoaded) {
          final limitedPosts = state.posts.take(maxItems).toList();
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '최근 게시글',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (onViewAll != null)
                    TextButton(
                      onPressed: onViewAll,
                      child: const Text('전체 보기'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (limitedPosts.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      '게시글이 없습니다',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...limitedPosts.map((post) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: CommunityPostCard(
                    post: post,
                    isCompact: true,
                    onTap: onPostTap != null 
                        ? () => onPostTap!(post)
                        : null,
                  ),
                )),
            ],
          );
        }

        if (state is CommunityLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}