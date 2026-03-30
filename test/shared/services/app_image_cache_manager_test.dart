import 'package:flutter_bloc_app/shared/services/app_image_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppImageCacheManager', () {
    test('exposes bounded cache defaults', () {
      expect(AppImageCacheManager.cacheKey, 'app_cached_network_images');
      expect(AppImageCacheManager.defaultMaxNrOfCacheObjects, 100);
      expect(AppImageCacheManager.defaultStalePeriod, const Duration(days: 14));
    });
  });
}
