import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service for managing pagination state and infinite scroll functionality
class PaginationService<T> {
  final String _cacheKey;
  final Future<List<T>> Function(int offset, int limit) _dataLoader;
  final int _pageSize;
  
  List<T> _items = [];
  int _currentOffset = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastLoadTime;
  
  // Cache settings
  static const Duration _cacheExpiration = Duration(minutes: 5);
  
  // Performance tracking
  int _totalRequests = 0;
  int _cacheHits = 0;
  
  PaginationService({
    required String cacheKey,
    required Future<List<T>> Function(int offset, int limit) dataLoader,
    int pageSize = 20,
  }) : _cacheKey = cacheKey,
       _dataLoader = dataLoader,
       _pageSize = pageSize;

  /// Get current items
  List<T> get items => List.unmodifiable(_items);
  
  /// Check if more data is available
  bool get hasMore => _hasMore;
  
  /// Check if currently loading
  bool get isLoading => _isLoading;
  
  /// Get current error message
  String? get error => _error;
  
  /// Get total number of items loaded
  int get totalItems => _items.length;
  
  /// Get cache hit ratio for performance monitoring
  double get cacheHitRatio => _totalRequests > 0 ? _cacheHits / _totalRequests : 0.0;
  
  /// Check if cache is valid
  bool get isCacheValid {
    if (_lastLoadTime == null) return false;
    return DateTime.now().difference(_lastLoadTime!) < _cacheExpiration;
  }

  /// Load initial data
  Future<void> loadInitial({bool forceRefresh = false}) async {
    if (_isLoading) return;
    
    // Use cache if valid and not forcing refresh
    if (!forceRefresh && isCacheValid && _items.isNotEmpty) {
      _cacheHits++;
      _totalRequests++;
      return;
    }
    
    _isLoading = true;
    _error = null;
    _totalRequests++;
    
    try {
      final newItems = await _dataLoader(0, _pageSize);
      
      _items = newItems;
      _currentOffset = newItems.length;
      _hasMore = newItems.length == _pageSize;
      _lastLoadTime = DateTime.now();
      
      debugPrint('PaginationService[$_cacheKey]: Loaded ${newItems.length} initial items');
    } catch (e) {
      _error = e.toString();
      debugPrint('PaginationService[$_cacheKey]: Error loading initial data: $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  /// Load more data (for infinite scroll)
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    
    _isLoading = true;
    _error = null;
    _totalRequests++;
    
    try {
      final newItems = await _dataLoader(_currentOffset, _pageSize);
      
      _items.addAll(newItems);
      _currentOffset += newItems.length;
      _hasMore = newItems.length == _pageSize;
      _lastLoadTime = DateTime.now();
      
      debugPrint('PaginationService[$_cacheKey]: Loaded ${newItems.length} more items (total: ${_items.length})');
    } catch (e) {
      _error = e.toString();
      debugPrint('PaginationService[$_cacheKey]: Error loading more data: $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  /// Refresh data (pull to refresh)
  Future<void> refresh() async {
    _currentOffset = 0;
    _hasMore = true;
    await loadInitial(forceRefresh: true);
  }

  /// Add new item to the beginning (for real-time updates)
  void prependItem(T item) {
    _items.insert(0, item);
    _currentOffset++;
  }

  /// Add new items to the beginning (for real-time updates)
  void prependItems(List<T> items) {
    _items.insertAll(0, items);
    _currentOffset += items.length;
  }

  /// Update an existing item
  void updateItem(T item, bool Function(T) matcher) {
    final index = _items.indexWhere(matcher);
    if (index != -1) {
      _items[index] = item;
    }
  }

  /// Remove an item
  void removeItem(bool Function(T) matcher) {
    final index = _items.indexWhere(matcher);
    if (index != -1) {
      _items.removeAt(index);
      _currentOffset--;
    }
  }

  /// Clear all data
  void clear() {
    _items.clear();
    _currentOffset = 0;
    _hasMore = true;
    _error = null;
    _lastLoadTime = null;
  }

  /// Get performance stats
  Map<String, dynamic> getStats() {
    return {
      'cache_key': _cacheKey,
      'total_items': _items.length,
      'current_offset': _currentOffset,
      'has_more': _hasMore,
      'is_loading': _isLoading,
      'total_requests': _totalRequests,
      'cache_hits': _cacheHits,
      'cache_hit_ratio': cacheHitRatio,
      'last_load_time': _lastLoadTime?.toIso8601String(),
      'cache_valid': isCacheValid,
    };
  }
}

/// Manager for multiple pagination services
class PaginationManager {
  static final Map<String, PaginationService> _services = {};
  
  /// Get or create a pagination service
  static PaginationService<T> getService<T>({
    required String key,
    required Future<List<T>> Function(int offset, int limit) dataLoader,
    int pageSize = 20,
  }) {
    if (!_services.containsKey(key)) {
      _services[key] = PaginationService<T>(
        cacheKey: key,
        dataLoader: dataLoader,
        pageSize: pageSize,
      );
    }
    return _services[key] as PaginationService<T>;
  }
  
  /// Remove a pagination service
  static void removeService(String key) {
    _services.remove(key);
  }
  
  /// Clear all services
  static void clearAll() {
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