import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jfit/core/utils/decimal_text_input_formatter.dart';

class ExerciseSet extends StatefulWidget {
  final Map<String, dynamic> setData;
  final int setIndex;
  final bool isActive;
  final void Function(Map<String, dynamic> updates) onUpdate;
  final VoidCallback onRemove;

  const ExerciseSet({
    super.key,
    required this.setData,
    required this.setIndex,
    required this.onUpdate,
    required this.onRemove,
    this.isActive = false,
  });

  @override
  State<ExerciseSet> createState() => _ExerciseSetState();
}

class _ExerciseSetState extends State<ExerciseSet> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  late FocusNode _weightFocus;
  late FocusNode _repsFocus;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: (widget.setData['weight'] ?? 0) == 0 ? '' : (widget.setData['weight']).toString(),
    );
    _repsController = TextEditingController(
      text: (widget.setData['reps'] ?? 0) == 0 ? '' : (widget.setData['reps']).toString(),
    );
    _weightFocus = FocusNode();
    _repsFocus = FocusNode();

    _weightFocus.addListener(_handleWeightFocusChange);
    _repsFocus.addListener(_handleRepsFocusChange);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _weightFocus.dispose();
    _repsFocus.dispose();
    super.dispose();
  }

  void _handleWeightFocusChange() {
    if (!_weightFocus.hasFocus) {
      final text = _weightController.text;
      if (text.isNotEmpty && !text.contains('.')) {
        final formatted = '$text.0';
        _weightController.text = formatted;
        widget.onUpdate({'weight': double.tryParse(formatted) ?? 0});
      } else {
        // commit current value
        widget.onUpdate({'weight': double.tryParse(text) ?? 0});
      }
    }
  }

  void _handleRepsFocusChange() {
    if (!_repsFocus.hasFocus) {
      final text = _repsController.text;
      widget.onUpdate({'reps': int.tryParse(text) ?? 0});
    }
  }

  @override
  void didUpdateWidget(ExerciseSet oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 값이 실제로 변경된 경우에만 텍스트 업데이트(커서 위치 보존)
    final newWeightValue = widget.setData['weight'] ?? 0;
    final newRepsValue = widget.setData['reps'] ?? 0;

    // 편집 중에는 외부 업데이트로 텍스트 덮어쓰지 않음
    if (!_weightFocus.hasFocus) {
      final newWeightText = newWeightValue == 0 ? '' : newWeightValue.toString();
      if (_weightController.text != newWeightText) {
        _weightController.text = newWeightText;
        _weightController.selection = TextSelection.fromPosition(
          TextPosition(offset: newWeightText.length),
        );
      }
    }

    if (!_repsFocus.hasFocus) {
      final newRepsText = newRepsValue == 0 ? '' : newRepsValue.toString();
      if (_repsController.text != newRepsText) {
        _repsController.text = newRepsText;
        _repsController.selection = TextSelection.fromPosition(
          TextPosition(offset: newRepsText.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = widget.setData['completed'] == true;
    final targetReps = widget.setData['target_reps'];
    final targetWeight = widget.setData['target_weight'];

    String targetText;
    if (targetWeight != null && targetWeight is num && targetWeight > 0) {
      // If weight has decimal part, keep one decimal place; else show as int.
      final String weightStr = (targetWeight % 1 == 0)
          ? targetWeight.toInt().toString()
          : targetWeight.toStringAsFixed(1);
      if (targetReps != null) {
        targetText = '$weightStr kg x $targetReps reps';
      } else {
        targetText = '$weightStr kg';
      }
    } else if (targetReps != null) {
      targetText = '$targetReps reps';
    } else {
      targetText = '(기록 없음)';
    }

    return Dismissible(
      key: widget.key ?? ValueKey(widget.setIndex),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.redAccent.withOpacity(0.8),
        child: const Icon(Icons.close, color: Colors.white, size: 18),
      ),
      child: Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // 30px: 세트 번호
          SizedBox(
            width: 30,
            child: Center(
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: completed
                      ? const Color(0xFF059669) // --set-completed
                      : widget.isActive
                          ? const Color(0xFF6366f1) // --set-active
                          : const Color(0xFF232323),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '${widget.setIndex + 1}',
                    style: TextStyle(
                      color: completed || widget.isActive
                          ? Colors.white
                          : const Color(0xFFa3a3a3),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 1fr: 타겟 정보
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                  targetText,
                style: const TextStyle(
                  color: Color(0xFF737373), // --text-muted
                  fontSize: 14,
                ),
              ),
            ),
          ),

          // 75px: 무게 입력
          SizedBox(
            width: 75,
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: completed
                    ? const Color(0xFF232323).withOpacity(0.5)
                    : const Color(0xFF232323),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: completed
                      ? const Color(0xFF059669).withOpacity(0.3)
                      : widget.isActive
                          ? const Color(0xFF6366f1).withOpacity(0.5)
                          : const Color(0xFF404040),
                  width: 1,
                ),
              ),
              child: TextFormField(
                controller: _weightController,
                  focusNode: _weightFocus,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                enabled: !completed,
                style: TextStyle(
                  color: completed 
                      ? const Color(0xFF737373)
                      : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                  decoration: InputDecoration(
                  border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    hintText: (targetWeight != null && targetWeight > 0)
                        ? ((targetWeight % 1 == 0)
                            ? targetWeight.toInt().toString()
                            : targetWeight.toStringAsFixed(1))
                        : '0',
                    hintStyle: const TextStyle(
                    color: Color(0xFF737373),
                    fontSize: 14,
                  ),
                ),
                inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                  onFieldSubmitted: (value) {
                    final weight = double.tryParse(value) ?? 0;
                  widget.onUpdate({'weight': weight});
                },
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 75px: 횟수 입력
          SizedBox(
            width: 75,
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: completed
                    ? const Color(0xFF232323).withOpacity(0.5)
                    : const Color(0xFF232323),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: completed
                      ? const Color(0xFF059669).withOpacity(0.3)
                      : widget.isActive
                          ? const Color(0xFF6366f1).withOpacity(0.5)
                          : const Color(0xFF404040),
                  width: 1,
                ),
              ),
              child: TextFormField(
                controller: _repsController,
                  focusNode: _repsFocus,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                enabled: !completed,
                style: TextStyle(
                  color: completed 
                      ? const Color(0xFF737373)
                      : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                  decoration: InputDecoration(
                  border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    hintText: targetReps?.toString() ?? '0',
                    hintStyle: const TextStyle(
                    color: Color(0xFF737373),
                    fontSize: 14,
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                  onFieldSubmitted: (value) {
                  final reps = int.tryParse(value) ?? 0;
                  widget.onUpdate({'reps': reps});
                },
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 40px: 완료 버튼
          SizedBox(
            width: 32,
            height: 32,
            child: GestureDetector(
                onTap: () {
                  debugPrint('[DBG] Toggle complete set ${widget.setIndex}');
                  widget.onUpdate({'completed': !completed});
                
                // 햅틱 피드백
                HapticFeedback.lightImpact();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: completed
                      ? const Color(0xFF059669)
                      : Colors.transparent,
                  border: Border.all(
                    color: completed
                        ? const Color(0xFF059669)
                        : const Color(0xFF404040),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: completed
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                            key: ValueKey('check'),
                          )
                        : Container(
                            key: const ValueKey('empty'),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
} 