import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

/// Service for monitoring performance of pagination and caching operations
class PerformanceMonitoringService {
  static final PerformanceMonitoringService _instance = PerformanceMonitoringService._internal();
  factory PerformanceMonitoringService() => _instance;
  PerformanceMonitoringService._internal();

  // Performance metrics storage
  final Map<String, List<PerformanceMetric>> _metrics = {};
  final Map<String, Timer> _activeTimers = {};
  
  // Configuration
  static const int _maxMetricsPerOperation = 100;
  static const Duration _metricRetentionPeriod = Duration(hours: 1);
  
  // Performance thresholds
  static const Duration _slowOperationThreshold = Duration(milliseconds: 1000);
  static const Duration _verySlowOperationThreshold = Duration(milliseconds: 3000);

  /// Start timing an operation
  void startOperation(String operationId, String operationType, {Map<String, dynamic>? metadata}) {
    if (_activeTimers.containsKey(operationId)) {
      debugPrint('Warning: Operation $operationId is already being timed');
      return;
    }

    _activeTimers[operationId] = Timer(const Duration(seconds: 30), () {
      // Auto-cleanup for operations that don't complete
      _activeTimers.remove(operationId);
      debugPrint('Warning: Operation $operationId timed out');
    });

    final metric = PerformanceMetric(
      operationId: operationId,
      operationType: operationType,
      startTime: DateTime.now(),
      metadata: metadata ?? {},
    );

    _addMetric(operationType, metric);
  }

  /// End timing an operation
  void endOperation(String operationId, {
    bool success = true,
    String? error,
    Map<String, dynamic>? additionalData,
  }) {
    final timer = _activeTimers.remove(operationId);
    timer?.cancel();

    final operationType = _findOperationTypeById(operationId);
    if (operationType == null) {
      debugPrint('Warning: Could not find operation type for $operationId');
      return;
    }

    final metrics = _metrics[operationType];
    if (metrics == null || metrics.isEmpty) {
      debugPrint('Warning: No metrics found for operation $operationId');
      return;
    }

    // Find the metric and update it
    final metricIndex = metrics.indexWhere((m) => m.operationId == operationId);
    if (metricIndex == -1) {
      debugPrint('Warning: Could not find metric for operation $operationId');
      return;
    }

    final metric = metrics[metricIndex];
    final updatedMetric = metric.copyWith(
      endTime: DateTime.now(),
      success: success,
      error: error,
      additionalData: additionalData,
    );

    metrics[metricIndex] = updatedMetric;

    // Log slow operations
    if (updatedMetric.duration != null) {
      if (updatedMetric.duration! > _verySlowOperationThreshold) {
        debugPrint('VERY SLOW OPERATION: $operationType took ${updatedMetric.duration!.inMilliseconds}ms');
      } else if (updatedMetric.duration! > _slowOperationThreshold) {
        debugPrint('SLOW OPERATION: $operationType took ${updatedMetric.duration!.inMilliseconds}ms');
      }
    }
  }

  /// Record a cache hit
  void recordCacheHit(String cacheType, String cacheKey, {int? itemCount}) {
    final metric = PerformanceMetric(
      operationId: 'cache_hit_${DateTime.now().millisecondsSinceEpoch}',
      operationType: 'cache_hit',
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      success: true,
      metadata: {
        'cache_type': cacheType,
        'cache_key': cacheKey,
        'item_count': itemCount,
      },
    );

    _addMetric('cache_hit', metric);
  }

  /// Record a cache miss
  void recordCacheMiss(String cacheType, String cacheKey) {
    final metric = PerformanceMetric(
      operationId: 'cache_miss_${DateTime.now().millisecondsSinceEpoch}',
      operationType: 'cache_miss',
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      success: true,
      metadata: {
        'cache_type': cacheType,
        'cache_key': cacheKey,
      },
    );

    _addMetric('cache_miss', metric);
  }

  /// Record pagination performance
  void recordPaginationLoad({
    required String listType,
    required int offset,
    required int limit,
    required int itemsLoaded,
    required Duration loadTime,
    required bool fromCache,
  }) {
    final metric = PerformanceMetric(
      operationId: 'pagination_${DateTime.now().millisecondsSinceEpoch}',
      operationType: 'pagination_load',
      startTime: DateTime.now().subtract(loadTime),
      endTime: DateTime.now(),
      success: true,
      metadata: {
        'list_type': listType,
        'offset': offset,
        'limit': limit,
        'items_loaded': itemsLoaded,
        'from_cache': fromCache,
        'load_efficiency': itemsLoaded / limit,
      },
    );

    _addMetric('pagination_load', metric);
  }

