#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

void main() async {
  print('=== 테스트 커버리지 분석 보고서 ===\n');
  
  // Read coverage data
  final coverageFile = File('coverage/lcov.info');
  if (!coverageFile.existsSync()) {
    print('❌ 커버리지 파일을 찾을 수 없습니다: coverage/lcov.info');
    return;
  }
  
  final coverageData = await coverageFile.readAsString();
  final analysis = analyzeCoverage(coverageData);
  
  // Print overall statistics
  print('📊 전체 커버리지 통계:');
  print('  - 총 파일 수: ${analysis['totalFiles']}');
  print('  - 총 라인 수: ${analysis['totalLines']}');
  print('  - 커버된 라인 수: ${analysis['coveredLines']}');
  print('  - 전체 커버리지: ${analysis['overallCoverage'].toStringAsFixed(2)}%\n');
  
  // Group Workout Community specific analysis
  final gwcAnalysis = analyzeGroupWorkoutCommunity(coverageData);
  print('🎯 Group Workout Community 커버리지:');
  print('  - 파일 수: ${gwcAnalysis['files']}');
  print('  - 총 라인 수: ${gwcAnalysis['totalLines']}');
  print('  - 커버된 라인 수: ${gwcAnalysis['coveredLines']}');
  print('  - 커버리지: ${gwcAnalysis['coverage'].toStringAsFixed(2)}%\n');
  
  // Detailed file analysis
  print('📁 파일별 상세 분석:');
  final fileAnalysis = analyzeFilesCoverage(coverageData);
  for (final file in fileAnalysis) {
    final coverage = file['coverage'] as double;
    final status = coverage >= 80 ? '✅' : coverage >= 50 ? '⚠️' : '❌';
    print('  $status ${file['name']}: ${coverage.toStringAsFixed(1)}% (${file['covered']}/${file['total']})');
  }
  
  print('\n🔍 커버리지 품질 분석:');
  final qualityAnalysis = analyzeQuality(fileAnalysis);
  print('  - 높은 커버리지 (≥80%): ${qualityAnalysis['high']}개 파일');
  print('  - 중간 커버리지 (50-79%): ${qualityAnalysis['medium']}개 파일');
  print('  - 낮은 커버리지 (<50%): ${qualityAnalysis['low']}개 파일');
  
  print('\n📋 개선 권장사항:');
  final recommendations = generateRecommendations(fileAnalysis);
  for (int i = 0; i < recommendations.length; i++) {
    print('  ${i + 1}. ${recommendations[i]}');
  }
  
  // Save detailed report
  await saveDetailedReport(analysis, gwcAnalysis, fileAnalysis, qualityAnalysis, recommendations);
  print('\n💾 상세 보고서가 test_coverage_report.md에 저장되었습니다.');
}

Map<String, dynamic> analyzeCoverage(String coverageData) {
  final lines = coverageData.split('\n');
  int totalFiles = 0;
  int totalLines = 0;
  int coveredLines = 0;
  
  for (final line in lines) {
    if (line.startsWith('SF:')) {
      totalFiles++;
    } else if (line.startsWith('DA:')) {
      totalLines++;
      final parts = line.substring(3).split(',');
      if (parts.length >= 2 && int.tryParse(parts[1]) != null && int.parse(parts[1]) > 0) {
        coveredLines++;
      }
    }
  }
  
  final coverage = totalLines > 0 ? (coveredLines / totalLines) * 100 : 0.0;
  
  return {
    'totalFiles': totalFiles,
    'totalLines': totalLines,
    'coveredLines': coveredLines,
    'overallCoverage': coverage,
  };
}

Map<String, dynamic> analyzeGroupWorkoutCommunity(String coverageData) {
  final lines = coverageData.split('\n');
  int files = 0;
  int totalLines = 0;
  int coveredLines = 0;
  bool inGwcFile = false;
  
  for (final line in lines) {
    if (line.startsWith('SF:')) {
      inGwcFile = line.contains('group_workout_community');
      if (inGwcFile) files++;
    } else if (line.startsWith('DA:') && inGwcFile) {
      totalLines++;
      final parts = line.substring(3).split(',');
      if (parts.length >= 2 && int.tryParse(parts[1]) != null && int.parse(parts[1]) > 0) {
        coveredLines++;
      }
    }
  }
  
  final coverage = totalLines > 0 ? (coveredLines / totalLines) * 100 : 0.0;
  
  return {
    'files': files,
    'totalLines': totalLines,
    'coveredLines': coveredLines,
    'coverage': coverage,
  };
}

