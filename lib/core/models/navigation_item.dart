import 'package:flutter/material.dart';

/// 네비게이션 아이템 모델
class NavigationItem {
  final IconData icon;
  final String label;
  final int index;

  const NavigationItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}