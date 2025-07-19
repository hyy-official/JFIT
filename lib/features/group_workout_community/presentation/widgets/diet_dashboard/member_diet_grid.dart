import 'package:flutter/material.dart';
import 'package:jfit/core/widgets/responsive_layout.dart';
import 'package:jfit/l10n/app_localizations.dart';
import '../../../domain/entities/pt_group_diet_summary.dart';

/// 멤버 식단 그리드 위젯
/// 그룹 멤버들의 식단 요약을 그리드 형태로 표시
class MemberDietGrid extends StatelessWidget {
  final String groupId;
  final String trainerId;
  final DateTime date;
  final int crossAxisCount;
  final bool isCompact;

  const MemberDietGrid({
    super.key,
    required this.groupId,
    required this.trainerId,
    required this.date,
    required this.crossAxisCount,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // TODO: Get actual data from BLoC
    final mockMembers = _generateMockData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.grid_view,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.memberDiets ?? '멤버 식단 현황',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showAllMembers(context),
              icon: const Icon(Icons.view_list, size: 16),
              label: Text(l10n.viewAll ?? '전체 보기'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: isCompact ? 1.2 : 1.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: mockMembers.length,
          itemBuilder: (context, index) {
            final member = mockMembers[index];
            return _buildMemberCard(context, member, l10n);
          },
        ),
      ],
    );
  }

  Widget _buildMemberCard(BuildContext context, PTGroupDietSummary member, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToMemberDetail(context, member),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 멤버 정보
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Text(
                      member.memberName.isNotEmpty ? member.memberName[0] : '?',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.memberName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _getStatusText(member, l10n),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(member),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusIcon(member),
                ],
              ),
              const SizedBox(height: 12),
              // 칼로리 달성률
              _buildProgressBar(
                context,
                l10n.calories ?? '칼로리',
                member.calorieAchievementRate,
                Colors.orange,
              ),
              const SizedBox(height: 8),
              // 단백질 달성률
              _buildProgressBar(
                context,
                l10n.protein ?? '단백질',
                member.proteinAchievementRate,
                Colors.purple,
              ),
              const SizedBox(height: 8),
              // 추가 정보
              Row(
                children: [
                  Icon(
                    Icons.restaurant,
                    size: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${member.mealCount}끼',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  if (member.hasMealPhotos)
                    Icon(
                      Icons.photo_camera,
                      size: 14,
                      color: Theme.of(context).primaryColor,
                    ),
                  if (member.hasTrainerNote) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.note,
                      size: 14,
                      color: Colors.blue,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: (percentage / 100).clamp(0.0, 1.0),
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 4,
        ),
      ],
    );
  }

  Widget _buildStatusIcon(PTGroupDietSummary member) {
    IconData icon;
    Color color;
    
    switch (member.dietStatus) {
      case '우수':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case '양호':
        icon = Icons.check_circle_outline;
        color = Colors.blue;
        break;
      case '부족':
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case '과다':
        icon = Icons.error;
        color = Colors.red;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
    }
    
    return Icon(icon, color: color, size: 20);
  }

  String _getStatusText(PTGroupDietSummary member, AppLocalizations l10n) {
    switch (member.dietStatus) {
      case '우수':
        return l10n.excellent ?? '우수';
      case '양호':
        return l10n.good ?? '양호';
      case '부족':
        return l10n.insufficient ?? '부족';
      case '과다':
        return l10n.excessive ?? '과다';
      default:
        return l10n.average ?? '보통';
    }
  }

  Color _getStatusColor(PTGroupDietSummary member) {
    switch (member.dietStatus) {
      case '우수':
        return Colors.green;
      case '양호':
        return Colors.blue;
      case '부족':
        return Colors.orange;
      case '과다':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _navigateToMemberDetail(BuildContext context, PTGroupDietSummary member) {
    Navigator.pushNamed(
      context,
      '/member-diet-detail',
      arguments: {
        'groupId': groupId,
        'memberId': member.memberId,
        'trainerId': trainerId,
        'initialDate': date,
      },
    );
  }

  void _showAllMembers(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/group-members-diet',
      arguments: {
        'groupId': groupId,
        'trainerId': trainerId,
        'date': date,
      },
    );
  }

  List<PTGroupDietSummary> _generateMockData() {
    return [
      PTGroupDietSummary(
        id: '1',
        groupId: groupId,
        memberId: 'member1',
        memberName: '김철수',
        summaryDate: date,
        totalCalories: 2100,
        totalProtein: 120,
        totalCarbs: 250,
        totalFat: 70,
        mealCount: 4,
        calorieGoal: 2200,
        proteinGoal: 130,
        mealPhotoUrls: ['photo1.jpg', 'photo2.jpg'],
        trainerNote: '잘하고 있습니다',
        lastMealTime: DateTime.now().subtract(const Duration(hours: 2)),
        // trainerId: trainerId, // Remove this parameter
      ),
      PTGroupDietSummary(
        id: '2',
        groupId: groupId,
        memberId: 'member2',
        memberName: '이영희',
        summaryDate: date,
        totalCalories: 1800,
        totalProtein: 90,
        totalCarbs: 200,
        totalFat: 60,
        mealCount: 3,
        calorieGoal: 2000,
        proteinGoal: 100,
        mealPhotoUrls: [],
        trainerNote: null,
        lastMealTime: DateTime.now().subtract(const Duration(hours: 4)),
        // trainerId: trainerId, // Remove this parameter
      ),
      PTGroupDietSummary(
        id: '3',
        groupId: groupId,
        memberId: 'member3',
        memberName: '박민수',
        summaryDate: date,
        totalCalories: 2500,
        totalProtein: 150,
        totalCarbs: 300,
        totalFat: 90,
        mealCount: 5,
        calorieGoal: 2300,
        proteinGoal: 140,
        mealPhotoUrls: ['photo3.jpg'],
        trainerNote: '칼로리 조절 필요',
        lastMealTime: DateTime.now().subtract(const Duration(hours: 1)),
        // trainerId: trainerId, // Remove this parameter
      ),
    ];
  }
}