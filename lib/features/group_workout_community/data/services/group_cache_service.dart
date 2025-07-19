import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/workout_group.dart';
import '../../domain/entities/community_post.dart';
import '../../domain/entities/group_member.dart';
import '../models/workout_group_model.dart';
import '../models/community_post_model.dart';
import '../models/group_member_model.dart';

/// Service for caching group workout community data
class GroupCacheService {
  static const String _groupsBoxName = 'workout_groups';
  static const String _postsBoxName = 'community_posts';
  static const String _membersBoxName = 'group_members';
  static const String _cacheTimestampPrefix = 'cache_timestamp_';
  static const String _lastSyncPrefix = 'last_sync_';
  
  // Cache expiration times
  static const Duration _groupCacheExpiration = Duration(minutes: 15);
  static const Duration _postCacheExpiration = Duration(minutes: 10);
  static const Duration _memberCacheExpiration = Duration(minutes: 20);
  
  late Box<String> _groupsBox;
  late Box<String> _postsBox;
  late Box<String> _membersBox;
  late SharedPreferences _prefs;
  
  bool _isInitialized = false;

  /// Initialize the cache service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _groupsBox = await Hive.openBox<String>(_groupsBoxName);
    _postsBox = await Hive.openBox<String>(_postsBoxName);
    _membersBox = await Hive.openBox<String>(_membersBoxName);
    _prefs = await SharedPreferences.getInstance();
    
