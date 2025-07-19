import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../domain/entities/content_report.dart';
import '../../../domain/entities/moderation_action.dart';
import '../../bloc/content_moderation/content_moderation_bloc.dart';

class ModerationActionDialog extends StatefulWidget {
  final ContentReport report;
  final VoidCallback onActionTaken;

  const ModerationActionDialog({
    super.key,
    required this.report,
    required this.onActionTaken,
  });

  @override
  State<ModerationActionDialog> createState() => _ModerationActionDialogState();
}

class _ModerationActionDialogState extends State<ModerationActionDialog> {
  ModerationActionType? _selectedActionType;
  final _reasonController = TextEditingController();
  final _durationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ContentModerationBloc>(),
      child: BlocConsumer<ContentModerationBloc, ContentModerationState>(
        listener: (context, state) {
          if (state is ModerationActionCreated) {
            widget.onActionTaken();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Moderation action taken successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ContentModerationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to take action: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return AlertDialog(
            title: const Text('Take Moderation Action'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Report summary
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Report: ${widget.report.reportReason.displayName}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Content: ${widget.report.reportedContentType.displayName}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (widget.report.reportDescription != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.report.reportDescription!,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Action type selection
                    const Text(
                      'Select Action:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    ...ModerationActionType.values.map((actionType) => 
                      RadioListTile<ModerationActionType>(
                        title: Text(actionType.displayName),
                        subtitle: Text(
                          actionType.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        value: actionType,
                        groupValue: _selectedActionType,
                        onChanged: (value) {
                          setState(() {
                            _selectedActionType = value;
                          });
                        },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Duration field (for temporary actions)
                    if (_selectedActionType == ModerationActionType.temporaryBan) ...[
                      TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(
                          labelText: 'Duration (hours)',
                          hintText: 'e.g., 24, 72, 168',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Duration is required for temporary bans';
                          }
                          final duration = int.tryParse(value);
                          if (duration == null || duration <= 0) {
                            return 'Please enter a valid duration in hours';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Reason field
                    TextFormField(
                      controller: _reasonController,
                      decoration: const InputDecoration(
                        labelText: 'Action Reason *',
                        hintText: 'Explain why you are taking this action...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      maxLength: 500,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Action reason is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: state is ContentModerationLoading 
                    ? null 
                    : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: state is ContentModerationLoading || _selectedActionType == null
                    ? null
                    : () => _takeAction(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: state is ContentModerationLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Take Action'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _takeAction(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      int? durationHours;
      if (_selectedActionType == ModerationActionType.temporaryBan) {
        durationHours = int.tryParse(_durationController.text);
      }

      // Determine target content type based on report
      ModerationTargetType targetContentType;
      switch (widget.report.reportedContentType) {
        case ReportedContentType.post:
          targetContentType = ModerationTargetType.post;
          break;
        case ReportedContentType.comment:
          targetContentType = ModerationTargetType.comment;
          break;
        case ReportedContentType.message:
          targetContentType = ModerationTargetType.message;
          break;
        case ReportedContentType.user:
          targetContentType = ModerationTargetType.user;
          break;
      }

      context.read<ContentModerationBloc>().add(
        CreateModerationActionEvent(
          reportId: widget.report.id,
          targetContentType: targetContentType,
          targetContentId: widget.report.reportedContentId,
          targetUserId: widget.report.reportedUserId ?? widget.report.reporterId,
          actionType: _selectedActionType!,
          actionReason: _reasonController.text.trim(),
          durationHours: durationHours,
        ),
      );
    }
  }
}

// Extensions for display names and descriptions
extension ModerationActionTypeExtensions on ModerationActionType {
  String get displayName {
    switch (this) {
      case ModerationActionType.warning:
        return 'Warning';
      case ModerationActionType.contentRemoval:
        return 'Remove Content';
      case ModerationActionType.contentEdit:
        return 'Edit Content';
      case ModerationActionType.temporaryBan:
        return 'Temporary Ban';
      case ModerationActionType.permanentBan:
        return 'Permanent Ban';
      case ModerationActionType.groupRemoval:
        return 'Remove from Group';
      case ModerationActionType.dismissReport:
        return 'Dismiss Report';
    }
  }

  String get description {
    switch (this) {
      case ModerationActionType.warning:
        return 'Send a warning to the user about their behavior';
      case ModerationActionType.contentRemoval:
        return 'Remove the reported content from the platform';
      case ModerationActionType.contentEdit:
        return 'Edit or modify the reported content';
      case ModerationActionType.temporaryBan:
        return 'Temporarily ban the user for a specified duration';
      case ModerationActionType.permanentBan:
        return 'Permanently ban the user from the platform';
      case ModerationActionType.groupRemoval:
        return 'Remove the user from the specific group';
      case ModerationActionType.dismissReport:
        return 'Dismiss the report without taking action';
    }
  }
}