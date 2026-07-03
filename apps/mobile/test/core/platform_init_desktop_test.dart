import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/core/constants/constants.dart';
import 'package:flutter_bloc_app/core/platform_init.dart';
import 'package:mocktail/mocktail.dart';
import 'package:window_manager/window_manager.dart';

class _MockWindowManager extends Mock implements WindowManager {}

void main() {
  setUpAll(() {
    registerFallbackValue(const Size(0, 0));
  });

  group('PlatformInit.initialize (desktop)', () {
    test('configures window when predicate reports desktop', () async {
      final manager = _MockWindowManager();
      when(() => manager.ensureInitialized()).thenAnswer((_) async {});
      when(() => manager.setMinimumSize(any())).thenAnswer((_) async {});

      await PlatformInit.initialize(
        manager: manager,
        isDesktopPredicate: () => true,
      );

      verify(() => manager.ensureInitialized()).called(1);
      verify(
        () => manager.setMinimumSize(AppConstants.minWindowSize),
      ).called(1);
    });
  });
}
