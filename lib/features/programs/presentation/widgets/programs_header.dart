import 'package:flutter/material.dart';

class ProgramsHeader extends StatelessWidget {
  const ProgramsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (Navigator.canPop(context))
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            padding: const EdgeInsets.only(right: 4),
            constraints: const BoxConstraints(),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            '헬스장',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
} 