import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Network request optimization utility
/// Prevents duplicate requests, implements caching, and provides request deduplication
class NetworkRequestOptimizer {
  static final NetworkRequestOptimizer _instance = NetworkRequestOptimizer._internal();
  factory NetworkRequestOptimizer() => _instance;
  NetworkRequestOptimizer._internal();

  // Request deduplication
  final Map<String, Completer<dynamic>> _pendingRequests = {};
  
  // Response caching
  final Map<String, CachedResponse> _responseCache = {};
  static const Duration _defaultCacheExpiration = Duration(minutes: 5);
  
  // Performance metrics
  int _totalRequests = 0;
  int _deduplicatedRequests = 0;
  int _cacheHits = 0;
  int _cacheMisses = 0;

  /// Execute a request with deduplication and caching
  Future<T> executeRequest<T>({
    required String requestKey,
    required Future<T> Function() requestFunction,
    Duration? cacheExpiration,
    bool enableCache = true,
    bool enableDeduplication = true,
  }) async {
    _totalRequests++;
    
    // Check cache first if enabled
    if (enableCache) {
      final cachedResponse = _getCachedResponse<T>(requestKey, cacheExpiration);
      if (cachedResponse != null) {
        _cacheHits++;
        return cachedResponse;
      }
      _cacheMisses++;
    }
    
    // Check for pending request if deduplication is enabled
    if (enableDeduplication && _pendingRequests.containsKey(requestKey)) {
      _deduplicatedRequests++;
      if (kDebugMode) {
        print('🔄 Deduplicating request: $requestKey');
      }
      return await _pendingRequests[requestKey]!.future as T;
    }
    
    // Create new request
    final completer = Completer<T>();
    if (enableDeduplication) {
      _pendingRequests[requestKey] = completer as Completer<dynamic>;
    }
    
    try {
      final result = await requestFunction();
      
      // Cache the response if enabled
      if (enableCache) {
        _cacheResponse(requestKey, result, cacheExpiration);
      }
      
      completer.complete(result);
      return result;
    } catch (error) {
      completer.completeError(error);
      rethrow;
    } finally {
      // Clean up pending request
      if (enableDeduplication) {
        _pendingRequests.remove(requestKey);
      }
    }
  }

  /// Get cached response if valid
  T? _getCachedResponse<T>(String requestKey, Duration? cacheExpiration) {
    final cached = _responseCache[requestKey];
    if (cached == null) return null;
    
    final expiration = cacheExpiration ?? _defaultCacheExpiration;
    final isExpired = DateTime.now().difference(cached.timestamp) > expiration;
    
    if (isExpired) {
      _responseCache.remove(requestKey);
      return null;
    }
    
    return cached.response as T?;
  }

  /// Cache a response
  void _cacheResponse<T>(String requestKey, T response, Duration? cacheExpiration) {
    _responseCache[requestKey] = CachedResponse(
      response: response,
      timestamp: DateTime.now(),
      expiration: cacheExpiration ?? _defaultCacheExpiration,
    );
    
    // Clean up expired cache entries periodically
    _cleanupExpiredCache();
  }

  /// Clean up expired cache entries
  void _cleanupExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    for (final entry in _responseCache.entries) {
      final cached = entry.value;
      if (now.difference(cached.timestamp) > cached.expiration) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _responseCache.remove(key);
    }
  }

  /// Generate request key for common patterns
  static String generateRequestKey({
    required String endpoint,
    Map<String, dynamic>? parameters,
    String? userId,
  }) {
    final buffer = StringBuffer(endpoint);
    
    if (userId != null) {
      buffer.write('_user:$userId');
    }
    
    if (parameters != null && parameters.isNotEmpty) {
      final sortedParams = Map.fromEntries(
        parameters.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
      );
      buffer.write('_params:${jsonEncode(sortedParams)}');
    }
    
    return buffer.toString();
  }

  /// Clear all cached responses
  void clearCache() {
    _responseCache.clear();
  }

  /// Clear cache for specific key pattern
  void clearCachePattern(String pattern) {
    final keysToRemove = _responseCache.keys
        .where((key) => key.contains(pattern))
        .toList();
    
    for (final key in keysToRemove) {
      _responseCache.remove(key);
    }
  }

  /// Get performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    final totalCacheRequests = _cacheHits + _cacheMisses;
    final cacheHitRate = totalCacheRequests > 0 
        ? (_cacheHits / totalCacheRequests) * 100 
        : 0.0;
    
    final deduplicationRate = _totalRequests > 0 
        ? (_deduplicatedRequests / _totalRequests) * 100 
        : 0.0;
    
    return {
      'total_requests': _totalRequests,
      'deduplicated_requests': _deduplicatedRequests,
      'deduplication_rate_percentage': deduplicationRate.toStringAsFixed(2),
      'cache_hits': _cacheHits,
      'cache_misses': _cacheMisses,
      'cache_hit_rate_percentage': cacheHitRate.toStringAsFixed(2),
      'cached_responses': _responseCache.length,
      'pending_requests': _pendingRequests.length,
      'estimated_cache_size_kb': _estimateCacheSize(),
    };
  }

  /// Estimate cache size in KB
  double _estimateCacheSize() {
    // Rough estimation: each cached response ~2KB on average
    return _responseCache.length * 2.0;
  }

  /// Reset performance metrics
  void resetMetrics() {
    _totalRequests = 0;
    _deduplicatedRequests = 0;
    _cacheHits = 0;
    _cacheMisses = 0;
  }

  /// Print performance report (debug mode only)
  void printPerformanceReport() {
    if (!kDebugMode) return;
    
    final metrics = getPerformanceMetrics();
    print('📡 Network Request Optimizer Report');
    print('=' * 40);
    print('Total Requests: ${metrics['total_requests']}');
    print('Deduplicated: ${metrics['deduplicated_requests']} (${metrics['deduplication_rate_percentage']}%)');
    print('Cache Hits: ${metrics['cache_hits']} (${metrics['cache_hit_rate_percentage']}%)');
    print('Cache Misses: ${metrics['cache_misses']}');
    print('Cached Responses: ${metrics['cached_responses']}');
    print('Pending Requests: ${metrics['pending_requests']}');
    print('Cache Size: ${metrics['estimated_cache_size_kb']} KB');
  }
}

/// Cached response container
class CachedResponse {
  final dynamic response;
  final DateTime timestamp;
  final Duration expiration;

  CachedResponse({
    required this.response,
    required this.timestamp,
    required this.expiration,
  });
}

/// Extension for easy request key generation
extension RequestKeyGenerator on String {
  /// Generate a request key with user context
  String withUser(String userId) {
    return NetworkRequestOptimizer.generateRequestKey(
      endpoint: this,
      userId: userId,
    );
  }
  
  /// Generate a request key with parameters
  String withParams(Map<String, dynamic> parameters) {
    return NetworkRequestOptimizer.generateRequestKey(
      endpoint: this,
      parameters: parameters,
    );
  }
  
  /// Generate a request key with user and parameters
  String withUserAndParams(String userId, Map<String, dynamic> parameters) {
    return NetworkRequestOptimizer.generateRequestKey(
      endpoint: this,
      userId: userId,
      parameters: parameters,
    );
  }
}