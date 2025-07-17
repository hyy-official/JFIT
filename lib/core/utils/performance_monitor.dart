import 'package:flutter/foundation.dart';

/// Simple performance monitoring utility for tracking app initialization
/// and BLoC creation performance
class PerformanceMonitor {
  static final Map<String, DateTime> _startTimes = {};
  static final Map<String, Duration> _durations = {};

  /// Start timing an operation
  static void startTiming(String operation) {
    _startTimes[operation] = DateTime.now();
    if (kDebugMode) {
      debugPrint('⏱️ [Performance] Started: $operation');
    }
  }

  /// End timing an operation and log the duration
  static void endTiming(String operation) {
    final startTime = _startTimes[operation];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _durations[operation] = duration;
      _startTimes.remove(operation);
      
      if (kDebugMode) {
        debugPrint('✅ [Performance] Completed: $operation in ${duration.inMilliseconds}ms');
      }
    }
  }

  /// Get the duration of a completed operation
  static Duration? getDuration(String operation) {
    return _durations[operation];
  }

  /// Log all recorded durations
  static void logAllDurations() {
    if (kDebugMode) {
      debugPrint('📊 [Performance] Summary:');
      for (final entry in _durations.entries) {
        debugPrint('  ${entry.key}: ${entry.value.inMilliseconds}ms');
      }
    }
  }

  /// Clear all recorded data
  static void clear() {
    _startTimes.clear();
    _durations.clear();
  }

  /// Track memory usage (simplified)
  static void logMemoryUsage(String context) {
    if (kDebugMode) {
      // This is a simplified memory tracking - in production you might want
      // to use more sophisticated memory profiling tools
      debugPrint('🧠 [Memory] Context: $context');
    }
  }
}