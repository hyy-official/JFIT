import 'package:flutter/material.dart';
import '../../../domain/entities/content_report.dart';

class ReportListItem extends StatelessWidget {
  final ContentReport report;
  final VoidCallback onTakeAction;
  final Function(ReportStatus) onUpdateStatus;

  const ReportListItem({
    super.key,
    required this.report,
    required this.onTakeAction,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: _buildPriorityIcon(),
        title: Text(
          '${report.reportedContentType.displayName.toUpperCase()} - ${report.reportReason.displayName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(),
                const SizedBox(width: 8),
                Text(
                  'Reported ${_formatTimeAgo(report.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Report details
                if (report.reportDescription != null) ...[
                  const Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(report.reportDescription!),
                  const SizedBox(height: 16),
                ],
                
                // Report metadata
                _buildInfoRow('Report ID', report.id),
                _buildInfoRow('Content ID', report.reportedContentId),
                if (report.reportedUserId != null)
                  _buildInfoRow('Reported User', report.reportedUserId!),
                if (report.groupId != null)
                  _buildInfoRow('Group ID', report.groupId!),
                _buildInfoRow('Priority', report.priority.displayName),
                _buildInfoRow('Created', report.createdAt.toString()),
                _buildInfoRow('Updated', report.updatedAt.toString()),
                
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  children: [
                    if (report.status == ReportStatus.pending) ...[
                      ElevatedButton.icon(
                        onPressed: () => onUpdateStatus(ReportStatus.underReview),
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('Review'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    
                    if (report.status != ReportStatus.resolved) ...[
                      ElevatedButton.icon(
                        onPressed: onTakeAction,
                        icon: const Icon(Icons.gavel, size: 16),
                        label: const Text('Take Action'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    
                    if (report.status != ReportStatus.dismissed) ...[
                      OutlinedButton.icon(
                        onPressed: () => onUpdateStatus(ReportStatus.dismissed),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Dismiss'),
                      ),
                      const SizedBox(width: 8),
                    ],
                    
                    if (report.status != ReportStatus.resolved) ...[
                      OutlinedButton.icon(
                        onPressed: () => onUpdateStatus(ReportStatus.resolved),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Resolve'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityIcon() {
    IconData icon;
    Color color;
    
    switch (report.priority) {
      case ReportPriority.urgent:
        icon = Icons.warning;
        color = Colors.red;
        break;
      case ReportPriority.high:
        icon = Icons.priority_high;
        color = Colors.orange;
        break;
      case ReportPriority.medium:
        icon = Icons.remove;
        color = Colors.blue;
        break;
      case ReportPriority.low:
        icon = Icons.low_priority;
        color = Colors.green;
        break;
    }
    
    return Icon(icon, color: color);
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;
    
    switch (report.status) {
      case ReportStatus.pending:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      case ReportStatus.underReview:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        break;
      case ReportStatus.resolved:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case ReportStatus.dismissed:
        backgroundColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        report.status.displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// Extensions for display names (if not already defined elsewhere)
extension ReportStatusDisplayExtension on ReportStatus {
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

extension ReportPriorityDisplayExtension on ReportPriority {
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

extension ReportReasonDisplayExtension on ReportReason {
  String get displayName {
    switch (this) {
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.harassment:
        return 'Harassment';
      case ReportReason.inappropriateContent:
        return 'Inappropriate Content';
      case ReportReason.hateSpeech:
        return 'Hate Speech';
      case ReportReason.violence:
        return 'Violence';
      case ReportReason.misinformation:
        return 'Misinformation';
      case ReportReason.copyright:
        return 'Copyright';
      case ReportReason.other:
        return 'Other';
    }
  }
}

extension ReportedContentTypeDisplayExtension on ReportedContentType {
  String get displayName {
    switch (this) {
      case ReportedContentType.post:
        return 'post';
      case ReportedContentType.comment:
        return 'comment';
      case ReportedContentType.message:
        return 'message';
      case ReportedContentType.user:
        return 'user';
    }
  }
}