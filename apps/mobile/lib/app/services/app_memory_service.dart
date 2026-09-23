import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:design_system/design_system.dart' show ResilientSvgAssetImage;
import 'package:flutter/painting.dart';
import 'package:flutter_bloc_app/app/services/app_image_cache_manager.dart';
import 'package:utilities/utilities.dart' show AppMemoryTrimLevel;
import 'package:utilities/utilities.dart';

/// Centralizes app-wide memory trimming using existing cache owners.
///
/// Why: Dart GC only frees *unreachable* heap objects; trim ends retention of
/// image / SVG / feature static caches so they can become eligible. Native and
/// external memory are separate from Dart heap size — see
/// `docs/performance/dart_memory_under_the_hood.md`.
///
/// Optional `onStaticCacheTrim` is wired from the composition root (DI) so
/// this library does not depend on feature implementations.
class AppMemoryService {
  new({
    AppImageCacheManager? imageCacheManager,
    Future<void> Function(AppMemoryTrimLevel level)? onImageCacheTrim,
    Future<void> Function(AppMemoryTrimLevel level)? onStaticCacheTrim,
  }) : assert(
         imageCacheManager != null || onImageCacheTrim != null,
         'Provide either imageCacheManager or onImageCacheTrim.',
       ),
       _onImageCacheTrim =
           onImageCacheTrim ??
           imageCacheManager?.onTrim ??
           _missingImageCacheTrim,
       _onStaticCacheTrim = onStaticCacheTrim ?? _noopStaticCacheTrim;

  final Future<void> Function(AppMemoryTrimLevel level) _onImageCacheTrim;
  final Future<void> Function(AppMemoryTrimLevel level) _onStaticCacheTrim;

  static Future<void> _noopStaticCacheTrim(AppMemoryTrimLevel _) async {}

  Future<void>? _trimInFlight;
  AppMemoryTrimLevel? _queuedLevel;

  static Future<void> _missingImageCacheTrim(AppMemoryTrimLevel level) async {
    throw StateError('Provide either imageCacheManager or onImageCacheTrim.');
  }

  Future<void> trim(AppMemoryTrimLevel level) async {
    final Future<void>? inFlight = _trimInFlight;
    if (inFlight != null) {
      _queuedLevel = _mergeLevels(_queuedLevel, level);
      await inFlight;
      return;
    }

    final Future<void> run = _performTrim(level);
    _trimInFlight = run;

    try {
      await run;
    } finally {
      if (identical(_trimInFlight, run)) {
        _trimInFlight = null;
      }
      final AppMemoryTrimLevel? queued = _queuedLevel;
      _queuedLevel = null;
      if (queued != null) {
        await trim(queued);
      }
    }
  }

  AppMemoryTrimLevel _mergeLevels(
    AppMemoryTrimLevel? current,
    AppMemoryTrimLevel next,
  ) {
    if (current == AppMemoryTrimLevel.pressure ||
        next == AppMemoryTrimLevel.pressure) {
      return AppMemoryTrimLevel.pressure;
    }
    return AppMemoryTrimLevel.background;
  }

  Future<void> _performTrim(AppMemoryTrimLevel level) async {
    final ImageCache imageCache = PaintingBinding.instance.imageCache
      ..clearLiveImages();
    if (level == AppMemoryTrimLevel.pressure) {
      imageCache
        ..clear()
        ..clearLiveImages();
    }

    await _runSafely(
      'ResilientSvgAssetImage.trimCache',
      () => ResilientSvgAssetImage.trimCache(level: level),
    );
    await _runSafely('staticCacheTrim', () => _onStaticCacheTrim(level));
    await _runSafely(
      'AppImageCacheManager.onTrim',
      () => _onImageCacheTrim(level),
    );
  }

  Future<void> _runSafely(String label, Future<void> Function() action) async {
    try {
      await action();
    } on Object catch (error, stackTrace) {
      AppLogger.error('AppMemoryService $label failed', error, stackTrace);
    }
  }
}