    _isInitialized = true;
  }

  /// Cache workout groups for a user
  Future<void> cacheUserGroups(String userId, List<WorkoutGroup> groups) async {
    await _ensureInitialized();
    
    final cacheKey = 'user_groups_$userId';
    final groupModels = groups.map((g) => WorkoutGroupModel.fromEntity(g)).toList();
    final jsonData = jsonEncode(groupModels.map((g) => g.toJson()).toList());
    
    await _groupsBox.put(cacheKey, jsonData);
    await _setCacheTimestamp(cacheKey);
  }

  /// Get cached workout groups for a user
  Future<List<WorkoutGroup>?> getCachedUserGroups(String userId) async {
    await _ensureInitialized();
    
    final cacheKey = 'user_groups_$userId';
    
    if (!_isCacheValid(cacheKey, _groupCacheExpiration)) {
      return null;
    }
    
    final jsonData = _groupsBox.get(cacheKey);
    if (jsonData == null) return null;
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonData);
      return jsonList
          .map((json) => WorkoutGroupModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      // Invalid cache data, remove it
      await _groupsBox.delete(cacheKey);
      return null;
    }
  }

  /// Cache community posts
  Future<void> cachePosts(String cacheKey, List<CommunityPost> posts) async {
    await _ensureInitialized();
    
    final postModels = posts.map((p) => CommunityPostModel.fromEntity(p)).toList();
    final jsonData = jsonEncode(postModels.map((p) => p.toJson()).toList());
    
    await _postsBox.put(cacheKey, jsonData);
    await _setCacheTimestamp(cacheKey);
  }

  /// Get cached community posts
  Future<List<CommunityPost>?> getCachedPosts(String cacheKey) async {
    await _ensureInitialized();
    
    if (!_isCacheValid(cacheKey, _postCacheExpiration)) {
      return null;
    }
    
    final jsonData = _postsBox.get(cacheKey);
    if (jsonData == null) return null;
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonData);
      return jsonList
          .map((json) => CommunityPostModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      // Invalid cache data, remove it
      await _postsBox.delete(cacheKey);
      return null;
    }
  }

  /// Cache group members
  Future<void> cacheGroupMembers(String groupId, List<GroupMember> members) async {
    await _ensureInitialized();
    
    final cacheKey = 'group_members_$groupId';
    final memberModels = members.map((m) => GroupMemberModel.fromEntity(m)).toList();
    final jsonData = jsonEncode(memberModels.map((m) => m.toJson()).toList());
    
    await _membersBox.put(cacheKey, jsonData);
    await _setCacheTimestamp(cacheKey);
  }

  /// Get cached group members
  Future<List<GroupMember>?> getCachedGroupMembers(String groupId) async {
    await _ensureInitialized();
    
    final cacheKey = 'group_members_$groupId';
    
    if (!_isCacheValid(cacheKey, _memberCacheExpiration)) {
      return null;
    }
    
    final jsonData = _membersBox.get(cacheKey);
    if (jsonData == null) return null;
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonData);
      return jsonList
          .map((json) => GroupMemberModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      // Invalid cache data, remove it
      await _membersBox.delete(cacheKey);
      return null;
    }
  }

  /// Invalidate specific cache entries
  Future<void> invalidateCache(String cacheKey) async {
    await _ensureInitialized();
    
    await _groupsBox.delete(cacheKey);
    await _postsBox.delete(cacheKey);
    await _membersBox.delete(cacheKey);
    await _prefs.remove('$_cacheTimestampPrefix$cacheKey');
  }

  /// Invalidate cache entries matching a pattern
  Future<void> invalidateCachePattern(String pattern) async {
    await _ensureInitialized();
    
    // Find matching keys in all boxes
    final groupKeys = _groupsBox.keys.where((key) => key.toString().contains(pattern));
    final postKeys = _postsBox.keys.where((key) => key.toString().contains(pattern));
    final memberKeys = _membersBox.keys.where((key) => key.toString().contains(pattern));
    
    // Delete matching entries
    for (final key in groupKeys) {
      await _groupsBox.delete(key);
      await _prefs.remove('$_cacheTimestampPrefix$key');
    }
    
    for (final key in postKeys) {
      await _postsBox.delete(key);
      await _prefs.remove('$_cacheTimestampPrefix$key');
    }
    
    for (final key in memberKeys) {
      await _membersBox.delete(key);
      await _prefs.remove('$_cacheTimestampPrefix$key');
    }
  }

  /// Invalidate all user-related caches
  Future<void> invalidateUserCaches(String userId) async {
    await _ensureInitialized();
    
    final userGroupsKey = 'user_groups_$userId';
    await invalidateCache(userGroupsKey);
    
    // Also invalidate any posts that might be user-specific
    final keys = _postsBox.keys.where((key) => key.toString().contains(userId));
    for (final key in keys) {
      await invalidateCache(key.toString());
    }
  }

  /// Invalidate group-related caches
  Future<void> invalidateGroupCaches(String groupId) async {
    await _ensureInitialized();
    
    final groupMembersKey = 'group_members_$groupId';
    await invalidateCache(groupMembersKey);
    
    // Invalidate group posts
    final groupPostsKey = 'group_posts_$groupId';
    await invalidateCache(groupPostsKey);
  }

  /// Clear all caches
  Future<void> clearAllCaches() async {
    await _ensureInitialized();
    
    await _groupsBox.clear();
    await _postsBox.clear();
    await _membersBox.clear();
    
    // Clear timestamps
    final keys = _prefs.getKeys().where((key) => key.startsWith(_cacheTimestampPrefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    await _ensureInitialized();
    
    return {
      'groups_cache_size': _groupsBox.length,
      'posts_cache_size': _postsBox.length,
      'members_cache_size': _membersBox.length,
      'total_cache_entries': _groupsBox.length + _postsBox.length + _membersBox.length,
    };
  }

  /// Set last sync timestamp for a data type
  Future<void> setLastSyncTime(String dataType) async {
    await _ensureInitialized();
    await _prefs.setInt('$_lastSyncPrefix$dataType', DateTime.now().millisecondsSinceEpoch);
  }

  /// Get last sync timestamp for a data type
  Future<DateTime?> getLastSyncTime(String dataType) async {
    await _ensureInitialized();
    final timestamp = _prefs.getInt('$_lastSyncPrefix$dataType');
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  /// Check if data needs sync based on last sync time
  Future<bool> needsSync(String dataType, Duration syncInterval) async {
    final lastSync = await getLastSyncTime(dataType);
    if (lastSync == null) return true;
    
    return DateTime.now().difference(lastSync) > syncInterval;
  }

  // Private helper methods

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  Future<void> _setCacheTimestamp(String cacheKey) async {
    await _prefs.setInt(
      '$_cacheTimestampPrefix$cacheKey',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  bool _isCacheValid(String cacheKey, Duration expiration) {
    final timestamp = _prefs.getInt('$_cacheTimestampPrefix$cacheKey');
    if (timestamp == null) return false;
    
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cacheTime) < expiration;
  }

  /// Generate cache key for posts with filters
  String generatePostsCacheKey({
    String? categoryId,
    String? groupId,
    String? searchQuery,
    String? sortBy,
    int limit = 20,
    int offset = 0,
  }) {
    final parts = <String>['posts'];
    
    if (categoryId != null) parts.add('cat_$categoryId');
    if (groupId != null) parts.add('group_$groupId');
    if (searchQuery != null && searchQuery.isNotEmpty) {
      parts.add('search_${searchQuery.hashCode}');
    }
    if (sortBy != null) parts.add('sort_$sortBy');
    parts.add('limit_$limit');
    parts.add('offset_$offset');
    
    return parts.join('_');
  }

  /// Cache paginated data with merge support
  Future<void> cachePaginatedPosts({
    required String baseKey,
    required List<CommunityPost> posts,
    required int offset,
    required int limit,
    bool append = false,
  }) async {
    await _ensureInitialized();
    
    final cacheKey = '${baseKey}_page_${offset}_$limit';
    
    if (append && offset > 0) {
      // Try to get existing data and append
      final existingKey = '${baseKey}_merged';
      final existingData = await getCachedPosts(existingKey);
      
      if (existingData != null) {
        final mergedPosts = [...existingData, ...posts];
        await cachePosts(existingKey, mergedPosts);
      } else {
        await cachePosts(cacheKey, posts);
      }
    } else {
      await cachePosts(cacheKey, posts);
      // Also cache as merged data for first page
      if (offset == 0) {
        await cachePosts('${baseKey}_merged', posts);
      }
    }
  }

  /// Get cached paginated posts with merge support
  Future<List<CommunityPost>?> getCachedPaginatedPosts({
    required String baseKey,
    required int offset,
    required int limit,
    bool preferMerged = true,
  }) async {
    await _ensureInitialized();
    
    // Try merged data first if preferred and offset is 0
    if (preferMerged && offset == 0) {
      final mergedData = await getCachedPosts('${baseKey}_merged');
      if (mergedData != null && mergedData.length >= limit) {
        return mergedData.take(limit).toList();
      }
    }
    
    // Fall back to specific page cache
    final cacheKey = '${baseKey}_page_${offset}_$limit';
    return await getCachedPosts(cacheKey);
  }

  /// Preload cache with background refresh
  Future<void> preloadCache({
    required String cacheKey,
    required Future<List<dynamic>> Function() dataLoader,
    required void Function(String key, List<dynamic> data) cacheUpdater,
  }) async {
    await _ensureInitialized();
    
    // Check if cache needs refresh
    if (_isCacheValid(cacheKey, _postCacheExpiration)) {
      return; // Cache is still valid
    }
    
    try {
      final data = await dataLoader();
      cacheUpdater(cacheKey, data);
    } catch (e) {
      // Silently fail for background preloading
      print('Preload cache failed for $cacheKey: $e');
    }
  }

  /// Smart cache invalidation based on data relationships
  Future<void> smartInvalidate({
    String? userId,
    String? groupId,
    String? postId,
    String? categoryId,
  }) async {
    await _ensureInitialized();
    
    final keysToInvalidate = <String>[];
    
    // Collect keys to invalidate based on relationships
    if (userId != null) {
      keysToInvalidate.add('user_groups_$userId');
      // Find posts by this user
      final userPostKeys = _postsBox.keys.where((key) => 
        key.toString().contains('author_$userId'));
      keysToInvalidate.addAll(userPostKeys.map((k) => k.toString()));
    }
    
    if (groupId != null) {
      keysToInvalidate.add('group_members_$groupId');
      keysToInvalidate.add('group_posts_$groupId');
      keysToInvalidate.add('group_activities_$groupId');
      // Find all posts related to this group
      final groupPostKeys = _postsBox.keys.where((key) => 
        key.toString().contains('group_$groupId'));
      keysToInvalidate.addAll(groupPostKeys.map((k) => k.toString()));
    }
    
    if (postId != null) {
      keysToInvalidate.add('post_$postId');
      keysToInvalidate.add('post_comments_$postId');
      // Find all caches that might contain this post
      final postRelatedKeys = _postsBox.keys.where((key) => 
        key.toString().contains(postId));
      keysToInvalidate.addAll(postRelatedKeys.map((k) => k.toString()));
    }
    
    if (categoryId != null) {
      // Find all posts in this category
      final categoryPostKeys = _postsBox.keys.where((key) => 
        key.toString().contains('cat_$categoryId'));
      keysToInvalidate.addAll(categoryPostKeys.map((k) => k.toString()));
    }
    
    // Invalidate all collected keys
    for (final key in keysToInvalidate.toSet()) {
      await invalidateCache(key);
    }
  }

  /// Cache warming - preload frequently accessed data
  Future<void> warmCache({
    String? userId,
    List<String>? groupIds,
    List<String>? categoryIds,
  }) async {
    await _ensureInitialized();
    
    // This would typically be called with actual data loaders
    // For now, we'll just mark the intent to warm these caches
    final warmKeys = <String>[];
    
    if (userId != null) {
      warmKeys.add('user_groups_$userId');
    }
    
    if (groupIds != null) {
      for (final groupId in groupIds) {
        warmKeys.add('group_members_$groupId');
        warmKeys.add('group_posts_$groupId');
      }
    }
    
    if (categoryIds != null) {
      for (final categoryId in categoryIds) {
        warmKeys.add('posts_cat_$categoryId');
      }
    }
    
    // Set warm cache markers
    for (final key in warmKeys) {
      await _prefs.setBool('warm_$key', true);
    }
  }

  /// Check if cache should be warmed
  Future<bool> shouldWarmCache(String cacheKey) async {
    await _ensureInitialized();
    return _prefs.getBool('warm_$cacheKey') ?? false;
  }

  /// Get detailed cache performance metrics
  Future<Map<String, dynamic>> getDetailedCacheStats() async {
    await _ensureInitialized();
    
    final now = DateTime.now();
    int validEntries = 0;
    int expiredEntries = 0;
    int totalSize = 0;
    
    // Analyze groups cache
    for (final key in _groupsBox.keys) {
      final data = _groupsBox.get(key);
      if (data != null) {
        totalSize += data.length;
        if (_isCacheValid(key.toString(), _groupCacheExpiration)) {
          validEntries++;
        } else {
          expiredEntries++;
        }
      }
    }
    
    // Analyze posts cache
    for (final key in _postsBox.keys) {
      final data = _postsBox.get(key);
      if (data != null) {
        totalSize += data.length;
        if (_isCacheValid(key.toString(), _postCacheExpiration)) {
          validEntries++;
        } else {
          expiredEntries++;
        }
      }
    }
    
    // Analyze members cache
    for (final key in _membersBox.keys) {
      final data = _membersBox.get(key);
      if (data != null) {
        totalSize += data.length;
        if (_isCacheValid(key.toString(), _memberCacheExpiration)) {
          validEntries++;
        } else {
          expiredEntries++;
        }
      }
    }
    
    return {
      'total_entries': validEntries + expiredEntries,
      'valid_entries': validEntries,
      'expired_entries': expiredEntries,
      'total_size_bytes': totalSize,
      'total_size_mb': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      'cache_efficiency': validEntries / (validEntries + expiredEntries),
      'groups_cache_size': _groupsBox.length,
      'posts_cache_size': _postsBox.length,
      'members_cache_size': _membersBox.length,
      'timestamp': now.toIso8601String(),
    };
  }

  /// Cleanup expired cache entries
  Future<int> cleanupExpiredEntries() async {
    await _ensureInitialized();
    
    int cleanedCount = 0;
    final keysToRemove = <String>[];
    
    // Check groups cache
    for (final key in _groupsBox.keys) {
      if (!_isCacheValid(key.toString(), _groupCacheExpiration)) {
        keysToRemove.add(key.toString());
      }
    }
    
    // Check posts cache
    for (final key in _postsBox.keys) {
      if (!_isCacheValid(key.toString(), _postCacheExpiration)) {
        keysToRemove.add(key.toString());
      }
    }
    
    // Check members cache
    for (final key in _membersBox.keys) {
      if (!_isCacheValid(key.toString(), _memberCacheExpiration)) {
        keysToRemove.add(key.toString());
      }
    }
    
    // Remove expired entries
    for (final key in keysToRemove) {
      await invalidateCache(key);
      cleanedCount++;
    }
    
    return cleanedCount;
  }

  /// Dispose resources
  Future<void> dispose() async {
    if (_isInitialized) {
      await _groupsBox.close();
      await _postsBox.close();
      await _membersBox.close();
      _isInitialized = false;
    }
  }
}