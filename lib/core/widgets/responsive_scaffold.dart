import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';

class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final int currentIndex;
  final void Function(int)? onNavTap;
  final VoidCallback? onAiTap;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.currentIndex = 0,
    this.onNavTap,
    this.onAiTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      appBar: appBar,
      drawer: isWide ? null : null,
      body: Row(
        children: [
          if (isWide)
            _SideNavigation(currentIndex: currentIndex, onTap: onNavTap, onAiTap: onAiTap),
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : _BottomNavigation(currentIndex: currentIndex, onTap: onNavTap, onAiTap: onAiTap),
      floatingActionButton: isWide && onAiTap != null
          ? FloatingActionButton(
              onPressed: onAiTap,
              child: Icon(Icons.smart_toy),
              backgroundColor: Colors.deepPurple,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

class _SideNavigation extends StatelessWidget {
  final int currentIndex;
  final void Function(int)? onTap;
  final VoidCallback? onAiTap;
  const _SideNavigation({this.currentIndex = 0, this.onTap, this.onAiTap});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: 80,
      color: Colors.black,
      child: Column(
        children: [
          SizedBox(height: 24),
          Icon(Icons.fitness_center, color: Colors.deepPurple, size: 36),
          SizedBox(height: 32),
          _NavIcon(icon: Icons.show_chart, label: l10n?.dashboard ?? '대시보드', selected: currentIndex == 0, onTap: () => onTap?.call(0)),
          _NavIcon(icon: Icons.fitness_center, label: l10n?.exercise ?? '운동 기록', selected: currentIndex == 1, onTap: () => onTap?.call(1)),
          _NavIcon(icon: Icons.timer, label: l10n?.workout ?? '내 운동', selected: currentIndex == 2, onTap: () => onTap?.call(2)),
          _NavIcon(icon: Icons.extension, label: l10n?.routine ?? '루틴', selected: currentIndex == 3, onTap: () => onTap?.call(3)),
          _NavIcon(icon: Icons.restaurant, label: l10n?.diet ?? '식단', selected: currentIndex == 4, onTap: () => onTap?.call(4)),
          Spacer(),
          if (onAiTap != null)
            IconButton(
              icon: Icon(Icons.smart_toy, color: Colors.white),
              onPressed: onAiTap,
              tooltip: 'AI',
            ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _NavIcon({required this.icon, required this.label, this.selected = false, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: selected ? Colors.deepPurple : Colors.grey[500], size: 20),
                SizedBox(height: 1),
                Flexible(
                  child: Text(
                    label, 
                    style: TextStyle(
                      color: selected ? Colors.deepPurple : Colors.grey[500], 
                      fontSize: 9,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final void Function(int)? onTap;
  final VoidCallback? onAiTap;
  const _BottomNavigation({this.currentIndex = 0, this.onTap, this.onAiTap});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BottomAppBar(
      color: Colors.black,
      height: 65,
      child: Row(
        children: [
          _NavIcon(icon: Icons.show_chart, label: l10n?.dashboard ?? '대시보드', selected: currentIndex == 0, onTap: () => onTap?.call(0)),
          _NavIcon(icon: Icons.fitness_center, label: l10n?.exercise ?? '운동 기록', selected: currentIndex == 1, onTap: () => onTap?.call(1)),
          _NavIcon(icon: Icons.timer, label: l10n?.workout ?? '내 운동', selected: currentIndex == 2, onTap: () => onTap?.call(2)),
          _NavIcon(icon: Icons.extension, label: l10n?.routine ?? '루틴', selected: currentIndex == 3, onTap: () => onTap?.call(3)),
          _NavIcon(icon: Icons.restaurant, label: l10n?.diet ?? '식단', selected: currentIndex == 4, onTap: () => onTap?.call(4)),
          if (onAiTap != null)
            Expanded(
              child: IconButton(
                icon: Icon(Icons.smart_toy, color: Colors.white, size: 20),
                onPressed: onAiTap,
                tooltip: 'AI',
              ),
            ),
        ],
      ),
    );
  }
} 