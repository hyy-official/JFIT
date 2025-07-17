import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/features/meal/bloc/meal_bloc.dart';
import 'package:jfit/features/meal/bloc/meal_state.dart';
import 'package:jfit/features/meal/bloc/meal_event.dart' as meal_events;
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_state.dart';
import 'package:jfit/features/records/data/models/meal_record_model.dart';
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

  @override
  void initState() {
    super.initState();
    _loadMealRecords();
  }

  @override
  void didUpdateWidget(covariant DietTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _loadMealRecords();
    }
  }

  void _loadMealRecords() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<MealBloc>().add(meal_events.LoadMealRecords(
        userId: authState.user.id,
        date: widget.selectedDate,
      ));
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 요구사항
    
    return BlocBuilder<MealBloc, MealState>(
      builder: (context, state) {
        if (state is MealLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MealErrorState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '식단 데이터를 불러오는 중 오류가 발생했습니다',
                  style: TextStyle(color: context.colors.textSecondary),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loadMealRecords,
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          );
        }

        List<MealRecord> mealRecords = [];
        if (state is MealRecordsLoaded) {
          mealRecords = state.mealRecords;
        }

        // Calculate totals from MealRecord objects
        double totalCarbs = 0;
        double totalProtein = 0;
        double totalFat = 0;

        for (final record in mealRecords) {
          totalCarbs += record.totalCarbs ?? 0;
          totalProtein += record.totalProtein ?? 0;
          totalFat += record.totalFat ?? 0;
        }

        // Group by meal type
        final Map<String, MealTypeSummary> grouped = {};
        for (final record in mealRecords) {
          final type = record.mealType;
          grouped.putIfAbsent(type, () => MealTypeSummary(type));
          grouped[type]!.addMealRecord(record);
        }

        // Sort by meal type order
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
      },
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

  void addMealRecord(MealRecord record) {
    totalCalories += record.totalCalories ?? 0;
    totalCarbs += record.totalCarbs ?? 0;
    totalProtein += record.totalProtein ?? 0;
    totalFat += record.totalFat ?? 0;
  }
} 