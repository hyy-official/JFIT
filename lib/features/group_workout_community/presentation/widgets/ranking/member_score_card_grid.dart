import 'package:flutter/material.dart';

class MemberScoreCardGrid extends StatelessWidget {
  final List<Map<String, dynamic>> memberScores;
  final ValueChanged<String>? onMemberTap;

  const MemberScoreCardGrid({
    super.key,
    required this.memberScores,
    this.onMemberTap,
  });

  @override
  Widget build(BuildContext context) {
    if (memberScores.isEmpty) {
      return const Center(
        child: Text('멤버 점수 데이터가 없습니다'),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: memberScores.length,
      itemBuilder: (context, index) {
        final member = memberScores[index];
        final rank = index + 1;
        return _buildMemberCard(context, member, rank);
      },
    );
  }

  Widget _buildMemberCard(BuildContext context, Map<String, dynamic> member, int rank) {
    final memberId = member['memberId'] as String? ?? '';
    final memberName = member['memberName'] as String? ?? 'Unknown';
    final totalScore = member['totalScore'] as double? ?? 0.0;
    final balanceScore = member['balanceScore'] as double? ?? 0.0;
    final volumeScore = member['volumeScore'] as double? ?? 0.0;
    final progressScore = member['progressScore'] as double? ?? 0.0;
    final consistencyScore = member['consistencyScore'] as double? ?? 0.0;
    final grade = _calculateGrade(totalScore);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => onMemberTap?.call(memberId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with rank and member info
              _buildCardHeader(context, memberName, rank, grade),
              const SizedBox(height: 16),
              // Total score
              _buildTotalScore(context, totalScore),
              const SizedBox(height: 16),
              // Score breakdown
              Expanded(child: _buildScoreBreakdown(context, balanceScore, volumeScore, progressScore, consistencyScore)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context, String memberName, int rank, String grade) {
    return Row(
      children: [
        // Rank badge
        Container(
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
        ),
        const SizedBox(width: 12),
        // Member info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                memberName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getGradeColor(grade),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '등급 $grade',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalScore(BuildContext context, double totalScore) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getScoreColor(totalScore),
            _getScoreColor(totalScore).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            totalScore.toStringAsFixed(1),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            '총점',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdown(
    BuildContext context,
    double balanceScore,
    double volumeScore,
    double progressScore,
    double consistencyScore,
  ) {
    final scores = [
      ('균형', balanceScore, Colors.green),
      ('볼륨', volumeScore, Colors.blue),
      ('진전', progressScore, Colors.orange),
      ('일관성', consistencyScore, Colors.purple),
    ];

    return Column(
      children: scores.map((scoreData) {
        final (label, score, color) = scoreData;
        return Expanded(
          child: _buildScoreItem(context, label, score, color),
        );
      }).toList(),
    );
  }

  Widget _buildScoreItem(BuildContext context, String label, double score, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            score.toStringAsFixed(0),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 4;
    if (screenWidth > 800) return 3;
    if (screenWidth > 600) return 2;
    return 1;
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