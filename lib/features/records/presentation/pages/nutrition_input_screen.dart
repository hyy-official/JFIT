import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:jfit/core/theme/nutrition_input_theme.dart';
import 'package:jfit/models/nutrition_info.dart';

class NutritionInputScreen extends StatefulWidget {
  final NutritionInfo initial;
  NutritionInputScreen({super.key, NutritionInfo? initial}) : initial = initial ?? NutritionInfo();

  @override
  State<NutritionInputScreen> createState() => _NutritionInputScreenState();
}

class _NutritionInputScreenState extends State<NutritionInputScreen> {
  late NutritionInfo _info;
  final _numberFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'));
  late double _baseSize;
  late bool _isCalculatorMode; // DB 데이터 기반 계산기 모드 여부
  
  // 계산기 모드를 위한 원본 표준 영양 정보 (100g당 또는 표준량당)
  late double _baseCalories;
  late double _baseProtein;
  late double _baseCarbs;
  late double _baseFat;
  late double _standardSize;
  
  // 입력 필드 컨트롤러들 - 포커스 유지를 위해 상태로 관리
  late TextEditingController _totalSizeController;
  late TextEditingController _energyController;
  late TextEditingController _proteinController;
  late TextEditingController _fatController;
  late TextEditingController _carbsController;

