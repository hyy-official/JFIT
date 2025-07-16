import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:jfit/models/food_search_item.dart';
import 'package:jfit/services/food_api_service.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'nutrition_manual_input_screen.dart';
import 'food_nutrition_calculator_screen.dart';
import 'package:get_it/get_it.dart';
import 'package:jfit/core/services/supabase_service.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/core/utils/responsive_utils.dart';
import 'package:jfit/models/nutrition_info.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final _api = FoodApiService();
  final _ctrl = TextEditingController();
  List<FoodSearchItem> _results = [];
  bool _loading = false;
  Timer? _debounce;

  String _activeTab = 'recent';
  final List<FoodSearchItem> _recentFoods = [];
  final List<FoodSearchItem> _customFoods = [];

  @override
  void initState() {
    super.initState();
    _loadRecentFoods();
  }

  Future<void> _loadRecentFoods() async {
    final supa = GetIt.instance<SupabaseService>();
    final rows = await supa.searchFoodItems(''); // fetch all? implement query later
    setState(() {
      _recentFoods.clear();
      _recentFoods.addAll(rows.map((e) => FoodSearchItem.fromJson(e)));
    });
  }

  void _onTextChanged(String value) {
    _debounce?.cancel();
    if (value.isEmpty) {
      setState(() {
        _results.clear();
        _loading = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(value));
  }

  Future<void> _search(String q) async {
    if (q.isEmpty) return;
    setState(() => _loading = true);
    final res = await _api.searchFoods(q);
    setState(() {
      _results = res;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = context.isDesktop ? BorderRadius.circular(24) : const BorderRadius.vertical(top: Radius.circular(24));
    return ClipRRect(
      borderRadius: radius,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          backgroundColor: context.colors.background,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          leading: const SizedBox.shrink(),
          actions: [
            IconButton(
              icon: Icon(Icons.close, color: context.colors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _ctrl,
                  style: TextStyle(color: context.colors.textPrimary, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: '음식 또는 브랜드 이름',
                    hintStyle: TextStyle(color: context.colors.textSecondary),
                    prefixIcon: Icon(LucideIcons.search, color: context.colors.textSecondary),
                    filled: true,
                    fillColor: context.colors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onChanged: _onTextChanged,
                  onSubmitted: _search,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:16.0),
                child: SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final info = await _openNutritionManualInput(context);
                      if (info != null) Navigator.pop(context, info);
                    },
                    icon: Icon(LucideIcons.plusCircle, size: 18, color: context.colors.textSecondary),
                    label: Text('직접 추가', style: TextStyle(color: context.colors.textSecondary)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: context.colors.surface,
                      side: BorderSide(color: context.colors.surface),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top:8.0),
                child: _AdvertisementBanner(),
              ),
              Padding(
                padding: const EdgeInsets.only(top:8.0),
                child: Row(
                  children: [
                    _buildTabButton('recent','최근 먹은'),
                    _buildTabButton('custom','직접 추가한'),
                  ],
                ),
              ),
              if (_loading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (_ctrl.text.isNotEmpty)
                Expanded(child: _results.isEmpty ? _buildEmpty() : _buildList())
              else
                Expanded(child: _buildTabContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Text('검색 결과가 없습니다', style: TextStyle(color: context.colors.textSecondary)),
      );

  Widget _buildList() => ListView.separated(
        itemCount: _results.length,
        separatorBuilder: (_, __) => Divider(color: context.colors.surface),
        itemBuilder: (_, i) {
          final item = _results[i];
          return ListTile(
            title: Text(item.foodName, style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
            subtitle: Text(_buildSubtitle(context, item), style: TextStyle(color: context.colors.textSecondary)),
            trailing: Icon(LucideIcons.chevronRight, color: context.colors.textSecondary),
            onTap: () async {
              final info = item.toNutritionInfo();
              final res = await _openNutritionCalculator(context, info, item.id);
              if (res != null) Navigator.pop(context, res);
            },
          );
        },
      );

  String _buildSubtitle(BuildContext context, FoodSearchItem item) {
    final lang = Localizations.localeOf(context).languageCode;
    final isKo = lang == 'ko';

    final grams = item.standardSizeG.toStringAsFixed(0);
    if (isKo) {
      return '${grams}g당 ${item.caloriesStandard.toStringAsFixed(0)} kcal | '
          '탄 ${item.carbsStandard.toStringAsFixed(0)}g '
          '단 ${item.proteinStandard.toStringAsFixed(0)}g '
          '지 ${item.fatStandard.toStringAsFixed(0)}g';
    } else {
      return 'Per ${grams}g: ${item.caloriesStandard.toStringAsFixed(0)} kcal | '
          'C ${item.carbsStandard.toStringAsFixed(0)}g '
          'P ${item.proteinStandard.toStringAsFixed(0)}g '
          'F ${item.fatStandard.toStringAsFixed(0)}g';
    }
  }

  Widget _buildTabButton(String key, String label) {
    final active = _activeTab == key;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: active ? BoxDecoration(border: Border(bottom: BorderSide(color: context.colors.primary, width: 2))) : null,
          child: Center(child: Text(label, style: TextStyle(color: active ? context.colors.primary : context.colors.textSecondary, fontWeight: FontWeight.w600))),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_activeTab == 'recent') {
      return _recentFoods.isEmpty ? _buildEmptyState('최근 먹은 음식이 없어요','최근 식단에 기록한 음식을 볼 수 있어요', LucideIcons.utensilsCrossed) : _buildFoodList(_recentFoods);
    } else {
      return _customFoods.isEmpty ? _buildEmptyState('직접 추가한 음식이 없어요','자주 먹는 음식을 추가하고 관리해보세요', LucideIcons.plusCircle) : _buildFoodList(_customFoods);
    }
  }

  Widget _buildFoodList(List<FoodSearchItem> items) => ListView.separated(
    itemCount: items.length + 1,
    separatorBuilder: (_, __) => Divider(color: context.colors.surface),
    itemBuilder: (ctx,index){
      if(index==0){
        return const Padding(
          padding: EdgeInsets.symmetric(vertical:8.0),
          //child: _AdvertisementBanner(),
        );
      }
      final item = items[index-1];
      return ListTile(
        title: Text(item.foodName, style: TextStyle(color: context.colors.textPrimary)),
        subtitle: Text(_buildSubtitle(context, item), style: TextStyle(color: context.colors.textSecondary)),
        trailing: Icon(LucideIcons.chevronRight, color: context.colors.textSecondary),
        onTap: () async {
          final info = item.toNutritionInfo();
          final res = await _openNutritionCalculator(context, info, item.id);
          if (res != null) Navigator.pop(context, res);
        },
      );
    },
  );

  Widget _buildEmptyState(String title,String subtitle, IconData icon) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal:24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,size:48,color: context.colors.textSecondary),
          const SizedBox(height:16),
          Text(title, style: TextStyle(color: context.colors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height:8),
          Text(subtitle, style: TextStyle(color: context.colors.textSecondary)),
        ],
      ),
    ),
  );

  Future<NutritionInfo?> _openNutritionCalculator(BuildContext context, NutritionInfo foodData, String foodItemId) async {
    final isDesktop = context.isDesktop;
    if (isDesktop) {
      return showDialog<NutritionInfo>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => Dialog(
          insetPadding: const EdgeInsets.all(32),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480, maxHeight: 800),
              child: FoodNutritionCalculatorScreen(foodData: foodData, foodItemId: foodItemId),
            ),
          ),
        ),
      );
    } else {
      return showModalBottomSheet<NutritionInfo>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => FractionallySizedBox(
          heightFactor: 0.95,
          child: Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: FoodNutritionCalculatorScreen(foodData: foodData, foodItemId: foodItemId),
          ),
        ),
      );
    }
  }

  Future<NutritionInfo?> _openNutritionManualInput(BuildContext context) async {
    final isDesktop = context.isDesktop;
    if (isDesktop) {
      return showDialog<NutritionInfo>(
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
              child: const NutritionManualInputScreen(),
            ),
          ),
        ),
      );
    } else {
      return showModalBottomSheet<NutritionInfo>(
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
            child: const NutritionManualInputScreen(),
          ),
        ),
      );
    }
  }
}

// Gradient banner widget
class _AdvertisementBanner extends StatelessWidget {
  const _AdvertisementBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [context.colors.primary, context.colors.secondary]),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.local_fire_department, color: context.colors.textPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Text('프리미엄 운동 프로그램', style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
          ),
          Icon(Icons.open_in_new, color: context.colors.textPrimary),
        ],
      ),
    );
  }
} 