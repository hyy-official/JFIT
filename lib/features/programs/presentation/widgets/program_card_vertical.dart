import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/features/programs/presentation/pages/program_detail_page.dart';

class ProgramCardVertical extends StatelessWidget {
  final Map<String, dynamic> data;
  const ProgramCardVertical({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProgramDetailPage(program: data),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.programCardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 60,
                height: 60,
                color: Colors.grey[800],
                child: data['image'] != null
                    ? Image.network(
                        data['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(Icons.image, color: Colors.white24, size: 24),
                        ),
                      )
                    : Center(
                        child: Icon(Icons.image, color: Colors.white24, size: 24),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if ((data['badge'] ?? '').isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accent1,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(data['badge'], style: const TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          data['title'],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data['coach'],
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(data['level'], style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      const SizedBox(width: 8),
                      Text(data['weeks'], style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 