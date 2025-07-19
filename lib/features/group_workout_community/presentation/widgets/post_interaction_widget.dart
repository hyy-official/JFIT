import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/post_interaction/post_interaction_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/post_interaction/post_interaction_event.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/post_interaction/post_interaction_state.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/like_dislike_button.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/bookmark_share_widget.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/comment_list_widget.dart';
import 'package:jfit/features/group_workout_community/domain/entities/community_post.dart';
import 'package:jfit/features/group_workout_community/domain/entities/post_comment.dart';

/// 게시글 상호작용 종합 위젯 - 좋아요, 댓글, 북마크, 공유 기능 통합
class PostInteractionWidget extends StatefulWidget {
  final CommunityPost post;
  final String currentUserId;
  final bool showComments;
  final bool isCompact;

  const PostInteractionWidget({
    super.key,
    required this.post,
    required this.currentUserId,
    this.showComments = true,
    this.isCompact = false,
  });

  @override
  State<PostInteractionWidget> createState() => _PostInteractionWidgetState();
}

class _PostInteractionWidgetState extends State<PostInteractionWidget> {
  List<PostComment> _comments = [];
  bool _isLoadingComments = false;
  bool _showAllComments = false;
  bool _isLiked = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Load comments if needed
    if (widget.showComments) {
      _loadComments();
    }
    
    // Check if user has liked/bookmarked this post
    _checkUserInteractions();
  }

  void _loadComments() {
    setState(() {
      _isLoadingComments = true;
    });
    
    context.read<PostInteractionBloc>().add(LoadComments(
      postId: widget.post.id,
      limit: _showAllComments ? 100 : 5,
    ));
  }

  void _checkUserInteractions() {
    context.read<PostInteractionBloc>().add(CheckUserInteractions(
      postId: widget.post.id,
      userId: widget.currentUserId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostInteractionBloc, PostInteractionState>(
      listener: (context, state) {
        if (state is CommentsLoaded) {
          setState(() {
            _comments = state.comments;
            _isLoadingComments = false;
          });
        } else if (state is UserInteractionsLoaded) {
          setState(() {
            _isLiked = state.isLiked;
            _isBookmarked = state.isBookmarked;
          });
        } else if (state is CommentAdded) {
          _loadComments(); // Refresh comments
        } else if (state is PostInteractionError) {
          setState(() {
            _isLoadingComments = false;
          });
          _showErrorSnackBar(state.message);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final deviceType = BreakpointUtils.getDeviceType(constraints.maxWidth);
          return _buildInteractionWidget(deviceType);
        },
      ),
    );
  }

  Widget _buildInteractionWidget(DeviceType deviceType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main interaction buttons
        _buildInteractionButtons(deviceType),
        
        // Comments section
        if (widget.showComments) ...[
          const SizedBox(height: 16),
          _buildCommentsSection(deviceType),
        ],
      ],
    );
  }

  Widget _buildInteractionButtons(DeviceType deviceType) {
    final theme = Theme.of(context);
    
    if (widget.isCompact) {
      return _buildCompactInteractionButtons(deviceType);
    }
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: deviceType.isMobile ? 12 : 16,
        vertical: deviceType.isMobile ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Top row - Like/Dislike and Bookmark/Share
          Row(
            children: [
              LikeDislikeButton(
                postId: widget.post.id,
                userId: widget.currentUserId,
                likesCount: widget.post.likesCount,
                isLiked: _isLiked,
                showDislike: false, // Usually posts don't have dislike
              ),
              
              const Spacer(),
              
              BookmarkShareWidget(
                postId: widget.post.id,
                userId: widget.currentUserId,
                postTitle: widget.post.title,
                postUrl: 'https://app.jfit.com/post/${widget.post.id}', // TODO: Generate proper URL
                isBookmarked: _isBookmarked,
              ),
            ],
          ),
          
          // Bottom row - Stats
          if (!deviceType.isMobile) ...[
            const SizedBox(height: 8),
            _buildInteractionStats(deviceType),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactInteractionButtons(DeviceType deviceType) {
    return Row(
      children: [
        LikeDislikeButton(
          postId: widget.post.id,
          userId: widget.currentUserId,
          likesCount: widget.post.likesCount,
          isLiked: _isLiked,
          showDislike: false,
          isCompact: true,
        ),
        
        const SizedBox(width: 8),
        
        // Comment button
        TextButton.icon(
          onPressed: () => _toggleCommentsVisibility(),
          icon: Icon(
            Icons.comment_outlined,
            size: deviceType.isMobile ? 16 : 18,
          ),
          label: Text('${widget.post.commentsCount}'),
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        
        const Spacer(),
        
        BookmarkShareWidget(
          postId: widget.post.id,
          userId: widget.currentUserId,
          postTitle: widget.post.title,
          postUrl: 'https://app.jfit.com/post/${widget.post.id}',
          isBookmarked: _isBookmarked,
          isCompact: true,
        ),
      ],
    );
  }

  Widget _buildInteractionStats(DeviceType deviceType) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      children: [
        // Views
        Icon(
          Icons.visibility,
          size: 14,
          color: colorScheme.outline,
        ),
        const SizedBox(width: 4),
        Text(
          '${widget.post.viewsCount}회 조회',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.outline,
            fontSize: deviceType.isMobile ? 11 : 12,
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Comments
        Icon(
          Icons.comment,
          size: 14,
          color: colorScheme.outline,
        ),
        const SizedBox(width: 4),
        Text(
          '${widget.post.commentsCount}개 댓글',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.outline,
            fontSize: deviceType.isMobile ? 11 : 12,
          ),
        ),
        
        const Spacer(),
        
        // Post date
        Text(
          _formatPostDate(widget.post.createdAt),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.outline,
            fontSize: deviceType.isMobile ? 11 : 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection(DeviceType deviceType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comments header
        Row(
          children: [
            Text(
              '댓글 ${widget.post.commentsCount}개',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const Spacer(),
            
            if (_comments.length > 5 && !_showAllComments)
              TextButton(
                onPressed: () {
                  setState(() {
                    _showAllComments = true;
                  });
                  _loadComments();
                },
                child: const Text('모든 댓글 보기'),
              ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Comment input
        CommentInputWidget(
          postId: widget.post.id,
          onCommentSubmitted: () => _loadComments(),
        ),
        
        const SizedBox(height: 16),
        
        // Comments list
        if (_isLoadingComments)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          )
        else
          CommentListWidget(
            postId: widget.post.id,
            comments: _comments,
            currentUserId: widget.currentUserId,
            onCommentAdded: () => _loadComments(),
          ),
      ],
    );
  }

  void _toggleCommentsVisibility() {
    // This would typically navigate to a detailed post view
    // For now, just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('댓글 상세 보기 기능 구현 예정')),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  String _formatPostDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    }
  }
}