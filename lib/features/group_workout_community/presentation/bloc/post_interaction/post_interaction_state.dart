import 'package:flutter/foundation.dart';
import 'package:jfit/core/bloc/base_bloc.dart';
import 'package:jfit/core/error/bloc_errors.dart';
import 'package:jfit/features/group_workout_community/domain/entities/post_comment.dart';
import 'package:jfit/features/group_workout_community/domain/entities/community_post.dart';

/// Base class for all PostInteraction-related states
abstract class PostInteractionState extends BaseState {
  const PostInteractionState();
}

/// Initial state
class PostInteractionInitial extends PostInteractionState {
  const PostInteractionInitial();

  @override
  List<Object?> get props => [];
}

/// Loading state
class PostInteractionLoading extends PostInteractionState {
  final String? message;
  final String? operationType;

  const PostInteractionLoading({
    this.message,
    this.operationType,
  });

  @override
  List<Object?> get props => [message, operationType];
}

/// State when comments are loaded
class CommentsLoaded extends PostInteractionState {
  final String postId;
  final List<PostComment> comments;
  final bool hasMore;
  final int totalCount;
  final DateTime loadedAt;

  const CommentsLoaded({
    required this.postId,
    required this.comments,
    this.hasMore = false,
    this.totalCount = 0,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [postId, comments, hasMore, totalCount, loadedAt];

  CommentsLoaded copyWith({
    String? postId,
    List<PostComment>? comments,
    bool? hasMore,
    int? totalCount,
    DateTime? loadedAt,
  }) {
    return CommentsLoaded(
      postId: postId ?? this.postId,
      comments: comments ?? this.comments,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
      loadedAt: loadedAt ?? this.loadedAt,
    );
  }

  CommentsLoaded addMoreComments(List<PostComment> newComments) {
    return copyWith(
      comments: [...comments, ...newComments],
      hasMore: newComments.isNotEmpty,
      totalCount: totalCount + newComments.length,
      loadedAt: DateTime.now(),
    );
  }
}

/// State when comment is added
class CommentAdded extends PostInteractionState {
  final PostComment comment;
  final DateTime addedAt;

  const CommentAdded({
    required this.comment,
    required this.addedAt,
  });

  @override
  List<Object?> get props => [comment, addedAt];
}

/// State when comment is updated
class CommentUpdated extends PostInteractionState {
  final PostComment comment;
  final DateTime updatedAt;

  const CommentUpdated({
    required this.comment,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [comment, updatedAt];
}

/// State when comment is deleted
class CommentDeleted extends PostInteractionState {
  final String commentId;
  final DateTime deletedAt;

  const CommentDeleted({
    required this.commentId,
    required this.deletedAt,
  });

  @override
  List<Object?> get props => [commentId, deletedAt];
}

/// State when like is toggled
class LikeToggled extends PostInteractionState {
  final String postId;
  final String? commentId;
  final String userId;
  final bool isLiked;
  final LikeType likeType;
  final DateTime toggledAt;

  const LikeToggled({
    required this.postId,
    this.commentId,
    required this.userId,
    required this.isLiked,
    required this.likeType,
    required this.toggledAt,
  });

  @override
  List<Object?> get props => [postId, commentId, userId, isLiked, likeType, toggledAt];
}

/// State when like status is checked
class LikeStatusChecked extends PostInteractionState {
  final String postId;
  final String? commentId;
  final String userId;
  final bool isLiked;
  final DateTime checkedAt;

  const LikeStatusChecked({
    required this.postId,
    this.commentId,
    required this.userId,
    required this.isLiked,
    required this.checkedAt,
  });

  @override
  List<Object?> get props => [postId, commentId, userId, isLiked, checkedAt];
}

/// State when view count is incremented
class ViewCountIncremented extends PostInteractionState {
  final String postId;
  final DateTime incrementedAt;

  const ViewCountIncremented({
    required this.postId,
    required this.incrementedAt,
  });

  @override
  List<Object?> get props => [postId, incrementedAt];
}

/// State when real-time comment update is received
class CommentUpdatedRealtime extends PostInteractionState {
  final String postId;
  final Map<String, dynamic> commentData;
  final DateTime updatedAt;

  const CommentUpdatedRealtime({
    required this.postId,
    required this.commentData,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [postId, commentData, updatedAt];
}

/// State when comments are refreshed
class CommentsRefreshed extends PostInteractionState {
  final String postId;
  final DateTime refreshedAt;

  const CommentsRefreshed({
    required this.postId,
    required this.refreshedAt,
  });

  @override
  List<Object?> get props => [postId, refreshedAt];
}

/// Error state
class PostInteractionErrorState extends PostInteractionState {
  final BlocError error;
  final bool isRetryable;
  final VoidCallback? retryAction;
  final String? operationType;

  const PostInteractionErrorState(
    this.error, {
    this.isRetryable = false,
    this.retryAction,
    this.operationType,
  });

  @override
  List<Object?> get props => [error, isRetryable, retryAction, operationType];

  String get userMessage {
    switch (error.code) {
      case 'comment_add_failed':
        return '댓글 작성에 실패했습니다.';
      case 'comment_update_failed':
        return '댓글 수정에 실패했습니다.';
      case 'comment_delete_failed':
        return '댓글 삭제에 실패했습니다.';
      case 'like_toggle_failed':
        return '좋아요 처리에 실패했습니다.';
      case 'comments_load_failed':
        return '댓글을 불러오는데 실패했습니다.';
      default:
        return '작업 중 오류가 발생했습니다.';
    }
  }

  factory PostInteractionErrorState.fromError(dynamic error, {String? operationType}) {
    if (error is BlocError) {
      return PostInteractionErrorState(error, operationType: operationType);
    }
    return PostInteractionErrorState(
      PostInteractionError(error.toString()),
      operationType: operationType,
    );
  }
}

class PostInteractionError extends BlocError {
  const PostInteractionError(String message, {String? code}) : super(message, code: code);
}