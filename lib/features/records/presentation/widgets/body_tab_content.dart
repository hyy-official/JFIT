import 'package:flutter/material.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:get_it/get_it.dart';
import 'package:jfit/core/services/supabase_service.dart';

/// 신체 & 운동 탭 컨텐츠
class BodyTabContent extends StatefulWidget {
  final DateTime selectedDate;
  const BodyTabContent({super.key, required this.selectedDate});

  @override
  State<BodyTabContent> createState() => _BodyTabContentState();
}

class _BodyTabContentState extends State<BodyTabContent>
    with AutomaticKeepAliveClientMixin {
  final SupabaseService _supabaseService = GetIt.instance<SupabaseService>();
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(covariant BodyTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _fetch();
    }
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final res = await _supabaseService.getBodyMeasurementForDate(widget.selectedDate);
    setState(() {
      _data = res;
      _loading = false;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 요구사항
    
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_data == null) {
      return Center(child: Text('오늘 기록된 신체 정보가 없습니다', style: TextStyle(color: context.colors.textMuted)));
    }

    return BodyMeasurementCard(data: _data!);
  }
}

class BodyMeasurementCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const BodyMeasurementCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final weight = (data['weight'] as num?)?.toDouble();
    final muscle = (data['muscle_mass'] as num?)?.toDouble();
    final fat = (data['body_fat_percentage'] as num?)?.toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _metric('체중', weight, 'kg'),
          _metric('골격근량', muscle, 'kg'),
          _metric('체지방률', fat, '%'),
        ],
      ),
    );
  }

  Widget _metric(String label, double? value, String unit) {
    return Builder(
      builder: (context) => Column(
        children: [
          Text(label, style: TextStyle(color: context.colors.textSecondary, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value != null ? value.toStringAsFixed(1) : '-',
              style: TextStyle(color: context.colors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(unit, style: TextStyle(color: context.colors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
} 