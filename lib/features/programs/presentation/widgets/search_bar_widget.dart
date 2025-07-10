import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/features/programs/presentation/pages/search_page.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SearchPage(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.programCardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.white38),
            const SizedBox(width: 12),
            Text(
              '루틴 또는 코치 이름을 검색하세요',
              style: const TextStyle(color: Colors.white38, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
} 