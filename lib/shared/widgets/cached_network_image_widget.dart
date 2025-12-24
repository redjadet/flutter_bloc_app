import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A reusable widget for displaying cached network images with proper error handling.
///
/// This widget wraps `CachedNetworkImage` to provide consistent image loading,
/// caching, and error handling throughout the app.
///
/// **Features:**
/// - Automatic caching of downloaded images
/// - Loading placeholder support
/// - Error handling with fallback widget
/// - Memory-efficient image loading
///
/// **Usage Example:**
/// ```dart
/// CachedNetworkImageWidget(
///   imageUrl: 'https://example.com/image.jpg',
///   fit: BoxFit.cover,
///   placeholder: (context) => CircularProgressIndicator(),
///   errorWidget: (context, url, error) => Icon(Icons.error),
/// )
/// ```
class CachedNetworkImageWidget extends StatelessWidget {
  const CachedNetworkImageWidget({
    required this.imageUrl,
    this.fit,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration,
    this.fadeOutDuration,
    this.memCacheWidth,
    this.memCacheHeight,
    super.key,
  });

  /// The URL of the image to load.
  final String imageUrl;

  /// How the image should be inscribed into the available space.
  final BoxFit? fit;

  /// The width of the image.
  final double? width;

  /// The height of the image.
  final double? height;

  /// Widget displayed while the image is loading.
  ///
  /// If not provided, a default loading indicator is shown.
  final Widget Function(BuildContext context, String url)? placeholder;

  /// Widget displayed when the image fails to load.
  ///
  /// If not provided, a default error icon is shown.
  final Widget Function(BuildContext context, String url, Object error)?
  errorWidget;

  /// Duration for the fade-in animation when the image loads.
  final Duration? fadeInDuration;

  /// Duration for the fade-out animation when the image is removed.
  final Duration? fadeOutDuration;

  /// Maximum width for the image in memory cache (for memory optimization).
  final int? memCacheWidth;

  /// Maximum height for the image in memory cache (for memory optimization).
  final int? memCacheHeight;

  @override
  Widget build(final BuildContext context) => CachedNetworkImage(
    imageUrl: imageUrl,
    fit: fit,
    width: width,
    height: height,
    placeholder:
        placeholder ??
        (final context, final url) => ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
    errorWidget:
        errorWidget ??
        (final context, final url, final error) => ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
    fadeInDuration: fadeInDuration ?? const Duration(milliseconds: 300),
    fadeOutDuration: fadeOutDuration ?? const Duration(milliseconds: 100),
    memCacheWidth: memCacheWidth,
    memCacheHeight: memCacheHeight,
  );
}
