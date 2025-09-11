import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/core/constants.dart';
import 'package:window_manager/window_manager.dart';

/// Platform-specific initialization utilities
class PlatformInit {
  /// Initializes platform-specific features
  static Future<void> initialize() async {
    if (!kIsWeb && _isDesktopPlatform()) {
      await _initializeDesktop();
    }
  }

  /// Checks if the current platform is desktop
  static bool _isDesktopPlatform() {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  /// Initializes desktop-specific features
  static Future<void> _initializeDesktop() async {
    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(AppConstants.minWindowSize);
  }
}
