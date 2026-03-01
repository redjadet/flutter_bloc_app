import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Displays an SVG asset but falls back to the embedded raster payload when
/// the vector contains base64 bitmap data that Flutter cannot render.
///
/// **Why this exists:** Some SVG files contain embedded base64-encoded raster images
/// (e.g., PNG data) that Flutter's SVG renderer cannot display. This widget detects
/// such cases and extracts the raster image for display instead.
///
/// **How it works:**
/// 1. Loads the SVG file and checks for base64 image data using regex
/// 2. If found, decodes the base64 data and displays it as `Image.memory`
/// 3. If not found, falls back to normal SVG rendering via `SvgPicture.asset`
/// 4. Caches the result to avoid re-parsing on rebuilds
///
/// **Usage Example:**
/// ```dart
/// ResilientSvgAssetImage(
///   assetPath: 'assets/icons/logo.svg',
///   fit: BoxFit.contain,
///   fallbackBuilder: () => const CircularProgressIndicator(),
/// )
/// ```
///
/// **Performance:** Uses static caching to avoid re-parsing SVG files on every rebuild.
/// The cache is bounded to avoid unbounded memory growth when many distinct paths are used.
class ResilientSvgAssetImage extends StatelessWidget {
  const ResilientSvgAssetImage({
    required this.assetPath,
    required this.fit,
    required this.fallbackBuilder,
    super.key,
  });

  final String assetPath;
  final BoxFit fit;
  final Widget Function() fallbackBuilder;

  static const int _maxCacheSize = 64;
  static final Map<String, Uint8List?> _cache = {};
  static final Pattern _base64Pattern = RegExp(
    r'data:image/[^;]+;base64,([^"\\)]+)',
  );

  Future<Uint8List?> _loadBytes() async {
    if (_cache.containsKey(assetPath)) {
      return _cache[assetPath];
    }

    try {
      final svgString = await rootBundle.loadString(assetPath);
      final match = (_base64Pattern as RegExp).firstMatch(svgString);
      final String? base64Group = match?.group(1);
      if (base64Group != null && base64Group.isNotEmpty) {
        final bytes = base64Decode(base64Group);
        _evictIfNeeded();
        _cache[assetPath] = bytes;
        return bytes;
      }
    } on Exception catch (error, stackTrace) {
      // Fallbacks below handle display; log so we do not fail silently
      AppLogger.error(
        'ResilientSvgAssetImage: asset load/decode failed for $assetPath',
        error,
        stackTrace,
      );
    }

    _evictIfNeeded();
    _cache[assetPath] = null;
    return null;
  }

  static void _evictIfNeeded() {
    while (_cache.length >= _maxCacheSize && _cache.isNotEmpty) {
      _cache.remove(_cache.keys.first);
    }
  }

  Widget _buildSvgPicture() {
    try {
      return SvgPicture.asset(
        assetPath,
        fit: fit,
        placeholderBuilder: (_) => fallbackBuilder(),
      );
    } on Exception catch (_) {
      return fallbackBuilder();
    }
  }

  @override
  Widget build(final BuildContext context) {
    if (_cache.containsKey(assetPath)) {
      final bytes = _cache[assetPath];
      if (bytes case final data?) {
        return Image.memory(data, fit: fit);
      }
      return _buildSvgPicture();
    }

    return FutureBuilder<Uint8List?>(
      future: _loadBytes(),
      builder: (final context, final snapshot) {
        final bytes = snapshot.data;
        if (bytes case final data?) {
          return Image.memory(data, fit: fit);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return fallbackBuilder();
        }

        if (snapshot.hasError) {
          AppLogger.error(
            'ResilientSvgAssetImage load failed',
            snapshot.error,
            snapshot.stackTrace,
          );
        }
        return _buildSvgPicture();
      },
    );
  }
}
