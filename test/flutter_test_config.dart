import 'dart:async';

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
  LeakTesting.settings = LeakTesting.settings.withIgnoredAll();
  LeakTracking.warnForUnsupportedPlatforms = false;
  await testMain();
}