  /// Get performance statistics for an operation type
  PerformanceStats getStats(String operationType) {
    final metrics = _metrics[operationType] ?? [];
    
    if (metrics.isEmpty) {
      return PerformanceStats(
        operationType: operationType,
        totalOperations: 0,
        successfulOperations: 0,
        failedOperations: 0,
        averageDuration: Duration.zero,
        minDuration: Duration.zero,
        maxDuration: Duration.zero,
        cacheHitRatio: 0.0,
      );
    }

    final completedMetrics = metrics.where((m) => m.endTime != null).toList();
    final successfulMetrics = completedMetrics.where((m) => m.success).toList();
    final failedMetrics = completedMetrics.where((m) => !m.success).toList();

    final durations = completedMetrics
        .map((m) => m.duration!)
        .where((d) => d.inMilliseconds > 0)
        .toList();

    Duration averageDuration = Duration.zero;
    Duration minDuration = Duration.zero;
    Duration maxDuration = Duration.zero;

    if (durations.isNotEmpty) {
      final totalMs = durations.fold<int>(0, (sum, d) => sum + d.inMilliseconds);
      averageDuration = Duration(milliseconds: totalMs ~/ durations.length);
      minDuration = durations.reduce((a, b) => a < b ? a : b);
      maxDuration = durations.reduce((a, b) => a > b ? a : b);
    }

    // Calculate cache hit ratio for cache operations
    double cacheHitRatio = 0.0;
    if (operationType.contains('cache')) {
      final cacheHits = _metrics['cache_hit']?.length ?? 0;
      final cacheMisses = _metrics['cache_miss']?.length ?? 0;
      final totalCacheOps = cacheHits + cacheMisses;
      if (totalCacheOps > 0) {
        cacheHitRatio = cacheHits / totalCacheOps;
      }
    }

    return PerformanceStats(
      operationType: operationType,
      totalOperations: metrics.length,
      successfulOperations: successfulMetrics.length,
      failedOperations: failedMetrics.length,
      averageDuration: averageDuration,
      minDuration: minDuration,
      maxDuration: maxDuration,
      cacheHitRatio: cacheHitRatio,
      recentMetrics: metrics.take(10).toList(),
    );
  }

