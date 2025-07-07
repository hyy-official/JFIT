import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:jfit/core/theme/nutrition_input_theme.dart';
import 'package:jfit/models/nutrition_info.dart';
import 'package:jfit/core/utils/responsive_utils.dart';

/// 영양성분 수동 입력 전용 페이지
/// 사용자가 직접 모든 영양성분을 입력하는 화면
class NutritionManualInputScreen extends StatefulWidget {
  final NutritionInfo? initial;

  const NutritionManualInputScreen({super.key, this.initial});

  @override
  State<NutritionManualInputScreen> createState() => _NutritionManualInputScreenState();
}

class _NutritionManualInputScreenState extends State<NutritionManualInputScreen> {
  late NutritionInfo _info;
  final _numberFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'));
  
  // 입력 필드 컨트롤러들
  late TextEditingController _foodNameController;
  late TextEditingController _totalSizeController;
  late TextEditingController _energyController;
  late TextEditingController _proteinController;
  late TextEditingController _fatController;
  late TextEditingController _carbsController;

  @override
  void initState() {
    super.initState();
    
    _info = widget.initial ?? NutritionInfo();
    
    // 컨트롤러 초기화
    _foodNameController = TextEditingController(text: _info.foodName);
    _totalSizeController = TextEditingController(text: _info.totalSize == 0 ? '' : _info.totalSize.toStringAsFixed(1));
    _energyController = TextEditingController(text: _info.calories == 0 ? '' : _info.calories.toStringAsFixed(1));
    _proteinController = TextEditingController(text: _info.protein == 0 ? '' : _info.protein.toStringAsFixed(1));
    _fatController = TextEditingController(text: _info.fat == 0 ? '' : _info.fat.toStringAsFixed(1));
    _carbsController = TextEditingController(text: _info.carbs == 0 ? '' : _info.carbs.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _totalSizeController.dispose();
    _energyController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = context.isDesktop ? BorderRadius.circular(24) : const BorderRadius.vertical(top: Radius.circular(24));
    return ClipRRect(
      borderRadius: radius,
      child: Scaffold(
        backgroundColor: NutritionInputTheme.screenBackground,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  '영양성분 직접 입력',
                  style: const TextStyle(
                    color: NutritionInputTheme.primaryTextColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextInput(
                  label: '음식명',
                  controller: _foodNameController,
                  onChanged: (v) => setState(() => _info.foodName = v),
                ),
                const SizedBox(height: 16),
                _buildNutritionInputRow(
                  label: '총 중량',
                  unit: 'g',
                  controller: _totalSizeController,
                  onChanged: (v) => setState(() => _info.totalSize = v),
                ),
                const SizedBox(height: 24),
                _buildNutritionInputRow(
                  label: '칼로리',
                  unit: 'kcal',
                  controller: _energyController,
                  onChanged: (v) => setState(() => _info.calories = v),
                ),
                _buildNutritionInputRow(
                  label: '탄수화물',
                  unit: 'g',
                  controller: _carbsController,
                  onChanged: (v) => setState(() => _info.carbs = v),
                ),
                _buildNutritionInputRow(
                  label: '단백질',
                  unit: 'g',
                  controller: _proteinController,
                  onChanged: (v) => setState(() => _info.protein = v),
                ),
                _buildNutritionInputRow(
                  label: '지방',
                  unit: 'g',
                  controller: _fatController,
                  onChanged: (v) => setState(() => _info.fat = v),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _info.isValid ? () {
                      // totalSize(중량)가 0이면 weight를 설정하지 않음
                      if (_info.totalSize > 0) {
                        _info.weight = _info.totalSize;
                      }
                      Navigator.pop(context, _info);
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _info.isValid ? NutritionInputTheme.accentColor : NutritionInputTheme.inputBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '저장',
                      style: TextStyle(
                        color: _info.isValid ? Colors.white : NutritionInputTheme.secondaryTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: NutritionInputTheme.screenBackground,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Container(
        width: 48,
        height: 5,
        decoration: BoxDecoration(
          color: NutritionInputTheme.inputBackground,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      leading: const SizedBox.shrink(),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: NutritionInputTheme.primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildTextInput({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: NutritionInputTheme.labelStyle),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: NutritionInputTheme.valueStyle.copyWith(
            color: NutritionInputTheme.primaryTextColor,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: NutritionInputTheme.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildNutritionInputRow({
    required String label,
    required String unit,
    required TextEditingController controller,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: Text(label, style: NutritionInputTheme.labelStyle)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_numberFormatter],
              textAlign: TextAlign.right,
              style: NutritionInputTheme.valueStyle.copyWith(
                color: NutritionInputTheme.primaryTextColor,
              ),
              decoration: InputDecoration(
                suffixText: unit,
                suffixStyle: NutritionInputTheme.labelStyle.copyWith(
                  color: NutritionInputTheme.primaryTextColor,
                ),
                filled: true,
                fillColor: NutritionInputTheme.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => onChanged(double.tryParse(v) ?? 0.0),
            ),
          ),
        ],
      ),
    );
  }
} 