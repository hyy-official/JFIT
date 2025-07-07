import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_state.dart';

class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final int currentIndex;
  final void Function(int)? onNavTap;
  final VoidCallback? onAiTap;
  final Widget? rightPanel;
  final double rightPanelWidth;
  final bool showDefaultRightPanel;
  final DateTime? selectedDate;
  final UserDailySummary? dailySummary;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    this.currentIndex = 0,
    this.onNavTap,
    this.onAiTap,
    required this.body,
    this.rightPanel,
    this.rightPanelWidth = 300,
    this.showDefaultRightPanel = true,
    this.selectedDate,
    this.dailySummary,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 1200;
    final showRightPanel = isWide && (rightPanel != null || showDefaultRightPanel);
    
    return Scaffold(
      appBar: appBar,
      drawer: isWide ? null : null,
      bottomNavigationBar: isWide ? null : _BottomNavigation(currentIndex: currentIndex, onTap: onNavTap, onAiTap: onAiTap),
      body: Row(
        children: [
          if (isWide)
            Flexible(
              flex: 3, // 약 15%
              child: _SideNavigation(currentIndex: currentIndex, onTap: onNavTap, onAiTap: onAiTap),
            ),
          if (isWide)
            VerticalDivider(width: 1, color: AppTheme.surface2),
          Flexible(
            flex: isWide ? 14 : 1, // 약 70% (모바일에서는 전체)
            child: body,
          ),
          if (showRightPanel)
            VerticalDivider(width: 1, color: AppTheme.surface2),
          if (showRightPanel)
            Flexible(
              flex: 3, // 약 15%
              child: rightPanel ?? _DefaultRightPanel(
                selectedDate: selectedDate ?? DateTime.now(),
                dailySummary: dailySummary,
              ),
            ),
        ],
      ),
    );
  }
}

/// 기본 우측 사이드 패널 (데스크톱 전용)
class _DefaultRightPanel extends StatelessWidget {
  final DateTime selectedDate;
  final UserDailySummary? dailySummary;
  
  const _DefaultRightPanel({
    required this.selectedDate,
    this.dailySummary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.secondaryBackground1,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '오늘의 요약',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _SummaryTile(label: '운동', value: '${dailySummary?.totalWorkoutDurationMinutes ?? 0}분'),
            _SummaryTile(label: '칼로리', value: '${dailySummary?.totalCaloriesConsumed ?? 0}kcal'),
            const SizedBox(height: 24),
            const _PremiumCard(),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  
  const _SummaryTile({required this.label, required this.value});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: AppTheme.accentGradient,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.track_changes, color: Colors.white),
          const SizedBox(height: 12),
          const Text('프리미엄 플랜', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          const Text('더 많은 기능을 경험해보세요', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
            ),
            onPressed: () {},
            child: const Text('업그레이드'),
          ),
        ],
      ),
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
      width: 280,
      color: AppTheme.secondaryBackground1,
      child: Column(
        children: [
          // ----- Header (Logo + App name) -----
          Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.fitness_center, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('JFIT', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                      SizedBox(height: 2),
                      Text('하루의 일기장', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          const SizedBox(height: 12),
          _NavIcon(horizontal: true, icon: Icons.restaurant, label: l10n?.diet ?? '식단', selected: currentIndex == 0, onTap: () => onTap?.call(0)),
          _NavIcon(horizontal: true, icon: Icons.show_chart, label: l10n?.dashboard ?? '대시보드', selected: currentIndex == 1, onTap: () => onTap?.call(1)),
          _NavIcon(horizontal: true, icon: Icons.fitness_center, label: l10n?.exercise ?? '운동 기록', selected: currentIndex == 2, onTap: () => onTap?.call(2)),
          _NavIcon(horizontal: true, icon: Icons.timer, label: l10n?.workout ?? '내 운동', selected: currentIndex == 3, onTap: () => onTap?.call(3)),
          _NavIcon(horizontal: true, icon: Icons.extension, label: l10n?.routine ?? '루틴', selected: currentIndex == 4, onTap: () => onTap?.call(4)),
          Spacer(),
          // ----- Bottom Profile -----
          const _BottomProfile(),
          SizedBox(height: 16),
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
  final bool horizontal;
  const _NavIcon({required this.icon, required this.label, this.selected = false, this.onTap, this.horizontal = false});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 50,
            alignment: Alignment.center,
            child: horizontal
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(icon, color: selected ? Colors.deepPurple : Colors.grey[500], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: selected ? Colors.deepPurple : Colors.grey[500],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: selected ? Colors.deepPurple : Colors.grey[500], size: 20),
                      const SizedBox(height: 1),
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
          _NavIcon(icon: Icons.restaurant, label: l10n?.diet ?? '식단', selected: currentIndex == 0, onTap: () => onTap?.call(0)),
          _NavIcon(icon: Icons.show_chart, label: l10n?.dashboard ?? '대시보드', selected: currentIndex == 1, onTap: () => onTap?.call(1)),
          _NavIcon(icon: Icons.fitness_center, label: l10n?.exercise ?? '운동 기록', selected: currentIndex == 2, onTap: () => onTap?.call(2)),
          _NavIcon(icon: Icons.timer, label: l10n?.workout ?? '내 운동', selected: currentIndex == 3, onTap: () => onTap?.call(3)),
          _NavIcon(icon: Icons.extension, label: l10n?.routine ?? '루틴', selected: currentIndex == 4, onTap: () => onTap?.call(4)),
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

class _BottomProfile extends StatelessWidget {
  const _BottomProfile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String displayName = 'Guest';
        String subtitle = 'Welcome!';

        if (state is AuthAuthenticated) {
          final user = state.user;
          displayName = user.fullName?.isNotEmpty == true ? user.fullName! : user.username;
          subtitle = user.email;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(color: AppTheme.surface1),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.accent1,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 