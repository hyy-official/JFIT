import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../domain/entities/content_report.dart';
import '../../bloc/content_moderation/content_moderation_bloc.dart';

class ReportContentDialog extends StatefulWidget {
  final ReportedContentType contentType;
  final String contentId;
  final String? reportedUserId;
  final String? groupId;
  final String contentPreview;

  const ReportContentDialog({
    super.key,
    required this.contentType,
    required this.contentId,
    this.reportedUserId,
    this.groupId,
    required this.contentPreview,
  });

  @override
  State<ReportContentDialog> createState() => _ReportContentDialogState();
}

class _ReportContentDialogState extends State<ReportContentDialog> {
  ReportReason? _selectedReason;
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ContentModerationBloc>(),
      child: BlocConsumer<ContentModerationBloc, ContentModerationState>(
        listener: (context, state) {
          if (state is ContentModerationSuccess) {
            Navigator.of(context).pop(true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Report submitted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ContentModerationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to submit report: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return AlertDialog(
            title: const Text('Report Content'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Content preview
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
                            'Reporting ${widget.contentType.displayName}:',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.contentPreview,
                            style: const TextStyle(fontSize: 14),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Report reason selection
                    const Text(
                      'Why are you reporting this content?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    ...ReportReason.values.map((reason) => RadioListTile<ReportReason>(
                      title: Text(reason.displayName),
                      subtitle: Text(
                        reason.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      value: reason,
                      groupValue: _selectedReason,
                      onChanged: (value) {
                        setState(() {
                          _selectedReason = value;
                        });
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    )),
                    
                    const SizedBox(height: 16),
                    
                    // Additional description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Additional details (optional)',
                        hintText: 'Provide more context about why you\'re reporting this content...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      maxLength: 500,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: state is ContentModerationLoading 
                    ? null 
                    : () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: state is ContentModerationLoading || _selectedReason == null
                    ? null
                    : () => _submitReport(context),
                child: state is ContentModerationLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Report'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _submitReport(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ContentModerationBloc>().add(
        SubmitContentReportEvent(
          contentType: widget.contentType,
          contentId: widget.contentId,
          reportedUserId: widget.reportedUserId,
          groupId: widget.groupId,
          reportReason: _selectedReason!,
          reportDescription: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
        ),
      );
    }
  }
}

// Extension to add display names and descriptions for report reasons
extension ReportReasonExtensions on ReportReason {
  String get displayName {
    switch (this) {
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.harassment:
        return 'Harassment or Bullying';
      case ReportReason.inappropriateContent:
        return 'Inappropriate Content';
      case ReportReason.hateSpeech:
        return 'Hate Speech';
      case ReportReason.violence:
        return 'Violence or Threats';
      case ReportReason.misinformation:
        return 'False Information';
      case ReportReason.copyright:
        return 'Copyright Violation';
      case ReportReason.other:
        return 'Other';
    }
  }

  String get description {
    switch (this) {
      case ReportReason.spam:
        return 'Unwanted commercial content or repetitive posts';
      case ReportReason.harassment:
        return 'Targeting someone with unwanted or harmful behavior';
      case ReportReason.inappropriateContent:
        return 'Content that violates community guidelines';
      case ReportReason.hateSpeech:
        return 'Content that attacks people based on identity';
      case ReportReason.violence:
        return 'Threats of violence or harmful content';
      case ReportReason.misinformation:
        return 'False or misleading information';
      case ReportReason.copyright:
        return 'Unauthorized use of copyrighted material';
      case ReportReason.other:
        return 'Something else not covered by other categories';
    }
  }
}

extension ReportedContentTypeExtensions on ReportedContentType {
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