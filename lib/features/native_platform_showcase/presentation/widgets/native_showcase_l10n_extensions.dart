import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_platform_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_capability_kind.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

extension AppPlatformKindL10n on AppPlatformKind {
  String label(final AppLocalizations l10n) => switch (this) {
    AppPlatformKind.android => l10n.nativePlatformShowcasePlatformAndroid,
    AppPlatformKind.ios => l10n.nativePlatformShowcasePlatformIos,
    AppPlatformKind.macos => l10n.nativePlatformShowcasePlatformMacos,
    AppPlatformKind.windows => l10n.nativePlatformShowcasePlatformWindows,
    AppPlatformKind.linux => l10n.nativePlatformShowcasePlatformLinux,
    AppPlatformKind.web => l10n.nativePlatformShowcasePlatformWeb,
  };
}

extension NativeCapabilityKindL10n on NativeCapabilityKind {
  String title(final AppLocalizations l10n) => switch (this) {
    NativeCapabilityKind.nativeViewEmbedding =>
      l10n.nativePlatformShowcaseCapabilityNativeViewEmbeddingTitle,
    NativeCapabilityKind.platformPackageManager =>
      l10n.nativePlatformShowcaseCapabilityPlatformPackageManagerTitle,
    NativeCapabilityKind.nativeCodeInterop =>
      l10n.nativePlatformShowcaseCapabilityNativeCodeInteropTitle,
    NativeCapabilityKind.lowLevelGraphics =>
      l10n.nativePlatformShowcaseCapabilityLowLevelGraphicsTitle,
    NativeCapabilityKind.adaptiveGestures =>
      l10n.nativePlatformShowcaseCapabilityAdaptiveGesturesTitle,
  };

  String summary(final AppLocalizations l10n) => switch (this) {
    NativeCapabilityKind.nativeViewEmbedding =>
      l10n.nativePlatformShowcaseCapabilityNativeViewEmbeddingSummary,
    NativeCapabilityKind.platformPackageManager =>
      l10n.nativePlatformShowcaseCapabilityPlatformPackageManagerSummary,
    NativeCapabilityKind.nativeCodeInterop =>
      l10n.nativePlatformShowcaseCapabilityNativeCodeInteropSummary,
    NativeCapabilityKind.lowLevelGraphics =>
      l10n.nativePlatformShowcaseCapabilityLowLevelGraphicsSummary,
    NativeCapabilityKind.adaptiveGestures =>
      l10n.nativePlatformShowcaseCapabilityAdaptiveGesturesSummary,
  };
}
