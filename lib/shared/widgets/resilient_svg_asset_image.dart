import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Displays an SVG asset but falls back to the embedded raster payload when
/// the vector contains base64 bitmap data that Flutter cannot render.
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
      if (match != null) {
        final bytes = base64Decode(match.group(1)!);
        _cache[assetPath] = bytes;
        return bytes;
      }
    } on Exception catch (_) {
      // ignore asset read issues; fallbacks below handle them gracefully
    }

    _cache[assetPath] = null;
    return null;
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
  Widget build(BuildContext context) {
    if (_cache.containsKey(assetPath)) {
      final bytes = _cache[assetPath];
      if (bytes != null) {
        return Image.memory(bytes, fit: fit);
      }
      return _buildSvgPicture();
    }

    return FutureBuilder<Uint8List?>(
      future: _loadBytes(),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes != null) {
          return Image.memory(bytes, fit: fit);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return fallbackBuilder();
        }

        return _buildSvgPicture();
      },
    );
  }
}
