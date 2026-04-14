import 'dart:io' show Platform;

import 'package:flutter/material.dart' show Size;
import 'package:window_manager/window_manager.dart';

Future<void> initializePlatformWindowingImpl({
  required Object minWindowSize,
  required Object? manager,
  required bool Function()? isDesktopPredicate,
}) async {
  final Size size = minWindowSize is Size
      ? minWindowSize
      : const Size(390, 390);
  final bool Function() predicate = isDesktopPredicate ?? _isDesktopPlatform;
  if (!predicate()) return;

  final WindowManager wm = manager is WindowManager ? manager : windowManager;
  await wm.ensureInitialized();
  await wm.setMinimumSize(size);
}

bool _isDesktopPlatform() {
  // window_manager is only meaningful on desktop platforms; on other platforms
  // this path should be a no-op.
  return Platform.isMacOS || Platform.isLinux || Platform.isWindows;
}
