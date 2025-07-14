import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:jfit/core/theme/nutrition_input_theme.dart';
import 'package:jfit/models/nutrition_info.dart';
import 'package:jfit/core/utils/responsive_utils.dart';
import 'package:get_it/get_it.dart';
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
  final SupabaseService _supabaseService = GetIt.instance<SupabaseService>();
  
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
                _buildNutritionDonut(),
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
    return Row(
      children: [
        const SizedBox(width: 8),
        Expanded(
      child: Text(
        widget.foodData.foodName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
          ),
      ),
      ],
    );
  }
  
  Widget _buildWeightControl() {
    const maxWeight = 500.0;
    return Container(
      padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2B35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3A3B45)),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _roundIconButton(Icons.remove, () {
                final newWeight = (_currentWeight - 10).clamp(0, maxWeight).toDouble();
                _updateWeight(newWeight);
              }),
              Column(
                children: [
                  Text('${_currentWeight.toInt()} g', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('섭취량', style: TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
              _roundIconButton(Icons.add, () {
                final newWeight = (_currentWeight + 10).clamp(0, maxWeight).toDouble();
              _updateWeight(newWeight);
              }),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: const Color(0xFF6B73FF),
              inactiveTrackColor: const Color(0xFF3A3B45),
              thumbColor: const Color(0xFFB794F6),
            ),
            child: Slider(
              value: _currentWeight.clamp(0, maxWeight),
              min: 0,
              max: maxWeight,
              onChanged: (value) => _updateWeight(value),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('0g', style: TextStyle(color: Colors.white60, fontSize: 12)),
              Text('500g', style: TextStyle(color: Colors.white60, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _roundIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
          decoration: BoxDecoration(
        color: const Color(0xFF3A3B45),
        borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
  
  Widget _buildNutritionDonut() {
    final total = _result.carbs + _result.protein + _result.fat;
    if (total <= 0) return const SizedBox.shrink();
    
    return Row(
      children: [
        MacroDonutChart(
          carbs: _result.carbs,
          protein: _result.protein,
          fat: _result.fat,
          calories: _result.calories,
          size: 120,
        ),
        const SizedBox(width: 100),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem('탄수화물', _result.carbs, const Color(0xFF6B73FF)),
              const SizedBox(height: 1),
              _buildLegendItem('단백질', _result.protein, const Color(0xFFB794F6)),
              const SizedBox(height: 1),
              _buildLegendItem('지방', _result.fat, const Color(0xFFF687B3)),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildLegendItem(String label, double value, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('$label ${value.toStringAsFixed(1)}g', style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
  
  Widget _buildNutritionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
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
          const SizedBox(height: 5),
          
          // 영양성분 그리드
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNutritionItem('탄수화물', '${_result.carbs.toStringAsFixed(1)}g'),
              _buildNutritionItem('단백질', '${_result.protein.toStringAsFixed(1)}g'),
              _buildNutritionItem('지방', '${_result.fat.toStringAsFixed(1)}g'),
            ],
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
        const SizedBox(height: 1),
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
        // 정보 제보 배너
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('제보 기능은 아직 미구현입니다.')),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2814), // 어두운 옐로우 톤 배경
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFFFC107)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '음식 정보가 정확한가요? 제보해 주세요!',
                    style: TextStyle(color: Color(0xFFFFC107), fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
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


  Future<void> _returnResult() async {
    Navigator.pop(context, _result);
  }
}

/// 도넛 차트: 탄수/단백질/지방 비율을 원형으로 표시
class MacroDonutChart extends StatelessWidget {
  final double carbs;
  final double protein;
  final double fat;
  final double calories;
  final double size;

  const MacroDonutChart({
    super.key,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.calories,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final total = carbs + protein + fat;
    if (total <= 0) {
      return SizedBox(width: size, height: size);
    }

    final carbsSweep = carbs / total * 360;
    final proteinSweep = protein / total * 360;
    final fatSweep = fat / total * 360;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(
          carbsSweep: carbsSweep,
          proteinSweep: proteinSweep,
          fatSweep: fatSweep,
        ),
        child: Center(
                      child: Text(
            '${calories.toStringAsFixed(0)}\nkcal',
                        textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double carbsSweep;
  final double proteinSweep;
  final double fatSweep;

  _DonutPainter({required this.carbsSweep, required this.proteinSweep, required this.fatSweep});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const thickness = 16.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    double startAngle = -90 * 3.1415926535 / 180; // top

    // Carbs - blue
    paint.color = const Color(0xFF6B73FF);
    canvas.drawArc(rect.deflate(thickness / 2), startAngle, carbsSweep * 3.1415926535 / 180, false, paint);
    startAngle += carbsSweep * 3.1415926535 / 180;

    // Protein - purple
    paint.color = const Color(0xFFB794F6);
    canvas.drawArc(rect.deflate(thickness / 2), startAngle, proteinSweep * 3.1415926535 / 180, false, paint);
    startAngle += proteinSweep * 3.1415926535 / 180;

    // Fat - pink
    paint.color = const Color(0xFFF687B3);
    canvas.drawArc(rect.deflate(thickness / 2), startAngle, fatSweep * 3.1415926535 / 180, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 