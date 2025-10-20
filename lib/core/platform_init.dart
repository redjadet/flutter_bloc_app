import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/core/constants.dart';
import 'package:window_manager/window_manager.dart';

/// Platform-specific initialization utilities
class PlatformInit {
  /// Initializes platform-specific features
  static Future<void> initialize({
    WindowManager? manager,
    bool Function()? isDesktopPredicate,
  }) async {
    final bool Function() predicate = isDesktopPredicate ?? _isDesktopPlatform;
    if (!kIsWeb && predicate()) {
      await _initializeDesktop(manager ?? windowManager);
    }
  }

  /// Checks if the current platform is desktop
  static bool _isDesktopPlatform() {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  /// Initializes desktop-specific features
  static Future<void> _initializeDesktop(WindowManager manager) async {
    await manager.ensureInitialized();
    await manager.setMinimumSize(AppConstants.minWindowSize);
  }
}
