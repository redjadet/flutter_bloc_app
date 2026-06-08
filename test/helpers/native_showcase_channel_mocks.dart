import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const MethodChannel nativeShowcaseTestChannel = MethodChannel(
  'com.example.flutter_bloc_app/native_showcase',
);

/// Registers a fast MethodChannel stub so widget/web preflight tests do not
/// hang waiting for a native embedder that is not present in the test VM.
void registerNativeShowcaseChannelMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(nativeShowcaseTestChannel, (
        final MethodCall call,
      ) async {
        switch (call.method) {
          case 'invokeSwift':
            return 'Swift showcase bridge (test mock)';
          case 'invokeKotlin':
            return 'Kotlin showcase bridge (test mock)';
        }
        return null;
      });
}

void clearNativeShowcaseChannelMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(nativeShowcaseTestChannel, null);
}
