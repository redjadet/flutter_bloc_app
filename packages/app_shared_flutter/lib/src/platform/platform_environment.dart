import 'package:app_shared_flutter/src/platform/platform_environment_stub.dart'
    if (dart.library.io) 'package:app_shared_flutter/src/platform/platform_environment_io.dart'
    if (dart.library.html) 'package:app_shared_flutter/src/platform/platform_environment_web.dart';

/// Returns the best-effort process environment map.
///
/// - On IO platforms, this returns `Platform.environment`.
/// - On web, this returns an empty map.
Map<String, String> platformEnvironment() => readPlatformEnvironment();
