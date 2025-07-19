import 'package:flutter/material.dart';
import '../../../domain/entities/content_report.dart';
import 'report_content_dialog.dart';

class ReportContentButton extends StatelessWidget {
  final ReportedContentType contentType;
  final String contentId;
  final String? reportedUserId;
  final String? groupId;
  final String contentPreview;
  final Widget? child;
  final bool showIcon;
  final String? tooltip;

  const ReportContentButton({
    super.key,
    required this.contentType,
    required this.contentId,
    this.reportedUserId,
    this.groupId,
    required this.contentPreview,
    this.child,
    this.showIcon = true,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = child ?? (showIcon 
        ? IconButton(
            icon: const Icon(Icons.flag_outlined),
            onPressed: () => _showReportDialog(context),
            tooltip: tooltip ?? 'Report content',
          )
        : TextButton.icon(
            icon: const Icon(Icons.flag_outlined, size: 16),
            label: const Text('Report'),
            onPressed: () => _showReportDialog(context),
          ));

    return button;
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ReportContentDialog(
        contentType: contentType,
        contentId: contentId,
        reportedUserId: reportedUserId,
        groupId: groupId,
        contentPreview: contentPreview,
      ),
    );
  }
}

/// A mixin that can be used by widgets that display content to easily add reporting functionality
mixin ReportableContentMixin<T extends StatefulWidget> on State<T> {
  void showReportDialog({
    required ReportedContentType contentType,
    required String contentId,
    String? reportedUserId,
    String? groupId,
    required String contentPreview,
  }) {
    showDialog(
      context: context,
      builder: (context) => ReportContentDialog(
        contentType: contentType,
        contentId: contentId,
        reportedUserId: reportedUserId,
        groupId: groupId,
        contentPreview: contentPreview,
      ),
    );
  }

  Widget buildReportButton({
    required ReportedContentType contentType,
    required String contentId,
    String? reportedUserId,
    String? groupId,
    required String contentPreview,
    Widget? child,
    bool showIcon = true,
    String? tooltip,
  }) {
    return ReportContentButton(
      contentType: contentType,
      contentId: contentId,
      reportedUserId: reportedUserId,
      groupId: groupId,
      contentPreview: contentPreview,
      showIcon: showIcon,
      tooltip: tooltip,
      child: child,
    );
  }
}