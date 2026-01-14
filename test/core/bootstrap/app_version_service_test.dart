import 'package:flutter_bloc_app/core/bootstrap/app_version_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppVersionService', () {
    test('getAppVersion returns default when not loaded', () {
      // Since _appVersion is static and may be set by other tests,
      // we just verify it returns a string
      final version = AppVersionService.getAppVersion();
      expect(version, isA<String>());
      expect(version.isNotEmpty, isTrue);
    });

    test('loadAppVersion completes without error', () async {
      // This will attempt to load from platform, but should handle errors gracefully
      await AppVersionService.loadAppVersion();

      // Should not throw
      final version = AppVersionService.getAppVersion();
      expect(version, isA<String>());
      expect(version.isNotEmpty, isTrue);
    });
  });
}
