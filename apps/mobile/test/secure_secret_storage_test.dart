import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  group('InMemorySecretStorage', () {
    test('write/read/delete works as expected', () async {
      final storage = InMemorySecretStorage();

      expect(await storage.read('token'), isNull);

      await storage.write('token', 'secret');
      expect(await storage.read('token'), 'secret');

      await storage.delete('token');
      expect(await storage.read('token'), isNull);
    });

    test('withoutLogs toggles AppLogger silence flag', () async {
      final storage = InMemorySecretStorage();
      final int value = storage.withoutLogs(() {
        expect(AppLogger.isSilenced, isTrue);
        return 21;
      });
      expect(value, 21);

      final int asyncValue = await storage.withoutLogsAsync(() async {
        expect(AppLogger.isSilenced, isTrue);
        return 34;
      });
      expect(asyncValue, 34);
      expect(AppLogger.isSilenced, isFalse);
    });

    test('default storage uses memory on macOS debug', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      expect(createDefaultSecretStorage(), isA<InMemorySecretStorage>());
    });

    test('default storage uses memory on iOS debug', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      expect(createDefaultSecretStorage(), isA<InMemorySecretStorage>());
    });

    test('default storage uses memory on Android debug', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      expect(createDefaultSecretStorage(), isA<InMemorySecretStorage>());
    });
  });

  group('FlutterSecureSecretStorage', () {
    const MethodChannel channel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );

    final Map<String, String> fakeStore = <String, String>{};

    setUp(() {
      fakeStore.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
            switch (call.method) {
              case 'read':
                return fakeStore[call.arguments['key'] as String?] ??
                    call.arguments['defaultValue'];
              case 'write':
                fakeStore[call.arguments['key'] as String] =
                    call.arguments['value'] as String;
                return null;
              case 'delete':
                fakeStore.remove(call.arguments['key'] as String);
                return null;
              default:
                throw PlatformException(
                  code: 'unhandled',
                  message: call.method,
                );
            }
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('write/read/delete delegates to flutter_secure_storage', () async {
      final storage = FlutterSecureSecretStorage();

      await storage.write('token', 'secure');
      expect(fakeStore['token'], 'secure');
      expect(await storage.read('token'), 'secure');

      await storage.delete('token');
      expect(fakeStore.containsKey('token'), isFalse);
      expect(await storage.read('token'), isNull);
    });

    test('read gracefully handles platform errors', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
            throw PlatformException(code: 'error');
          });

      final storage = FlutterSecureSecretStorage();
      expect(await storage.read('token'), isNull);
    });

    test('readResult maps PlatformException to StorageFailure', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
            throw PlatformException(code: 'error');
          });

      final storage = FlutterSecureSecretStorage();
      final result = await storage.readResult('token');

      expect(result, isA<FailureResult<String?>>());
      expect(result.failureOrNull, isA<StorageFailure>());
    });

    test('readResult maps MissingPluginException to PlatformFailure', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
            throw MissingPluginException('unavailable');
          });

      final storage = FlutterSecureSecretStorage();
      final result = await storage.readResult('token');

      expect(result.failureOrNull, isA<PlatformFailure>());
    });

    test('readResult returns Success on happy path', () async {
      final storage = FlutterSecureSecretStorage();
      await storage.write('token', 'secure');

      final result = await storage.readResult('token');

      expect(result, isA<Success<String?>>());
      expect(result.getOrNull(), 'secure');
    });

    test('write and delete swallow platform errors', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
            throw MissingPluginException('unavailable');
          });

      final storage = FlutterSecureSecretStorage();
      await storage.write('token', 'value');
      await storage.delete('token');
    });

    test('withoutLogs proxies to AppLogger helpers', () async {
      final storage = FlutterSecureSecretStorage();
      final int value = storage.withoutLogs(() {
        expect(AppLogger.isSilenced, isTrue);
        return 7;
      });
      expect(value, 7);

      final int asyncValue = await storage.withoutLogsAsync(() async {
        expect(AppLogger.isSilenced, isTrue);
        return 11;
      });
      expect(asyncValue, 11);
      expect(AppLogger.isSilenced, isFalse);
    });
  });
}