  /// Get overall performance summary
  Map<String, dynamic> getOverallStats() {
    final allStats = <String, PerformanceStats>{};
    for (final operationType in _metrics.keys) {
      allStats[operationType] = getStats(operationType);
    }

    final totalOperations = allStats.values.fold<int>(0, (sum, stats) => sum + stats.totalOperations);
    final totalSuccessful = allStats.values.fold<int>(0, (sum, stats) => sum + stats.successfulOperations);
    final totalFailed = allStats.values.fold<int>(0, (sum, stats) => sum + stats.failedOperations);

    final overallCacheHitRatio = _calculateOverallCacheHitRatio();

    return {
      'total_operations': totalOperations,
      'successful_operations': totalSuccessful,
      'failed_operations': totalFailed,
      'success_rate': totalOperations > 0 ? totalSuccessful / totalOperations : 0.0,
      'overall_cache_hit_ratio': overallCacheHitRatio,
      'operation_types': allStats.keys.toList(),
      'detailed_stats': allStats.map((key, stats) => MapEntry(key, stats.toMap())),
      'slow_operations': _getSlowOperations(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Get slow operations for optimization
  List<Map<String, dynamic>> getSlowOperations({int limit = 10}) {
    return _getSlowOperations(limit: limit);
  }

  /// Clear old metrics to prevent memory leaks
  void cleanupOldMetrics() {
    final cutoffTime = DateTime.now().subtract(_metricRetentionPeriod);
    
    for (final operationType in _metrics.keys.toList()) {
      final metrics = _metrics[operationType]!;
      metrics.removeWhere((metric) => metric.startTime.isBefore(cutoffTime));
      
      if (metrics.isEmpty) {
        _metrics.remove(operationType);
      }
    }
  }

  /// Clear all metrics
  void clearAllMetrics() {
    _metrics.clear();
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();
  }

  // Private helper methods

  void _addMetric(String operationType, PerformanceMetric metric) {
    _metrics.putIfAbsent(operationType, () => <PerformanceMetric>[]);
    final metrics = _metrics[operationType]!;
    
    metrics.add(metric);
    
    // Keep only recent metrics to prevent memory issues
    if (metrics.length > _maxMetricsPerOperation) {
      metrics.removeRange(0, metrics.length - _maxMetricsPerOperation);
    }
  }

  String? _findOperationTypeById(String operationId) {
    for (final entry in _metrics.entries) {
      if (entry.value.any((metric) => metric.operationId == operationId)) {
        return entry.key;
      }
    }
    return null;
  }

  double _calculateOverallCacheHitRatio() {
    final cacheHits = _metrics['cache_hit']?.length ?? 0;
    final cacheMisses = _metrics['cache_miss']?.length ?? 0;
    final totalCacheOps = cacheHits + cacheMisses;
    return totalCacheOps > 0 ? cacheHits / totalCacheOps : 0.0;
  }

  List<Map<String, dynamic>> _getSlowOperations({int limit = 10}) {
    final slowOps = <Map<String, dynamic>>[];
    
    for (final entry in _metrics.entries) {
      for (final metric in entry.value) {
        if (metric.duration != null && metric.duration! > _slowOperationThreshold) {
          slowOps.add({
            'operation_type': entry.key,
            'operation_id': metric.operationId,
            'duration_ms': metric.duration!.inMilliseconds,
            'success': metric.success,
            'error': metric.error,
            'timestamp': metric.startTime.toIso8601String(),
            'metadata': metric.metadata,
          });
        }
      }
    }
    
    // Sort by duration (slowest first)
    slowOps.sort((a, b) => (b['duration_ms'] as int).compareTo(a['duration_ms'] as int));
    
    return slowOps.take(limit).toList();
  }
}

/// Individual performance metric
class PerformanceMetric {
  final String operationId;
  final String operationType;
  final DateTime startTime;
  final DateTime? endTime;
  final bool success;
  final String? error;
  final Map<String, dynamic> metadata;
  final Map<String, dynamic>? additionalData;

  const PerformanceMetric({
    required this.operationId,
    required this.operationType,
    required this.startTime,
    this.endTime,
    this.success = true,
    this.error,
    this.metadata = const {},
    this.additionalData,
  });

  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  PerformanceMetric copyWith({
    String? operationId,
    String? operationType,
    DateTime? startTime,
    DateTime? endTime,
    bool? success,
    String? error,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? additionalData,
  }) {
    return PerformanceMetric(
      operationId: operationId ?? this.operationId,
      operationType: operationType ?? this.operationType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      success: success ?? this.success,
      error: error ?? this.error,
      metadata: metadata ?? this.metadata,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'operation_id': operationId,
      'operation_type': operationType,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration_ms': duration?.inMilliseconds,
      'success': success,
      'error': error,
      'metadata': metadata,
      'additional_data': additionalData,
    };
  }
}

/// Performance statistics for an operation type
class PerformanceStats {
  final String operationType;
  final int totalOperations;
  final int successfulOperations;
  final int failedOperations;
  final Duration averageDuration;
  final Duration minDuration;
  final Duration maxDuration;
  final double cacheHitRatio;
  final List<PerformanceMetric> recentMetrics;

  const PerformanceStats({
    required this.operationType,
    required this.totalOperations,
    required this.successfulOperations,
    required this.failedOperations,
    required this.averageDuration,
    required this.minDuration,
    required this.maxDuration,
    required this.cacheHitRatio,
    this.recentMetrics = const [],
  });

  double get successRate => totalOperations > 0 ? successfulOperations / totalOperations : 0.0;
  double get failureRate => totalOperations > 0 ? failedOperations / totalOperations : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'operation_type': operationType,
      'total_operations': totalOperations,
      'successful_operations': successfulOperations,
      'failed_operations': failedOperations,
      'success_rate': successRate,
      'failure_rate': failureRate,
      'average_duration_ms': averageDuration.inMilliseconds,
      'min_duration_ms': minDuration.inMilliseconds,
      'max_duration_ms': maxDuration.inMilliseconds,
      'cache_hit_ratio': cacheHitRatio,
      'recent_metrics_count': recentMetrics.length,
    };
  }
}

/// Extension for easy performance monitoring
extension PerformanceMonitoring on Future<T> Function<T>() {
  Future<T> withPerformanceMonitoring<T>(
    String operationType,
    String operationId, {
    Map<String, dynamic>? metadata,
  }) async {
    final monitor = PerformanceMonitoringService();
    monitor.startOperation(operationId, operationType, metadata: metadata);
    
    try {
      final result = await this();
      monitor.endOperation(operationId, success: true);
      return result;
    } catch (error) {
      monitor.endOperation(operationId, success: false, error: error.toString());
      rethrow;
    }
  }
}