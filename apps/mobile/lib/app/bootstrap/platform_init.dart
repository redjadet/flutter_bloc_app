import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/app/bootstrap/platform_init_impl.dart';
import 'package:flutter_bloc_app/app/config/app_constants.dart';

/// Platform-specific initialization utilities
class PlatformInit {
  /// Initializes platform-specific features
  static Future<void> initialize({
    final Object? manager,
    final bool Function()? isDesktopPredicate,
  }) async {
    if (kIsWeb) return;
    await initializePlatformWindowing(
      minWindowSize: AppConstants.minWindowSize,
      manager: manager,
      isDesktopPredicate: isDesktopPredicate,
    );
  }
}
