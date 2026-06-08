import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_platform_kind.dart';

class RuntimePlatformProbe {
  const RuntimePlatformProbe({
    this.isWeb,
    this.platform,
  });

  final bool? isWeb;
  final TargetPlatform? platform;

  bool get _resolvedIsWeb => isWeb ?? kIsWeb;

  TargetPlatform get _resolvedPlatform => platform ?? defaultTargetPlatform;

  AppPlatformKind resolve() {
    if (_resolvedIsWeb) {
      return AppPlatformKind.web;
    }
    return switch (_resolvedPlatform) {
      TargetPlatform.android => AppPlatformKind.android,
      TargetPlatform.iOS => AppPlatformKind.ios,
      TargetPlatform.macOS => AppPlatformKind.macos,
      TargetPlatform.windows => AppPlatformKind.windows,
      TargetPlatform.linux => AppPlatformKind.linux,
      TargetPlatform.fuchsia => AppPlatformKind.android,
    };
  }
}
