import 'package:flutter/material.dart';

class MemberScoreTable extends StatelessWidget {
  final List<Map<String, dynamic>> memberScores;
  final String sortBy;
  final bool sortAscending;
  final Function(String, bool) onSort;
  final ValueChanged<String>? onMemberTap;

  const MemberScoreTable({
    super.key,
    required this.memberScores,
    required this.sortBy,
    required this.sortAscending,
    required this.onSort,
    this.onMemberTap,
  });

  @override
  Widget build(BuildContext context) {
    if (memberScores.isEmpty) {
      return const Center(
        child: Text('멤버 점수 데이터가 없습니다'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortColumnIndex: _getSortColumnIndex(),
        sortAscending: sortAscending,
        columns: [
          DataColumn(
            label: const Text('순위'),
            onSort: (columnIndex, ascending) => onSort('rank', ascending),
          ),
          DataColumn(
            label: const Text('멤버'),
            onSort: (columnIndex, ascending) => onSort('memberName', ascending),
          ),
          DataColumn(
            label: const Text('총점'),
            numeric: true,
            onSort: (columnIndex, ascending) => onSort('totalScore', ascending),
          ),
          DataColumn(
            label: const Text('균형'),
            numeric: true,
            onSort: (columnIndex, ascending) => onSort('balanceScore', ascending),
          ),
          DataColumn(
            label: const Text('볼륨'),
            numeric: true,
            onSort: (columnIndex, ascending) => onSort('volumeScore', ascending),
          ),
          DataColumn(
            label: const Text('진전'),
            numeric: true,
            onSort: (columnIndex, ascending) => onSort('progressScore', ascending),
          ),
          DataColumn(
            label: const Text('일관성'),
            numeric: true,
            onSort: (columnIndex, ascending) => onSort('consistencyScore', ascending),
          ),
          const DataColumn(label: Text('등급')),
        ],
        rows: memberScores.asMap().entries.map((entry) {
          final index = entry.key;
          final member = entry.value;
          return _buildDataRow(context, member, index + 1);
        }).toList(),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, Map<String, dynamic> member, int rank) {
    final memberId = member['memberId'] as String? ?? '';
    final memberName = member['memberName'] as String? ?? 'Unknown';
    final totalScore = member['totalScore'] as double? ?? 0.0;
    final balanceScore = member['balanceScore'] as double? ?? 0.0;
    final volumeScore = member['volumeScore'] as double? ?? 0.0;
    final progressScore = member['progressScore'] as double? ?? 0.0;
    final consistencyScore = member['consistencyScore'] as double? ?? 0.0;
    final grade = _calculateGrade(totalScore);

    return DataRow(
      onSelectChanged: (_) => onMemberTap?.call(memberId),
      cells: [
        DataCell(_buildRankCell(context, rank)),
        DataCell(_buildMemberCell(context, memberName)),
        DataCell(_buildScoreCell(context, totalScore, _getScoreColor(totalScore))),
        DataCell(_buildScoreCell(context, balanceScore, Colors.green)),
        DataCell(_buildScoreCell(context, volumeScore, Colors.blue)),
        DataCell(_buildScoreCell(context, progressScore, Colors.orange)),
        DataCell(_buildScoreCell(context, consistencyScore, Colors.purple)),
        DataCell(_buildGradeCell(context, grade)),
      ],
    );
  }

  Widget _buildRankCell(BuildContext context, int rank) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _getRankColor(rank),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCell(BuildContext context, String memberName) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            memberName.isNotEmpty ? memberName[0].toUpperCase() : '?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          memberName,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCell(BuildContext context, double score, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        score.toStringAsFixed(1),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildGradeCell(BuildContext context, String grade) {
    final color = _getGradeColor(grade);
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          grade,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  int _getSortColumnIndex() {
    switch (sortBy) {
      case 'rank':
        return 0;
      case 'memberName':
        return 1;
      case 'totalScore':
        return 2;
      case 'balanceScore':
        return 3;
      case 'volumeScore':
        return 4;
      case 'progressScore':
        return 5;
      case 'consistencyScore':
        return 6;
      default:
        return 2;
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[400]!;
      default:
        return Colors.blue;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.purple;
    if (score >= 80) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 60) return Colors.orange;
    if (score >= 50) return Colors.red;
    return Colors.grey;
  }

  String _calculateGrade(double score) {
    if (score >= 90) return 'S';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'F';
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'S':
        return Colors.purple;
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}