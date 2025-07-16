import 'package:flutter/material.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/l10n/app_localizations.dart';

class AddExerciseModal extends StatefulWidget {
  final Function(String exerciseName) onAdd;
  final VoidCallback? onCancel;

  const AddExerciseModal({
    super.key,
    required this.onAdd,
    this.onCancel,
  });

  @override
  State<AddExerciseModal> createState() => _AddExerciseModalState();
}

class _AddExerciseModalState extends State<AddExerciseModal> {
  final TextEditingController _exerciseController = TextEditingController();

  @override
  void dispose() {
    _exerciseController.dispose();
    super.dispose();
  }

  void _addExercise() {
    final exerciseName = _exerciseController.text.trim();
    if (exerciseName.isNotEmpty) {
      widget.onAdd(exerciseName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(
            maxWidth: 400,
            maxHeight: 300,
          ),
          decoration: BoxDecoration(
            color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.colors.background.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                        const SizedBox(height: 24),
                _buildExerciseInput(),
                        const SizedBox(height: 24),
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.colors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.fitness_center,
            color: context.colors.textPrimary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
                 Text(
            AppLocalizations.of(context)?.exerciseAdd ?? 'Add Exercise',
            style: TextStyle(
              color: context.colors.textPrimary,
            fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        const Spacer(),
                IconButton(
                  onPressed: () {
                    widget.onCancel?.call();
                  },
          icon: Icon(Icons.close, color: context.colors.textMuted, size: 24),
                ),
              ],
    );
  }

  Widget _buildExerciseInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.exerciseEnterName ?? 'Exercise Name',
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
          child: TextField(
            controller: _exerciseController,
            style: TextStyle(color: context.colors.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: '예: 벤치 프레스, 스쿼트, 데드리프트...',
              hintStyle: TextStyle(color: context.colors.textMuted, fontSize: 16),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            onSubmitted: (_) => _addExercise(),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              widget.onCancel?.call();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: context.colors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '취소',
                        style: TextStyle(
                          color: context.colors.textMuted,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
            Expanded(
          child: ElevatedButton(
            onPressed: _addExercise,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '추가',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              ),
            ),
        ),
      ],
    );
  }
}