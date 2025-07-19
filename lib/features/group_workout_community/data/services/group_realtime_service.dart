import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_activity.dart';
import 'package:jfit/features/group_workout_community/domain/entities/community_post.dart';
import 'package:jfit/features/group_workout_community/domain/entities/post_comment.dart';
import 'package:jfit/features/group_workout_community/data/models/group_activity_model.dart';
import 'package:jfit/features/group_workout_community/data/models/community_post_model.dart';
import 'package:jfit/features/group_workout_community/data/models/post_comment_model.dart';

/// Service for handling real-time subscriptions for group workout community features
class GroupRealtimeService {
  final SupabaseClient _supabase;
  final Map<String, RealtimeChannel> _activeChannels = {};

  GroupRealtimeService(this._supabase);

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Subscribe to group activities for a specific group
  Stream<List<GroupActivity>> subscribeToGroupActivities(String groupId) {
    final controller = StreamController<List<GroupActivity>>.broadcast();
    
    // First, load existing activities
    _loadInitialGroupActivities(groupId).then((activities) {
      if (!controller.isClosed) {
        controller.add(activities);
      }
    });

    // Set up real-time subscription
    final channelName = 'group_activities_$groupId';
    final channel = _supabase.channel(channelName);
    
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'group_activities',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'group_id',
            value: groupId,
          ),
          callback: (payload) {
            if (!controller.isClosed) {
              try {
                final activity = GroupActivityModel.fromJson(payload.newRecord);
                controller.add([activity.toEntity()]);
              } catch (e) {
                print('Error parsing group activity: $e');
              }
            }
          },
        )
        .subscribe((status, [error]) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            print('Successfully subscribed to group activities for group: $groupId');
          } else if (error != null) {
            print('Error subscribing to group activities: $error');
            if (!controller.isClosed) {
              controller.addError(error);
            }
          }
        });

    // Handle real-time changes
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public', 
      table: 'group_activities',
      callback: (payload) async {
        try {
          // Reload activities when changes occur
          final activities = await _loadInitialGroupActivities(groupId);
          if (!controller.isClosed) {
            controller.add(activities);
          }
        } catch (e) {
          print('Error handling group activity change: $e');
          if (!controller.isClosed) {
            controller.addError(e);
          }
        }
      },
    );

    _activeChannels[channelName] = channel;

    // Clean up when stream is cancelled
    controller.onCancel = () {
      _unsubscribeFromChannel(channelName);
    };

    return controller.stream;
  }

  /// Subscribe to group messages for real-time chat
  Stream<List<Map<String, dynamic>>> subscribeToGroupMessages(String groupId) {
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();
    
    // First, load existing messages
    _loadInitialGroupMessages(groupId).then((messages) {
      if (!controller.isClosed) {
        controller.add(messages);
      }
    });

    // Set up real-time subscription
    final channelName = 'group_messages_$groupId';
    final channel = _supabase.channel(channelName);
    
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'group_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'group_id',
            value: groupId,
          ),
          callback: (payload) {
            // Handle real-time message changes
            _loadInitialGroupMessages(groupId).then((messages) {
              if (!controller.isClosed) {
                controller.add(messages);
              }
            }).catchError((e) {
              print('Error handling group message change: $e');
              if (!controller.isClosed) {
                controller.addError(e);
              }
            });
          },
        )
        .subscribe((status, [error]) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            print('Successfully subscribed to group messages for group: $groupId');
          } else if (error != null) {
            print('Error subscribing to group messages: $error');
            if (!controller.isClosed) {
              controller.addError(error);
            }
          }
        });

    // Handle real-time changes
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'group_messages',
      callback: (payload) async {
        try {
          // Reload messages when changes occur
          final messages = await _loadInitialGroupMessages(groupId);
          if (!controller.isClosed) {
            controller.add(messages);
          }
        } catch (e) {
          print('Error handling group message change: $e');
          if (!controller.isClosed) {
            controller.addError(e);
          }
        }
      },
    );

    _activeChannels[channelName] = channel;

    // Clean up when stream is cancelled
    controller.onCancel = () {
      _unsubscribeFromChannel(channelName);
    };

    return controller.stream;
  }

  /// Subscribe to post interactions (likes, comments) for real-time updates
  Stream<Map<String, dynamic>> subscribeToPostInteractions(String postId) {
    final controller = StreamController<Map<String, dynamic>>.broadcast();
    
    // First, load initial interaction data
    _loadInitialPostInteractions(postId).then((interactions) {
      if (!controller.isClosed) {
        controller.add(interactions);
      }
    });

    // Set up real-time subscription for comments
    final commentsChannelName = 'post_comments_$postId';
    final commentsChannel = _supabase.channel(commentsChannelName);
    
    commentsChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'post_comments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'post_id',
            value: postId,
          ),
          callback: (payload) {
            // Handle comment changes
          },
        )
        .subscribe((status, [error]) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            print('Successfully subscribed to post comments for post: $postId');
          } else if (error != null) {
            print('Error subscribing to post comments: $error');
          }
        });

    // Set up real-time subscription for likes
    final likesChannelName = 'post_likes_$postId';
    final likesChannel = _supabase.channel(likesChannelName);
    
    likesChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'post_likes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'post_id',
            value: postId,
          ),
          callback: (payload) {
            // Handle like changes
          },
        )
        .subscribe((status, [error]) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            print('Successfully subscribed to post likes for post: $postId');
          } else if (error != null) {
            print('Error subscribing to post likes: $error');
          }
        });

    // Handle real-time changes for both comments and likes
    final handleChange = (payload) async {
      try {
        final interactions = await _loadInitialPostInteractions(postId);
        if (!controller.isClosed) {
          controller.add(interactions);
        }
      } catch (e) {
        print('Error handling post interaction change: $e');
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    };

    commentsChannel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'post_comments',
      callback: handleChange,
    );

    likesChannel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'post_likes',
      callback: handleChange,
    );

    _activeChannels[commentsChannelName] = commentsChannel;
    _activeChannels[likesChannelName] = likesChannel;

    // Clean up when stream is cancelled
    controller.onCancel = () {
      _unsubscribeFromChannel(commentsChannelName);
      _unsubscribeFromChannel(likesChannelName);
    };

    return controller.stream;
  }

  /// Subscribe to community posts for real-time updates
  Stream<List<CommunityPost>> subscribeToCommunityPosts({String? categoryId, String? groupId}) {
    final controller = StreamController<List<CommunityPost>>.broadcast();
    
    // First, load existing posts
    _loadInitialCommunityPosts(categoryId: categoryId, groupId: groupId).then((posts) {
      if (!controller.isClosed) {
        controller.add(posts);
      }
    });

    // Set up real-time subscription
    final channelName = 'community_posts_${categoryId ?? 'all'}_${groupId ?? 'all'}';
    final channel = _supabase.channel(channelName);
    
    // Set up filters for the subscription
    PostgresChangeFilter? filter;
    if (categoryId != null && groupId != null) {
      // Both filters - this might need to be handled differently
      filter = PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'category_id',
        value: categoryId,
      );
    } else if (categoryId != null) {
      filter = PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'category_id',
        value: categoryId,
      );
    } else if (groupId != null) {
      filter = PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'group_id',
        value: groupId,
      );
    }

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'community_posts',
          filter: filter,
          callback: (payload) async {
            try {
              final posts = await _loadInitialCommunityPosts(categoryId: categoryId, groupId: groupId);
              if (!controller.isClosed) {
                controller.add(posts);
              }
            } catch (e) {
              print('Error handling community post change: $e');
              if (!controller.isClosed) {
                controller.addError(e);
              }
            }
          },
        )
        .subscribe((status, [error]) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            print('Successfully subscribed to community posts');
          } else if (error != null) {
            print('Error subscribing to community posts: $error');
            if (!controller.isClosed) {
              controller.addError(error);
            }
          }
        });

    _activeChannels[channelName] = channel;

    // Clean up when stream is cancelled
    controller.onCancel = () {
      _unsubscribeFromChannel(channelName);
    };

    return controller.stream;
  }

  /// Load initial group activities
  Future<List<GroupActivity>> _loadInitialGroupActivities(String groupId) async {
    try {
      final response = await _supabase
          .from('group_activities')
          .select('''
            id,
            group_id,
            user_id,
            activity_type,
            activity_data,
            created_at,
            mentioned_user_ids,
            user_profiles!inner(username, full_name)
          ''')
          .eq('group_id', groupId)
          .order('created_at', ascending: false)
          .limit(50);

      return (response as List)
          .map((json) => GroupActivityModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      print('Error loading initial group activities: $e');
      return [];
    }
  }

  /// Load initial group messages
  Future<List<Map<String, dynamic>>> _loadInitialGroupMessages(String groupId) async {
    try {
      final response = await _supabase
          .from('group_messages')
          .select('''
            id,
            group_id,
            sender_id,
            message_text,
            message_type,
            reply_to_message_id,
            created_at,
            updated_at,
            is_deleted,
            user_profiles!inner(username, full_name)
          ''')
          .eq('group_id', groupId)
          .eq('is_deleted', false)
          .order('created_at', ascending: true)
          .limit(100);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error loading initial group messages: $e');
      return [];
    }
  }

  /// Load initial post interactions
  Future<Map<String, dynamic>> _loadInitialPostInteractions(String postId) async {
    try {
      // Load comments
      final commentsResponse = await _supabase
          .from('post_comments')
          .select('''
            id,
            post_id,
            author_id,
            parent_comment_id,
            content,
            likes_count,
            is_deleted,
            created_at,
            updated_at,
            user_profiles!inner(username, full_name)
          ''')
          .eq('post_id', postId)
          .eq('is_deleted', false)
          .order('created_at', ascending: true);

      // Load likes count
      final likesResponse = await _supabase
          .from('post_likes')
          .select('like_type')
          .eq('post_id', postId);

      final comments = (commentsResponse as List)
          .map((json) => PostCommentModel.fromJson(json).toEntity())
          .toList();

      final likes = (likesResponse as List).cast<Map<String, dynamic>>();
      final likesCount = likes.where((like) => like['like_type'] == 'like').length;
      final dislikesCount = likes.where((like) => like['like_type'] == 'dislike').length;

      // Check if current user has liked/disliked
      bool? userLikeStatus;
      if (_currentUserId != null) {
        final userLikeResponse = await _supabase
            .from('post_likes')
            .select('like_type')
            .eq('post_id', postId)
            .eq('user_id', _currentUserId!)
            .maybeSingle();
        
        if (userLikeResponse != null) {
          userLikeStatus = userLikeResponse['like_type'] == 'like';
        }
      }

      return {
        'comments': comments,
        'likesCount': likesCount,
        'dislikesCount': dislikesCount,
        'userLikeStatus': userLikeStatus,
      };
    } catch (e) {
      print('Error loading initial post interactions: $e');
      return {
        'comments': <PostComment>[],
        'likesCount': 0,
        'dislikesCount': 0,
        'userLikeStatus': null,
      };
    }
  }

  /// Load initial community posts
  Future<List<CommunityPost>> _loadInitialCommunityPosts({String? categoryId, String? groupId}) async {
    try {
      var query = _supabase
          .from('community_posts')
          .select('''
            id,
            author_id,
            group_id,
            category_id,
            title,
            content,
            post_type,
            media_urls,
            tags,
            likes_count,
            comments_count,
            views_count,
            is_pinned,
            is_deleted,
            created_at,
            updated_at,
            user_profiles!inner(username, full_name),
            post_categories(name, color_code)
          ''')
          .eq('is_deleted', false);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      if (groupId != null) {
        query = query.eq('group_id', groupId);
      }

      final response = await query
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: false)
          .limit(50);

      return (response as List)
          .map((json) => CommunityPostModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      print('Error loading initial community posts: $e');
      return [];
    }
  }

  /// Unsubscribe from a specific channel
  void _unsubscribeFromChannel(String channelName) {
    final channel = _activeChannels[channelName];
    if (channel != null) {
      _supabase.removeChannel(channel);
      _activeChannels.remove(channelName);
      print('Unsubscribed from channel: $channelName');
    }
  }

  /// Unsubscribe from all active channels
  void unsubscribeFromAll() {
    for (final channelName in _activeChannels.keys.toList()) {
      _unsubscribeFromChannel(channelName);
    }
    print('Unsubscribed from all channels');
  }

  /// Send typing indicator for group chat
  Future<void> sendTypingIndicator(String groupId, bool isTyping) async {
    if (_currentUserId == null) return;

    final channelName = 'group_messages_$groupId';
    final channel = _activeChannels[channelName];
    
    if (channel != null) {
      await channel.sendBroadcastMessage(
        event: 'typing',
        payload: {
          'user_id': _currentUserId,
          'group_id': groupId,
          'is_typing': isTyping,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  /// Listen to typing indicators
  Stream<Map<String, dynamic>> subscribeToTypingIndicators(String groupId) {
    final controller = StreamController<Map<String, dynamic>>.broadcast();
    
    final channelName = 'group_messages_$groupId';
    final channel = _activeChannels[channelName];
    
    if (channel != null) {
      channel.onBroadcast(
        event: 'typing',
        callback: (payload) {
          if (!controller.isClosed) {
            controller.add(payload);
          }
        },
      );
    }

    return controller.stream;
  }

  /// Dispose of the service and clean up all subscriptions
  void dispose() {
    unsubscribeFromAll();
  }
}