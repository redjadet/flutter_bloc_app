import 'package:flutter_bloc_app/shared/utils/platform_environment_stub.dart'
    if (dart.library.io) 'package:flutter_bloc_app/shared/utils/platform_environment_io.dart'
    if (dart.library.html) 'package:flutter_bloc_app/shared/utils/platform_environment_web.dart';

/// Returns the best-effort process environment map.
///
/// - On IO platforms, this returns `Platform.environment`.
/// - On web, this returns an empty map.
Map<String, String> platformEnvironment() => readPlatformEnvironment();
