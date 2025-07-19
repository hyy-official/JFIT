import 'package:flutter/material.dart';
import 'package:jfit/core/widgets/responsive_layout.dart';
import 'package:jfit/features/group_workout_community/domain/entities/community_post.dart';
import 'package:jfit/features/group_workout_community/domain/entities/post_search_criteria.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/community_post_card.dart';

/// 게시글 검색 결과를 표시하는 위젯
class PostSearchResults extends StatelessWidget {
  final List<CommunityPost> posts;
  final PostSearchCriteria searchCriteria;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  final Function(CommunityPost) onPostTap;
  final Function(CommunityPost)? onLikePost;
  final Function(CommunityPost)? onBookmarkPost;
  final ScrollController? scrollController;

  const PostSearchResults({
    super.key,
    required this.posts,
    required this.searchCriteria,
    this.isLoading = false,
    this.hasMore = false,
    this.onLoadMore,
    required this.onPostTap,
    this.onLikePost,
    this.onBookmarkPost,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && posts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('게시글을 검색하고 있습니다...'),
          ],
        ),
      );
    }

    if (posts.isEmpty) {
      return _buildEmptyResults(context);
    }

    return ResponsiveLayout(
      mobile: _buildMobileResults(context),
      tablet: _buildTabletResults(context),
      desktop: _buildDesktopResults(context),
    );
  }

  Widget _buildMobileResults(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Trigger search refresh
        onLoadMore?.call();
      },
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: posts.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == posts.length) {
            return _buildLoadMoreIndicator(context);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CommunityPostCard(
              post: posts[index],
              onTap: () => onPostTap(posts[index]),
              onLike: onLikePost != null 
                  ? () => onLikePost!(posts[index])
                  : null,
              onBookmark: onBookmarkPost != null 
                  ? () => onBookmarkPost!(posts[index])
                  : null,
              showFullContent: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabletResults(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onLoadMore?.call();
      },
      child: GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: posts.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == posts.length) {
            return _buildLoadMoreIndicator(context);
          }

          return CommunityPostCard(
            post: posts[index],
            onTap: () => onPostTap(posts[index]),
            onLike: onLikePost != null 
                ? () => onLikePost!(posts[index])
                : null,
            onBookmark: onBookmarkPost != null 
                ? () => onBookmarkPost!(posts[index])
                : null,
            showFullContent: false,
            isGridView: true,
          );
        },
      ),
    );
  }

  Widget _buildDesktopResults(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onLoadMore?.call();
      },
      child: GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: posts.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == posts.length) {
            return _buildLoadMoreIndicator(context);
          }

          return CommunityPostCard(
            post: posts[index],
            onTap: () => onPostTap(posts[index]),
            onLike: onLikePost != null 
                ? () => onLikePost!(posts[index])
                : null,
            onBookmark: onBookmarkPost != null 
                ? () => onBookmarkPost!(posts[index])
                : null,
            showFullContent: false,
            isGridView: true,
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: onLoadMore,
          child: const Text('더 보기'),
        ),
      ),
    );
  }

  Widget _buildEmptyResults(BuildContext context) {
    final theme = Theme.of(context);
    final hasSearchQuery = searchCriteria.searchQuery?.isNotEmpty ?? false;
    final hasFilters = searchCriteria.hasFilters;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearchQuery || hasFilters ? Icons.search_off : Icons.article_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyResultsTitle(hasSearchQuery, hasFilters),
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyResultsSubtitle(hasSearchQuery, hasFilters),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (hasSearchQuery || hasFilters) ...[
              ElevatedButton.icon(
                onPressed: () {
                  // Clear search and filters
                  onLoadMore?.call();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('검색 초기화'),
              ),
              const SizedBox(height: 8),
            ],
            TextButton.icon(
              onPressed: () {
                // Navigate to create post
                Navigator.of(context).pushNamed('/community/create');
              },
              icon: const Icon(Icons.add),
              label: const Text('새 게시글 작성'),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmptyResultsTitle(bool hasSearchQuery, bool hasFilters) {
    if (hasSearchQuery && hasFilters) {
      return '검색 조건에 맞는 게시글이 없습니다';
    } else if (hasSearchQuery) {
      return '검색 결과가 없습니다';
    } else if (hasFilters) {
      return '필터 조건에 맞는 게시글이 없습니다';
    } else {
      return '아직 게시글이 없습니다';
    }
  }

  String _getEmptyResultsSubtitle(bool hasSearchQuery, bool hasFilters) {
    if (hasSearchQuery && hasFilters) {
      return '다른 검색어나 필터 조건을 시도해보세요';
    } else if (hasSearchQuery) {
      return '다른 검색어로 시도해보거나 새 게시글을 작성해보세요';
    } else if (hasFilters) {
      return '필터 조건을 조정하거나 새 게시글을 작성해보세요';
    } else {
      return '첫 번째 게시글을 작성해보세요';
    }
  }
}

/// 검색 결과 통계를 표시하는 위젯
class PostSearchResultsStats extends StatelessWidget {
  final int totalResults;
  final PostSearchCriteria searchCriteria;
  final Duration? searchDuration;

  const PostSearchResultsStats({
    super.key,
    required this.totalResults,
    required this.searchCriteria,
    this.searchDuration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (totalResults == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _buildStatsText(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildStatsText() {
    final buffer = StringBuffer();
    
    buffer.write('총 ${totalResults}개의 게시글');
    
    if (searchCriteria.searchQuery?.isNotEmpty ?? false) {
      buffer.write(' (검색: "${searchCriteria.searchQuery}")');
    }
    
    if (searchDuration != null) {
      final ms = searchDuration!.inMilliseconds;
      buffer.write(' • ${ms}ms');
    }
    
    return buffer.toString();
  }
}

/// 검색 제안 위젯
class PostSearchSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSuggestionTap;

  const PostSearchSuggestions({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '검색 제안',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...suggestions.map((suggestion) => ListTile(
            leading: Icon(
              Icons.search,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            title: Text(suggestion),
            onTap: () => onSuggestionTap(suggestion),
            dense: true,
          )),
        ],
      ),
    );
  }
}