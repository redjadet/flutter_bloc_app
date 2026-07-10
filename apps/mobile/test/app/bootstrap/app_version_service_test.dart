import 'package:flutter_bloc_app/app/bootstrap/app_version_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  group('AppVersionService', () {
    test('getAppVersion returns default before load', () {
      expect(AppVersionService.getAppVersion(), kDefaultAppVersion);
    });

    test('loadAppVersion caches non-empty version', () async {
      PackageInfo.setMockInitialValues(
        appName: 'test',
        packageName: 'test',
        version: '2.3.4',
        buildNumber: '1',
        buildSignature: 'sig',
        installerStore: null,
      );

      await AppVersionService.loadAppVersion();

      expect(AppVersionService.getAppVersion(), '2.3.4');
    });

    test('loadAppVersion falls back when version is blank', () async {
      PackageInfo.setMockInitialValues(
        appName: 'test',
        packageName: 'test',
        version: '   ',
        buildNumber: '1',
        buildSignature: 'sig',
        installerStore: null,
      );

      await AppVersionService.loadAppVersion();

      expect(AppVersionService.getAppVersion(), kDefaultAppVersion);
    });
  });
}
