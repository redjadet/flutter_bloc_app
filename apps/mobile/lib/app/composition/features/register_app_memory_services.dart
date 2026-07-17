import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/app/services/app_image_cache_manager.dart';
import 'package:flutter_bloc_app/app/services/app_memory_service.dart';
import 'package:flutter_bloc_app/features/chart/data/http_chart_repository.dart';

const bool _isFlutterTestProcess = bool.fromEnvironment('FLUTTER_TEST');

/// Registers image cache manager and app memory service.
void registerAppMemoryServices() {
  if (!_isFlutterTestProcess) {
    registerLazySingletonIfAbsent<AppImageCacheManager>(
      AppImageCacheManager.new,
      dispose: (final manager) => manager.dispose(),
    );
  }
  registerLazySingletonIfAbsent<AppMemoryService>(
    () => _isFlutterTestProcess
        ? AppMemoryService(onImageCacheTrim: (level) async {})
        : AppMemoryService(
            imageCacheManager: getIt<AppImageCacheManager>(),
            onChartMemoryTrim: (level) async {
              HttpChartRepository.trimMemory(level);
            },
          ),
  );
}
