import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import 'package:jfit/l10n/app_localizations.dart';

class MemberDietDetailPage extends StatefulWidget {
  final String memberId;
  final String groupId;
  final String memberName;

  const MemberDietDetailPage({
    Key? key,
    required this.memberId,
    required this.groupId,
    required this.memberName,
  }) : super(key: key);

  @override
  State<MemberDietDetailPage> createState() => _MemberDietDetailPageState();
}

class _MemberDietDetailPageState extends State<MemberDietDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

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

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.memberName}의 식단 관리'),
        bottom: BreakpointUtils.isMobile(MediaQuery.of(context).size.width) 
            ? null 
            : TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '영양 요약'),
                  Tab(text: '식사 기록'),
                  Tab(text: '준수율'),
                  Tab(text: '피드백'),
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
    return Column(
      children: [
        _buildDateSelector(context),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildNutritionSummary(context),
                _buildMealHistory(context),
                _buildComplianceChart(context),
                _buildFeedbackList(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(BuildContext context) {
    return Column(
      children: [
        _buildDateSelector(context),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildNutritionSummary(context),
              _buildMealHistory(context),
              _buildComplianceChart(context),
              _buildFeedbackList(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _onDateChanged(_selectedDate.subtract(const Duration(days: 1)));
            },
          ),
          TextButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                _onDateChanged(date);
              }
            },
            child: Text(
              '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _selectedDate.isBefore(DateTime.now()) 
                ? () {
                    _onDateChanged(_selectedDate.add(const Duration(days: 1)));
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '영양 요약',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('영양 차트가 여기에 표시됩니다.'),
                  const SizedBox(height: 16),
                  Text('진행 차트가 여기에 표시됩니다.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealHistory(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '식사 기록',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('식사 기록이 여기에 표시됩니다.'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceChart(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '식단 준수율',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('준수율 차트가 여기에 표시됩니다.'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '피드백 내역',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () {
                  // Navigate to feedback creation page
                },
                child: const Text('피드백 작성'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('피드백 목록이 여기에 표시됩니다.'),
            ),
          ),
        ],
      ),
    );
  }
}