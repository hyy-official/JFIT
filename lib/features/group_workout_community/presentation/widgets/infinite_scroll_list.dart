import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Generic infinite scroll list widget with pull-to-refresh support
class InfiniteScrollList<T> extends StatefulWidget {
  final List<T> items;
  final bool hasMore;
  final bool isLoading;
  final String? error;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final VoidCallback onLoadMore;
  final VoidCallback onRefresh;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final EdgeInsetsGeometry? padding;
  final ScrollController? scrollController;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final double loadMoreThreshold;
  final bool enablePullToRefresh;
  final Widget? separator;
  final int? itemCount;

  const InfiniteScrollList({
    Key? key,
    required this.items,
    required this.hasMore,
    required this.isLoading,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.onRefresh,
    this.error,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.padding,
    this.scrollController,
    this.shrinkWrap = false,
    this.physics,
    this.loadMoreThreshold = 200.0,
    this.enablePullToRefresh = true,
    this.separator,
    this.itemCount,
  }) : super(key: key);

  @override
  State<InfiniteScrollList<T>> createState() => _InfiniteScrollListState<T>();
}

class _InfiniteScrollListState<T> extends State<InfiniteScrollList<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - widget.loadMoreThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (!widget.hasMore || widget.isLoading || _isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      widget.onLoadMore();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    try {
      widget.onRefresh();
    } catch (e) {
      // Handle refresh error
      debugPrint('Refresh error: $e');
    }
  }

  Widget _buildLoadingIndicator() {
    return widget.loadingWidget ?? 
      const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
  }

  Widget _buildErrorWidget() {
    return widget.errorWidget ?? 
      Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                widget.error ?? '오류가 발생했습니다',
                style: Theme.of(context).textTheme.bodyLarge,
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

  Widget _buildEmptyWidget() {
    return widget.emptyWidget ?? 
      Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inbox_outlined,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                '데이터가 없습니다',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildList() {
    if (widget.error != null && widget.items.isEmpty) {
      return _buildErrorWidget();
    }

    if (widget.items.isEmpty && !widget.isLoading) {
      return _buildEmptyWidget();
    }

    final itemCount = widget.itemCount ?? widget.items.length;
    final totalCount = itemCount + (widget.hasMore ? 1 : 0);

    return ListView.separated(
      controller: _scrollController,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      itemCount: totalCount,
      separatorBuilder: (context, index) {
        if (index >= itemCount - 1) {
          return const SizedBox.shrink();
        }
        return widget.separator ?? const SizedBox.shrink();
      },
      itemBuilder: (context, index) {
        if (index >= itemCount) {
          // Loading indicator at the bottom
          return _buildLoadingIndicator();
        }

        if (index >= widget.items.length) {
          // Placeholder for items not yet loaded
          return const SizedBox(
            height: 80,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return widget.itemBuilder(context, widget.items[index], index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && widget.isLoading) {
      return _buildLoadingIndicator();
    }

    Widget child = _buildList();

    if (widget.enablePullToRefresh) {
      child = RefreshIndicator(
        onRefresh: _onRefresh,
        child: child,
      );
    }

    return child;
  }
}

/// Sliver version of infinite scroll list
class SliverInfiniteScrollList<T> extends StatefulWidget {
  final List<T> items;
  final bool hasMore;
  final bool isLoading;
  final String? error;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final VoidCallback onLoadMore;
  final Widget? loadingWidget;
  final Widget? separator;
  final double loadMoreThreshold;

  const SliverInfiniteScrollList({
    Key? key,
    required this.items,
    required this.hasMore,
    required this.isLoading,
    required this.itemBuilder,
    required this.onLoadMore,
    this.error,
    this.loadingWidget,
    this.separator,
    this.loadMoreThreshold = 200.0,
  }) : super(key: key);

  @override
  State<SliverInfiniteScrollList<T>> createState() => _SliverInfiniteScrollListState<T>();
}

class _SliverInfiniteScrollListState<T> extends State<SliverInfiniteScrollList<T>> {
  bool _isLoadingMore = false;

  Future<void> _loadMore() async {
    if (!widget.hasMore || widget.isLoading || _isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      widget.onLoadMore();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.items.length + (widget.hasMore ? 1 : 0);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Trigger load more when approaching the end
          if (index >= widget.items.length - 3 && widget.hasMore && !_isLoadingMore) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadMore();
            });
          }

          if (index >= widget.items.length) {
            // Loading indicator at the bottom
            return widget.loadingWidget ?? 
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
          }

          return Column(
            children: [
              widget.itemBuilder(context, widget.items[index], index),
              if (index < widget.items.length - 1 && widget.separator != null)
                widget.separator!,
            ],
          );
        },
        childCount: itemCount,
      ),
    );
  }
}

/// Grid version of infinite scroll
class InfiniteScrollGrid<T> extends StatefulWidget {
  final List<T> items;
  final bool hasMore;
  final bool isLoading;
  final String? error;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final VoidCallback onLoadMore;
  final VoidCallback onRefresh;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final ScrollController? scrollController;
  final bool enablePullToRefresh;
  final double loadMoreThreshold;

  const InfiniteScrollGrid({
    Key? key,
    required this.items,
    required this.hasMore,
    required this.isLoading,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.onRefresh,
    this.error,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.padding,
    this.scrollController,
    this.enablePullToRefresh = true,
    this.loadMoreThreshold = 200.0,
  }) : super(key: key);

  @override
  State<InfiniteScrollGrid<T>> createState() => _InfiniteScrollGridState<T>();
}

class _InfiniteScrollGridState<T> extends State<InfiniteScrollGrid<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - widget.loadMoreThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (!widget.hasMore || widget.isLoading || _isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      widget.onLoadMore();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    try {
      widget.onRefresh();
    } catch (e) {
      debugPrint('Refresh error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.items.isEmpty && !widget.isLoading) {
      return const Center(
        child: Text('데이터가 없습니다'),
      );
    }

    Widget child = GridView.builder(
      controller: _scrollController,
      padding: widget.padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: widget.items.length + (widget.hasMore ? widget.crossAxisCount : 0),
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return widget.itemBuilder(context, widget.items[index], index);
      },
    );

    if (widget.enablePullToRefresh) {
      child = RefreshIndicator(
        onRefresh: _onRefresh,
        child: child,
      );
    }

    return child;
  }
}