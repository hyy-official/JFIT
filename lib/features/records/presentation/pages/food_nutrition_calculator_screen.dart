import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:jfit/core/theme/nutrition_input_theme.dart';
import 'package:jfit/models/nutrition_info.dart';
import 'package:jfit/core/utils/responsive_utils.dart';
import 'package:jfit/core/services/supabase_service.dart';

/// 영양성분 계산기 전용 페이지
/// DB에서 가져온 음식 데이터를 기반으로 중량에 따른 영양성분을 계산
class FoodNutritionCalculatorScreen extends StatefulWidget {
  final NutritionInfo foodData;
  final String? foodItemId; // DB의 food_items 테이블 ID

  const FoodNutritionCalculatorScreen({
    super.key,
    required this.foodData,
    this.foodItemId,
  });

  @override
  State<FoodNutritionCalculatorScreen> createState() => _FoodNutritionCalculatorScreenState();
}

class _FoodNutritionCalculatorScreenState extends State<FoodNutritionCalculatorScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  
  late NutritionInfo _result;
  late TextEditingController _weightController;
  
  // 기준 영양 정보 (DB에서 가져온 표준량 기준)
  late double _standardSize;
  late double _baseCalories;
  late double _baseProtein;
  late double _baseCarbs;
  late double _baseFat;
  
  double _currentWeight = 100.0;
  String _selectedMealType = 'breakfast'; // 기본값: 아침식사
  bool _isSaving = false;

  // 식사 타입 옵션
  final Map<String, String> _mealTypes = {
    'breakfast': '아침',
    'lunch': '점심',
    'dinner': '저녁',
    'snack': '간식',
  };
  
  @override
  void initState() {
    super.initState();
    
    // 기준 정보 설정
    _standardSize = widget.foodData.servingSize;
    _baseCalories = widget.foodData.calories;
    _baseProtein = widget.foodData.protein;
    _baseCarbs = widget.foodData.carbs;
    _baseFat = widget.foodData.fat;
    
    // 초기 중량을 표준량으로 설정
    _currentWeight = _standardSize;
    _weightController = TextEditingController(text: _currentWeight.toInt().toString());
    
    // 결과 초기화
    _result = NutritionInfo(
      foodName: widget.foodData.foodName,
      servingSize: _currentWeight,
      totalSize: _currentWeight,
      calories: _baseCalories,
      protein: _baseProtein,
      carbs: _baseCarbs,
      fat: _baseFat,
      foodItemId: widget.foodItemId,
      weight: _currentWeight,
    );
  }
  
  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }
  
  void _updateWeight(double newWeight) {
    if (newWeight <= 0) return;
    
    setState(() {
      _currentWeight = newWeight;
      _weightController.text = newWeight.toInt().toString();
      _recalculateNutrition();
    });
  }
  
  void _recalculateNutrition() {
    final ratio = _currentWeight / _standardSize;
    setState(() {
      _result.totalSize = _currentWeight;
      _result.servingSize = _currentWeight;
      _result.calories = _baseCalories * ratio;
      _result.protein = _baseProtein * ratio;
      _result.carbs = _baseCarbs * ratio;
      _result.fat = _baseFat * ratio;
      _result.foodItemId = widget.foodItemId; // DB 음식 ID 설정
      _result.weight = _currentWeight; // 실제 섭취 중량 설정
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final radius = context.isDesktop ? BorderRadius.circular(24) : const BorderRadius.vertical(top: Radius.circular(24));
    return ClipRRect(
      borderRadius: radius,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1B23),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1B23),
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2B35),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          leading: const SizedBox.shrink(),
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildWeightControl(),
                const SizedBox(height: 24),
                _buildNutritionRatioBar(),
                const SizedBox(height: 24),
                _buildNutritionCard(),
                const Spacer(),
                _buildBottomSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Center(
      child: Text(
        widget.foodData.foodName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  Widget _buildWeightControl() {
    return Row(
      children: [
        // 감소 버튼
        Container(
          width: 120,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2B35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3A3B45)),
          ),
          child: IconButton(
            onPressed: () {
              final newWeight = (_currentWeight - 10).clamp(10, 9999).toDouble();
              _updateWeight(newWeight);
            },
            icon: const Icon(Icons.remove, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(width: 12),
        
        // 중량 입력 필드
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2B35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3A3B45)),
            ),
            child: TextField(
              controller: _weightController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
              onChanged: (value) {
                final weight = double.tryParse(value);
                if (weight != null && weight > 0) {
                  setState(() {
                    _currentWeight = weight;
                    _recalculateNutrition();
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // g 단위 표시
        Container(
          width: 80,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2B35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3A3B45)),
          ),
          child: const Center(
            child: Text(
              'g',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // 증가 버튼
        Container(
          width: 120,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2B35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3A3B45)),
          ),
          child: IconButton(
            onPressed: () {
              final newWeight = (_currentWeight + 10).clamp(10, 9999).toDouble();
              _updateWeight(newWeight);
            },
            icon: const Icon(Icons.add, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }
  
  Widget _buildNutritionRatioBar() {
    final total = _result.carbs + _result.protein + _result.fat;
    if (total <= 0) return const SizedBox.shrink();
    
    final carbsRatio = _result.carbs / total;
    final proteinRatio = _result.protein / total;
    final fatRatio = _result.fat / total;
    
    return Column(
      children: [
        // 비율 텍스트
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildRatioText('탄수화물', '${(carbsRatio * 100).toInt()}%', const Color(0xFF6B73FF)),
            _buildRatioText('단백질', '${(proteinRatio * 100).toInt()}%', const Color(0xFFB794F6)),
            _buildRatioText('지방', '${(fatRatio * 100).toInt()}%', const Color(0xFFF687B3)),
          ],
        ),
        const SizedBox(height: 8),
        
        // 비율 바
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              if (carbsRatio > 0)
                Expanded(
                  flex: (carbsRatio * 1000).toInt(),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF6B73FF),
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
                    ),
                  ),
                ),
              if (proteinRatio > 0)
                Expanded(
                  flex: (proteinRatio * 1000).toInt(),
                  child: Container(
                    color: const Color(0xFFB794F6),
                  ),
                ),
              if (fatRatio > 0)
                Expanded(
                  flex: (fatRatio * 1000).toInt(),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF687B3),
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildRatioText(String label, String ratio, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label $ratio',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildNutritionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2B35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A3B45)),
      ),
      child: Column(
        children: [
          // 칼로리
          Text(
            '${_result.calories.toStringAsFixed(1)}kcal',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // 영양성분 그리드
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNutritionItem('탄수화물', '${_result.carbs.toStringAsFixed(1)}g'),
              _buildNutritionItem('단백질', '${_result.protein.toStringAsFixed(1)}g'),
              _buildNutritionItem('지방', '${_result.fat.toStringAsFixed(1)}g'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 추가 영양성분 (나트륨 등)
          const Text(
            '나트륨 134mg',
            style: TextStyle(
              color: Color(0xFF8B8B8B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNutritionItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8B8B8B),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildBottomSection() {
    return Column(
      children: [
        // 식사 타입 선택
        _buildMealTypeSelector(),
        
        const SizedBox(height: 24),
        
        // 정보가 잘못되었나요?
        TextButton(
          onPressed: () {
            // TODO: 피드백 기능
          },
          child: const Text(
            '음식 정보가 잘못됐나요?',
            style: TextStyle(
              color: Color(0xFF8B8B8B),
              fontSize: 14,
            ),
          ),
        ),
        
        TextButton(
          onPressed: () {
            // TODO: 제보하기 기능  
          },
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF2A2B35),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFF3A3B45)),
            ),
          ),
          child: const Text(
            '제보하기',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 추가하기 버튼
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _returnResult,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B73FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '추가하기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2B35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A3B45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '식사 타입',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _mealTypes.entries.map((entry) {
              final isSelected = _selectedMealType == entry.key;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMealType = entry.key;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF6B73FF) : const Color(0xFF3A3B45),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        entry.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF8B8B8B),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _returnResult() async {
    Navigator.pop(context, _result);
  }
} 