import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/core/constants/constants.dart';
import 'package:window_manager/window_manager.dart';

/// Platform-specific initialization utilities
class PlatformInit {
  /// Initializes platform-specific features
  static Future<void> initialize({
    final WindowManager? manager,
    final bool Function()? isDesktopPredicate,
  }) async {
    final bool Function() predicate = isDesktopPredicate ?? _isDesktopPlatform;
    if (!kIsWeb && predicate()) {
      await _initializeDesktop(manager ?? windowManager);
    }
  }

  /// Checks if the current platform is desktop
  static bool _isDesktopPlatform() =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  /// Initializes desktop-specific features
  static Future<void> _initializeDesktop(final WindowManager manager) async {
    await manager.ensureInitialized();
    await manager.setMinimumSize(AppConstants.minWindowSize);
  }
}
