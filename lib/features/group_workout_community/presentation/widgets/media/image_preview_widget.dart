import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Widget for previewing selected images before upload
class ImagePreviewWidget extends StatelessWidget {
  final List<String> imagePaths;
  final Function(int index)? onRemove;
  final Function(int index)? onEdit;
  final bool showEditButton;
  final bool showRemoveButton;
  final double itemHeight;
  final EdgeInsets padding;

  const ImagePreviewWidget({
    super.key,
    required this.imagePaths,
    this.onRemove,
    this.onEdit,
    this.showEditButton = true,
    this.showRemoveButton = true,
    this.itemHeight = 120,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    if (imagePaths.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: itemHeight + padding.vertical,
      padding: padding,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _ImagePreviewItem(
              imagePath: imagePaths[index],
              index: index,
              onRemove: onRemove,
              onEdit: onEdit,
              showEditButton: showEditButton,
              showRemoveButton: showRemoveButton,
              height: itemHeight,
            ),
          );
        },
      ),
    );
  }
}

class _ImagePreviewItem extends StatelessWidget {
  final String imagePath;
  final int index;
  final Function(int index)? onRemove;
  final Function(int index)? onEdit;
  final bool showEditButton;
  final bool showRemoveButton;
  final double height;

  const _ImagePreviewItem({
    required this.imagePath,
    required this.index,
    this.onRemove,
    this.onEdit,
    required this.showEditButton,
    required this.showRemoveButton,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: height,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(imagePath),
              width: height,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: height,
                  height: height,
                  color: theme.colorScheme.surfaceVariant,
                  child: Icon(
                    LucideIcons.imageOff,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 32,
                  ),
                );
              },
            ),
          ),
          
          // Overlay with buttons
          if (showEditButton || showRemoveButton)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
          
          // Edit button
          if (showEditButton && onEdit != null)
            Positioned(
              top: 4,
              left: 4,
              child: _ActionButton(
                icon: LucideIcons.edit2,
                onPressed: () => onEdit!(index),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          
          // Remove button
          if (showRemoveButton && onRemove != null)
            Positioned(
              top: 4,
              right: 4,
              child: _ActionButton(
                icon: LucideIcons.x,
                onPressed: () => onRemove!(index),
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
            ),
          
          // Image index indicator
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${index + 1}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            size: 16,
            color: foregroundColor,
          ),
        ),
      ),
    );
  }
}

/// Widget for displaying uploaded images with URLs
class UploadedImagePreviewWidget extends StatelessWidget {
  final List<String> imageUrls;
  final Function(int index)? onRemove;
  final bool showRemoveButton;
  final double itemHeight;
  final EdgeInsets padding;

  const UploadedImagePreviewWidget({
    super.key,
    required this.imageUrls,
    this.onRemove,
    this.showRemoveButton = true,
    this.itemHeight = 120,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: itemHeight + padding.vertical,
      padding: padding,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _UploadedImagePreviewItem(
              imageUrl: imageUrls[index],
              index: index,
              onRemove: onRemove,
              showRemoveButton: showRemoveButton,
              height: itemHeight,
            ),
          );
        },
      ),
    );
  }
}

class _UploadedImagePreviewItem extends StatelessWidget {
  final String imageUrl;
  final int index;
  final Function(int index)? onRemove;
  final bool showRemoveButton;
  final double height;

  const _UploadedImagePreviewItem({
    required this.imageUrl,
    required this.index,
    this.onRemove,
    required this.showRemoveButton,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: height,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: height,
              height: height,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: height,
                  height: height,
                  color: theme.colorScheme.surfaceVariant,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: height,
                  height: height,
                  color: theme.colorScheme.surfaceVariant,
                  child: Icon(
                    LucideIcons.imageOff,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 32,
                  ),
                );
              },
            ),
          ),
          
          // Remove button
          if (showRemoveButton && onRemove != null)
            Positioned(
              top: 4,
              right: 4,
              child: _ActionButton(
                icon: LucideIcons.x,
                onPressed: () => onRemove!(index),
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
            ),
          
          // Image index indicator
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${index + 1}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}