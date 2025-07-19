import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../domain/entities/content_report.dart';
import '../../../domain/entities/moderation_action.dart';
import '../../bloc/content_moderation/content_moderation_bloc.dart';
import 'report_list_item.dart';
import 'moderation_action_dialog.dart';

class ModerationDashboard extends StatefulWidget {
  final String? groupId;

  const ModerationDashboard({
    super.key,
    this.groupId,
  });

  @override
  State<ModerationDashboard> createState() => _ModerationDashboardState();
}

class _ModerationDashboardState extends State<ModerationDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ReportStatus? _selectedStatus;
  ReportPriority? _selectedPriority;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    context.read<ContentModerationBloc>().add(
          LoadReportsForModerationEvent(
            groupId: widget.groupId,
            status: _selectedStatus,
            priority: _selectedPriority,
          ),
        );
    
    context.read<ContentModerationBloc>().add(
          LoadReportStatisticsEvent(
            groupId: widget.groupId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ContentModerationBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.groupId != null ? 'Group Moderation' : 'Global Moderation'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Reports', icon: Icon(Icons.report)),
              Tab(text: 'Actions', icon: Icon(Icons.gavel)),
              Tab(text: 'Statistics', icon: Icon(Icons.analytics)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildReportsTab(),
            _buildActionsTab(),
            _buildStatisticsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsTab() {
    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<ReportStatus?>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<ReportStatus?>(
                      value: null,
                      child: Text('All Statuses'),
                    ),
                    ...ReportStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.displayName),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                    _loadInitialData();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<ReportPriority?>(
                  value: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<ReportPriority?>(
                      value: null,
                      child: Text('All Priorities'),
                    ),
                    ...ReportPriority.values.map((priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(priority.displayName),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value;
                    });
                    _loadInitialData();
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Reports list
        Expanded(
          child: BlocBuilder<ContentModerationBloc, ContentModerationState>(
            builder: (context, state) {
              if (state is ContentModerationLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (state is ContentModerationError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text('Error: ${state.message}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadInitialData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              
              if (state is ModerationReportsLoaded) {
                if (state.reports.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No reports found'),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () async => _loadInitialData(),
                  child: ListView.builder(
                    itemCount: state.reports.length,
                    itemBuilder: (context, index) {
                      final report = state.reports[index];
                      return ReportListItem(
                        report: report,
                        onTakeAction: () => _showModerationActionDialog(report),
                        onUpdateStatus: (status) => _updateReportStatus(report.id, status),
                      );
                    },
                  ),
                );
              }
              
              return const Center(child: Text('No data available'));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionsTab() {
    return const Center(
      child: Text('Moderation Actions - Coming Soon'),
    );
  }

  Widget _buildStatisticsTab() {
    return BlocBuilder<ContentModerationBloc, ContentModerationState>(
      builder: (context, state) {
        if (state is ReportStatisticsLoaded) {
          return _buildStatisticsContent(state.statistics);
        }
        
        if (state is ContentModerationLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is ContentModerationError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        
        return const Center(child: Text('No statistics available'));
      },
    );
  }

  Widget _buildStatisticsContent(Map<String, dynamic> stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Reports',
                  stats['total_reports']?.toString() ?? '0',
                  Icons.report,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  stats['pending_reports']?.toString() ?? '0',
                  Icons.pending,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'High Priority',
                  stats['high_priority_reports']?.toString() ?? '0',
                  Icons.priority_high,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Resolved',
                  stats['resolved_reports']?.toString() ?? '0',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Reports by reason
          const Text(
            'Reports by Reason',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          if (stats['reports_by_reason'] != null)
            ...((stats['reports_by_reason'] as Map<String, dynamic>).entries.map(
              (entry) => ListTile(
                leading: const Icon(Icons.label),
                title: Text(entry.key),
                trailing: Text(
                  entry.value.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showModerationActionDialog(ContentReport report) {
    showDialog(
      context: context,
      builder: (context) => ModerationActionDialog(
        report: report,
        onActionTaken: () {
          Navigator.of(context).pop();
          _loadInitialData();
        },
      ),
    );
  }

  void _updateReportStatus(String reportId, ReportStatus status) {
    context.read<ContentModerationBloc>().add(
          UpdateReportStatusEvent(
            reportId: reportId,
            status: status,
          ),
        );
  }
}

// Extensions for display names
extension ReportStatusExtensions on ReportStatus {
  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.underReview:
        return 'Under Review';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.dismissed:
        return 'Dismissed';
    }
  }
}

extension ReportPriorityExtensions on ReportPriority {
  String get displayName {
    switch (this) {
      case ReportPriority.low:
        return 'Low';
      case ReportPriority.medium:
        return 'Medium';
      case ReportPriority.high:
        return 'High';
      case ReportPriority.urgent:
        return 'Urgent';
    }
  }
}