import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/core/utils/bloc_performance_monitor.dart';
import 'package:jfit/core/utils/network_request_optimizer.dart';

void main() {
  group('Performance Optimization Tests', () {
    late BlocPerformanceMonitor performanceMonitor;
    late NetworkRequestOptimizer networkOptimizer;

    setUp(() {
      performanceMonitor = BlocPerformanceMonitor();
      networkOptimizer = NetworkRequestOptimizer();
    });

    tearDown(() {
      performanceMonitor.stopMonitoring();
      performanceMonitor.clearMetrics();
      networkOptimizer.clearCache();
      networkOptimizer.resetMetrics();
    });

    group('BlocPerformanceMonitor', () {
      test('should start and stop monitoring correctly', () {
        expect(performanceMonitor.isMonitoring, isFalse);
        
        performanceMonitor.startMonitoring();
        expect(performanceMonitor.isMonitoring, isTrue);
        
        performanceMonitor.stopMonitoring();
        expect(performanceMonitor.isMonitoring, isFalse);
      });

      test('should generate performance report', () {
        final report = performanceMonitor.getPerformanceReport();
        
        expect(report, isA<Map<String, dynamic>>());
        expect(report['monitoring_active'], isA<bool>());
        expect(report['total_blocs_tracked'], isA<int>());
        expect(report['recommendations'], isA<List>());
        expect(report['overall_memory_usage_mb'], isA<double>());
        expect(report['bloc_details'], isA<Map>());
      });

      test('should provide optimization recommendations', () {
        final report = performanceMonitor.getPerformanceReport();
        final recommendations = report['recommendations'] as List<String>;
        
        expect(recommendations, isA<List<String>>());
        // Recommendations should be empty for a fresh monitor
        expect(recommendations.length, greaterThanOrEqualTo(0));
      });

      test('should clear metrics correctly', () {
        performanceMonitor.clearMetrics();
        final report = performanceMonitor.getPerformanceReport();
        
        expect(report['total_blocs_tracked'], equals(0));
        expect((report['bloc_details'] as Map).isEmpty, isTrue);
      });
    });

    group('NetworkRequestOptimizer', () {
      test('should deduplicate identical requests', () async {
        const requestKey = 'test-request';
        int callCount = 0;
        
        Future<String> testRequest() async {
          callCount++;
          await Future.delayed(const Duration(milliseconds: 50));
          return 'result-$callCount';
        }
        
        // Make multiple identical requests simultaneously
        final futures = List.generate(3, (_) => 
          networkOptimizer.executeRequest(
            requestKey: requestKey,
            requestFunction: testRequest,
            enableDeduplication: true,
          )
        );
        
        final results = await Future.wait(futures);
        
        // All requests should return the same result
        expect(results, everyElement(equals('result-1')));
        
        // Function should have been called only once
        expect(callCount, equals(1));
        
        // Check metrics
        final metrics = networkOptimizer.getPerformanceMetrics();
        expect(metrics['total_requests'], equals(3));
        expect(metrics['deduplicated_requests'], equals(2));
      });

      test('should cache responses and improve performance', () async {
        const requestKey = 'cached-request';
        int callCount = 0;
        
        Future<String> testRequest() async {
          callCount++;
          return 'cached-result-$callCount';
        }
        
        // First request - should execute function
        final result1 = await networkOptimizer.executeRequest(
          requestKey: requestKey,
          requestFunction: testRequest,
          enableCache: true,
        );
        
        // Second request - should use cache
        final result2 = await networkOptimizer.executeRequest(
          requestKey: requestKey,
          requestFunction: testRequest,
          enableCache: true,
        );
        
        // Both results should be the same
        expect(result1, equals(result2));
        expect(result1, equals('cached-result-1'));
        
        // Function should have been called only once
        expect(callCount, equals(1));
        
        // Check cache metrics
        final metrics = networkOptimizer.getPerformanceMetrics();
        expect(metrics['cache_hits'], equals(1));
        expect(metrics['cache_misses'], equals(1));
      });

      test('should generate consistent request keys', () {
        const endpoint = '/api/test';
        const userId = 'user123';
        final params = {'param1': 'value1', 'param2': 'value2'};
        
        final key1 = NetworkRequestOptimizer.generateRequestKey(
          endpoint: endpoint,
          userId: userId,
          parameters: params,
        );
        
        final key2 = NetworkRequestOptimizer.generateRequestKey(
          endpoint: endpoint,
          userId: userId,
          parameters: params,
        );
        
        expect(key1, equals(key2));
        
        // Test extension methods
        final key3 = endpoint.withUserAndParams(userId, params);
        expect(key3, equals(key1));
      });

      test('should handle cache expiration', () async {
        const requestKey = 'expiring-request';
        int callCount = 0;
        
        Future<String> testRequest() async {
          callCount++;
          return 'result-$callCount';
        }
        
        // First request with very short cache expiration
        await networkOptimizer.executeRequest(
          requestKey: requestKey,
          requestFunction: testRequest,
          enableCache: true,
          cacheExpiration: const Duration(milliseconds: 10),
        );
        
        // Wait for cache to expire
        await Future.delayed(const Duration(milliseconds: 20));
        
        // Second request should execute function again
        await networkOptimizer.executeRequest(
          requestKey: requestKey,
          requestFunction: testRequest,
          enableCache: true,
          cacheExpiration: const Duration(milliseconds: 10),
        );
        
        // Function should have been called twice
        expect(callCount, equals(2));
      });

      test('should clear cache correctly', () {
        networkOptimizer.clearCache();
        final metrics = networkOptimizer.getPerformanceMetrics();
        
        expect(metrics['cached_responses'], equals(0));
      });

      test('should reset metrics correctly', () {
        networkOptimizer.resetMetrics();
        final metrics = networkOptimizer.getPerformanceMetrics();
        
        expect(metrics['total_requests'], equals(0));
        expect(metrics['deduplicated_requests'], equals(0));
        expect(metrics['cache_hits'], equals(0));
        expect(metrics['cache_misses'], equals(0));
      });
    });

    group('Integration Tests', () {
      test('should work together for optimal performance', () async {
        // Start performance monitoring
        performanceMonitor.startMonitoring();
        
        // Simulate some network requests
        await networkOptimizer.executeRequest(
          requestKey: 'test-integration',
          requestFunction: () async => 'integration-result',
          enableCache: true,
        );
        
        // Check that both utilities are working
        expect(performanceMonitor.isMonitoring, isTrue);
        
        final performanceReport = performanceMonitor.getPerformanceReport();
        expect(performanceReport, isA<Map<String, dynamic>>());
        
        final networkMetrics = networkOptimizer.getPerformanceMetrics();
        expect(networkMetrics, isA<Map<String, dynamic>>());
        expect(networkMetrics['total_requests'], greaterThan(0));
        
        performanceMonitor.stopMonitoring();
      });
    });
  });
}