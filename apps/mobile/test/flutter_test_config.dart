import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

import 'helpers/native_showcase_channel_mocks.dart';
import 'helpers/test_temp_root_stub.dart'
    if (dart.library.io) 'helpers/test_temp_root_io.dart';

const MethodChannel _pathProviderChannel = MethodChannel(
  'plugins.flutter.io/path_provider',
);

Future<void> testExecutable(final FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final originalOnError = FlutterError.onError;
  FlutterError.onError = (final FlutterErrorDetails details) {
    final Object exception = details.exception;
    final String message = details.exceptionAsString();
    final bool isRenderFlexOverflow = message.contains(
      'A RenderFlex overflowed',
    );
    final bool isTextOverflow =
        message.contains('A RenderParagraph overflowed') ||
        message.contains('overflowed by') &&
            message.contains('RenderParagraph');

    // Allow local debugging escape hatch.
    const bool allow = bool.fromEnvironment('ALLOW_FLUTTER_LAYOUT_OVERFLOWS');
    if (!allow && (isRenderFlexOverflow || isTextOverflow)) {
      // Fail fast: layout overflow should never ship.
      // Use a TestFailure so output is clean.
      throw TestFailure('Layout overflow detected during test run:\n$message');
    }

    // Preserve original behavior and still surface errors.
    if (originalOnError != null) {
      originalOnError(details);
    } else {
      FlutterError.presentError(details);
    }

    // Keep stack trace in logs for post-mortem even if presentError is filtered.
    if (details.stack != null) {
      log('FlutterError', error: exception, stackTrace: details.stack);
    }
  };

  final String tempRoot = await createTestTempRoot();
  registerNativeShowcaseChannelMock();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_pathProviderChannel, (final call) async {
        switch (call.method) {
          case 'getTemporaryDirectory':
          case 'getApplicationSupportDirectory':
          case 'getApplicationDocumentsDirectory':
          case 'getApplicationCacheDirectory':
          case 'getExternalStorageDirectory':
            return tempRoot;
          case 'getExternalCacheDirectories':
          case 'getExternalStorageDirectories':
            return <String>[tempRoot];
        }
        return null;
      });
  LeakTesting.enable();
  // Untagged tests stay ignored; leakSafeTestWidgets opts tagged tests back in.
  LeakTesting.settings = LeakTesting.settings.withIgnoredAll();
  LeakTracking.warnForUnsupportedPlatforms = false;
  try {
    await testMain();
  } finally {
    FlutterError.onError = originalOnError;
  }
}
