import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/core/theme/second_theme.dart';
import 'package:jfit/features/programs/data/models/user_program_day_model.dart';
import 'package:jfit/features/programs/data/models/workout_session_model.dart';

/// 운동 시작 버튼 위젯
class StartWorkoutButton extends StatelessWidget {
  final List<UserProgramDayModel> weekDays;
  final int selectedDay;
  final UserProgramDayModel? selectedDayObj;
  final WorkoutSessionModel? session;
  final VoidCallback? onPressed;

  const StartWorkoutButton({
    super.key,
    required this.weekDays,
    required this.selectedDay,
    required this.selectedDayObj,
    required this.session,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // 선택된 일차가 유효한지 확인
    final isValidSelection = weekDays.isNotEmpty && 
                           selectedDay < weekDays.length && 
                           selectedDayObj != null && 
                           weekDays[selectedDay] == selectedDayObj;
    
    // 선택된 일차가 완료되었는지 확인
    final isCompleted = selectedDayObj?.completedAt != null;
    
    // 버튼 활성화 조건: 유효한 선택 + 세션 존재 + 미완료 상태
    final isEnabled = isValidSelection && session != null && !isCompleted;
    
    // 버튼 텍스트 결정
    String buttonText;
    if (isCompleted) {
      buttonText = 'Day${selectedDayObj?.day ?? ''} 완료됨';
    } else if (session == null) {
      buttonText = 'Day${selectedDayObj?.day ?? ''} 세션 없음';
    } else {
      buttonText = 'Day${selectedDayObj?.day ?? ''} 시작하기';
    }

    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: isEnabled ? AppTheme.accentGradient : null,
        color: isEnabled ? null : SecondTheme.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: isEnabled
            ? null
            : Border.all(
                color: SecondTheme.border,
                width: 1,
              ),
      ),
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: isEnabled ? Colors.white : SecondTheme.textMuted,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.play_arrow,
              color: isEnabled ? Colors.white : SecondTheme.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}