import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/features/programs/presentation/bloc/programs_bloc.dart';
import 'package:jfit/features/programs/presentation/bloc/programs_event.dart';
import 'package:jfit/features/programs/presentation/bloc/programs_state.dart';
import 'program_detail_sheet.dart';
import '../../bloc/record_bloc.dart';
import '../../bloc/record_event.dart';

class ExerciseRoutineCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String desc;
  final String imageUrl;
  final String userProgramId;
  final int currentWeek;
  final int currentDay;
  final double progress;
  final bool isRestDay;
  final VoidCallback? onReturn; // 돌아올 때 콜백

  const ExerciseRoutineCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.desc,
    required this.imageUrl,
    required this.userProgramId,
    required this.currentWeek,
    required this.currentDay,
    required this.progress,
    required this.isRestDay,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // ProgramDetailSheet 모달로 표시
        final isDesktop = MediaQuery.of(context).size.width > 600;
        final programsBloc = context.read<ProgramsBloc>();
        
        if (isDesktop) {
          showDialog(
            context: context,
            builder: (context) => Center(
              child: SizedBox(
                width: 600,
                child: BlocProvider.value(
                  value: programsBloc,
                  child: ProgramDetailSheet(
                    programName: title,
                    progressPercent: progress * 100,
                    userProgramId: userProgramId,
                  ),
                ),
              ),
            ),
          );
        } else {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => BlocProvider.value(
              value: programsBloc,
              child: ProgramDetailSheet(
                programName: title,
                progressPercent: progress * 100,
                userProgramId: userProgramId,
              ),
            ),
          );
        }
        
        // 돌아왔을 때 콜백 호출
        if (onReturn != null) {
          onReturn!();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.programCardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isRestDay ? AppTheme.textMuted : AppTheme.textSub,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 진행률 표시
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.textMuted.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isRestDay ? AppTheme.textMuted : AppTheme.programAccentBlue,
                    ),
                    minHeight: 3,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}% 진행',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // 메뉴 버튼
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteDialog(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('삭제', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              icon: Icon(
                Icons.more_vert,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(width: 8),
            // 이미지 또는 아이콘
            _buildImageWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (imageUrl.isEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: AppTheme.programBackground,
        child: Icon(
          Icons.fitness_center,
          color: AppTheme.textMuted,
          size: 24,
        ),
      );
    }

    return CircleAvatar(
      radius: 28,
      backgroundColor: AppTheme.programBackground,
      child: ClipOval(
        child: Image.network(
          imageUrl,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 56,
              height: 56,
              color: AppTheme.programBackground,
              child: Icon(
                Icons.image_not_supported,
                color: AppTheme.textMuted,
                size: 24,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 56,
              height: 56,
              color: AppTheme.programBackground,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                  color: AppTheme.textMuted,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('프로그램 삭제'),
          content: Text('정말로 "$title" 프로그램을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<RecordBloc>().add(
                  DeleteUserProgram(userProgramId: userProgramId),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }
} 