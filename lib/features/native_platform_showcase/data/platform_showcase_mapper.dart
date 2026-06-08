import 'package:flutter_bloc_app/features/native_platform_showcase/data/platform_capability_catalog.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_platform_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_capability.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_capability_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_call_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/platform_showcase_data.dart';

/// Stable UI order for capability tiles (not tied to enum declaration order).
const List<NativeCapabilityKind> showcaseCapabilityOrder =
    <NativeCapabilityKind>[
      NativeCapabilityKind.nativeViewEmbedding,
      NativeCapabilityKind.platformPackageManager,
      NativeCapabilityKind.nativeCodeInterop,
      NativeCapabilityKind.lowLevelGraphics,
      NativeCapabilityKind.adaptiveGestures,
    ];

PlatformShowcaseData mapShowcase(final AppPlatformKind platform) {
  final Map<NativeCapabilityKind, String>? details =
      platformCapabilityCatalog[platform];
  if (details == null) {
    throw StateError('Missing capability catalog for $platform');
  }
  final List<NativeCapability> capabilities = showcaseCapabilityOrder
      .map((final kind) {
        final String? platformDetail = details[kind];
        if (platformDetail == null) {
          throw StateError('Missing platform detail for $kind on $platform');
        }
        return NativeCapability(
          kind: kind,
          platformDetail: platformDetail,
        );
      })
      .toList(growable: false);
  return PlatformShowcaseData(
    platform: platform,
    capabilities: capabilities,
    interopResults: const <NativeInteropCallResult>[],
  );
}
