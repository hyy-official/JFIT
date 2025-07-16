import 'package:flutter/material.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:jfit/core/utils/responsive_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:get_it/get_it.dart';
import 'package:jfit/core/services/supabase_service.dart';

/// 신체 정보 입력 시트 컨텐츠
class BodyAddSheetContent extends StatefulWidget {
  final DateTime selectedDate;

  const BodyAddSheetContent({super.key, required this.selectedDate});

  @override
  State<BodyAddSheetContent> createState() => _BodyAddSheetContentState();
}

class _BodyAddSheetContentState extends State<BodyAddSheetContent> {
  final _weightController = TextEditingController();
  final _muscleController = TextEditingController();
  final _fatController = TextEditingController();
  final _sleepController = TextEditingController();
  final _wakeController = TextEditingController();
  final _memoController = TextEditingController();

  int _bowelCount = 0;
  int _conditionIndex = -1; // -1 = none, 0~4 worst~best
  bool _menstruation = false;
  bool _lifestyleExpanded = true;

  final SupabaseService _supabaseService = GetIt.instance<SupabaseService>();

  // 마스킹 포맷터 (데스크톱용)
  final MaskTextInputFormatter _timeMask = MaskTextInputFormatter(
    mask: '##:##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _weightController.dispose();
    _muscleController.dispose();
    _fatController.dispose();
    _sleepController.dispose();
    _wakeController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy년 MM월 dd일').format(widget.selectedDate);

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHandlebar(),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text('$formattedDate 신체',
                  style: TextStyle(color: context.colors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBodySection(),
                    const SizedBox(height: 24),
                    _buildLifestyleSection(),
                    const SizedBox(height: 24),
                    _buildMemoSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _onSave,
                  child: Text('저장하기', style: TextStyle(color: context.colors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandlebar() => Container(
        width: 48,
        height: 5,
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: context.colors.borderVariant,
          borderRadius: BorderRadius.circular(4),
        ),
      );

  Widget _buildBodySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('신체 기록',
            style: TextStyle(color: context.colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _buildInputRow('체중', 'kg', _weightController),
        const SizedBox(height: 12),
        _buildInputRow('골격근량', 'kg', _muscleController),
        const SizedBox(height: 12),
        _buildInputRow('체지방률', '%', _fatController),
        const SizedBox(height: 24),
        Text('눈바디',
            style: TextStyle(color: context.colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {},
          child: DottedBorderWidget(
            child: SizedBox(
              height: 140,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, color: context.colors.textMuted, size: 32),
                    const SizedBox(height: 8),
                    Text('사진 추가', style: TextStyle(color: context.colors.textMuted)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputRow(String label, String unit, TextEditingController controller) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: TextStyle(color: context.colors.textSecondary, fontSize: 14)),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: context.colors.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: '입력하기',
              hintStyle: TextStyle(color: context.colors.textMuted),
              filled: true,
              fillColor: context.colors.surfaceVariant.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(unit, style: TextStyle(color: context.colors.textSecondary)),
      ],
    );
  }

  Widget _buildLifestyleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _lifestyleExpanded = !_lifestyleExpanded),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('생활 기록',
                  style: TextStyle(color: context.colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
              Icon(_lifestyleExpanded ? Icons.remove : Icons.add, color: context.colors.textMuted),
            ],
          ),
        ),
        if (_lifestyleExpanded) ...[
          const SizedBox(height: 16),
          _buildConditionChips(),
          const SizedBox(height: 16),
          _buildTimeInputRow('취침 시간', _sleepController),
          const SizedBox(height: 12),
          _buildTimeInputRow('기상 시간', _wakeController),
          const SizedBox(height: 12),
          _buildBowelRow(),
          const SizedBox(height: 12),
          _buildMenstruationRow(),
        ],
      ],
    );
  }

  Widget _buildConditionChips() {
    const labels = ['최악', '나쁨', '보통', '좋음', '최상'];
    return Wrap(
      spacing: 8,
      children: List.generate(labels.length, (i) {
        final selected = _conditionIndex == i;
        return ChoiceChip(
          label: Text(labels[i]),
          selected: selected,
          selectedColor: context.colors.primary,
          onSelected: (_) => setState(() => _conditionIndex = i),
        );
      }),
    );
  }

  Widget _buildTimeInputRow(String label, TextEditingController controller) {
    final isDesktop = context.isDesktop;

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: TextStyle(color: context.colors.textSecondary, fontSize: 14)),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            readOnly: !isDesktop,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: '입력하기',
              hintStyle: TextStyle(color: context.colors.textMuted),
              filled: true,
              fillColor: context.colors.surfaceVariant.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onTap: () async {
              if (!isDesktop) {
                _showWheelTimePicker(controller);
              }
            },
            onChanged: isDesktop
                ? (val) {
                    if (_timeMask.isFill()) {
                      final parts = val.split(':');
                      final h = int.tryParse(parts[0]);
                      final m = int.tryParse(parts[1]);
                      if (h != null && m != null && h < 24 && m < 60) {
                        // valid time, nothing else
                      }
                    }
                  }
                : null,
            inputFormatters: isDesktop ? [_timeMask] : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBowelRow() {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text('배변', style: TextStyle(color: context.colors.textSecondary, fontSize: 14)),
        ),
        IconButton(
          icon: Icon(Icons.remove, color: context.colors.textMuted),
          onPressed: _bowelCount > 0 ? () => setState(() => _bowelCount--) : null,
        ),
        Text('$_bowelCount회', style: TextStyle(color: context.colors.textPrimary)),
        IconButton(
          icon: Icon(Icons.add, color: context.colors.textMuted),
          onPressed: () => setState(() => _bowelCount++),
        ),
      ],
    );
  }

  Widget _buildMenstruationRow() {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text('월경', style: TextStyle(color: context.colors.textSecondary, fontSize: 14)),
        ),
        Switch(
          value: _menstruation,
          onChanged: (val) => setState(() => _menstruation = val),
        ),
        const SizedBox(width: 8),
        Text(_menstruation ? '진행 중' : '없음', style: TextStyle(color: context.colors.textPrimary)),
      ],
    );
  }

  Widget _buildMemoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('메모',
            style: TextStyle(color: context.colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        TextField(
          controller: _memoController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: '기분, 컨디션, 몸 상태 등을 자유롭게 입력해 주세요',
            hintStyle: TextStyle(color: context.colors.textMuted),
            filled: true,
            fillColor: context.colors.surfaceVariant.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  void _onSave() {
    // 기본 유효성: 체중, 근육, 체지방 중 하나는 입력
    if (_weightController.text.isEmpty && _muscleController.text.isEmpty && _fatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('체중 등 신체 데이터를 입력해 주세요')));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      _supabaseService.saveBodyMeasurement(
        measuredDate: widget.selectedDate,
        weight: double.tryParse(_weightController.text),
        muscleMass: double.tryParse(_muscleController.text),
        bodyFatPercentage: double.tryParse(_fatController.text),
        conditionRating: _conditionIndex >= 0 ? _conditionIndex : null,
        sleepTime: _sleepController.text.isNotEmpty ? _parseTime(_sleepController.text) : null,
        wakeTime: _wakeController.text.isNotEmpty ? _parseTime(_wakeController.text) : null,
        bowelCount: _bowelCount,
        menstruation: _menstruation,
        memo: _memoController.text,
        // photo upload 별도 TODO
      ).then((_) {
        Navigator.of(context)
          ..pop() // loading
          ..pop(); // sheet
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('신체 정보가 저장되었습니다'), backgroundColor: context.colors.success));
      });
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
    }
  }

  DateTime _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    return DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day, h, m);
  }

  void _showWheelTimePicker(TextEditingController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        // 기본 시간을 현재 텍스트필드 값 또는 현재 시간으로 설정
        DateTime initial = DateTime.now();
        if (controller.text.isNotEmpty && RegExp(r'^\d{1,2}:\d{2}').hasMatch(controller.text)) {
          final parts = controller.text.split(':');
          final h = int.tryParse(parts[0]);
          final m = int.tryParse(parts[1]);
          if (h != null && m != null) {
            initial = DateTime(2020, 1, 1, h, m);
          }
        }

        DateTime tempTime = initial;

        return SizedBox(
          height: 260,
          child: Column(
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: initial,
                  onDateTimeChanged: (dt) {
                    tempTime = dt;
                    controller.text = DateFormat('HH:mm').format(dt);
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('완료', style: TextStyle(color: context.colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    foregroundColor: context.colors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Simple dotted border wrapper using CustomPaint (avoiding extra dependency if dotted_border not added)
class DottedBorderWidget extends StatelessWidget {
  final Widget child;
  const DottedBorderWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border, width: 1, style: BorderStyle.solid),
      ),
      child: child,
    );
  }
} 