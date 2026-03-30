import 'dart:async';

import 'package:flutter_bloc_app/features/chart/data/api/coingecko_api.dart';
import 'package:flutter_bloc_app/features/chart/data/http_chart_repository.dart';
import 'package:flutter_bloc_app/shared/services/app_memory_service.dart';
import 'package:flutter_bloc_app/shared/services/app_memory_trim_level.dart';
import 'package:flutter_bloc_app/shared/widgets/resilient_svg_asset_image.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCoingeckoApi implements CoingeckoApi {
  @override
  Future<String> getBitcoinMarketChart(
    final Map<String, String> query,
    final String accept,
  ) async => '''
{
  "prices": [
    [1711929600000, 70000],
    [1712016000000, 70500]
  ]
}
''';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppMemoryService', () {
    test(
      'background trim shrinks svg cache and preserves chart cache',
      () async {
        final List<AppMemoryTrimLevel> imageCacheTrimCalls =
            <AppMemoryTrimLevel>[];
        final AppMemoryService service = AppMemoryService(
          onImageCacheTrim: (final level) async {
            imageCacheTrimCalls.add(level);
          },
        );

        final HttpChartRepository chartRepository = HttpChartRepository(
          api: _FakeCoingeckoApi(),
        );
        await chartRepository.fetchTrendingCounts();
        ResilientSvgAssetImage.debugStoreCacheEntry('a', null);
        ResilientSvgAssetImage.debugStoreCacheEntry('b', null);
        ResilientSvgAssetImage.debugStoreCacheEntry('c', null);

        await service.trim(AppMemoryTrimLevel.background);

        expect(HttpChartRepository.debugCacheSize, greaterThan(0));
        expect(ResilientSvgAssetImage.debugCacheSize, lessThanOrEqualTo(2));
        expect(imageCacheTrimCalls, <AppMemoryTrimLevel>[
          AppMemoryTrimLevel.background,
        ]);

        HttpChartRepository.clearCache();
        await ResilientSvgAssetImage.trimCache(
          level: AppMemoryTrimLevel.pressure,
        );
      },
    );

    test('pressure trim clears aggressive in-memory caches', () async {
      final List<AppMemoryTrimLevel> imageCacheTrimCalls =
          <AppMemoryTrimLevel>[];
      final AppMemoryService service = AppMemoryService(
        onImageCacheTrim: (final level) async {
          imageCacheTrimCalls.add(level);
        },
      );

      final HttpChartRepository chartRepository = HttpChartRepository(
        api: _FakeCoingeckoApi(),
      );
      await chartRepository.fetchTrendingCounts();
      ResilientSvgAssetImage.debugStoreCacheEntry('a', null);
      ResilientSvgAssetImage.debugStoreCacheEntry('b', null);

      await service.trim(AppMemoryTrimLevel.pressure);

      expect(HttpChartRepository.debugCacheSize, 0);
      expect(ResilientSvgAssetImage.debugCacheSize, 0);
      expect(imageCacheTrimCalls, <AppMemoryTrimLevel>[
        AppMemoryTrimLevel.pressure,
      ]);

      await ResilientSvgAssetImage.trimCache(
        level: AppMemoryTrimLevel.pressure,
      );
    });

    test(
      'queued pressure trim escalates an in-flight background trim',
      () async {
        final Completer<void> allowBackgroundTrim = Completer<void>();
        final List<AppMemoryTrimLevel> imageCacheTrimCalls =
            <AppMemoryTrimLevel>[];
        final AppMemoryService service = AppMemoryService(
          onImageCacheTrim: (final level) async {
            imageCacheTrimCalls.add(level);
            if (level == AppMemoryTrimLevel.background &&
                !allowBackgroundTrim.isCompleted) {
              await allowBackgroundTrim.future;
            }
          },
        );

        final HttpChartRepository chartRepository = HttpChartRepository(
          api: _FakeCoingeckoApi(),
        );
        await chartRepository.fetchTrendingCounts();
        ResilientSvgAssetImage.debugStoreCacheEntry('a', null);
        ResilientSvgAssetImage.debugStoreCacheEntry('b', null);

        final Future<void> backgroundTrim = service.trim(
          AppMemoryTrimLevel.background,
        );
        final Future<void> pressureTrim = service.trim(
          AppMemoryTrimLevel.pressure,
        );

        await Future<void>.delayed(Duration.zero);
        expect(imageCacheTrimCalls, <AppMemoryTrimLevel>[
          AppMemoryTrimLevel.background,
        ]);
        expect(HttpChartRepository.debugCacheSize, greaterThan(0));

        allowBackgroundTrim.complete();
        await Future.wait(<Future<void>>[backgroundTrim, pressureTrim]);

        expect(imageCacheTrimCalls, <AppMemoryTrimLevel>[
          AppMemoryTrimLevel.background,
          AppMemoryTrimLevel.pressure,
        ]);
        expect(HttpChartRepository.debugCacheSize, 0);
        expect(ResilientSvgAssetImage.debugCacheSize, 0);
      },
    );
  });
}
