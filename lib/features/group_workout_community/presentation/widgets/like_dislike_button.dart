import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/post_interaction/post_interaction_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/post_interaction/post_interaction_event.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/post_interaction/post_interaction_state.dart';

/// 좋아요/싫어요 버튼 위젯 - 터치 영역 최적화, 애니메이션 효과
class LikeDislikeButton extends StatefulWidget {
  final String postId;
  final String? commentId;
  final String userId;
  final int likesCount;
  final int dislikesCount;
  final bool isLiked;
  final bool isDisliked;
  final bool showDislike;
  final bool isCompact;

  const LikeDislikeButton({
    super.key,
    required this.postId,
    this.commentId,
    required this.userId,
    required this.likesCount,
    this.dislikesCount = 0,
    this.isLiked = false,
    this.isDisliked = false,
    this.showDislike = true,
    this.isCompact = false,
  });

  @override
  State<LikeDislikeButton> createState() => _LikeDislikeButtonState();
}

class _LikeDislikeButtonState extends State<LikeDislikeButton>
    with TickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late AnimationController _dislikeAnimationController;
  late Animation<double> _likeScaleAnimation;
  late Animation<double> _dislikeScaleAnimation;
  
  bool _isLiked = false;
  bool _isDisliked = false;
  int _likesCount = 0;
  int _dislikesCount = 0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    
    _isLiked = widget.isLiked;
    _isDisliked = widget.isDisliked;
    _likesCount = widget.likesCount;
    _dislikesCount = widget.dislikesCount;
    
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _dislikeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _likeScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _dislikeScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _dislikeAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _dislikeAnimationController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    // Optimistic update
    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _likesCount--;
      } else {
        _isLiked = true;
        _likesCount++;
        if (_isDisliked) {
          _isDisliked = false;
          _dislikesCount--;
        }
      }
    });
    
    // Animate
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });
    
    // Send to BLoC
    context.read<PostInteractionBloc>().add(ToggleLike(
      postId: widget.postId,
      commentId: widget.commentId,
      userId: widget.userId,
      likeType: LikeType.like,
    ));
    
    // Reset processing state after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  void _toggleDislike() {
    if (_isProcessing || !widget.showDislike) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    // Optimistic update
    setState(() {
      if (_isDisliked) {
        _isDisliked = false;
        _dislikesCount--;
      } else {
        _isDisliked = true;
        _dislikesCount++;
        if (_isLiked) {
          _isLiked = false;
          _likesCount--;
        }
      }
    });
    
    // Animate
    _dislikeAnimationController.forward().then((_) {
      _dislikeAnimationController.reverse();
    });
    
    // Send to BLoC
    context.read<PostInteractionBloc>().add(ToggleLike(
      postId: widget.postId,
      commentId: widget.commentId,
      userId: widget.userId,
      likeType: LikeType.dislike,
    ));
    
    // Reset processing state after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });
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
        // Like button
        AnimatedBuilder(
          animation: _likeScaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _likeScaleAnimation.value,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggleLike,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: deviceType.isMobile ? 12 : 16,
                      vertical: deviceType.isMobile ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: _isLiked
                          ? colorScheme.primaryContainer.withOpacity(0.3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isLiked
                            ? colorScheme.primary
                            : colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_outline,
                          size: deviceType.isMobile ? 16 : 18,
                          color: _isLiked
                              ? Colors.red
                              : colorScheme.onSurfaceVariant,
                        ),
                        if (_likesCount > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            _formatCount(_likesCount),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _isLiked
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: _isLiked ? FontWeight.w600 : FontWeight.normal,
                              fontSize: deviceType.isMobile ? 11 : 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        
        // Dislike button
        if (widget.showDislike) ...[
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _dislikeScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _dislikeScaleAnimation.value,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _toggleDislike,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: deviceType.isMobile ? 12 : 16,
                        vertical: deviceType.isMobile ? 6 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: _isDisliked
                            ? colorScheme.errorContainer.withOpacity(0.3)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isDisliked
                              ? colorScheme.error
                              : colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                            size: deviceType.isMobile ? 16 : 18,
                            color: _isDisliked
                                ? colorScheme.error
                                : colorScheme.onSurfaceVariant,
                          ),
                          if (_dislikesCount > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              _formatCount(_dislikesCount),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _isDisliked
                                    ? colorScheme.error
                                    : colorScheme.onSurfaceVariant,
                                fontWeight: _isDisliked ? FontWeight.w600 : FontWeight.normal,
                                fontSize: deviceType.isMobile ? 11 : 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildCompactButtons(DeviceType deviceType) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Compact like button
        AnimatedBuilder(
          animation: _likeScaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _likeScaleAnimation.value,
              child: IconButton(
                onPressed: _toggleLike,
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_outline,
                  color: _isLiked ? Colors.red : colorScheme.onSurfaceVariant,
                ),
                iconSize: deviceType.isMobile ? 18 : 20,
                constraints: BoxConstraints(
                  minWidth: BreakpointUtils.minTouchTarget,
                  minHeight: BreakpointUtils.minTouchTarget,
                ),
                tooltip: _isLiked ? '좋아요 취소' : '좋아요',
              ),
            );
          },
        ),
        
        // Like count
        if (_likesCount > 0)
          Text(
            _formatCount(_likesCount),
            style: theme.textTheme.bodySmall?.copyWith(
              color: _isLiked ? Colors.red : colorScheme.onSurfaceVariant,
              fontWeight: _isLiked ? FontWeight.w600 : FontWeight.normal,
              fontSize: deviceType.isMobile ? 11 : 12,
            ),
          ),
        
        // Compact dislike button
        if (widget.showDislike) ...[
          const SizedBox(width: 4),
          AnimatedBuilder(
            animation: _dislikeScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _dislikeScaleAnimation.value,
                child: IconButton(
                  onPressed: _toggleDislike,
                  icon: Icon(
                    _isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                    color: _isDisliked ? colorScheme.error : colorScheme.onSurfaceVariant,
                  ),
                  iconSize: deviceType.isMobile ? 18 : 20,
                  constraints: BoxConstraints(
                    minWidth: BreakpointUtils.minTouchTarget,
                    minHeight: BreakpointUtils.minTouchTarget,
                  ),
                  tooltip: _isDisliked ? '싫어요 취소' : '싫어요',
                ),
              );
            },
          ),
          
          // Dislike count
          if (_dislikesCount > 0)
            Text(
              _formatCount(_dislikesCount),
              style: theme.textTheme.bodySmall?.copyWith(
                color: _isDisliked ? colorScheme.error : colorScheme.onSurfaceVariant,
                fontWeight: _isDisliked ? FontWeight.w600 : FontWeight.normal,
                fontSize: deviceType.isMobile ? 11 : 12,
              ),
            ),
        ],
      ],
    );
  }

  String _formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
  }
}