List<Map<String, dynamic>> analyzeFilesCoverage(String coverageData) {
  final lines = coverageData.split('\n');
  final files = <Map<String, dynamic>>[];
  String? currentFile;
  int totalLines = 0;
  int coveredLines = 0;
  
  for (final line in lines) {
    if (line.startsWith('SF:')) {
      // Save previous file if exists
      if (currentFile != null) {
        final coverage = totalLines > 0 ? (coveredLines / totalLines) * 100 : 0.0;
        files.add({
          'name': currentFile,
          'total': totalLines,
          'covered': coveredLines,
          'coverage': coverage,
        });
      }
      
      // Start new file
      currentFile = line.substring(3);
      totalLines = 0;
      coveredLines = 0;
    } else if (line.startsWith('DA:') && currentFile != null) {
      totalLines++;
      final parts = line.substring(3).split(',');
      if (parts.length >= 2 && int.tryParse(parts[1]) != null && int.parse(parts[1]) > 0) {
        coveredLines++;
      }
    }
  }
  
  // Don't forget the last file
  if (currentFile != null) {
    final coverage = totalLines > 0 ? (coveredLines / totalLines) * 100 : 0.0;
    files.add({
      'name': currentFile,
      'total': totalLines,
      'covered': coveredLines,
      'coverage': coverage,
    });
  }
  
  // Sort by coverage percentage (lowest first for priority)
  files.sort((a, b) => (a['coverage'] as double).compareTo(b['coverage'] as double));
  
  return files;
}

Map<String, int> analyzeQuality(List<Map<String, dynamic>> fileAnalysis) {
  int high = 0, medium = 0, low = 0;
  
  for (final file in fileAnalysis) {
    final coverage = file['coverage'] as double;
    if (coverage >= 80) {
      high++;
    } else if (coverage >= 50) {
      medium++;
    } else {
      low++;
    }
  }
  
  return {'high': high, 'medium': medium, 'low': low};
}

List<String> generateRecommendations(List<Map<String, dynamic>> fileAnalysis) {
  final recommendations = <String>[];
  
  // Find files with 0% coverage
  final zeroCoverage = fileAnalysis.where((f) => (f['coverage'] as double) == 0.0).toList();
  if (zeroCoverage.isNotEmpty) {
    recommendations.add('${zeroCoverage.length}개 파일의 커버리지가 0%입니다. 기본 테스트 케이스 추가가 필요합니다.');
  }
  
  // Find files with low coverage
  final lowCoverage = fileAnalysis.where((f) => (f['coverage'] as double) < 50 && (f['coverage'] as double) > 0).toList();
  if (lowCoverage.isNotEmpty) {
    recommendations.add('${lowCoverage.length}개 파일의 커버리지가 50% 미만입니다. 추가 테스트 케이스가 필요합니다.');
  }
  
  // Check for group_workout_community specific files
  final gwcFiles = fileAnalysis.where((f) => (f['name'] as String).contains('group_workout_community')).toList();
  final lowGwcFiles = gwcFiles.where((f) => (f['coverage'] as double) < 70).toList();
  if (lowGwcFiles.isNotEmpty) {
    recommendations.add('Group Workout Community 기능의 ${lowGwcFiles.length}개 파일이 70% 미만의 커버리지를 가집니다.');
  }
  
  // General recommendations
  recommendations.add('테스트 실행 전 모든 컴파일 에러를 수정해야 합니다.');
  recommendations.add('Mock 객체와 실제 인터페이스 간의 불일치를 해결해야 합니다.');
  recommendations.add('BLoC 이벤트 및 상태 클래스의 생성자 시그니처를 확인해야 합니다.');
  
  return recommendations;
}

