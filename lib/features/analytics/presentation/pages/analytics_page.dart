import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/features/analytics/data/repositories/mock_analytics_repository.dart';
import 'package:jfit/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:jfit/features/analytics/presentation/widgets/diet_tab.dart';
import 'package:jfit/features/analytics/presentation/widgets/exercise_tab.dart';
import 'package:jfit/features/analytics/presentation/widgets/body_tab.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  static const routeName = '/analytics';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalyticsBloc(
        analyticsRepository: MockAnalyticsRepository(),
      )..add(const FetchAnalyticsData(period: '7d')),
      child: const _AnalyticsView(),
    );
  }
}

class _AnalyticsView extends StatefulWidget {
  const _AnalyticsView();

  @override
  State<_AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<_AnalyticsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getHeaderRange(String period) {
    final now = DateTime.now();
    DateTime start;
    switch (period) {
      case '7d':
        start = now.subtract(const Duration(days: 6));
        break;
      case '1m':
        start = now.subtract(const Duration(days: 29));
        break;
      case '3m':
        start = now.subtract(const Duration(days: 89));
        break;
      case '1y':
      default:
        start = DateTime(now.year - 1, now.month, now.day);
        break;
    }
    String formatDate(DateTime d) =>
        '${d.year}년 ${d.month.toString().padLeft(2, '0')}월 ${d.day.toString().padLeft(2, '0')}일';
    return '${formatDate(start)} - ${formatDate(now)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: BlocBuilder<AnalyticsBloc, AnalyticsState>(
          builder: (context, state) {
            if (state is AnalyticsLoaded) {
              return Text(
                _getHeaderRange(state.period),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              );
            }
            return const Text('');
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _CustomTabBar(
              controller: _tabController,
              tabs: const ['식단', '운동', '신체'],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DietTab(),
          ExerciseTab(),
          BodyTab(),
        ],
      ),
    );
  }
}

class _CustomTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;

  const _CustomTabBar({
    required this.controller,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.surface1.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.surface2.withOpacity(0.5), width: 1),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          gradient: AppTheme.accentGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent1.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorPadding: const EdgeInsets.all(4),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        dividerColor: Colors.transparent,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        tabAlignment: TabAlignment.fill,
        tabs: tabs.map((text) => Tab(text: text)).toList(),
      ),
    );
  }
}