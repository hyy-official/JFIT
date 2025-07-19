import 'package:flutter/material.dart';
import '../../../domain/entities/user_workout_score.dart';
import '../../../domain/entities/group_ranking.dart';

class UserScoreOverviewCard extends StatelessWidget {
  final UserWorkoutScore userScore;
  final RankingPeriod period;

  const UserScoreOverviewCard({
    super.key,
    required this.userScore,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main score display
        _buildMainScoreDisplay(context),
        const SizedBox(height: 16),
        // Score components
        _buildScoreComponents(context),
        const SizedBox(height: 16),
        // Grade and status
        _buildGradeAndStatus(context),
      ],
    );
  }

  Widget _buildMainScoreDisplay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getScoreColor(userScore.totalScore),
            _getScoreColor(userScore.totalScore).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '${userScore.totalScore.toStringAsFixed(1)}',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '총점',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '등급 ${userScore.scoreGrade}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreComponents(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildScoreComponent(
            context,
            '균형',
            userScore.bodyBalanceScore,
            Icons.balance,
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildScoreComponent(
            context,
            '볼륨',
            userScore.volumeScore,
            Icons.fitness_center,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildScoreComponent(
            context,
            '진전',
            userScore.progressScore,
            Icons.trending_up,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildScoreComponent(
            context,
            '일관성',
            userScore.consistencyScore,
            Icons.schedule,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreComponent(
    BuildContext context,
    String label,
    double score,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            score.toStringAsFixed(0),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildGradeAndStatus(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatusItem(
            context,
            '운동 균형',
            userScore.isBalanced ? '균형잡힘' : '불균형',
            userScore.isBalanced ? Icons.check_circle : Icons.warning,
            userScore.isBalanced ? Colors.green : Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusItem(
            context,
            '성과 수준',
            userScore.isExcellent ? '우수' : userScore.isGood ? '양호' : '개선 필요',
            userScore.isExcellent ? Icons.star : userScore.isGood ? Icons.thumb_up : Icons.trending_up,
            userScore.isExcellent ? Colors.purple : userScore.isGood ? Colors.blue : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.purple;
    if (score >= 80) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 60) return Colors.orange;
    if (score >= 50) return Colors.red;
    return Colors.grey;
  }
}