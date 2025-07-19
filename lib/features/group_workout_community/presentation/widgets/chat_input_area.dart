import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/breakpoint_utils.dart';

class ChatInputArea extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSendMessage;
  final Function(String) onTypingChanged;
  final Function(String) onImagePicked;
  final VoidCallback onWorkoutShare;

  const ChatInputArea({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSendMessage,
    required this.onTypingChanged,
    required this.onImagePicked,
    required this.onWorkoutShare,
  });

  @override
  State<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea> {
  bool _isExpanded = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    widget.onTypingChanged(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(
            left: _getPaddingForScreenWidth(screenWidth),
            right: _getPaddingForScreenWidth(screenWidth),
            top: 12,
            bottom: keyboardHeight > 0 ? 12 : 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Expanded options
              if (_isExpanded)
                _buildExpandedOptions(screenWidth),
              
              // Main input row
              _buildMainInputRow(screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  double _getPaddingForScreenWidth(double screenWidth) {
    if (BreakpointUtils.isMobile(screenWidth)) {
      return 16.0;
    } else if (BreakpointUtils.isTablet(screenWidth)) {
      return 20.0;
    } else {
      return 24.0;
    }
  }

  Widget _buildExpandedOptions(double screenWidth) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildOptionButton(
            icon: Icons.photo_camera,
            label: 'Camera',
            onTap: () => _pickImage(ImageSource.camera),
          ),
          _buildOptionButton(
            icon: Icons.photo_library,
            label: 'Gallery',
            onTap: () => _pickImage(ImageSource.gallery),
          ),
          _buildOptionButton(
            icon: Icons.fitness_center,
            label: 'Workout',
            onTap: widget.onWorkoutShare,
          ),
          if (BreakpointUtils.isDesktop(screenWidth))
            _buildOptionButton(
              icon: Icons.attach_file,
              label: 'File',
              onTap: () {
                // TODO: Implement file sharing
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('File sharing coming soon')),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        onTap();
        setState(() {
          _isExpanded = false;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInputRow(double screenWidth) {
    final isMobile = BreakpointUtils.isMobile(screenWidth);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Expand button (mobile only)
        if (isMobile)
          IconButton(
            icon: Icon(
              _isExpanded ? Icons.close : Icons.add,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
        
        // Quick action buttons (tablet/desktop)
        if (!isMobile) ...[
          IconButton(
            icon: const Icon(Icons.photo_camera),
            onPressed: () => _pickImage(ImageSource.camera),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: () => _pickImage(ImageSource.gallery),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          IconButton(
            icon: const Icon(Icons.fitness_center),
            onPressed: widget.onWorkoutShare,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ],
        
        // Text input field
        Expanded(
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 40,
              maxHeight: 120,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
              onSubmitted: (_) {
                if (widget.controller.text.trim().isNotEmpty) {
                  widget.onSendMessage();
                }
              },
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Send button
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: widget.controller,
          builder: (context, value, child) {
            final hasText = value.text.trim().isNotEmpty;
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                icon: Icon(
                  hasText ? Icons.send : Icons.mic,
                  color: hasText
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                onPressed: hasText
                    ? widget.onSendMessage
                    : () {
                        // TODO: Implement voice message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Voice messages coming soon')),
                        );
                      },
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        widget.onImagePicked(image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}