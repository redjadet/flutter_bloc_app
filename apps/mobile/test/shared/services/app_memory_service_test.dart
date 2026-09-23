import 'dart:async';

import 'package:flutter_bloc_app/app/services/app_memory_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utilities/utilities.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('forwards trim level to static-cache and image callbacks', () async {
    final List<AppMemoryTrimLevel> staticLevels = <AppMemoryTrimLevel>[];
    final List<AppMemoryTrimLevel> imageLevels = <AppMemoryTrimLevel>[];
    final AppMemoryService service = AppMemoryService(
      onImageCacheTrim: (AppMemoryTrimLevel level) async {
        imageLevels.add(level);
      },
      onStaticCacheTrim: (AppMemoryTrimLevel level) async {
        staticLevels.add(level);
      },
    );

    await service.trim(AppMemoryTrimLevel.background);

    expect(staticLevels, <AppMemoryTrimLevel>[AppMemoryTrimLevel.background]);
    expect(imageLevels, <AppMemoryTrimLevel>[AppMemoryTrimLevel.background]);
  });

  test('queued pressure trim runs after in-flight background trim', () async {
    final Completer<void> allowBackgroundImageTrim = Completer<void>();
    final List<AppMemoryTrimLevel> imageLevels = <AppMemoryTrimLevel>[];
    final AppMemoryService service = AppMemoryService(
      onImageCacheTrim: (AppMemoryTrimLevel level) async {
        imageLevels.add(level);
        if (level == AppMemoryTrimLevel.background) {
          await allowBackgroundImageTrim.future;
        }
      },
      onStaticCacheTrim: (_) async {},
    );

    final Future<void> backgroundTrim = service.trim(
      AppMemoryTrimLevel.background,
    );
    final Future<void> pressureTrim = service.trim(AppMemoryTrimLevel.pressure);

    await Future<void>.delayed(Duration.zero);
    expect(imageLevels, <AppMemoryTrimLevel>[AppMemoryTrimLevel.background]);

    allowBackgroundImageTrim.complete();
    await Future.wait(<Future<void>>[backgroundTrim, pressureTrim]);

    expect(imageLevels, <AppMemoryTrimLevel>[
      AppMemoryTrimLevel.background,
      AppMemoryTrimLevel.pressure,
    ]);
  });
}
