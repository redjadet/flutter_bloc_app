import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/shared/platform/native_platform_service.dart';

typedef MethodCallHandler = Future<dynamic> Function(MethodCall call);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel(
    'com.example.flutter_bloc_app/native',
  );

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('NativePlatformService', () {
    test('returns NativePlatformInfo from platform channel', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
            if (call.method == 'getPlatformInfo') {
              return <String, dynamic>{
                'platform': 'android',
                'version': '13',
                'manufacturer': 'TestCo',
                'model': 'Pixel Test',
              };
            }
            throw PlatformException(code: 'unhandled');
          });

      final service = NativePlatformService();
      final info = await service.getPlatformInfo();

      expect(info.platform, 'android');
      expect(info.version, '13');
      expect(info.manufacturer, 'TestCo');
      expect(info.model, 'Pixel Test');
      expect(info.toString(), contains('android 13'));
    });

    test('handles null response gracefully', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async => null);

      final service = NativePlatformService();
      final info = await service.getPlatformInfo();

      expect(info.platform, 'unknown');
      expect(info.version, 'unknown');
      expect(info.manufacturer, isNull);
      expect(info.model, isNull);
    });
  });
}