  @override
  void initState() {
    super.initState();
    _info = NutritionInfo(
      foodName: widget.initial.foodName,
      servingSize: widget.initial.servingSize,
      totalSize: widget.initial.totalSize,
      calories: widget.initial.calories,
      carbs: widget.initial.carbs,
      protein: widget.initial.protein,
      fat: widget.initial.fat,
    );
    _baseSize = _info.totalSize == 0 ? 100.0 : _info.totalSize;
    
    // DB에서 온 데이터인지 확인 (음식명 + 영양정보가 모두 있으면 계산기 모드)
    _isCalculatorMode = widget.initial.foodName.isNotEmpty && 
                       widget.initial.calories > 0 && 
                       widget.initial.servingSize > 0;
    
    if (_isCalculatorMode) {
      // 표준량 기준 영양정보 저장 (계산의 기준점)
      _standardSize = widget.initial.servingSize;
      _baseCalories = widget.initial.calories;
      _baseProtein = widget.initial.protein;
      _baseCarbs = widget.initial.carbs;
      _baseFat = widget.initial.fat;
    }
    
    // 컨트롤러 초기화 - 포커스 유지를 위해
    _totalSizeController = TextEditingController(text: _info.totalSize == 0 ? '' : _info.totalSize.toStringAsFixed(1));
    _energyController = TextEditingController(text: _info.calories == 0 ? '' : _info.calories.toStringAsFixed(1));
    _proteinController = TextEditingController(text: _info.protein == 0 ? '' : _info.protein.toStringAsFixed(1));
    _fatController = TextEditingController(text: _info.fat == 0 ? '' : _info.fat.toStringAsFixed(1));
    _carbsController = TextEditingController(text: _info.carbs == 0 ? '' : _info.carbs.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _totalSizeController.dispose();
    _energyController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  void _recalculateNutrition() {
    if (!_isCalculatorMode) return;
    
    // 현재 중량 기준으로 영양성분 재계산
    final ratio = _info.totalSize / _standardSize;
    setState(() {
      _info.calories = _baseCalories * ratio;
      _info.protein = _baseProtein * ratio;
      _info.carbs = _baseCarbs * ratio;
      _info.fat = _baseFat * ratio;
      _info.servingSize = _info.totalSize; // 섭취량 = 총중량으로 동기화
      
      // 컨트롤러 텍스트도 업데이트 (계산기 모드에서는 읽기 전용이므로)
      _energyController.text = _info.calories.toStringAsFixed(1);
      _proteinController.text = _info.protein.toStringAsFixed(1);
      _carbsController.text = _info.carbs.toStringAsFixed(1);
      _fatController.text = _info.fat.toStringAsFixed(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutritionInputTheme.screenBackground,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isCalculatorMode) _buildCalculatorHeader(),
              _buildTextInput(
                label: '음식명',
                initialValue: _info.foodName,
                onChanged: (v) => setState(() => _info.foodName = v),
                enabled: !_isCalculatorMode, // 계산기 모드에서는 음식명 수정 불가
              ),
              const SizedBox(height: 16),
              _buildNutritionInputRowWithController(
                label: '총 중량',
                unit: 'g',
                controller: _totalSizeController,
                onChanged: (v) {
                  setState(() {
                    _info.totalSize = v;
                    _baseSize = v;
                  });
                  if (_isCalculatorMode) {
                    _recalculateNutrition();
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_isCalculatorMode) _buildFractionRow(),
              const SizedBox(height: 24),
              _buildNutritionInputRowWithController(
                label: '칼로리',
                unit: 'kcal',
                controller: _energyController,
                onChanged: (v) => setState(() => _info.calories = v),
                readOnly: _isCalculatorMode,
              ),
              _buildNutritionInputRowWithController(
                label: '탄수화물', 
                unit: 'g', 
                controller: _carbsController,
                onChanged: (v) => setState(() => _info.carbs = v),
                readOnly: _isCalculatorMode,
              ),
              _buildNutritionInputRowWithController(
                label: '단백질', 
                unit: 'g', 
                controller: _proteinController,
                onChanged: (v) => setState(() => _info.protein = v),
                readOnly: _isCalculatorMode,
              ),
              _buildNutritionInputRowWithController(
                label: '지방', 
                unit: 'g', 
                controller: _fatController,
                onChanged: (v) => setState(() => _info.fat = v),
                readOnly: _isCalculatorMode,
              ),
              if (_isCalculatorMode) const SizedBox(height: 16),
              if (_isCalculatorMode) _buildCalculatorInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalculatorHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: NutritionInputTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NutritionInputTheme.accentColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.calculator, color: NutritionInputTheme.accentColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '계산기 모드: 중량 변경 시 영양성분이 자동 계산됩니다',
              style: TextStyle(
                color: NutritionInputTheme.accentColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NutritionInputTheme.inputBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기준 정보 (${_standardSize.toStringAsFixed(0)}g당)',
            style: TextStyle(
              color: NutritionInputTheme.secondaryTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_baseCalories.toStringAsFixed(0)} kcal | '
            '탄 ${_baseCarbs.toStringAsFixed(1)}g | '
            '단 ${_baseProtein.toStringAsFixed(1)}g | '
            '지 ${_baseFat.toStringAsFixed(1)}g',
            style: TextStyle(
              color: NutritionInputTheme.secondaryTextColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: NutritionInputTheme.screenBackground,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.x),
        color: NutritionInputTheme.primaryTextColor,
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Text(
        _isCalculatorMode ? '영양성분 계산기' : '영양성분 입력',
        style: const TextStyle(
          color: NutritionInputTheme.primaryTextColor, 
          fontSize: 18, 
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _info.isValid ? () => Navigator.pop(context, _info) : null,
          child: Text(
            '저장', 
            style: TextStyle(
              color: _info.isValid ? NutritionInputTheme.accentColor : NutritionInputTheme.secondaryTextColor, 
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildTextInput({
    required String label, 
    required String initialValue, 
    required ValueChanged<String> onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: NutritionInputTheme.labelStyle),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: initialValue),
          style: NutritionInputTheme.valueStyle.copyWith(
            color: enabled ? NutritionInputTheme.primaryTextColor : NutritionInputTheme.secondaryTextColor,
          ),
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? NutritionInputTheme.inputBackground : NutritionInputTheme.inputBackground.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildNutritionInputRowWithController({
    required String label, 
    required String unit, 
    required TextEditingController controller,
    required ValueChanged<double> onChanged,
    bool readOnly = false,
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
              readOnly: readOnly,
              style: NutritionInputTheme.valueStyle.copyWith(
                color: readOnly ? NutritionInputTheme.secondaryTextColor : NutritionInputTheme.primaryTextColor,
              ),
              decoration: InputDecoration(
                suffixText: unit,
                suffixStyle: NutritionInputTheme.labelStyle.copyWith(
                  color: readOnly ? NutritionInputTheme.secondaryTextColor : NutritionInputTheme.primaryTextColor,
                ),
                filled: true,
                fillColor: readOnly 
                    ? NutritionInputTheme.inputBackground.withOpacity(0.5)
                    : NutritionInputTheme.inputBackground,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: readOnly ? null : (v) => onChanged(double.tryParse(v) ?? 0.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFractionRow() {
    final fractions = [
      {'label': '¼', 'value': 0.25},
      {'label': '⅓', 'value': 1 / 3},
      {'label': '½', 'value': 0.5},
      {'label': '⅔', 'value': 2 / 3},
      {'label': '전체', 'value': 1.0},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('분량 선택', style: NutritionInputTheme.labelStyle),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: fractions.map((f) {
            final bool isWhole = f['value'] == 1.0;
            final targetWeight = (_baseSize * (f['value'] as double)).roundToDouble();
            final isSelected = (_info.totalSize - targetWeight).abs() < 0.1;
            
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _info.totalSize = targetWeight;
                      _totalSizeController.text = targetWeight.toStringAsFixed(1);
                    });
                    _recalculateNutrition();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: isSelected 
                        ? NutritionInputTheme.accentColor.withOpacity(0.2)
                        : NutritionInputTheme.inputBackground,
                    side: BorderSide(
                      color: isSelected 
                          ? NutritionInputTheme.accentColor 
                          : NutritionInputTheme.inputBackground,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        f['label'] as String, 
                        style: TextStyle(
                          color: isSelected 
                              ? NutritionInputTheme.accentColor 
                              : NutritionInputTheme.primaryTextColor, 
                          fontSize: isWhole ? 14 : 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (!isWhole) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${targetWeight.toStringAsFixed(0)}g',
                          style: TextStyle(
                            color: isSelected 
                                ? NutritionInputTheme.accentColor 
                                : NutritionInputTheme.secondaryTextColor,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
} 