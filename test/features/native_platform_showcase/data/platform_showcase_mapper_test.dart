import 'package:flutter_bloc_app/features/native_platform_showcase/data/platform_showcase_mapper.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_platform_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_capability_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapShowcase', () {
    test('uses android catalog details when platform is android', () {
      final data = mapShowcase(AppPlatformKind.android);

      expect(data.platform, AppPlatformKind.android);
      expect(data.capabilities, hasLength(5));
      expect(
        data.capabilities.map((final c) => c.kind).toList(),
        showcaseCapabilityOrder,
      );
      expect(
        data.capabilities.first.platformDetail,
        'Hybrid Composition / Texture Layer; HCPP-ready',
      );
      expect(data.interopResults, isEmpty);
    });

    test('returns five capabilities in stable order for iOS', () {
      final data = mapShowcase(AppPlatformKind.ios);

      expect(data.platform, AppPlatformKind.ios);
      expect(data.capabilities, hasLength(5));
      expect(
        data.capabilities.map((final c) => c.kind).toList(),
        showcaseCapabilityOrder,
      );
      expect(
        data.capabilities.first.platformDetail,
        'UiKitView / PlatformView',
      );
    });

    test('uses web catalog details when platform is web', () {
      final data = mapShowcase(AppPlatformKind.web);

      expect(data.platform, AppPlatformKind.web);
      final interop = data.capabilities.firstWhere(
        (final c) => c.kind == NativeCapabilityKind.nativeCodeInterop,
      );
      expect(interop.platformDetail, 'JS interop + Wasm');
    });
  });
}
