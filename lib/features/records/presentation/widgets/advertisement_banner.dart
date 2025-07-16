import 'package:flutter/material.dart';
import 'package:jfit/core/theme/theme_system.dart';

/// 광고/프로그램 배너 (간단한 그래디언트 카드)
class AdvertisementBanner extends StatelessWidget {
  const AdvertisementBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: context.colors.gradient,
      ),
      child: Builder(
        builder: (context) => Row(
          children: [
            Icon(Icons.track_changes, color: context.colors.textPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '프리미엄 운동 프로그램',
                style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold),
              ),
            ),
            Icon(Icons.open_in_new, color: context.colors.textPrimary),
          ],
        ),
      ),
    );
  }
} 