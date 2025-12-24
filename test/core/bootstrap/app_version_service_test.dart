import 'package:flutter_bloc_app/core/bootstrap/app_version_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppVersionService', () {
    test('getAppVersion returns default before loading', () {
      // Initially returns default version
      expect(AppVersionService.getAppVersion(), '1.0.0');
    });

    test('loadAppVersion completes without throwing', () async {
      // This test verifies the service can be called without throwing
      // In a test environment, PackageInfo.fromPlatform may not work,
      // but the method should handle it gracefully
      await expectLater(AppVersionService.loadAppVersion(), completes);
    });

    test(
      'getAppVersion provides synchronous access after attempted load',
      () async {
        // Load version (may fail in test environment)
        await AppVersionService.loadAppVersion();

        // Should still return a string (either loaded or default)
        final version = AppVersionService.getAppVersion();
        expect(version, isA<String>());
        expect(version.isNotEmpty, isTrue);
      },
    );

    test('getAppVersion always returns a valid version string', () {
      // Multiple calls should be consistent
      final version1 = AppVersionService.getAppVersion();
      final version2 = AppVersionService.getAppVersion();

      expect(version1, equals(version2));
      expect(version1, isA<String>());
      expect(version1.isNotEmpty, isTrue);
    });
  });
}
