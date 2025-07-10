import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/features/programs/presentation/pages/program_detail_page.dart';

class ProgramCardHorizontal extends StatelessWidget {
  final Map<String, dynamic> data;
  const ProgramCardHorizontal({required this.data, super.key});

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
        width: 140,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF23242B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 90,
                width: double.infinity,
                color: Colors.grey[800],
                child: data['image'] != null
                    ? Image.network(
                        data['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(Icons.image, color: Colors.white24, size: 40),
                        ),
                      )
                    : Center(
                        child: Icon(Icons.image, color: Colors.white24, size: 40),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if ((data['badge'] ?? '').isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accent1,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(data['badge'], style: const TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  if ((data['badge'] ?? '').isNotEmpty) const SizedBox(height: 4),
                  Text(
                    data['title'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data['coach'],
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
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