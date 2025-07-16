import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../theme/theme_system.dart';

/// 테마 전환 버튼 위젯
class ThemeToggleButton extends StatelessWidget {
  final bool showLabel;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;

  const ThemeToggleButton({
    super.key,
    this.showLabel = false,
    this.iconSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: padding ?? const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colors.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => _showThemeSelector(context, themeManager),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      themeManager.themeIcon,
                      key: ValueKey(themeManager.themeMode),
                      size: iconSize ?? 20,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  if (showLabel) ...[
                    const SizedBox(width: 8),
                    Text(
                      themeManager.themeName,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 테마 선택 다이얼로그 표시
  void _showThemeSelector(BuildContext context, ThemeManager themeManager) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ThemeSelector(themeManager: themeManager),
    );
  }
}

/// 테마 선택 바텀시트
class ThemeSelector extends StatelessWidget {
  final ThemeManager themeManager;

  const ThemeSelector({
    super.key,
    required this.themeManager,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.colors.border,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 제목
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              '테마 선택',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ),
          
          // 테마 옵션들
          _buildThemeOption(
            context,
            title: '라이트 모드',
            subtitle: '밝은 테마',
            icon: Icons.light_mode,
            mode: ThemeMode.light,
            isSelected: themeManager.themeMode == ThemeMode.light,
          ),
          
          _buildThemeOption(
            context,
            title: '다크 모드',
            subtitle: '어두운 테마',
            icon: Icons.dark_mode,
            mode: ThemeMode.dark,
            isSelected: themeManager.themeMode == ThemeMode.dark,
          ),
          
          _buildThemeOption(
            context,
            title: '시스템 설정',
            subtitle: '기기 설정에 따라 자동 변경',
            icon: Icons.brightness_auto,
            mode: ThemeMode.system,
            isSelected: themeManager.themeMode == ThemeMode.system,
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
    required bool isSelected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected 
            ? context.colors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? context.colors.primary
              : context.colors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected 
                ? context.colors.primary
                : context.colors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected 
                ? context.colors.textPrimary
                : context.colors.textSecondary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: context.colors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: context.colors.primary,
                size: 24,
              )
            : null,
        onTap: () {
          themeManager.setThemeMode(mode);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}