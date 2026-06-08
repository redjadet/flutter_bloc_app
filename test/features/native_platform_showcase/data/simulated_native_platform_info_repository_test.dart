import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/data/runtime_platform_probe.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/data/simulated_native_platform_info_repository.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_platform_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SimulatedNativePlatformInfoRepository', () {
    test('loadShowcase resolves probe platform into mapped data', () async {
      final repository = SimulatedNativePlatformInfoRepository(
        probe: const RuntimePlatformProbe(
          isWeb: false,
          platform: TargetPlatform.android,
        ),
      );

      final data = await repository.loadShowcase();

      expect(data.platform, AppPlatformKind.android);
      expect(data.capabilities, hasLength(5));
    });

    test('loadShowcase maps web when probe reports web', () async {
      final repository = SimulatedNativePlatformInfoRepository(
        probe: const RuntimePlatformProbe(isWeb: true),
      );

      final data = await repository.loadShowcase();

      expect(data.platform, AppPlatformKind.web);
    });
  });
}
