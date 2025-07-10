import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/features/records/presentation/widgets/diet_add_sheet.dart';
import 'package:jfit/features/records/presentation/widgets/body_add_sheet.dart';

/// Quick Add Section with Workout card spanning 2 columns
class QuickAddSection extends StatelessWidget {
  const QuickAddSection({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = (MediaQuery.of(context).size.width >= 1024) ? 16.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 추가',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: spacing / 2),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardHeight = constraints.maxWidth >= 768 ? 120.0 : 100.0;

            return Column(
              children: [
                // Workout card full width
                WorkoutCard(height: cardHeight),
                SizedBox(height: spacing),
                Row(
                  children: [
                    Expanded(child: QuickCard(icon: Icons.restaurant, label: '식단', accent: const Color(0xFF34D399))),
                    SizedBox(width: spacing),
                    Expanded(child: QuickCard(icon: Icons.person, label: '신체', accent: const Color(0xFFFBBF24))),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class WorkoutCard extends StatelessWidget {
  final double height;
  const WorkoutCard({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface1.withOpacity(0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surface2, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.accent1, AppTheme.accent2]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fitness_center, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('운동', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('0/1 완료', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSub)),
              ],
            ),
          ),
          const Icon(Icons.add, color: Colors.white),
        ],
      ),
    );
  }
}

class QuickCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color accent;
  const QuickCard({super.key, required this.icon, required this.label, required this.accent});

  @override
  State<QuickCard> createState() => _QuickCardState();
}

class _QuickCardState extends State<QuickCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    void handleTap() {
      if (widget.label == '식단') {
        _showAddDietSheet(context);
      } else if (widget.label == '신체') {
        _showAddBodySheet(context);
      }
    }

    return GestureDetector(
      onTap: handleTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: AnimatedScale(
          scale: _hovering ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface1.withOpacity(0.75),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _hovering ? widget.accent : AppTheme.surface2, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_hovering ? 0.25 : 0.15),
                  blurRadius: _hovering ? 16 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [widget.accent.withOpacity(0.8), widget.accent]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showAddDietSheet(BuildContext context, {DateTime? date}) {
  final isDesktop = MediaQuery.of(context).size.width >= 1024;
  if (isDesktop) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(32),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: DietAddSheetContent(selectedDate: date ?? DateTime.now()),
          ),
        ),
      ),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.9,
        child: DietAddSheetContent(selectedDate: date ?? DateTime.now()),
      ),
    );
  }
}

void _showAddBodySheet(BuildContext context, {DateTime? date}) {
  final isDesktop = MediaQuery.of(context).size.width >= 1024;
  if (isDesktop) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(32),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BodyAddSheetContent(selectedDate: date ?? DateTime.now()),
          ),
        ),
      ),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.9,
        child: BodyAddSheetContent(selectedDate: date ?? DateTime.now()),
      ),
    );
  }
} 