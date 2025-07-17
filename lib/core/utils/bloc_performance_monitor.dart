import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

import 'package:jfit/core/bloc/bloc_provider_helper.dart';

/// Performance monitoring utility for BLoCs
/// Tracks memory usage, performance metrics, and provides optimization recommendations
class BlocPerformanceMonitor {
  static final BlocPerformanceMonitor _instance = BlocPerformanceMonitor._internal();
  factory BlocPerformanceMonitor() => _instance;
  BlocPerformanceMonitor._internal();

  // Performance tracking
  final Map<String, BlocMetrics> _blocMetrics = {};
  Timer? _monitoringTimer;
  bool _isMonitoring = false;

  /// Start performance monitoring
  void startMonitoring({Duration interval = const Duration(minutes: 1)}) {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _monitoringTimer = Timer.periodic(interval, (_) => _collectMetrics());
    
    if (kDebugMode) {
      developer.log('🔍 BLOC Performance Monitoring Started', name: 'BlocPerformanceMonitor');
    }
  }

  /// Stop performance monitoring
  void stopMonitoring() {
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    
    if (kDebugMode) {
      developer.log('🛑 BLOC Performance Monitoring Stopped', name: 'BlocPerformanceMonitor');
    }
  }

  /// Collect performance metrics from all tracked BLoCs
  void _collectMetrics() {
    try {
      final providerMetrics = BlocProviderHelper.getPerformanceMetrics();
      final timestamp = DateTime.now();
      
      // Update metrics for each BLOC
      final blocMetrics = providerMetrics['bloc_metrics'] as Map<String, dynamic>? ?? {};
      
      for (final entry in blocMetrics.entries) {
        final blocName = entry.key;
        final metrics = entry.value as Map<String, dynamic>;
        
        _blocMetrics[blocName] ??= BlocMetrics(blocName);
        _blocMetrics[blocName]!.updateMetrics(metrics, timestamp);
      }
      
      // Log performance warnings if needed
      _checkPerformanceWarnings();
      
    } catch (e) {
      if (kDebugMode) {
        developer.log('❌ Error collecting BLOC metrics: $e', name: 'BlocPerformanceMonitor');
      }
    }
  }

  /// Check for performance warnings and log them
  void _checkPerformanceWarnings() {
    for (final metrics in _blocMetrics.values) {
      final warnings = metrics.getPerformanceWarnings();
      
      for (final warning in warnings) {
        if (kDebugMode) {
          developer.log('⚠️ ${metrics.blocName}: $warning', name: 'BlocPerformanceMonitor');
        }
      }
    }
  }

  /// Get comprehensive performance report
  Map<String, dynamic> getPerformanceReport() {
    final report = <String, dynamic>{
      'monitoring_active': _isMonitoring,
      'total_blocs_tracked': _blocMetrics.length,
      'report_generated_at': DateTime.now().toIso8601String(),
      'overall_memory_usage_mb': BlocProviderHelper.getEstimatedMemoryUsage(),
      'bloc_details': {},
      'recommendations': _getOptimizationRecommendations(),
    };

    // Add detailed metrics for each BLOC
    for (final entry in _blocMetrics.entries) {
      report['bloc_details'][entry.key] = entry.value.toMap();
    }

    return report;
  }

  /// Get optimization recommendations based on collected metrics
  List<String> _getOptimizationRecommendations() {
    final recommendations = <String>[];
    
    // Check for memory usage issues
    final totalMemoryMB = BlocProviderHelper.getEstimatedMemoryUsage();
    if (totalMemoryMB > 50) {
      recommendations.add('High memory usage detected (${totalMemoryMB.toStringAsFixed(1)}MB). Consider implementing BLOC disposal strategies.');
    }
    
    // Check for long-running BLoCs
    final longRunningBlocs = _blocMetrics.values
        .where((metrics) => metrics.uptimeMinutes > 60)
        .map((metrics) => metrics.blocName)
        .toList();
    
    if (longRunningBlocs.isNotEmpty) {
      recommendations.add('Long-running BLoCs detected: ${longRunningBlocs.join(', ')}. Consider implementing inactivity cleanup.');
    }
    
    // Check for frequently recreated BLoCs
    final frequentlyRecreated = _blocMetrics.values
        .where((metrics) => metrics.recreationCount > 5)
        .map((metrics) => metrics.blocName)
        .toList();
    
    if (frequentlyRecreated.isNotEmpty) {
      recommendations.add('Frequently recreated BLoCs: ${frequentlyRecreated.join(', ')}. Consider using singleton pattern or better lifecycle management.');
    }
    
    // Check for inactive BLoCs
    final inactiveBlocs = _blocMetrics.values
        .where((metrics) => metrics.inactiveMinutes > 30)
        .map((metrics) => metrics.blocName)
        .toList();
    
    if (inactiveBlocs.isNotEmpty) {
      recommendations.add('Inactive BLoCs detected: ${inactiveBlocs.join(', ')}. Consider disposing them to free memory.');
    }
    
    return recommendations;
  }

