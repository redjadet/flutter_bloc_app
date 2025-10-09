import 'package:flutter_bloc_app/features/settings/domain/app_info.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PackageInfoAppInfoRepository implements AppInfoRepository {
  const PackageInfoAppInfoRepository();

  @override
  Future<AppInfo> load() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    final String resolvedVersion = info.version.trim().isNotEmpty
        ? info.version.trim()
        : 'unknown';
    final String resolvedBuild = info.buildNumber.trim().isNotEmpty
        ? info.buildNumber.trim()
        : 'unknown';
    return AppInfo(version: resolvedVersion, buildNumber: resolvedBuild);
  }
}
