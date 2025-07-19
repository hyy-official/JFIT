import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import 'package:jfit/l10n/app_localizations.dart';

class DietAnalysisReportPage extends StatefulWidget {
  final String groupId;
  final DateTime startDate;
  final DateTime endDate;

  const DietAnalysisReportPage({
    Key? key,
    required this.groupId,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  State<DietAnalysisReportPage> createState() => _DietAnalysisReportPageState();
}

class _DietAnalysisReportPageState extends State<DietAnalysisReportPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('식단 분석 리포트'),
        bottom: BreakpointUtils.isMobile(MediaQuery.of(context).size.width) 
            ? null 
            : TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '영양소 분석'),
                  Tab(text: '식사 패턴'),
                  Tab(text: '준수율 분석'),
                  Tab(text: '진행 상황'),
                ],
              ),
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (BreakpointUtils.isMobile(MediaQuery.of(context).size.width)) {
      return _buildMobileContent(context);
    } else {
      return _buildTabContent(context);
    }
  }

  Widget _buildMobileContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDateRangeInfo(context),
          _buildNutritionAnalysis(context),
          _buildMealPatternAnalysis(context),
          _buildComplianceAnalysis(context),
          _buildProgressAnalysis(context),
        ],
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    return Column(
      children: [
        _buildDateRangeInfo(context),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildNutritionAnalysis(context),
              _buildMealPatternAnalysis(context),
              _buildComplianceAnalysis(context),
              _buildProgressAnalysis(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '분석 기간: ${widget.startDate.year}/${widget.startDate.month}/${widget.startDate.day} - '
            '${widget.endDate.year}/${widget.endDate.month}/${widget.endDate.day}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionAnalysis(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '영양소 분석',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('영양소 차트가 여기에 표시됩니다.'),
                  const SizedBox(height: 16),
                  Text('영양소 섭취 분석 내용이 여기에 표시됩니다.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealPatternAnalysis(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '식사 패턴 분석',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('식사 분포 차트가 여기에 표시됩니다.'),
                  const SizedBox(height: 16),
                  Text('식사 패턴 분석 내용이 여기에 표시됩니다.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceAnalysis(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '준수율 분석',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('준수율 차트가 여기에 표시됩니다.'),
                  const SizedBox(height: 16),
                  Text('준수율 분석 내용이 여기에 표시됩니다.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressAnalysis(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '진행 상황 분석',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('진행 상황 차트가 여기에 표시됩니다.'),
                  const SizedBox(height: 16),
                  Text('진행 상황 분석 내용이 여기에 표시됩니다.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}