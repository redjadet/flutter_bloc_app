import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

const MethodChannel _pathProviderChannel = MethodChannel(
  'plugins.flutter.io/path_provider',
);

Future<void> testExecutable(final FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final Directory tempRoot = await Directory.systemTemp.createTemp(
    'flutter_bloc_app_test_',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_pathProviderChannel, (final call) async {
        switch (call.method) {
          case 'getTemporaryDirectory':
          case 'getApplicationSupportDirectory':
          case 'getApplicationDocumentsDirectory':
          case 'getApplicationCacheDirectory':
          case 'getExternalStorageDirectory':
            return tempRoot.path;
          case 'getExternalCacheDirectories':
          case 'getExternalStorageDirectories':
            return <String>[tempRoot.path];
        }
        return null;
      });
  LeakTesting.enable();
  LeakTesting.settings = LeakTesting.settings.withIgnoredAll();
  LeakTracking.warnForUnsupportedPlatforms = false;
  await testMain();
}
