import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/data/method_channel_native_showcase_host_language_service.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_bridge_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannelNativeShowcaseHostLanguageService', () {
    const MethodChannel channel = MethodChannel(
      'com.example.flutter_bloc_app/native_showcase',
    );

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('invokeSwift returns unavailable off Apple platforms', () async {
      const service = MethodChannelNativeShowcaseHostLanguageService();
      final result = await service.invokeSwift();

      expect(result.kind, NativeInteropBridgeKind.swift);
      expect(result.status, NativeInteropStatus.unavailable);
    });

    test('invokeKotlin returns unavailable off Android', () async {
      const service = MethodChannelNativeShowcaseHostLanguageService();
      final result = await service.invokeKotlin();

      expect(result.kind, NativeInteropBridgeKind.kotlin);
      expect(result.status, NativeInteropStatus.unavailable);
    });

    test(
      'invokeSwift maps missing handler to unavailable on Apple platforms',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);

        const service = MethodChannelNativeShowcaseHostLanguageService(
          channel: channel,
        );
        final result = await service.invokeSwift();

        expect(result.kind, NativeInteropBridgeKind.swift);
        expect(result.status, NativeInteropStatus.unavailable);
        expect(result.message, contains('not registered'));
      },
    );

    test('invokeSwift returns success when channel responds', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (final call) async {
            if (call.method == 'invokeSwift') {
              return 'Swift ok';
            }
            return null;
          });

      const service = MethodChannelNativeShowcaseHostLanguageService(
        channel: channel,
      );
      final result = await service.invokeSwift();

      expect(result.status, NativeInteropStatus.success);
      expect(result.message, 'Swift ok');
    });
  });
}
