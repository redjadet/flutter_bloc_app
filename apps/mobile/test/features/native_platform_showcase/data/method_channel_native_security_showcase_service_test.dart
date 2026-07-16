import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/data/method_channel_native_security_showcase_service.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannelNativeSecurityShowcaseService', () {
    const MethodChannel channel = MethodChannel(
      'com.example.flutter_bloc_app/native_security_showcase',
    );

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      debugDefaultTargetPlatformOverride = null;
    });

    test('returns unavailable/mobile_only off Android and iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      const service = MethodChannelNativeSecurityShowcaseService(
        channel: channel,
      );

      final result = await service.run(NativeSecurityOperation.p256SignVerify);

      expect(result.status, NativeSecurityStatus.unavailable);
      expect(result.reasonCode, 'mobile_only');
    });

    test('invokes the correct method name per operation', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final invokedMethods = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (final call) async {
            invokedMethods.add(call.method);
            return <String, Object?>{
              'schemaVersion': 1,
              'status': 'success',
              'reasonCode': 'ok',
              'platform': 'android',
            };
          });

      const service = MethodChannelNativeSecurityShowcaseService(
        channel: channel,
      );

      await service.run(NativeSecurityOperation.p256SignVerify);
      await service.run(NativeSecurityOperation.aesGcmRoundTrip);
      await service.run(NativeSecurityOperation.secureStorageLifecycle);
      await service.run(NativeSecurityOperation.biometricProtectedOperation);

      expect(invokedMethods, <String>[
        'p256SignVerify',
        'aesGcmRoundTrip',
        'secureStorageLifecycle',
        'biometricProtectedOperation',
      ]);
    });

    test('maps a successful reply to a success result', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (final call) async {
            return <String, Object?>{
              'schemaVersion': 1,
              'status': 'success',
              'reasonCode': 'ok',
              'platform': 'android',
              'hardwareBacked': true,
              'verified': true,
            };
          });

      const service = MethodChannelNativeSecurityShowcaseService(
        channel: channel,
      );
      final result = await service.run(NativeSecurityOperation.p256SignVerify);

      expect(result.status, NativeSecurityStatus.success);
      expect(result.reasonCode, 'ok');
      expect(result.hardwareBacked, isTrue);
    });

    test('rejects a native success reply without required evidence', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (final call) async {
            return <String, Object?>{
              'schemaVersion': 1,
              'status': 'success',
              'reasonCode': 'ok',
              'platform': 'android',
            };
          });

      const service = MethodChannelNativeSecurityShowcaseService(
        channel: channel,
      );
      final result = await service.run(NativeSecurityOperation.p256SignVerify);

      expect(result.status, NativeSecurityStatus.failed);
      expect(result.reasonCode, 'platform_error');
    });

    test('maps MissingPluginException to unavailable/missing_plugin', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      const service = MethodChannelNativeSecurityShowcaseService(
        channel: channel,
      );

      final result = await service.run(NativeSecurityOperation.aesGcmRoundTrip);

      expect(result.status, NativeSecurityStatus.unavailable);
      expect(result.reasonCode, 'missing_plugin');
    });

    test('maps a slow reply to unavailable/timeout', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (final call) async {
            await Future<void>.delayed(const Duration(seconds: 3));
            return <String, Object?>{
              'schemaVersion': 1,
              'status': 'success',
              'reasonCode': 'ok',
              'platform': 'android',
            };
          });

      const service = MethodChannelNativeSecurityShowcaseService(
        channel: channel,
      );
      final result = await service.run(
        NativeSecurityOperation.secureStorageLifecycle,
      );

      expect(result.status, NativeSecurityStatus.unavailable);
      expect(result.reasonCode, 'timeout');
    });

    test(
      'allows biometric replies slower than the non-interactive timeout',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (final call) async {
              await Future<void>.delayed(const Duration(seconds: 3));
              return <String, Object?>{
                'schemaVersion': 1,
                'status': 'success',
                'reasonCode': 'ok',
                'platform': 'android',
                'verified': true,
              };
            });

        const service = MethodChannelNativeSecurityShowcaseService(
          channel: channel,
        );
        final result = await service.run(
          NativeSecurityOperation.biometricProtectedOperation,
        );

        expect(result.status, NativeSecurityStatus.success);
        expect(result.reasonCode, 'ok');
        expect(result.verified, isTrue);
      },
    );

    test(
      'maps a biometric reply past the biometric timeout to unavailable/timeout',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (final call) async {
              await Future<void>.delayed(const Duration(milliseconds: 80));
              return <String, Object?>{
                'schemaVersion': 1,
                'status': 'success',
                'reasonCode': 'ok',
                'platform': 'android',
              };
            });

        const service = MethodChannelNativeSecurityShowcaseService(
          channel: channel,
          biometricInvokeTimeout: Duration(milliseconds: 20),
        );
        final result = await service.run(
          NativeSecurityOperation.biometricProtectedOperation,
        );

        expect(result.status, NativeSecurityStatus.unavailable);
        expect(result.reasonCode, 'timeout');
      },
    );

    test('maps PlatformException(biometric_canceled) to denied', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (final call) async {
            throw PlatformException(code: 'biometric_canceled');
          });

      const service = MethodChannelNativeSecurityShowcaseService(
        channel: channel,
      );
      final result = await service.run(
        NativeSecurityOperation.biometricProtectedOperation,
      );

      expect(result.status, NativeSecurityStatus.denied);
      expect(result.reasonCode, 'biometric_canceled');
    });

    test(
      'maps PlatformException(biometric_not_enrolled) to unavailable',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (final call) async {
              throw PlatformException(code: 'biometric_not_enrolled');
            });

        const service = MethodChannelNativeSecurityShowcaseService(
          channel: channel,
        );
        final result = await service.run(
          NativeSecurityOperation.biometricProtectedOperation,
        );

        expect(result.status, NativeSecurityStatus.unavailable);
        expect(result.reasonCode, 'biometric_not_enrolled');
      },
    );

    test(
      'maps an unrecognized PlatformException code to failed/platform_error',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (final call) async {
              throw PlatformException(code: 'unexpected_native_error');
            });

        const service = MethodChannelNativeSecurityShowcaseService(
          channel: channel,
        );
        final result = await service.run(
          NativeSecurityOperation.p256SignVerify,
        );

        expect(result.status, NativeSecurityStatus.failed);
        expect(result.reasonCode, 'platform_error');
      },
    );

    test(
      'maps success-looking PlatformException codes to failed/platform_error',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (final call) async {
              throw PlatformException(code: 'ok');
            });

        const service = MethodChannelNativeSecurityShowcaseService(
          channel: channel,
        );
        final result = await service.run(
          NativeSecurityOperation.p256SignVerify,
        );

        expect(result.status, NativeSecurityStatus.failed);
        expect(result.reasonCode, 'platform_error');
      },
    );

    test('maps a malformed reply to failed/malformed_reply', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (final call) async => 'oops');

      const service = MethodChannelNativeSecurityShowcaseService(
        channel: channel,
      );
      final result = await service.run(NativeSecurityOperation.aesGcmRoundTrip);

      expect(result.status, NativeSecurityStatus.failed);
      expect(result.reasonCode, 'malformed_reply');
    });
  });
}