Future<void> saveDetailedReport(
  Map<String, dynamic> analysis,
  Map<String, dynamic> gwcAnalysis,
  List<Map<String, dynamic>> fileAnalysis,
  Map<String, int> qualityAnalysis,
  List<String> recommendations,
) async {
  final report = StringBuffer();
  
  report.writeln('# 테스트 커버리지 분석 보고서');
  report.writeln('');
  report.writeln('생성일: ${DateTime.now().toIso8601String()}');
  report.writeln('');
  
  report.writeln('## 📊 전체 통계');
  report.writeln('');
  report.writeln('| 항목 | 값 |');
  report.writeln('|------|-----|');
  report.writeln('| 총 파일 수 | ${analysis['totalFiles']} |');
  report.writeln('| 총 라인 수 | ${analysis['totalLines']} |');
  report.writeln('| 커버된 라인 수 | ${analysis['coveredLines']} |');
  report.writeln('| 전체 커버리지 | ${analysis['overallCoverage'].toStringAsFixed(2)}% |');
  report.writeln('');
  
  report.writeln('## 🎯 Group Workout Community 커버리지');
  report.writeln('');
  report.writeln('| 항목 | 값 |');
  report.writeln('|------|-----|');
  report.writeln('| 파일 수 | ${gwcAnalysis['files']} |');
  report.writeln('| 총 라인 수 | ${gwcAnalysis['totalLines']} |');
  report.writeln('| 커버된 라인 수 | ${gwcAnalysis['coveredLines']} |');
  report.writeln('| 커버리지 | ${gwcAnalysis['coverage'].toStringAsFixed(2)}% |');
  report.writeln('');
  
  report.writeln('## 📁 파일별 상세 분석');
  report.writeln('');
  report.writeln('| 파일 | 커버리지 | 커버된 라인 | 총 라인 | 상태 |');
  report.writeln('|------|----------|-------------|---------|------|');
  
  for (final file in fileAnalysis) {
    final coverage = file['coverage'] as double;
    final status = coverage >= 80 ? '✅ 양호' : coverage >= 50 ? '⚠️ 보통' : '❌ 개선필요';
    final fileName = (file['name'] as String).split('/').last;
    report.writeln('| $fileName | ${coverage.toStringAsFixed(1)}% | ${file['covered']} | ${file['total']} | $status |');
  }
  report.writeln('');
  
  report.writeln('## 🔍 품질 분석');
  report.writeln('');
  report.writeln('- **높은 커버리지 (≥80%)**: ${qualityAnalysis['high']}개 파일');
  report.writeln('- **중간 커버리지 (50-79%)**: ${qualityAnalysis['medium']}개 파일');
  report.writeln('- **낮은 커버리지 (<50%)**: ${qualityAnalysis['low']}개 파일');
  report.writeln('');
  
  report.writeln('## 📋 개선 권장사항');
  report.writeln('');
  for (int i = 0; i < recommendations.length; i++) {
    report.writeln('${i + 1}. ${recommendations[i]}');
  }
  report.writeln('');
  
  report.writeln('## 🚨 발견된 주요 문제점');
  report.writeln('');
  report.writeln('### 컴파일 에러');
  report.writeln('- LogicalKeyboardKey import 누락');
  report.writeln('- GroupActivityType 타입 정의 문제');
  report.writeln('- BlocCommunicationEvent 추상 클래스 인스턴스화 시도');
  report.writeln('- Mock 객체 타입 불일치');
  report.writeln('');
  
  report.writeln('### 테스트 구조 문제');
  report.writeln('- 실제 구현과 테스트 코드 간 인터페이스 불일치');
  report.writeln('- 존재하지 않는 상태 클래스 참조');
  report.writeln('- 잘못된 매개변수 이름 사용');
  report.writeln('');
  
  report.writeln('## 🎯 다음 단계');
  report.writeln('');
  report.writeln('1. **즉시 수정 필요**: 모든 컴파일 에러 해결');
  report.writeln('2. **단기 목표**: Group Workout Community 테스트 70% 이상 커버리지 달성');
  report.writeln('3. **중기 목표**: 전체 테스트 스위트 안정화');
  report.writeln('4. **장기 목표**: 지속적인 테스트 품질 모니터링 체계 구축');
  
  await File('test_coverage_report.md').writeAsString(report.toString());
}