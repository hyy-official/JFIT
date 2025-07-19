import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/post_interaction/post_interaction_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/post_interaction/post_interaction_event.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/post_interaction/post_interaction_state.dart';

/// 북마크 및 공유 기능 위젯 - 플랫폼별 공유 옵션
class BookmarkShareWidget extends StatefulWidget {
  final String postId;
  final String userId;
  final String postTitle;
  final String postUrl;
  final bool isBookmarked;
  final bool isCompact;

  const BookmarkShareWidget({
    super.key,
    required this.postId,
    required this.userId,
    required this.postTitle,
    required this.postUrl,
    this.isBookmarked = false,
    this.isCompact = false,
  });

  @override
  State<BookmarkShareWidget> createState() => _BookmarkShareWidgetState();
}

class _BookmarkShareWidgetState extends State<BookmarkShareWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _bookmarkAnimationController;
  late Animation<double> _bookmarkScaleAnimation;
  
  bool _isBookmarked = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    
    _isBookmarked = widget.isBookmarked;
    
    _bookmarkAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _bookmarkScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _bookmarkAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _bookmarkAnimationController.dispose();
    super.dispose();
  }

  void _toggleBookmark() {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    // Optimistic update
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    
    // Animate
    _bookmarkAnimationController.forward().then((_) {
      _bookmarkAnimationController.reverse();
    });
    
    // Send to BLoC
    context.read<PostInteractionBloc>().add(ToggleBookmark(
      postId: widget.postId,
      userId: widget.userId,
    ));
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBookmarked ? '북마크에 추가되었습니다' : '북마크에서 제거되었습니다'),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Reset processing state
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildShareBottomSheet(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = BreakpointUtils.getDeviceType(constraints.maxWidth);
        
        if (widget.isCompact) {
          return _buildCompactButtons(deviceType);
        } else {
          return _buildFullButtons(deviceType);
        }
      },
    );
  }

  Widget _buildFullButtons(DeviceType deviceType) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bookmark button
        AnimatedBuilder(
          animation: _bookmarkScaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _bookmarkScaleAnimation.value,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggleBookmark,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: deviceType.isMobile ? 12 : 16,
                      vertical: deviceType.isMobile ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: _isBookmarked
                          ? colorScheme.secondaryContainer.withOpacity(0.3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isBookmarked
                            ? colorScheme.secondary
                            : colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                          size: deviceType.isMobile ? 16 : 18,
                          color: _isBookmarked
                              ? colorScheme.secondary
                              : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isBookmarked ? '저장됨' : '저장',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _isBookmarked
                                ? colorScheme.secondary
                                : colorScheme.onSurfaceVariant,
                            fontWeight: _isBookmarked ? FontWeight.w600 : FontWeight.normal,
                            fontSize: deviceType.isMobile ? 11 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(width: 8),
        
        // Share button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showShareOptions,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: deviceType.isMobile ? 12 : 16,
                vertical: deviceType.isMobile ? 6 : 8,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.share_outlined,
                    size: deviceType.isMobile ? 16 : 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '공유',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: deviceType.isMobile ? 11 : 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactButtons(DeviceType deviceType) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Compact bookmark button
        AnimatedBuilder(
          animation: _bookmarkScaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _bookmarkScaleAnimation.value,
              child: IconButton(
                onPressed: _toggleBookmark,
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  color: _isBookmarked 
                      ? colorScheme.secondary 
                      : colorScheme.onSurfaceVariant,
                ),
                iconSize: deviceType.isMobile ? 18 : 20,
                constraints: BoxConstraints(
                  minWidth: BreakpointUtils.minTouchTarget,
                  minHeight: BreakpointUtils.minTouchTarget,
                ),
                tooltip: _isBookmarked ? '북마크 제거' : '북마크 추가',
              ),
            );
          },
        ),
        
        // Compact share button
        IconButton(
          onPressed: _showShareOptions,
          icon: Icon(
            Icons.share_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
          iconSize: deviceType.isMobile ? 18 : 20,
          constraints: BoxConstraints(
            minWidth: BreakpointUtils.minTouchTarget,
            minHeight: BreakpointUtils.minTouchTarget,
          ),
          tooltip: '공유',
        ),
      ],
    );
  }

  Widget _buildShareBottomSheet() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            '공유하기',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Share options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareOption(
                icon: Icons.link,
                label: '링크 복사',
                onTap: _copyLink,
              ),
              _buildShareOption(
                icon: Icons.message,
                label: '메시지',
                onTap: _shareToMessages,
              ),
              _buildShareOption(
                icon: Icons.email,
                label: '이메일',
                onTap: _shareToEmail,
              ),
              _buildShareOption(
                icon: Icons.more_horiz,
                label: '더보기',
                onTap: _shareToOthers,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Cancel button
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          
          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: widget.postUrl));
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('링크가 클립보드에 복사되었습니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareToMessages() {
    Navigator.of(context).pop();
    // TODO: Implement share to messages
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('메시지 공유 기능 구현 예정')),
    );
  }

  void _shareToEmail() {
    Navigator.of(context).pop();
    // TODO: Implement share to email
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('이메일 공유 기능 구현 예정')),
    );
  }

  void _shareToOthers() {
    Navigator.of(context).pop();
    // TODO: Implement native share
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('시스템 공유 기능 구현 예정')),
    );
  }
}