import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service for managing lazy loading of data with caching and performance optimization
class LazyLoadingService<T> {
  final String _serviceKey;
  final Future<List<T>> Function(String parentId, int offset, int limit) _dataLoader;
  final int _pageSize;
  final Duration _cacheExpiration;
  
  // Cache for loaded data
  final Map<String, List<T>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, bool> _hasMoreData = {};
  final Map<String, bool> _isLoading = {};
  final Map<String, int> _currentOffsets = {};
  
  // Performance tracking
  int _totalRequests = 0;
  int _cacheHits = 0;
  int _cacheMisses = 0;
  
  LazyLoadingService({
    required String serviceKey,
    required Future<List<T>> Function(String parentId, int offset, int limit) dataLoader,
    int pageSize = 20,
    Duration cacheExpiration = const Duration(minutes: 10),
  }) : _serviceKey = serviceKey,
       _dataLoader = dataLoader,
       _pageSize = pageSize,
       _cacheExpiration = cacheExpiration;

  /// Load initial data for a parent entity
  Future<List<T>> loadInitial(String parentId, {bool forceRefresh = false}) async {
    _totalRequests++;
    
    // Check cache first
    if (!forceRefresh && _isCacheValid(parentId)) {
      _cacheHits++;
      return _cache[parentId] ?? [];
    }
    
    _cacheMisses++;
    
    if (_isLoading[parentId] == true) {
      // Wait for ongoing request
      await _waitForLoading(parentId);
      return _cache[parentId] ?? [];
    }
    
    _isLoading[parentId] = true;
    
    try {
      final data = await _dataLoader(parentId, 0, _pageSize);
      
      _cache[parentId] = data;
      _cacheTimestamps[parentId] = DateTime.now();
      _currentOffsets[parentId] = data.length;
      _hasMoreData[parentId] = data.length == _pageSize;
      
      debugPrint('LazyLoadingService[$_serviceKey]: Loaded ${data.length} items for $parentId');
      
      return data;
    } catch (e) {
      debugPrint('LazyLoadingService[$_serviceKey]: Error loading data for $parentId: $e');
      rethrow;
    } finally {
      _isLoading[parentId] = false;
    }
  }

  /// Load more data for pagination
  Future<List<T>> loadMore(String parentId) async {
    _totalRequests++;
    
    if (_isLoading[parentId] == true || _hasMoreData[parentId] != true) {
      return _cache[parentId] ?? [];
    }
    
    _isLoading[parentId] = true;
    
    try {
      final currentOffset = _currentOffsets[parentId] ?? 0;
      final newData = await _dataLoader(parentId, currentOffset, _pageSize);
      
      final existingData = _cache[parentId] ?? [];
      final allData = [...existingData, ...newData];
      
      _cache[parentId] = allData;
      _cacheTimestamps[parentId] = DateTime.now();
      _currentOffsets[parentId] = currentOffset + newData.length;
      _hasMoreData[parentId] = newData.length == _pageSize;
      
      debugPrint('LazyLoadingService[$_serviceKey]: Loaded ${newData.length} more items for $parentId (total: ${allData.length})');
      
      return allData;
    } catch (e) {
      debugPrint('LazyLoadingService[$_serviceKey]: Error loading more data for $parentId: $e');
      rethrow;
    } finally {
      _isLoading[parentId] = false;
    }
  }

  /// Get cached data without loading
  List<T>? getCached(String parentId) {
    if (_isCacheValid(parentId)) {
      _cacheHits++;
      _totalRequests++;
      return _cache[parentId];
    }
    return null;
  }

  /// Check if more data is available
  bool hasMore(String parentId) {
    return _hasMoreData[parentId] ?? true;
  }

  /// Check if currently loading
  bool isLoading(String parentId) {
    return _isLoading[parentId] ?? false;
  }

  /// Add new item to the beginning (for real-time updates)
  void prependItem(String parentId, T item) {
    final existingData = _cache[parentId] ?? [];
    _cache[parentId] = [item, ...existingData];
    _currentOffsets[parentId] = (_currentOffsets[parentId] ?? 0) + 1;
    _cacheTimestamps[parentId] = DateTime.now();
  }

  /// Update an existing item
  void updateItem(String parentId, T item, bool Function(T) matcher) {
    final existingData = _cache[parentId];
    if (existingData != null) {
      final index = existingData.indexWhere(matcher);
      if (index != -1) {
        existingData[index] = item;
        _cacheTimestamps[parentId] = DateTime.now();
      }
    }
  }

  /// Remove an item
  void removeItem(String parentId, bool Function(T) matcher) {
    final existingData = _cache[parentId];
    if (existingData != null) {
      final index = existingData.indexWhere(matcher);
      if (index != -1) {
        existingData.removeAt(index);
        _currentOffsets[parentId] = (_currentOffsets[parentId] ?? 0) - 1;
        _cacheTimestamps[parentId] = DateTime.now();
      }
    }
  }

