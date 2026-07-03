import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc_app/shared/services/app_memory_trim_level.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// App-owned cache manager for cached network images.
///
/// This keeps image caching bounded and gives the app shell a single place to
/// perform aggressive cache cleanup when the OS reports memory pressure.
class AppImageCacheManager extends CacheManager {
  AppImageCacheManager({
    Duration stalePeriod = defaultStalePeriod,
    int maxNrOfCacheObjects = defaultMaxNrOfCacheObjects,
  }) : super(
         Config(
           cacheKey,
           stalePeriod: stalePeriod,
           maxNrOfCacheObjects: maxNrOfCacheObjects,
         ),
       ) {
    if (!_isFlutterTestProcess) {
      CachedNetworkImageProvider.defaultCacheManager = this;
    }
  }

  static const String cacheKey = 'app_cached_network_images';
  static const Duration defaultStalePeriod = Duration(days: 14);
  static const int defaultMaxNrOfCacheObjects = 100;
  static const bool _isFlutterTestProcess = bool.fromEnvironment(
    'FLUTTER_TEST',
  );

  Future<void> onTrim(final AppMemoryTrimLevel level) async {
    if (level != AppMemoryTrimLevel.pressure) {
      return;
    }
    await emptyCache();
  }

  @override
  Future<void> dispose() async {
    try {
      await super.dispose();
    } on Object {
      // Tests may construct the manager before its underlying repo fully opens.
      // Treat dispose as best-effort so DI teardown remains idempotent.
    }
  }
}
