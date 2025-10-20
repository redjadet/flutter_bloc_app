import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/core/platform_init.dart';
import 'package:mocktail/mocktail.dart';
import 'package:window_manager/window_manager.dart';

class _MockWindowManager extends Mock implements WindowManager {}

void main() {
  setUpAll(() {
    registerFallbackValue(const Size(0, 0));
  });

  group('PlatformInit.initialize (non-desktop)', () {
    test('skips window manager configuration', () async {
      final manager = _MockWindowManager();

      await PlatformInit.initialize(
        manager: manager,
        isDesktopPredicate: () => false,
      );

      verifyNever(() => manager.ensureInitialized());
      verifyNever(() => manager.setMinimumSize(any()));
    });
  });
}
