import 'dart:async';

import 'package:flutter/painting.dart';
import 'package:flutter_bloc_app/features/chart/data/http_chart_repository.dart';
import 'package:flutter_bloc_app/shared/services/app_image_cache_manager.dart';
import 'package:flutter_bloc_app/shared/services/app_memory_trim_level.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/widgets/resilient_svg_asset_image.dart';

/// Centralizes app-wide memory trimming using existing cache owners.
class AppMemoryService {
  AppMemoryService({
    AppImageCacheManager? imageCacheManager,
    Future<void> Function(AppMemoryTrimLevel level)? onImageCacheTrim,
  }) : assert(
         imageCacheManager != null || onImageCacheTrim != null,
         'Provide either imageCacheManager or onImageCacheTrim.',
       ),
       _onImageCacheTrim =
           onImageCacheTrim ??
           imageCacheManager?.onTrim ??
           _missingImageCacheTrim;

  final Future<void> Function(AppMemoryTrimLevel level) _onImageCacheTrim;

  Future<void>? _trimInFlight;
  AppMemoryTrimLevel? _queuedLevel;

  static Future<void> _missingImageCacheTrim(
    final AppMemoryTrimLevel level,
  ) async {
    throw StateError('Provide either imageCacheManager or onImageCacheTrim.');
  }

  Future<void> trim(final AppMemoryTrimLevel level) async {
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
    final AppMemoryTrimLevel? current,
    final AppMemoryTrimLevel next,
  ) {
    if (current == AppMemoryTrimLevel.pressure ||
        next == AppMemoryTrimLevel.pressure) {
      return AppMemoryTrimLevel.pressure;
    }
    return AppMemoryTrimLevel.background;
  }

  Future<void> _performTrim(final AppMemoryTrimLevel level) async {
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
    await _runSafely(
      'HttpChartRepository.trimMemory',
      () async => HttpChartRepository.trimMemory(level),
    );
    await _runSafely(
      'AppImageCacheManager.onTrim',
      () => _onImageCacheTrim(level),
    );
  }

  Future<void> _runSafely(
    final String label,
    final Future<void> Function() action,
  ) async {
    try {
      await action();
    } on Object catch (error, stackTrace) {
      AppLogger.error('AppMemoryService $label failed', error, stackTrace);
    }
  }
}
