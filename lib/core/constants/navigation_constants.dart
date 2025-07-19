import 'package:flutter/material.dart';
import 'package:jfit/core/models/navigation_item.dart';

/// 앱 전체에서 사용하는 네비게이션 아이템 상수들
class NavigationConstants {
  static const int homeIndex = 0;
  static const int workoutIndex = 1;
  static const int programsIndex = 2;
  static const int groupsIndex = 3;
  static const int communityIndex = 4;
  
  /// 기본 네비게이션 아이템들
  static const List<NavigationItem> defaultNavigationItems = [
    NavigationItem(icon: Icons.restaurant, label: '홈', index: homeIndex),
    NavigationItem(icon: Icons.timer, label: '내 운동', index: workoutIndex),
    NavigationItem(icon: Icons.extension, label: '루틴', index: programsIndex),
    NavigationItem(icon: Icons.group, label: '그룹', index: groupsIndex),
    NavigationItem(icon: Icons.forum, label: '커뮤니티', index: communityIndex),
  ];
}