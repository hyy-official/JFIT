import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/services/image_cache_service.dart';

/// A widget that displays cached network images with fallback support
class CachedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration? cacheDuration;
  final Map<String, String>? headers;
  final BorderRadius? borderRadius;
  final bool enableMemoryCache;

  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.cacheDuration,
    this.headers,
    this.borderRadius,
    this.enableMemoryCache = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      httpHeaders: headers,
      memCacheWidth: enableMemoryCache ? _getMemCacheWidth() : null,
      memCacheHeight: enableMemoryCache ? _getMemCacheHeight() : null,
      placeholder: (context, url) => placeholder ?? _buildDefaultPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildDefaultErrorWidget(),
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 200),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
      child: const Icon(
        Icons.broken_image,
        color: Colors.grey,
        size: 32,
      ),
    );
  }

  int? _getMemCacheWidth() {
    if (width == null) return null;
    // Scale for device pixel ratio
    return (width! * 2).round();
  }

  int? _getMemCacheHeight() {
    if (height == null) return null;
    // Scale for device pixel ratio
    return (height! * 2).round();
  }
}

/// A specialized cached image widget for user avatars
class CachedAvatarImage extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String? fallbackText;
  final Color? backgroundColor;
  final Color? textColor;

  const CachedAvatarImage({
    super.key,
    this.imageUrl,
    required this.radius,
    this.fallbackText,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallbackAvatar(context);
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey[300],
      child: ClipOval(
        child: CachedImageWidget(
          imageUrl: imageUrl!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: _buildFallbackAvatar(context),
          errorWidget: _buildFallbackAvatar(context),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor.withOpacity(0.1),
      child: Text(
        _getInitials(),
        style: TextStyle(
          color: textColor ?? Theme.of(context).primaryColor,
          fontSize: radius * 0.6,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getInitials() {
    if (fallbackText == null || fallbackText!.isEmpty) {
      return '?';
    }
    
    final words = fallbackText!.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    
    return '?';
  }
}

/// A widget for displaying post images with optimized caching
class CachedPostImage extends StatelessWidget {
  final String imageUrl;
  final double? aspectRatio;
  final VoidCallback? onTap;
  final bool showFullScreenOnTap;

  const CachedPostImage({
    super.key,
    required this.imageUrl,
    this.aspectRatio,
    this.onTap,
    this.showFullScreenOnTap = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = CachedImageWidget(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(8),
    );

    if (aspectRatio != null) {
      imageWidget = AspectRatio(
        aspectRatio: aspectRatio!,
        child: imageWidget,
      );
    }

    if (onTap != null || showFullScreenOnTap) {
      imageWidget = GestureDetector(
        onTap: onTap ?? () => _showFullScreenImage(context),
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  void _showFullScreenImage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImageViewer(imageUrl: imageUrl),
        fullscreenDialog: true,
      ),
    );
  }
}

/// Full screen image viewer
class _FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: CachedImageWidget(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

/// A grid widget for displaying multiple cached images
class CachedImageGrid extends StatelessWidget {
  final List<String> imageUrls;
  final int crossAxisCount;
  final double aspectRatio;
  final double spacing;
  final Function(String imageUrl, int index)? onImageTap;

  const CachedImageGrid({
    super.key,
    required this.imageUrls,
    this.crossAxisCount = 2,
    this.aspectRatio = 1.0,
    this.spacing = 8.0,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        aspectRatio: aspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        final imageUrl = imageUrls[index];
        return GestureDetector(
          onTap: () => onImageTap?.call(imageUrl, index),
          child: CachedImageWidget(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}