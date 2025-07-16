import 'package:flutter/material.dart';
import 'package:jfit/core/theme/theme_system.dart';

class ProgramsHeader extends StatelessWidget {
  const ProgramsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (Navigator.canPop(context))
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: context.colors.textPrimary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            padding: const EdgeInsets.only(right: 4),
            constraints: const BoxConstraints(),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            '헬스장',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
} 