import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

String? _iosAccessibilityFromCall(MethodCall call) {
  final Object? options = call.arguments['options'];
  if (options is! Map) {
    return null;
  }
  final Object? ios = options['iOptions'];
  if (ios is! Map) {
    return null;
  }
  return ios['accessibility'] as String?;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  group('Apple Keychain accessibility defaults', () {
    test('iOS options are ThisDeviceOnly and not synchronizable', () {
      const options = FlutterSecureSecretStorage.defaultIosOptions;

      expect(
        options.accessibility,
        KeychainAccessibility.first_unlock_this_device,
      );
      expect(options.synchronizable, isFalse);
      expect(options.toMap()['accessibility'], 'first_unlock_this_device');
      expect(options.toMap()['synchronizable'], 'false');
    });

    test('macOS options match iOS device-bound policy', () {
      const options = FlutterSecureSecretStorage.defaultMacOsOptions;

      expect(
        options.accessibility,
        KeychainAccessibility.first_unlock_this_device,
      );
      expect(options.synchronizable, isFalse);
    });

    test('default FlutterSecureStorage uses hardened Apple options', () {
      final storage =
          FlutterSecureSecretStorage.createDefaultFlutterSecureStorage();

      expect(
        storage.iOptions.accessibility,
        KeychainAccessibility.first_unlock_this_device,
      );
      expect(storage.iOptions.synchronizable, isFalse);
      expect(
        storage.mOptions.accessibility,
        KeychainAccessibility.first_unlock_this_device,
      );
      expect(storage.mOptions.synchronizable, isFalse);
    });

    test('plugin default remains migrate-capable (regression guard)', () {
      // Document why we override: library default is NOT ThisDeviceOnly.
      expect(
        IOSOptions.defaultOptions.accessibility,
        KeychainAccessibility.unlocked,
      );
    });
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

    test(
      'read migrates legacy unlocked Keychain values on Apple platforms',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        final Map<String, String> hardenedStore = <String, String>{};
        final Map<String, String> legacyStore = <String, String>{
          'hive_encryption_key': 'legacy-secret',
        };

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall call) async {
              final String? accessibility = _iosAccessibilityFromCall(call);
              final Map<String, String> store = accessibility == 'unlocked'
                  ? legacyStore
                  : hardenedStore;
              switch (call.method) {
                case 'read':
                  return store[call.arguments['key'] as String?] ??
                      call.arguments['defaultValue'];
                case 'write':
                  store[call.arguments['key'] as String] =
                      call.arguments['value'] as String;
                  return null;
                case 'delete':
                  store.remove(call.arguments['key'] as String);
                  return null;
                default:
                  throw PlatformException(
                    code: 'unhandled',
                    message: call.method,
                  );
              }
            });

        final storage = FlutterSecureSecretStorage(
          storage: FlutterSecureSecretStorage.createDefaultFlutterSecureStorage(),
          legacyMigrationStorage:
              FlutterSecureSecretStorage.createLegacyMigrationFlutterSecureStorage(),
        );

        expect(await storage.read('hive_encryption_key'), 'legacy-secret');
        expect(legacyStore.containsKey('hive_encryption_key'), isFalse);
        expect(hardenedStore['hive_encryption_key'], 'legacy-secret');
        expect(await storage.read('hive_encryption_key'), 'legacy-secret');
      },
    );

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
