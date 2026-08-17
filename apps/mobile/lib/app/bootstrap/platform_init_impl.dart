import 'package:flutter_bloc_app/app/bootstrap/platform_init_impl_stub.dart'
    if (dart.library.io) 'package:flutter_bloc_app/app/bootstrap/platform_init_impl_io.dart'
    if (dart.library.html) 'package:flutter_bloc_app/app/bootstrap/platform_init_impl_web.dart';
import 'package:material_ui/material_ui.dart' show Size;

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
