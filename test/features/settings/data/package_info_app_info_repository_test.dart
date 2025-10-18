import 'package:flutter_bloc_app/features/settings/data/package_info_app_info_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PackageInfoAppInfoRepository', () {
    const repository = PackageInfoAppInfoRepository();

    test('returns trimmed version and build number', () async {
      PackageInfo.setMockInitialValues(
        appName: 'Test App',
        packageName: 'app.test',
        version: ' 1.2.3 ',
        buildNumber: ' 42 ',
        buildSignature: 'signature',
      );

      final AppInfo info = await repository.load();

      expect(info.version, '1.2.3');
      expect(info.buildNumber, '42');
    });

    test('falls back to unknown when version info is blank', () async {
      PackageInfo.setMockInitialValues(
        appName: 'Test App',
        packageName: 'app.test',
        version: '   ',
        buildNumber: '',
        buildSignature: 'signature',
      );

      final AppInfo info = await repository.load();

      expect(info.version, 'unknown');
      expect(info.buildNumber, 'unknown');
    });
  });
}
