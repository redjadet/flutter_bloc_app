import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/core/platform_init.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_manager/window_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'PlatformInit initializes desktop window manager when on desktop',
    () async {
      final List<String> calls = <String>[];
      const MethodChannel channel = MethodChannel('window_manager');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
            calls.add(call.method);
            return null;
          });

      await PlatformInit.initialize(manager: windowManager);

      if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        expect(calls, contains('ensureInitialized'));
        expect(calls, contains('setMinimumSize'));
      }

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    },
  );
}
