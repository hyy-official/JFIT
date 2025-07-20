import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/post_interaction/post_interaction_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/post_interaction/post_interaction_event.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/post_interaction/post_interaction_state.dart';
import 'package:jfit/features/group_workout_community/domain/entities/post_comment.dart';
import 'package:jfit/features/group_workout_community/domain/entities/community_post.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/post_interaction_repository.dart';

/// 댓글 목록 위젯 - 대댓글 지원, 좋아요, 중첩 댓글 들여쓰기 반응형 처리
class CommentListWidget extends StatefulWidget {
  final String postId;
  final List<PostComment> comments;
  final String currentUserId;
  final VoidCallback? onCommentAdded;

  const CommentListWidget({
    super.key,
    required this.postId,
    required this.comments,
    required this.currentUserId,
    this.onCommentAdded,
  });

  @override
  State<CommentListWidget> createState() => _CommentListWidgetState();
}

class _CommentListWidgetState extends State<CommentListWidget> {
  final Map<String, bool> _expandedReplies = {};
  final Map<String, bool> _showReplyInput = {};

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = BreakpointUtils.getDeviceType(constraints.maxWidth);
        return _buildCommentList(deviceType);
      },
    );
  }

  Widget _buildCommentList(DeviceType deviceType) {
    if (widget.comments.isEmpty) {
      return _buildEmptyComments();
    }

    // Organize comments into parent-child structure
    final parentComments = widget.comments
        .where((comment) => comment.parentCommentId == null)
        .toList();
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: parentComments.length,
      itemBuilder: (context, index) {
        final comment = parentComments[index];
        final replies = widget.comments
            .where((c) => c.parentCommentId == comment.id)
            .toList();
        
        return _buildCommentThread(comment, replies, deviceType);
      },
    );
  }

  Widget _buildCommentThread(
    PostComment parentComment,
    List<PostComment> replies,
    DeviceType deviceType,
  ) {
    return Column(
      children: [
        _buildCommentItem(parentComment, deviceType, isReply: false),
        
        // Reply input for parent comment
        if (_showReplyInput[parentComment.id] == true)
          _buildReplyInput(parentComment.id, deviceType),
        
        // Replies
        if (replies.isNotEmpty) ...[
          if (_expandedReplies[parentComment.id] != true)
            _buildShowRepliesButton(parentComment.id, replies.length)
          else
            ...replies.map((reply) => Padding(
              padding: EdgeInsets.only(
                left: deviceType.isMobile ? 32.0 : 48.0,
              ),
              child: Column(
                children: [
                  _buildCommentItem(reply, deviceType, isReply: true),
                  if (_showReplyInput[reply.id] == true)
                    _buildReplyInput(reply.id, deviceType),
                ],
              ),
            )),
        ],
        
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCommentItem(
    PostComment comment,
    DeviceType deviceType, {
    required bool isReply,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(deviceType.isMobile ? 12.0 : 16.0),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isReply 
            ? colorScheme.surfaceVariant.withOpacity(0.3)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment header
          Row(
            children: [
              CircleAvatar(
                radius: deviceType.isMobile ? 14 : 16,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  size: deviceType.isMobile ? 14 : 16,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '사용자 이름', // TODO: Get actual author name
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: deviceType.isMobile ? 12 : 14,
                      ),
                    ),
                    Text(
                      _formatTimestamp(comment.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                        fontSize: deviceType.isMobile ? 10 : 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (comment.authorId == widget.currentUserId)
                PopupMenuButton<String>(
                  onSelected: (action) => _handleCommentAction(comment, action),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('수정'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete),
                        title: Text('삭제'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Comment content
          Text(
            comment.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: deviceType.isMobile ? 13 : 14,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Comment actions
          Row(
            children: [
              _buildCommentActionButton(
                icon: Icons.favorite_outline,
                label: '${comment.likesCount}',
                onPressed: () => _likeComment(comment),
                deviceType: deviceType,
              ),
              
              const SizedBox(width: 8),
              
              _buildCommentActionButton(
                icon: Icons.reply,
                label: '답글',
                onPressed: () => _toggleReplyInput(comment.id),
                deviceType: deviceType,
              ),
              
              const Spacer(),
              
              if (comment.updatedAt != comment.createdAt)
                Text(
                  '수정됨',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                    fontSize: deviceType.isMobile ? 10 : 11,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required DeviceType deviceType,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: deviceType.isMobile ? 14 : 16),
      label: Text(
        label,
        style: TextStyle(fontSize: deviceType.isMobile ? 11 : 12),
      ),
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.symmetric(
          horizontal: deviceType.isMobile ? 6 : 8,
          vertical: 2,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildShowRepliesButton(String parentCommentId, int replyCount) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(left: 32, top: 4),
      child: TextButton.icon(
        onPressed: () => _toggleReplies(parentCommentId),
        icon: const Icon(Icons.expand_more, size: 16),
        label: Text('답글 $replyCount개 보기'),
        style: TextButton.styleFrom(
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildReplyInput(String parentCommentId, DeviceType deviceType) {
    return Padding(
      padding: EdgeInsets.only(
        left: deviceType.isMobile ? 32.0 : 48.0,
        top: 8,
        bottom: 8,
      ),
      child: CommentInputWidget(
        postId: widget.postId,
        parentCommentId: parentCommentId,
        currentUserId: widget.currentUserId,
        hintText: '답글을 입력하세요...',
        onCommentSubmitted: () {
          setState(() {
            _showReplyInput[parentCommentId] = false;
          });
          widget.onCommentAdded?.call();
        },
        onCancel: () {
          setState(() {
            _showReplyInput[parentCommentId] = false;
          });
        },
      ),
    );
  }

  Widget _buildEmptyComments() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.comment_outlined,
            size: 48,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            '아직 댓글이 없습니다',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '첫 번째 댓글을 작성해보세요!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleReplies(String parentCommentId) {
    setState(() {
      _expandedReplies[parentCommentId] = !(_expandedReplies[parentCommentId] ?? false);
    });
  }

  void _toggleReplyInput(String commentId) {
    setState(() {
      _showReplyInput[commentId] = !(_showReplyInput[commentId] ?? false);
    });
  }

  void _likeComment(PostComment comment) {
    context.read<PostInteractionBloc>().add(ToggleLike(
      postId: widget.postId,
      commentId: comment.id,
      userId: widget.currentUserId,
      likeType: LikeType.like,
    ));
  }

  void _handleCommentAction(PostComment comment, String action) {
    switch (action) {
      case 'edit':
        _editComment(comment);
        break;
      case 'delete':
        _deleteComment(comment);
        break;
    }
  }

  void _editComment(PostComment comment) {
    // TODO: Implement edit comment functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('댓글 수정 기능 구현 예정')),
    );
  }

  void _deleteComment(PostComment comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('댓글 삭제'),
        content: const Text('정말로 이 댓글을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<PostInteractionBloc>().add(DeleteComment(
                commentId: comment.id,
                userId: widget.currentUserId,
              ));
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }
}

/// 댓글 작성 위젯 - 텍스트 입력, 답글 기능, 터치/키보드 입력 최적화
class CommentInputWidget extends StatefulWidget {
  final String postId;
  final String? parentCommentId;
  final String currentUserId;
  final String hintText;
  final VoidCallback? onCommentSubmitted;
  final VoidCallback? onCancel;

  const CommentInputWidget({
    super.key,
    required this.postId,
    this.parentCommentId,
    required this.currentUserId,
    this.hintText = '댓글을 입력하세요...',
    this.onCommentSubmitted,
    this.onCancel,
  });

  @override
  State<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitComment() {
    final content = _controller.text.trim();
    if (content.isEmpty || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    context.read<PostInteractionBloc>().add(AddComment(
      AddCommentRequest(
        postId: widget.postId,
        authorId: widget.currentUserId,
        content: content,
        parentCommentId: widget.parentCommentId,
      ),
    ));

    // Listen for comment submission result
    context.read<PostInteractionBloc>().stream.listen((state) {
      if (state is CommentAdded) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          _controller.clear();
          widget.onCommentSubmitted?.call();
        }
      } else if (state is PostInteractionErrorState) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.userMessage),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = BreakpointUtils.getDeviceType(constraints.maxWidth);
        return _buildCommentInput(deviceType);
      },
    );
  }

  Widget _buildCommentInput(DeviceType deviceType) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(deviceType.isMobile ? 8.0 : 12.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: deviceType.isMobile ? 14 : 16,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  size: deviceType.isMobile ? 14 : 16,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: deviceType.isMobile ? 8 : 12,
                      vertical: deviceType.isMobile ? 6 : 8,
                    ),
                  ),
                  maxLines: null,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                  style: TextStyle(
                    fontSize: deviceType.isMobile ? 13 : 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _isSubmitting ? null : _submitComment,
                icon: _isSubmitting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      )
                    : Icon(
                        Icons.send,
                        color: _controller.text.trim().isEmpty
                            ? colorScheme.outline
                            : colorScheme.primary,
                      ),
                iconSize: deviceType.isMobile ? 20 : 24,
              ),
            ],
          ),
          
          // Cancel button for replies
          if (widget.parentCommentId != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('취소'),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}