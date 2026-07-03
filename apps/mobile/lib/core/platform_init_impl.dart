import 'package:flutter/material.dart' show Size;
import 'package:flutter_bloc_app/core/platform_init_impl_stub.dart'
    if (dart.library.io) 'package:flutter_bloc_app/core/platform_init_impl_io.dart'
    if (dart.library.html) 'package:flutter_bloc_app/core/platform_init_impl_web.dart';

Future<void> initializePlatformWindowing({
  required Size minWindowSize,
  required Object? manager,
  required bool Function()? isDesktopPredicate,
}) async {
  await initializePlatformWindowingImpl(
    minWindowSize: minWindowSize,
    manager: manager,
    isDesktopPredicate: isDesktopPredicate,
  );
}
