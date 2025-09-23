import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InMemorySecretStorage', () {
    test('write/read/delete works as expected', () async {
      final storage = InMemorySecretStorage();

      expect(await storage.read('token'), isNull);

      await storage.write('token', 'secret');
      expect(await storage.read('token'), 'secret');

      await storage.delete('token');
      expect(await storage.read('token'), isNull);
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
  });
}