  /// Print performance report to console (debug mode only)
  void printPerformanceReport() {
    if (!kDebugMode) return;
    
    final report = getPerformanceReport();
    final buffer = StringBuffer();
    
    buffer.writeln('📊 BLOC Performance Report');
    buffer.writeln('=' * 50);
    buffer.writeln('Generated: ${report['report_generated_at']}');
    buffer.writeln('Monitoring Active: ${report['monitoring_active']}');
    buffer.writeln('Total BLoCs Tracked: ${report['total_blocs_tracked']}');
    buffer.writeln('Overall Memory Usage: ${report['overall_memory_usage_mb']} MB');
    buffer.writeln();
    
    // BLOC details
    final blocDetails = report['bloc_details'] as Map<String, dynamic>;
    if (blocDetails.isNotEmpty) {
      buffer.writeln('BLOC Details:');
      buffer.writeln('-' * 30);
      
      for (final entry in blocDetails.entries) {
        final blocName = entry.key;
        final details = entry.value as Map<String, dynamic>;
        
        buffer.writeln('$blocName:');
        buffer.writeln('  Uptime: ${details['uptime_minutes']} minutes');
        buffer.writeln('  Inactive: ${details['inactive_minutes']} minutes');
        buffer.writeln('  Recreations: ${details['recreation_count']}');
        buffer.writeln('  Warnings: ${(details['warnings'] as List).length}');
        buffer.writeln();
      }
    }
    
    // Recommendations
    final recommendations = report['recommendations'] as List<String>;
    if (recommendations.isNotEmpty) {
      buffer.writeln('Optimization Recommendations:');
      buffer.writeln('-' * 30);
      
      for (int i = 0; i < recommendations.length; i++) {
        buffer.writeln('${i + 1}. ${recommendations[i]}');
      }
    }
    
    developer.log(buffer.toString(), name: 'BlocPerformanceMonitor');
  }

  /// Clear all collected metrics
  void clearMetrics() {
    _blocMetrics.clear();
    BlocProviderHelper.clearPerformanceMetrics();
  }

  /// Get metrics for a specific BLOC
  BlocMetrics? getBlocMetrics(String blocName) {
    return _blocMetrics[blocName];
  }

  /// Check if monitoring is active
  bool get isMonitoring => _isMonitoring;
}

/// Metrics container for individual BLOC performance data
class BlocMetrics {
  final String blocName;
  DateTime? firstCreated;
  DateTime? lastActivity;
  int recreationCount = 0;
  int uptimeMinutes = 0;
  int inactiveMinutes = 0;
  final List<String> _warnings = [];

  BlocMetrics(this.blocName);

  /// Update metrics with new data
  void updateMetrics(Map<String, dynamic> metrics, DateTime timestamp) {
    // Parse creation time
    final creationTimeStr = metrics['creation_time'] as String?;
    if (creationTimeStr != null) {
      final creationTime = DateTime.parse(creationTimeStr);
      
      if (firstCreated == null) {
        firstCreated = creationTime;
      } else if (creationTime.isAfter(firstCreated!)) {
        // BLOC was recreated
        recreationCount++;
        firstCreated = creationTime;
      }
    }
    
    // Update uptime and activity
    uptimeMinutes = metrics['uptime_minutes'] as int? ?? 0;
    
    // Calculate inactivity (simplified - in real implementation you'd track last activity)
    final now = DateTime.now();
    if (lastActivity != null) {
      inactiveMinutes = now.difference(lastActivity!).inMinutes;
    }
    lastActivity = timestamp;
    
    // Clear old warnings
    _warnings.clear();
  }

  /// Get performance warnings for this BLOC
  List<String> getPerformanceWarnings() {
    _warnings.clear();
    
    if (uptimeMinutes > 120) {
      _warnings.add('Long uptime (${uptimeMinutes} minutes) - consider lifecycle optimization');
    }
    
    if (recreationCount > 3) {
      _warnings.add('High recreation count ($recreationCount) - check for memory leaks');
    }
    
    if (inactiveMinutes > 60) {
      _warnings.add('Long inactivity (${inactiveMinutes} minutes) - consider disposal');
    }
    
    return List.from(_warnings);
  }

  /// Convert metrics to map for reporting
  Map<String, dynamic> toMap() {
    return {
      'bloc_name': blocName,
      'first_created': firstCreated?.toIso8601String(),
      'last_activity': lastActivity?.toIso8601String(),
      'recreation_count': recreationCount,
      'uptime_minutes': uptimeMinutes,
      'inactive_minutes': inactiveMinutes,
      'warnings': getPerformanceWarnings(),
    };
  }
}