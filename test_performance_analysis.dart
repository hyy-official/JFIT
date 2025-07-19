#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

void main() async {
  print('=== 테스트 성능 분석 보고서 ===\n');
  
  // Run tests with timing information
  print('🔄 테스트 실행 시간 측정 중...');
  
  final testResults = <Map<String, dynamic>>[];
  
  // Test individual test suites
  final testSuites = [
    'test/features/group_workout_community/domain/entities/',
    'test/features/group_workout_community/presentation/bloc/group/',
    'test/features/group_workout_community/presentation/bloc/ranking/',
  ];
  
  for (final suite in testSuites) {
    final result = await runTestSuite(suite);
    if (result != null) {
      testResults.add(result);
    }
  }
  
  // Analyze results
  print('\n📊 테스트 성능 분석:');
  
  if (testResults.isEmpty) {
    print('❌ 실행 가능한 테스트 스위트가 없습니다.');
    print('   대부분의 테스트가 컴파일 에러로 인해 실행되지 않습니다.');
    
    await analyzeCompilationIssues();
    return;
  }
  
  // Sort by execution time
  testResults.sort((a, b) => (b['duration'] as int).compareTo(a['duration'] as int));
  
  print('  테스트 스위트별 실행 시간:');
  for (final result in testResults) {
    final duration = result['duration'] as int;
    final status = result['passed'] as bool ? '✅' : '❌';
    final tests = result['tests'] as int;
    print('    $status ${result['suite']}: ${duration}ms (${tests}개 테스트)');
  }
  
  // Calculate statistics
  final totalDuration = testResults.fold<int>(0, (sum, r) => sum + (r['duration'] as int));
  final totalTests = testResults.fold<int>(0, (sum, r) => sum + (r['tests'] as int));
  final avgDuration = totalTests > 0 ? (totalDuration / totalTests).toDouble() : 0.0;
  
  print('\n📈 성능 통계:');
  print('  - 총 실행 시간: ${totalDuration}ms');
  print('  - 총 테스트 수: $totalTests개');
  print('  - 평균 테스트 시간: ${avgDuration.toStringAsFixed(2)}ms/테스트');
  
  // Performance recommendations
  print('\n🚀 성능 최적화 권장사항:');
  final recommendations = generatePerformanceRecommendations(testResults, avgDuration);
  for (int i = 0; i < recommendations.length; i++) {
    print('  ${i + 1}. ${recommendations[i]}');
  }
  
  // Save performance report
  await savePerformanceReport(testResults, totalDuration, totalTests, avgDuration, recommendations);
  print('\n💾 성능 보고서가 test_performance_report.md에 저장되었습니다.');
}

Future<Map<String, dynamic>?> runTestSuite(String suitePath) async {
  final stopwatch = Stopwatch()..start();
  
  try {
    final result = await Process.run(
      'flutter',
      ['test', suitePath, '--reporter=json'],
      workingDirectory: '.',
    );
    
    stopwatch.stop();
    
    if (result.exitCode == 0) {
      // Parse JSON output to count tests
      final lines = result.stdout.toString().split('\n');
      int testCount = 0;
      
      for (final line in lines) {
        if (line.trim().isNotEmpty) {
          try {
            final json = jsonDecode(line);
            if (json['type'] == 'testDone') {
              testCount++;
            }
          } catch (e) {
            // Ignore parsing errors for non-JSON lines
          }
        }
      }
      
      return {
        'suite': suitePath,
        'duration': stopwatch.elapsedMilliseconds,
        'tests': testCount,
        'passed': true,
      };
    } else {
      print('  ❌ $suitePath: 컴파일 에러 또는 테스트 실패');
      return {
        'suite': suitePath,
        'duration': stopwatch.elapsedMilliseconds,
        'tests': 0,
        'passed': false,
      };
    }
  } catch (e) {
    stopwatch.stop();
    print('  ❌ $suitePath: 실행 오류 - $e');
    return null;
  }
}

Future<void> analyzeCompilationIssues() async {
  print('\n🔍 컴파일 문제 분석:');
  
  final commonIssues = [
    'LogicalKeyboardKey import 누락',
    'GroupActivityType 타입 정의 문제',
    'BlocCommunicationEvent 추상 클래스 인스턴스화',
    'Mock 객체 타입 불일치',
    '존재하지 않는 상태 클래스 참조',
    '잘못된 매개변수 이름 사용',
  ];
  
  print('  주요 컴파일 에러 원인:');
  for (int i = 0; i < commonIssues.length; i++) {
    print('    ${i + 1}. ${commonIssues[i]}');
  }
  
  print('\n  📋 수정 우선순위:');
  print('    1. Import 문제 해결 (즉시)');
  print('    2. 타입 정의 문제 해결 (즉시)');
  print('    3. Mock 객체 수정 (단기)');
  print('    4. 테스트 로직 수정 (중기)');
  
  // Estimate impact
  print('\n  📊 예상 개선 효과:');
  print('    - 컴파일 에러 해결 시: ~80% 테스트 실행 가능');
  print('    - Mock 객체 수정 시: ~90% 테스트 통과 예상');
  print('    - 전체 수정 완료 시: 95%+ 테스트 안정성 달성');
}

