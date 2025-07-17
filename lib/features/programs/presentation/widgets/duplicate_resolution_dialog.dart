import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/workout_program_failures.dart';
import '../bloc/programs_bloc.dart';
import '../bloc/programs_event.dart';

/// 중복 프로그램 해결을 위한 다이얼로그
class DuplicateResolutionDialog extends StatelessWidget {
  final ProgramDuplicateInfo duplicateInfo;
  final String templateProgramId;

  const DuplicateResolutionDialog({
    super.key,
    required this.duplicateInfo,
    required this.templateProgramId,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        '중복된 프로그램',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이미 "${duplicateInfo.programName}" 프로그램을 진행 중입니다.',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '현재 진행 상황',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      duplicateInfo.progressText,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(duplicateInfo.status),
                      size: 16,
                      color: _getStatusColor(duplicateInfo.status),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      duplicateInfo.statusText,
                      style: TextStyle(
                        fontSize: 14,
                        color: _getStatusColor(duplicateInfo.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '어떻게 하시겠습니까?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: _buildActionButtons(context),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final availableOptions = duplicateInfo.availableOptions;
    final buttons = <Widget>[];

    for (final option in availableOptions) {
      buttons.add(
        _buildOptionButton(
          context: context,
          option: option,
          text: option.displayText,
          description: option.description,
        ),
      );
    }

    return buttons;
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required ResolutionOption option,
    required String text,
    required String description,
  }) {
    Color buttonColor;
    Color textColor;
    
    switch (option) {
      case ResolutionOption.continueExisting:
        buttonColor = Colors.green;
        textColor = Colors.white;
        break;
      case ResolutionOption.restartProgram:
        buttonColor = Colors.orange;
        textColor = Colors.white;
        break;
      case ResolutionOption.createNewInstance:
        buttonColor = Colors.blue;
        textColor = Colors.white;
        break;
      case ResolutionOption.cancel:
        buttonColor = Colors.grey;
        textColor = Colors.white;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _handleOptionSelected(context, option),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: textColor,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleOptionSelected(BuildContext context, ResolutionOption option) {
    Navigator.of(context).pop();
    
    if (option == ResolutionOption.cancel) {
      context.read<ProgramsBloc>().add(const CancelDuplicateResolution());
    } else {
      context.read<ProgramsBloc>().add(
        ResolveDuplicateProgram(
          templateProgramId: templateProgramId,
          userProgramId: duplicateInfo.userProgramId,
          option: option,
        ),
      );
    }
  }

  IconData _getStatusIcon(ProgramStatus status) {
    switch (status) {
      case ProgramStatus.active:
        return Icons.play_circle_filled;
      case ProgramStatus.completed:
        return Icons.check_circle;
      case ProgramStatus.paused:
        return Icons.pause_circle_filled;
    }
  }

  Color _getStatusColor(ProgramStatus status) {
    switch (status) {
      case ProgramStatus.active:
        return Colors.green;
      case ProgramStatus.completed:
        return Colors.blue;
      case ProgramStatus.paused:
        return Colors.orange;
    }
  }

  /// 다이얼로그를 표시하는 정적 메서드
  static Future<void> show({
    required BuildContext context,
    required ProgramDuplicateInfo duplicateInfo,
    required String templateProgramId,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 외부 터치로 닫기 방지
      builder: (context) => DuplicateResolutionDialog(
        duplicateInfo: duplicateInfo,
        templateProgramId: templateProgramId,
      ),
    );
  }
}