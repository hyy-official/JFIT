import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/features/records/data/models/diet_entry.dart';
import 'package:jfit/core/utils/responsive_utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:jfit/core/services/supabase_service.dart';
import 'package:jfit/core/models/nutrition_info.dart';
import 'package:jfit/features/records/presentation/pages/nutrition_manual_input_screen.dart';
import 'package:jfit/features/records/presentation/pages/food_search_screen.dart';

class DietDetailForm extends StatefulWidget {
  final DateTime selectedDate;
  const DietDetailForm({super.key, required this.selectedDate});

  @override
  State<DietDetailForm> createState() => _DietDetailFormState();
}

class _DietDetailFormState extends State<DietDetailForm> {
  late DietEntry _dietEntry;
  final _foodNameController = TextEditingController();
  final _memoController = TextEditingController();
  late TextEditingController _timeController;
  String? _timeError; // 사진 메타데이터 시간 파싱 실패 시 메시지
  
  // 추가된 영양성분 목록
  List<NutritionInfo> _nutritionItems = [];

  @override
  void initState() {
    super.initState();
    _dietEntry = DietEntry(time: widget.selectedDate);
    _timeController = TextEditingController(text: DateFormat('HH:mm').format(_dietEntry.time));
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _memoController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHandlebar(),
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageUpload(),
                _buildFoodNameInput(),
                _buildSectionDivider(),
                _buildMealTypeSelection(),
                _buildSatisfactionSelection(),
                _buildScoreSelection(),
                _buildTimeAdjustment(),
                _buildSectionDivider(),
                _buildMemoInput(),
                _buildAccompanimentsSelection(),
                _buildSectionDivider(),
                _buildNutritionSection(),
                _buildSectionDivider(),
                _buildBookmarkToggle(),
                
              ],
            ),
          ),
        ),
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildHandlebar() => Container(
        width: 48,
        height: 5,
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(4),
        ),
      );

  Widget _buildHeader() {
    final formattedDate = DateFormat('yyyy년 MM월 dd일').format(widget.selectedDate);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Text('$formattedDate 식단', style: TextStyle(color: context.colors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
    );
  }

  Widget _buildImageUpload() {
    return Center(
      child: GestureDetector(
        onTap: _showImagePickerOptions,
        child: Stack(
          alignment: Alignment.center,
          children: [
            DottedBorder(
              color: context.colors.border,
              strokeWidth: 2,
              borderType: BorderType.Circle,
              dashPattern: const [6, 4],
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.surfaceVariant.withOpacity(0.5),
                ),
                child: _dietEntry.imagePath != null
                    ? ClipOval(child: Image.file(File(_dietEntry.imagePath!), fit: BoxFit.cover))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, size: 32, color: context.colors.textSecondary),
                          const SizedBox(height: 8),
                          Text('음식명 업로드', style: TextStyle(color: context.colors.textMuted, fontSize: 14)),
                        ],
                      ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.textPrimary,
                ),
                child: Icon(Icons.add, size: 20, color: context.colors.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('카메라로 촬영'), onTap: () => _pickImage(ImageSource.camera)),
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('갤러리에서 선택'), onTap: () => _pickImage(ImageSource.gallery)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() => _dietEntry.imagePath = picked.path);

      try {
        final fileDate = await File(picked.path).lastModified();
        _updateTime(fileDate);
        setState(() => _timeError = null);
      } catch (_) {
        _updateTime(DateTime.now());
        setState(() => _timeError = '사진의 시간을 불러올 수 없습니다');
      }
    }
  }

  void _updateTime(DateTime dt) {
    setState(() {
      _dietEntry.time = dt;
      _timeController.text = DateFormat('HH:mm').format(dt);
    });
  }

  Widget _buildFoodNameInput() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: SizedBox(
          height: 56,
          child: TextField(
            controller: _foodNameController,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '음식명 입력',
              hintStyle: TextStyle(color: context.colors.textMuted, fontSize: 18),
              filled: true,
              fillColor: context.colors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (v) => setState(() => _dietEntry.foodName = v),
          ),
        ),
      );

  Widget _buildMealTypeSelection() {
    const mealTypes = ['아침', '아점', '점심', '점저', '저녁', '야식'];
    return _buildChipsSection('분류', mealTypes, _dietEntry.mealTypes, onTap: (val) {
      setState(() {
        _dietEntry.mealTypes
          ..clear()
          ..add(val);
      });
    });
  }

  Widget _buildSatisfactionSelection() {
    const sat = ['가볍게', '적당히', '배부르게', '과하게'];
    return _buildChipsSection('포만감', sat, [_dietEntry.satisfaction], onTap: (val) {
      setState(() => _dietEntry.satisfaction = val);
    });
  }

  Widget _buildChipsSection(String title, List<String> options, List<String> selected, {required Function(String) onTap, bool multi = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(title, style: TextStyle(color: context.colors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600))),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((o) {
            final isSel = selected.contains(o);

            if (multi) {
              return FilterChip(
                label: Text(
                  o,
                  style: TextStyle(
                    color: isSel ? context.colors.textPrimary : context.colors.textSecondary,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                selected: isSel,
                selectedColor: context.colors.primary,
                backgroundColor: context.colors.surface,
                onSelected: (_) => onTap(o),
                shape: const StadiumBorder(),
                side: BorderSide.none,
              );
            } else {
              return ChoiceChip(
                label: Text(
                  o,
                  style: TextStyle(
                    color: isSel ? context.colors.textPrimary : context.colors.textSecondary,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                selected: isSel,
                selectedColor: context.colors.primary,
                backgroundColor: context.colors.surface,
                onSelected: (_) => onTap(o),
                shape: const StadiumBorder(),
                side: BorderSide.none,
              );
            }
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildScoreSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('점수', style: TextStyle(color: context.colors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600))),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) {
            final score = i + 1;
            final sel = _dietEntry.score == score;
            return GestureDetector(
              onTap: () => setState(() => _dietEntry.score = score),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sel ? context.colors.primary : context.colors.surface,
                ),
                child: Center(
                  child: Text(
                    score.toString(),
                    style: TextStyle(
                      color: sel ? context.colors.textPrimary : context.colors.textSecondary,
                      fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTimeAdjustment() {
    final isDesktop = context.isDesktop;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('시간', style: TextStyle(color: context.colors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        SizedBox(
          height: 48,
          child: TextField(
            controller: _timeController,
            readOnly: !isDesktop,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.colors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              filled: true,
              fillColor: context.colors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onTap: () async {
              if (!isDesktop) {
                _showWheelTimePicker();
              }
            },
            onChanged: isDesktop
                ? (val) {
                    if (RegExp(r'^\d{1,2}:\d{2}').hasMatch(val)) {
                      final parts = val.split(':');
                      final h = int.tryParse(parts[0]);
                      final m = int.tryParse(parts[1]);
                      if (h != null && m != null && h < 24 && m < 60) {
                        _updateTime(DateTime(_dietEntry.time.year, _dietEntry.time.month, _dietEntry.time.day, h, m));
                      }
                    }
                  }
                : null,
            inputFormatters: isDesktop
                ? [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                    LengthLimitingTextInputFormatter(5),
                  ]
                : null,
          ),
        ),
        if (_timeError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _timeError!,
              style: TextStyle(color: context.colors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildBookmarkToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('이 식단 북마크에 추가', style: TextStyle(color: context.colors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
        Switch(
          value: _dietEntry.isBookmarked,
          onChanged: (v) => setState(() => _dietEntry.isBookmarked = v),
          activeColor: context.colors.primary,
          activeTrackColor: context.colors.primary.withOpacity(0.5),
          inactiveThumbColor: context.colors.textSecondary,
          inactiveTrackColor: context.colors.surface,
        ),
      ],
    );
  }

  Widget _buildSaveButton() => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _isValidForSave ? _save : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isValidForSave ? context.colors.primary : context.colors.surface,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('저장하기', style: TextStyle(color: _isValidForSave ? context.colors.textPrimary : context.colors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      );

  // 저장 가능 여부 확인
  bool get _isValidForSave => 
    _dietEntry.mealTypes.isNotEmpty && 
    _nutritionItems.isNotEmpty;

  void _save() async {
    final supabaseService = GetIt.instance<SupabaseService>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      // 각 영양성분 항목을 개별적으로 user_meal_entries 테이블에 저장
      for (final nutritionItem in _nutritionItems) {
        // 식사 타입을 영어로 변환
        final mealType = _convertMealTypeToEnglish(_dietEntry.mealTypes.first);
        
        await supabaseService.saveMealEntry(
          foodName: nutritionItem.foodName,
          mealType: mealType,
          quantityG: _resolveQuantity(nutritionItem),
          entryDate: _dietEntry.time,
          calories: nutritionItem.calories,
          protein: nutritionItem.protein,
          carbohydrates: nutritionItem.carbs,
          fat: nutritionItem.fat,
          foodItemId: nutritionItem.foodItemId, // DB 음식 ID (있는 경우)
          notes: _dietEntry.memo.isNotEmpty ? _dietEntry.memo : null,
          mealTypes: _dietEntry.mealTypes,
          satisfaction: _dietEntry.satisfaction.isNotEmpty ? _dietEntry.satisfaction : null,
          score: _dietEntry.score,
          accompaniments: _dietEntry.accompaniments.isNotEmpty ? _dietEntry.accompaniments : null,
          imagePath: _dietEntry.imagePath,
        );
      }
      
      Navigator.of(context)
        ..pop() // loading
        ..pop(); // form
        
      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nutritionItems.length}개 항목이 저장되었습니다'),
          backgroundColor: context.colors.success,
        ),
      );
    } catch (e) {
      Navigator.pop(context); // loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    }
  }

  // 한국어 식사 타입을 영어로 변환
  String _convertMealTypeToEnglish(String koreanMealType) {
    switch (koreanMealType) {
      case '아침':
        return 'breakfast';
      case '아점':
        return 'brunch';
      case '점심':
        return 'lunch';
      case '점저':
        return 'lunch_dinner';
      case '저녁':
        return 'dinner';
      case '야식':
        return 'snack';
      default:
        return 'snack';
    }
  }



  // 섹션 구분선
  Widget _buildSectionDivider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Divider(color: context.colors.surface, thickness: 2, height: 1),
      );

  // 메모 입력
  Widget _buildMemoInput() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text('추가 입력', style: TextStyle(color: context.colors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          TextField(
            minLines: 3,
            controller: _memoController,
            maxLines: 3,
            style: TextStyle(color: context.colors.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: '간단한 메모를 남겨주세요... (선택)',
              hintStyle: TextStyle(color: context.colors.textMuted),
              filled: true,
              fillColor: context.colors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (v) => setState(() => _dietEntry.memo = v),
          ),
        ],
      );

  // 곁들임 선택
  Widget _buildAccompanimentsSelection() {
    final items = [
      {'id': 'drink', 'label': '음료와 함께', 'icon': Icons.local_cafe},
      {'id': 'alcohol', 'label': '술과 함께', 'icon': Icons.local_bar},
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text('곁들임', style: TextStyle(color: context.colors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          Row(
            children: items.map((item) {
              final selected = _dietEntry.accompaniments.contains(item['id']);
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      final id = item['id'] as String;
                      if (selected) {
                        _dietEntry.accompaniments.remove(id);
                      } else {
                        _dietEntry.accompaniments.add(id);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? context.colors.primary : context.colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? context.colors.primary : context.colors.textSecondary,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(item['icon'] as IconData, size: 18, color: selected ? context.colors.textPrimary : context.colors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          item['label'] as String,
                          style: TextStyle(color: selected ? context.colors.textPrimary : context.colors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
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

  // 영양성분 섹션 - 추가된 항목들을 보여주고 새로 추가할 수 있는 버튼들
  Widget _buildNutritionSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text('영양성분', style: TextStyle(color: context.colors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          // 추가된 영양성분 목록
          if (_nutritionItems.isNotEmpty) ...[
            ..._nutritionItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildNutritionItem(item, index);
            }).toList(),
            const SizedBox(height: 16),
          ],
          // 추가 버튼들
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _openNutritionInputScreen(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.surface,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('직접 추가', style: TextStyle(color: context.colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _openFoodSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.surface,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('음식 검색으로 추가', style: TextStyle(color: context.colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
            ],
          ),
        ],
      );

  // 개별 영양성분 항목 위젯
  Widget _buildNutritionItem(NutritionInfo item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.foodName,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _removeNutritionItem(index),
                icon: const Icon(Icons.close, size: 20),
                color: context.colors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '칼로리: ${item.calories.toStringAsFixed(1)}kcal',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '단백질: ${item.protein.toStringAsFixed(1)}g',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  '탄수화물: ${item.carbs.toStringAsFixed(1)}g',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '지방: ${item.fat.toStringAsFixed(1)}g',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (item.weight != null && item.weight! > 0) ...[
            const SizedBox(height: 4),
            Text(
              '중량: ${item.weight!.toStringAsFixed(0)}g',
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 영양성분 항목 제거
  void _removeNutritionItem(int index) {
    setState(() {
      _nutritionItems.removeAt(index);
    });
  }

  void _showWheelTimePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        DateTime tempTime = _dietEntry.time;
        return SizedBox(
          height: 260,
          child: Column(
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: _dietEntry.time,
                  onDateTimeChanged: (dt) {
                    tempTime = dt;
                    _updateTime(DateTime(
                      _dietEntry.time.year,
                      _dietEntry.time.month,
                      _dietEntry.time.day,
                      dt.hour,
                      dt.minute,
                    ));
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
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

  void _openNutritionInputScreen([NutritionInfo? initial]) async {
    final isDesktop = context.isDesktop;
    NutritionInfo? result;

    if (isDesktop) {
      result = await showDialog<NutritionInfo>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => Dialog(
          insetPadding: const EdgeInsets.all(32),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: BorderRadius.circular(24),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480, maxHeight: 800),
              child: NutritionManualInputScreen(initial: initial),
            ),
          ),
        ),
      );
    } else {
      result = await showModalBottomSheet<NutritionInfo>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => FractionallySizedBox(
          heightFactor: 0.95,
          child: Container(
            decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: NutritionManualInputScreen(initial: initial),
          ),
        ),
      );
    }
    
    if (result != null) {
      setState(() {
        _nutritionItems.add(result!);
      });
    }
  }

  void _openFoodSearch() async {
    final isDesktop = context.isDesktop;
    NutritionInfo? result;

    if (isDesktop) {
      result = await showDialog<NutritionInfo>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => Dialog(
          insetPadding: const EdgeInsets.all(32),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: BorderRadius.circular(24),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480, maxHeight: 800),
              child: const FoodSearchScreen(),
            ),
          ),
        ),
      );
    } else {
      result = await showModalBottomSheet<NutritionInfo>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => FractionallySizedBox(
          heightFactor: 0.95,
          child: Container(
            decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: const FoodSearchScreen(),
          ),
        ),
      );
    }

    if (result != null) {
      setState(() {
        _nutritionItems.add(result!);
      });
    }
  }

  double _resolveQuantity(NutritionInfo item) {
    if (item.weight != null && item.weight! > 0) {
      return item.weight!;
    }
    if (item.totalSize > 0) {
      return item.totalSize;
    }
    if (item.servingSize > 0) {
      return item.servingSize;
    }
    // 마지막 방어선: 1g 저장
    return 1.0;
  }
}

void showDietDetailForm(BuildContext context, DateTime selectedDate) {
  final isDesktop = context.isDesktop;
  if (isDesktop) {
    // 데스크톱: 중앙 모달 다이얼로그
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(32),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.background,
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480, maxHeight: 800),
            child: DietDetailForm(selectedDate: selectedDate),
          ),
        ),
      ),
    );
  } else {
    // 모바일: BottomSheet 방식
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.95,
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: DietDetailForm(selectedDate: selectedDate),
        ),
      ),
    );
  }
} 