import 'package:flutter/material.dart';
import 'package:jfit/core/theme/theme_system.dart';

class FilterChipsRow extends StatelessWidget {
  final List<String> filters;
  
  const FilterChipsRow({
    required this.filters,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) => FilterChip(
          label: Text(filters[idx], style: TextStyle(color: context.colors.textPrimary)),
          backgroundColor: context.colors.surface,
          selectedColor: context.colors.primary,
          selected: false,
          onSelected: (_) {},
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
} 