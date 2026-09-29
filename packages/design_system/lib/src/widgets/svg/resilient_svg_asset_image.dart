import 'dart:convert';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:utilities/utilities.dart' show AppMemoryTrimLevel;

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
/// The load [Future] is created in [State.initState] / [State.didUpdateWidget],
/// never in [State.build], so parent rebuilds do not restart the decode.
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
class ResilientSvgAssetImage extends StatefulWidget {
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

  @visibleForTesting
  static int get debugCacheSize => _cache.length;

  @visibleForTesting
  static int debugLoadStarts = 0;

  @visibleForTesting
  static void debugResetLoadStarts() => debugLoadStarts = 0;

  @visibleForTesting
  static void debugStoreCacheEntry(String key, Uint8List? value) {
    _evictIfNeeded();
    _cache[key] = value;
  }

  @visibleForTesting
  static void debugClearCache() => _cache.clear();

  static Future<void> trimCache({required AppMemoryTrimLevel level}) async {
    if (_cache.isEmpty) {
      return;
    }

    if (level == AppMemoryTrimLevel.background) {
      final int targetSize = _cache.length <= 1 ? 1 : _cache.length ~/ 2;
      while (_cache.length > targetSize && _cache.isNotEmpty) {
        _cache.remove(_cache.keys.first);
      }
      return;
    }

    _cache.clear();
  }

  static void _evictIfNeeded() {
    while (_cache.length >= _maxCacheSize && _cache.isNotEmpty) {
      _cache.remove(_cache.keys.first);
    }
  }

  static Future<Uint8List?> _loadBytes(String assetPath) async {
    if (_cache.containsKey(assetPath)) {
      return _cache[assetPath];
    }

    debugLoadStarts++;

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

  @override
  State<ResilientSvgAssetImage> createState() => _ResilientSvgAssetImageState();
}

class _ResilientSvgAssetImageState extends State<ResilientSvgAssetImage> {
  late Future<Uint8List?> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = ResilientSvgAssetImage._loadBytes(widget.assetPath);
  }

  @override
  void didUpdateWidget(covariant ResilientSvgAssetImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _loadFuture = ResilientSvgAssetImage._loadBytes(widget.assetPath);
    }
  }

  Widget _buildSvgPicture() {
    try {
      return SvgPicture.asset(
        widget.assetPath,
        fit: widget.fit,
        placeholderBuilder: (_) => widget.fallbackBuilder(),
      );
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'ResilientSvgAssetImage: SvgPicture.asset failed for ${widget.assetPath}',
        error,
        stackTrace,
      );
      return widget.fallbackBuilder();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ResilientSvgAssetImage._cache.containsKey(widget.assetPath)) {
      final bytes = ResilientSvgAssetImage._cache[widget.assetPath];
      if (bytes case final data?) {
        return Image.memory(data, fit: widget.fit);
      }
      return _buildSvgPicture();
    }

    return FutureBuilder<Uint8List?>(
      future: _loadFuture,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes case final data?) {
          return Image.memory(data, fit: widget.fit);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.fallbackBuilder();
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
