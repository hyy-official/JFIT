import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/core/services/supabase_service.dart';
import 'package:jfit/features/records/presentation/widgets/meal_type_summary_card.dart';
import 'package:jfit/features/records/presentation/widgets/macro_ratio_bar.dart';

/// 식단 탭 컨텐츠
class DietTabContent extends StatefulWidget {
  final DateTime selectedDate;

  const DietTabContent({super.key, required this.selectedDate});

  @override
  State<DietTabContent> createState() => _DietTabContentState();
}

class _DietTabContentState extends State<DietTabContent>
    with AutomaticKeepAliveClientMixin {
  final SupabaseService _supabaseService = GetIt.instance<SupabaseService>();
  List<Map<String, dynamic>> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void didUpdateWidget(covariant DietTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _loadEntries();
    }
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    final data = await _supabaseService.getMealEntriesForDate(widget.selectedDate);
    setState(() {
      _entries = data;
      _isLoading = false;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 요구사항
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    double totalCarbs = 0;
    double totalProtein = 0;
    double totalFat = 0;

    for (final e in _entries) {
      totalCarbs += (e['carbohydrates'] as num?)?.toDouble() ?? 0;
      totalProtein += (e['protein'] as num?)?.toDouble() ?? 0;
      totalFat += (e['fat'] as num?)?.toDouble() ?? 0;
    }

    // ----- meal_type 별로 그룹화 -----
    final Map<String, MealTypeSummary> grouped = {};
    for (final e in _entries) {
      final type = e['meal_type'] as String;
      grouped.putIfAbsent(type, () => MealTypeSummary(type));
      grouped[type]!.addEntry(e);
    }

    // 정렬 순서 정의
    const order = ['breakfast', 'lunch', 'dinner', 'snack'];
    final summaries = grouped.values.toList()
      ..sort((a, b) => order.indexOf(a.mealType).compareTo(order.indexOf(b.mealType)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MacroRatioBar(carbs: totalCarbs, protein: totalProtein, fat: totalFat),
        const SizedBox(height: 16),
        Expanded(
          child: summaries.isEmpty
              ? Center(child: Text('오늘 기록된 식단이 없습니다', style: TextStyle(color: context.colors.textSecondary)))
              : ListView.separated(
                  itemCount: summaries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return MealTypeSummaryCard(summary: summaries[index]);
                  },
                ),
        ),
      ],
    );
  }
}

/// 내부 집계 모델
class MealTypeSummary {
  final String mealType;
  double totalCalories = 0;
  double totalCarbs = 0;
  double totalProtein = 0;
  double totalFat = 0;

  MealTypeSummary(this.mealType);

  void addEntry(Map<String, dynamic> e) {
    totalCalories += (e['calories'] as num?)?.toDouble() ?? 0;
    totalCarbs += (e['carbohydrates'] as num?)?.toDouble() ?? 0;
    totalProtein += (e['protein'] as num?)?.toDouble() ?? 0;
    totalFat += (e['fat'] as num?)?.toDouble() ?? 0;
  }
} 