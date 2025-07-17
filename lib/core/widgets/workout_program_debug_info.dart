import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jfit/core/utils/workout_program_logger.dart';

/// 운동 프로그램 디버그 정보를 표시하는 위젯
/// 사용자 문제 해결을 위한 디버그 정보를 제공합니다.
class WorkoutProgramDebugInfo extends StatefulWidget {
  final String? userId;
  final String? currentOperation;
  final bool showFullLogs;

  const WorkoutProgramDebugInfo({
    super.key,
    this.userId,
    this.currentOperation,
    this.showFullLogs = false,
  });

  @override
  State<WorkoutProgramDebugInfo> createState() => _WorkoutProgramDebugInfoState();
}

class _WorkoutProgramDebugInfoState extends State<WorkoutProgramDebugInfo> {
  bool _isExpanded = false;
  Map<String, dynamic>? _debugInfo;
  List<WorkoutProgramLogEntry>? _recentLogs;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  void _loadDebugInfo() {
    setState(() {
      _debugInfo = WorkoutProgramLogger.generateDebugInfo(
        userId: widget.userId,
        currentOperation: widget.currentOperation,
      );
      _recentLogs = WorkoutProgramLogger.getLogHistory(
        minLevel: LogLevel.warning,
        limit: 10,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('디버그 정보'),
            subtitle: Text('문제 해결을 위한 시스템 정보'),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          if (_isExpanded) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSystemInfo(),
                  const SizedBox(height: 16),
                  _buildLogSummary(),
                  const SizedBox(height: 16),
                  _buildPerformanceInfo(),
                  if (widget.showFullLogs) ...[
                    const SizedBox(height: 16),
                    _buildRecentLogs(),
                  ],
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSystemInfo() {
    final appInfo = _debugInfo?['app_info'] as Map<String, dynamic>? ?? {};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '시스템 정보',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('사용자 ID', widget.userId ?? '알 수 없음'),
        _buildInfoRow('현재 작업', widget.currentOperation ?? '없음'),
        _buildInfoRow('디버그 모드', appInfo['debug_mode']?.toString() ?? 'false'),
        _buildInfoRow('릴리즈 모드', appInfo['release_mode']?.toString() ?? 'false'),
        _buildInfoRow('타임스탬프', _formatTimestamp(_debugInfo?['timestamp'])),
      ],
    );
  }

  Widget _buildLogSummary() {
    final logSummary = _debugInfo?['log_summary'] as Map<String, dynamic>? ?? {};
    final recentErrors = logSummary['recent_errors'] as List<dynamic>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '로그 요약',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('총 로그 수', logSummary['total_logs']?.toString() ?? '0'),
        _buildInfoRow('에러 수', logSummary['error_count']?.toString() ?? '0'),
        _buildInfoRow('경고 수', logSummary['warning_count']?.toString() ?? '0'),
        if (recentErrors.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '최근 에러:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          ...recentErrors.take(3).map((error) => Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              '• ${error['operation'] ?? 'unknown'}: ${error['message'] ?? 'No message'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildPerformanceInfo() {
    final performanceInfo = _debugInfo?['performance_info'] as Map<String, dynamic>? ?? {};
    final slowOperations = performanceInfo['slow_operations'] as List<dynamic>? ?? [];
    final activeTimers = performanceInfo['active_timers'] as List<dynamic>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '성능 정보',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('활성 타이머', activeTimers.length.toString()),
        _buildInfoRow('느린 작업 수', slowOperations.length.toString()),
        if (slowOperations.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '느린 작업:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          ...slowOperations.take(3).map((operation) => Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              '• ${operation['operation_id']}: ${operation['duration_ms']}ms',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildRecentLogs() {
    if (_recentLogs == null || _recentLogs!.isEmpty) {
      return const Text('최근 로그가 없습니다.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최근 로그',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: _recentLogs!.length,
            itemBuilder: (context, index) {
              final log = _recentLogs![index];
              return ListTile(
                dense: true,
                leading: _getLogLevelIcon(log.level),
                title: Text(
                  log.message,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                subtitle: Text(
                  '${log.operation ?? 'unknown'} - ${_formatTimestamp(log.timestamp.toIso8601String())}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: _refreshDebugInfo,
          icon: const Icon(Icons.refresh),
          label: const Text('새로고침'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _copyDebugInfo,
          icon: const Icon(Icons.copy),
          label: const Text('복사'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _clearLogs,
          icon: const Icon(Icons.clear),
          label: const Text('로그 지우기'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getLogLevelIcon(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Icon(Icons.info_outline, size: 16, color: Colors.blue);
      case LogLevel.info:
        return Icon(Icons.info, size: 16, color: Colors.green);
      case LogLevel.warning:
        return Icon(Icons.warning, size: 16, color: Colors.orange);
      case LogLevel.error:
        return Icon(Icons.error, size: 16, color: Colors.red);
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '알 수 없음';
    
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  void _refreshDebugInfo() {
    _loadDebugInfo();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('디버그 정보가 새로고침되었습니다.')),
    );
  }

  void _copyDebugInfo() {
    if (_debugInfo != null) {
      final debugText = _formatDebugInfoForCopy(_debugInfo!);
      Clipboard.setData(ClipboardData(text: debugText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('디버그 정보가 클립보드에 복사되었습니다.')),
      );
    }
  }

  void _clearLogs() {
    WorkoutProgramLogger.clearLogHistory();
    _loadDebugInfo();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('로그 히스토리가 지워졌습니다.')),
    );
  }

  String _formatDebugInfoForCopy(Map<String, dynamic> debugInfo) {
    final buffer = StringBuffer();
    buffer.writeln('=== 운동 프로그램 디버그 정보 ===');
    buffer.writeln('타임스탬프: ${debugInfo['timestamp']}');
    buffer.writeln('사용자 ID: ${widget.userId ?? '알 수 없음'}');
    buffer.writeln('현재 작업: ${widget.currentOperation ?? '없음'}');
    buffer.writeln();
    
    final logSummary = debugInfo['log_summary'] as Map<String, dynamic>? ?? {};
    buffer.writeln('로그 요약:');
    buffer.writeln('- 총 로그 수: ${logSummary['total_logs']}');
    buffer.writeln('- 에러 수: ${logSummary['error_count']}');
    buffer.writeln('- 경고 수: ${logSummary['warning_count']}');
    buffer.writeln();
    
    final recentErrors = logSummary['recent_errors'] as List<dynamic>? ?? [];
    if (recentErrors.isNotEmpty) {
      buffer.writeln('최근 에러:');
      for (final error in recentErrors) {
        buffer.writeln('- ${error['operation']}: ${error['message']}');
      }
      buffer.writeln();
    }
    
    final performanceInfo = debugInfo['performance_info'] as Map<String, dynamic>? ?? {};
    buffer.writeln('성능 정보:');
    buffer.writeln('- 활성 타이머: ${(performanceInfo['active_timers'] as List?)?.length ?? 0}');
    buffer.writeln('- 느린 작업 수: ${(performanceInfo['slow_operations'] as List?)?.length ?? 0}');
    
    return buffer.toString();
  }
}

/// 디버그 정보를 다이얼로그로 표시하는 헬퍼 함수
void showWorkoutProgramDebugDialog(
  BuildContext context, {
  String? userId,
  String? currentOperation,
  bool showFullLogs = false,
}) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        child: WorkoutProgramDebugInfo(
          userId: userId,
          currentOperation: currentOperation,
          showFullLogs: showFullLogs,
        ),
      ),
    ),
  );
}