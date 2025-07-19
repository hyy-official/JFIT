import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Service for caching images locally
class ImageCacheService {
  static const String _cacheBoxName = 'image_cache';
  static const String _metadataBoxName = 'image_metadata';
  static const Duration _defaultCacheExpiration = Duration(days: 7);
  static const int _maxCacheSize = 100 * 1024 * 1024; // 100MB
  
  late Box<Uint8List> _cacheBox;
  late Box<Map<String, dynamic>> _metadataBox;
  bool _isInitialized = false;

  /// Initialize the image cache service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _cacheBox = await Hive.openBox<Uint8List>(_cacheBoxName);
    _metadataBox = await Hive.openBox<Map<String, dynamic>>(_metadataBoxName);
    
    _isInitialized = true;
    
    // Clean up expired cache entries on initialization
    await _cleanupExpiredEntries();
  }

  /// Get cached image data
  Future<Uint8List?> getCachedImage(String imageUrl) async {
    await _ensureInitialized();
    
    final cacheKey = _generateCacheKey(imageUrl);
    final metadata = _metadataBox.get(cacheKey);
    
    if (metadata == null) return null;
    
    // Check if cache entry is expired
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(metadata['cached_at'] as int);
    final expiration = Duration(milliseconds: metadata['expiration_ms'] as int);
    
    if (DateTime.now().difference(cachedAt) > expiration) {
      await _removeCacheEntry(cacheKey);
      return null;
    }
    
    return _cacheBox.get(cacheKey);
  }

  /// Cache image data
  Future<void> cacheImage(
    String imageUrl,
    Uint8List imageData, {
    Duration? expiration,
  }) async {
    await _ensureInitialized();
    
    final cacheKey = _generateCacheKey(imageUrl);
    final cacheExpiration = expiration ?? _defaultCacheExpiration;
    
    // Check cache size and cleanup if necessary
    await _ensureCacheSize();
    
    final metadata = {
      'url': imageUrl,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
      'expiration_ms': cacheExpiration.inMilliseconds,
      'size': imageData.length,
      'access_count': 0,
      'last_accessed': DateTime.now().millisecondsSinceEpoch,
    };
    
    await _cacheBox.put(cacheKey, imageData);
    await _metadataBox.put(cacheKey, metadata);
  }

  /// Download and cache image from URL
  Future<Uint8List?> downloadAndCacheImage(
    String imageUrl, {
    Duration? expiration,
    Map<String, String>? headers,
  }) async {
    try {
      // Check if already cached
      final cachedData = await getCachedImage(imageUrl);
      if (cachedData != null) {
        await _updateAccessInfo(imageUrl);
        return cachedData;
      }
      
      // Download image
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final imageData = response.bodyBytes;
        await cacheImage(imageUrl, imageData, expiration: expiration);
        return imageData;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error downloading image: $e');
      return null;
    }
  }

  /// Preload images for better performance
  Future<void> preloadImages(List<String> imageUrls) async {
    final futures = imageUrls.map((url) => downloadAndCacheImage(url));
    await Future.wait(futures, eagerError: false);
  }

  /// Remove specific image from cache
  Future<void> removeFromCache(String imageUrl) async {
    await _ensureInitialized();
    
    final cacheKey = _generateCacheKey(imageUrl);
    await _removeCacheEntry(cacheKey);
  }

  /// Clear all cached images
  Future<void> clearCache() async {
    await _ensureInitialized();
    
    await _cacheBox.clear();
    await _metadataBox.clear();
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    await _ensureInitialized();
    
    int totalSize = 0;
    int expiredCount = 0;
    final now = DateTime.now();
    
    for (final metadata in _metadataBox.values) {
      final map = Map<String, dynamic>.from(metadata);
      totalSize += map['size'] as int;
      
      final cachedAt = DateTime.fromMillisecondsSinceEpoch(map['cached_at'] as int);
      final expiration = Duration(milliseconds: map['expiration_ms'] as int);
      
      if (now.difference(cachedAt) > expiration) {
        expiredCount++;
      }
    }
    
    return {
      'total_images': _cacheBox.length,
      'total_size_bytes': totalSize,
      'total_size_mb': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      'expired_count': expiredCount,
      'cache_hit_ratio': await _calculateHitRatio(),
    };
  }

  /// Optimize cache by removing least recently used items
  Future<void> optimizeCache() async {
    await _ensureInitialized();
    
    await _cleanupExpiredEntries();
    await _ensureCacheSize();
  }

  // Private helper methods

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  String _generateCacheKey(String imageUrl) {
    final bytes = utf8.encode(imageUrl);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _updateAccessInfo(String imageUrl) async {
    final cacheKey = _generateCacheKey(imageUrl);
    final metadata = _metadataBox.get(cacheKey);
    
    if (metadata != null) {
      final updatedMetadata = Map<String, dynamic>.from(metadata);
      updatedMetadata['access_count'] = (updatedMetadata['access_count'] as int) + 1;
      updatedMetadata['last_accessed'] = DateTime.now().millisecondsSinceEpoch;
      
      await _metadataBox.put(cacheKey, updatedMetadata);
    }
  }

  Future<void> _removeCacheEntry(String cacheKey) async {
    await _cacheBox.delete(cacheKey);
    await _metadataBox.delete(cacheKey);
  }

  Future<void> _cleanupExpiredEntries() async {
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    for (final entry in _metadataBox.toMap().entries) {
      final metadata = Map<String, dynamic>.from(entry.value);
      final cachedAt = DateTime.fromMillisecondsSinceEpoch(metadata['cached_at'] as int);
      final expiration = Duration(milliseconds: metadata['expiration_ms'] as int);
      
      if (now.difference(cachedAt) > expiration) {
        keysToRemove.add(entry.key);
      }
    }
    
    for (final key in keysToRemove) {
      await _removeCacheEntry(key);
    }
  }

  Future<void> _ensureCacheSize() async {
    int totalSize = 0;
    final entries = <MapEntry<String, int>>[];
    
    // Calculate total size and collect entries with their access info
    for (final entry in _metadataBox.toMap().entries) {
      final metadata = Map<String, dynamic>.from(entry.value);
      final size = metadata['size'] as int;
      final lastAccessed = metadata['last_accessed'] as int;
      
      totalSize += size;
      entries.add(MapEntry(entry.key, lastAccessed));
    }
    
    // If cache is too large, remove least recently used items
    if (totalSize > _maxCacheSize) {
      // Sort by last accessed time (oldest first)
      entries.sort((a, b) => a.value.compareTo(b.value));
      
      // Remove oldest entries until we're under the size limit
      for (final entry in entries) {
        if (totalSize <= _maxCacheSize * 0.8) break; // Leave some buffer
        
        final metadata = _metadataBox.get(entry.key);
        if (metadata != null) {
          final size = metadata['size'] as int;
          await _removeCacheEntry(entry.key);
          totalSize -= size;
        }
      }
    }
  }

  Future<double> _calculateHitRatio() async {
    int totalAccess = 0;
    int totalImages = 0;
    
    for (final metadata in _metadataBox.values) {
      final map = Map<String, dynamic>.from(metadata);
      totalAccess += map['access_count'] as int;
      totalImages++;
    }
    
    return totalImages > 0 ? totalAccess / totalImages : 0.0;
  }

  /// Dispose resources
  Future<void> dispose() async {
    if (_isInitialized) {
      await _cacheBox.close();
      await _metadataBox.close();
      _isInitialized = false;
    }
  }
}