  /// Clear cache for specific parent
  void clearCache(String parentId) {
    _cache.remove(parentId);
    _cacheTimestamps.remove(parentId);
    _hasMoreData.remove(parentId);
    _currentOffsets.remove(parentId);
    _isLoading.remove(parentId);
  }

  /// Clear all cache
  void clearAllCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    _hasMoreData.clear();
    _currentOffsets.clear();
    _isLoading.clear();
  }

  /// Preload data for multiple parents
  Future<void> preloadMultiple(List<String> parentIds) async {
    final futures = parentIds.map((parentId) async {
      try {
        if (!_isCacheValid(parentId)) {
          await loadInitial(parentId);
        }
      } catch (e) {
        debugPrint('LazyLoadingService[$_serviceKey]: Preload failed for $parentId: $e');
      }
    });
    
    await Future.wait(futures);
  }

  /// Get performance statistics
  Map<String, dynamic> getStats() {
    final cacheHitRatio = _totalRequests > 0 ? _cacheHits / _totalRequests : 0.0;
    
    return {
      'service_key': _serviceKey,
      'total_requests': _totalRequests,
      'cache_hits': _cacheHits,
      'cache_misses': _cacheMisses,
      'cache_hit_ratio': cacheHitRatio,
      'cached_parents': _cache.length,
      'total_cached_items': _cache.values.fold<int>(0, (sum, list) => sum + list.length),
      'loading_states': _isLoading.length,
    };
  }

  /// Check if cache is valid for a parent
  bool _isCacheValid(String parentId) {
    final timestamp = _cacheTimestamps[parentId];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _cacheExpiration;
  }

  /// Wait for ongoing loading to complete
  Future<void> _waitForLoading(String parentId) async {
    while (_isLoading[parentId] == true) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}

/// Manager for multiple lazy loading services
class LazyLoadingManager {
  static final Map<String, LazyLoadingService> _services = {};
  
  /// Get or create a lazy loading service
  static LazyLoadingService<T> getService<T>({
    required String key,
    required Future<List<T>> Function(String parentId, int offset, int limit) dataLoader,
    int pageSize = 20,
    Duration cacheExpiration = const Duration(minutes: 10),
  }) {
    if (!_services.containsKey(key)) {
      _services[key] = LazyLoadingService<T>(
        serviceKey: key,
        dataLoader: dataLoader,
        pageSize: pageSize,
        cacheExpiration: cacheExpiration,
      );
    }
    return _services[key] as LazyLoadingService<T>;
  }
  
  /// Remove a service
  static void removeService(String key) {
    _services.remove(key);
  }
  
  /// Clear all services
  static void clearAll() {
    for (final service in _services.values) {
      service.clearAllCache();
    }
    _services.clear();
  }
  
  /// Get stats for all services
  static Map<String, dynamic> getAllStats() {
    return {
      'total_services': _services.length,
      'services': _services.map((key, service) => MapEntry(key, service.getStats())),
    };
  }
}

/// Specialized lazy loading service for comments
class CommentLazyLoadingService extends LazyLoadingService<dynamic> {
  CommentLazyLoadingService({
    required Future<List<dynamic>> Function(String postId, int offset, int limit) commentLoader,
  }) : super(
    serviceKey: 'comments',
    dataLoader: commentLoader,
    pageSize: 20,
    cacheExpiration: const Duration(minutes: 5),
  );

  /// Load comments for a post with nested comment support
  Future<List<dynamic>> loadCommentsForPost(String postId, {bool forceRefresh = false}) async {
    return await loadInitial(postId, forceRefresh: forceRefresh);
  }

  /// Load more comments for a post
  Future<List<dynamic>> loadMoreCommentsForPost(String postId) async {
    return await loadMore(postId);
  }

  /// Add new comment (for real-time updates)
  void addNewComment(String postId, dynamic comment) {
    prependItem(postId, comment);
  }

  /// Update comment (for like/edit operations)
  void updateComment(String postId, dynamic comment, String commentId) {
    updateItem(postId, comment, (c) => c.id == commentId);
  }

  /// Remove comment
  void deleteComment(String postId, String commentId) {
    removeItem(postId, (c) => c.id == commentId);
  }
}

/// Specialized lazy loading service for activity feed
class ActivityFeedLazyLoadingService extends LazyLoadingService<dynamic> {
  ActivityFeedLazyLoadingService({
    required Future<List<dynamic>> Function(String groupId, int offset, int limit) activityLoader,
  }) : super(
    serviceKey: 'activity_feed',
    dataLoader: activityLoader,
    pageSize: 20,
    cacheExpiration: const Duration(minutes: 3),
  );

  /// Load activities for a group
  Future<List<dynamic>> loadActivitiesForGroup(String groupId, {bool forceRefresh = false}) async {
    return await loadInitial(groupId, forceRefresh: forceRefresh);
  }

  /// Load more activities for a group
  Future<List<dynamic>> loadMoreActivitiesForGroup(String groupId) async {
    return await loadMore(groupId);
  }

  /// Add new activity (for real-time updates)
  void addNewActivity(String groupId, dynamic activity) {
    prependItem(groupId, activity);
  }
}