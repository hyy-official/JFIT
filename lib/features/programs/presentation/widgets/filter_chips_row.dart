import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';

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
          label: Text(filters[idx], style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF23242B),
          selectedColor: AppTheme.accent1,
          selected: false,
          onSelected: (_) {},
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
} 