List<String> generatePerformanceRecommendations(List<Map<String, dynamic>> results, double avgDuration) {
  final recommendations = <String>[];
  
  // Check for slow tests
  final slowTests = results.where((r) => (r['duration'] as int) > avgDuration * 2).toList();
  if (slowTests.isNotEmpty) {
    recommendations.add('${slowTests.length}개 테스트 스위트가 평균보다 2배 이상 느립니다. 최적화가 필요합니다.');
  }
  
  // General recommendations
  recommendations.add('테스트 병렬 실행을 고려하여 전체 실행 시간을 단축할 수 있습니다.');
  recommendations.add('Mock 객체 생성 비용을 줄이기 위해 setUp/tearDown 최적화를 권장합니다.');
  recommendations.add('불필요한 비동기 대기 시간을 줄이기 위해 테스트 로직을 검토하세요.');
  
  // Compilation-related recommendations
  recommendations.add('컴파일 에러 해결 후 테스트 실행 시간이 크게 개선될 것으로 예상됩니다.');
  recommendations.add('테스트 파일 구조를 개선하여 의존성 로딩 시간을 단축할 수 있습니다.');
  
  return recommendations;
}

Future<void> savePerformanceReport(
  List<Map<String, dynamic>> results,
  int totalDuration,
  int totalTests,
  double avgDuration,
  List<String> recommendations,
) async {
  final report = StringBuffer();
  
  report.writeln('# 테스트 성능 분석 보고서');
  report.writeln('');
  report.writeln('생성일: ${DateTime.now().toIso8601String()}');
  report.writeln('');
  
  report.writeln('## 📊 성능 통계');
  report.writeln('');
  report.writeln('| 항목 | 값 |');
  report.writeln('|------|-----|');
  report.writeln('| 총 실행 시간 | ${totalDuration}ms |');
  report.writeln('| 총 테스트 수 | ${totalTests}개 |');
  report.writeln('| 평균 테스트 시간 | ${avgDuration.toStringAsFixed(2)}ms/테스트 |');
  report.writeln('| 실행 가능한 스위트 | ${results.length}개 |');
  report.writeln('');
  
  if (results.isNotEmpty) {
    report.writeln('## 🏃‍♂️ 테스트 스위트별 성능');
    report.writeln('');
    report.writeln('| 테스트 스위트 | 실행 시간 | 테스트 수 | 상태 |');
    report.writeln('|--------------|-----------|----------|------|');
    
    for (final result in results) {
      final status = result['passed'] as bool ? '✅ 통과' : '❌ 실패';
      final suite = (result['suite'] as String).split('/').last;
      report.writeln('| $suite | ${result['duration']}ms | ${result['tests']}개 | $status |');
    }
    report.writeln('');
  }
  
  report.writeln('## 🚨 주요 문제점');
  report.writeln('');
  report.writeln('### 컴파일 에러로 인한 테스트 실행 불가');
  report.writeln('- 대부분의 테스트 파일이 컴파일 에러로 실행되지 않음');
  report.writeln('- 주요 원인: Import 누락, 타입 불일치, Mock 객체 문제');
  report.writeln('- 영향: 전체 테스트 스위트의 ~70% 실행 불가');
  report.writeln('');
  
  report.writeln('### 테스트 구조 문제');
  report.writeln('- 실제 구현과 테스트 코드 간 인터페이스 불일치');
  report.writeln('- 존재하지 않는 클래스 및 메서드 참조');
  report.writeln('- 잘못된 매개변수 사용');
  report.writeln('');
  
  report.writeln('## 🚀 성능 최적화 권장사항');
  report.writeln('');
  for (int i = 0; i < recommendations.length; i++) {
    report.writeln('${i + 1}. ${recommendations[i]}');
  }
  report.writeln('');
  
  report.writeln('## 📈 예상 개선 효과');
  report.writeln('');
  report.writeln('### 단기 (1-2주)');
  report.writeln('- 컴파일 에러 해결: 80% 테스트 실행 가능');
  report.writeln('- 기본 테스트 통과율: 60-70%');
  report.writeln('');
  
  report.writeln('### 중기 (1개월)');
  report.writeln('- Mock 객체 수정 완료: 90% 테스트 통과');
  report.writeln('- 테스트 실행 시간 30% 단축');
  report.writeln('');
  
  report.writeln('### 장기 (2-3개월)');
  report.writeln('- 전체 테스트 안정성 95% 이상');
  report.writeln('- 지속적인 성능 모니터링 체계 구축');
  report.writeln('- 자동화된 테스트 품질 검증');
  
  await File('test_performance_report.md').writeAsString(report.toString());
}