import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Default version string when package info is unavailable.
const String kDefaultAppVersion = '1.0.0';

/// Service for loading and caching app version information.
class AppVersionService {
  AppVersionService._();

  static String? _appVersion;

  /// Get the app version synchronously, with fallback to default.
  static String getAppVersion() => _appVersion ?? kDefaultAppVersion;

  /// Load app version from platform package info.
  static Future<void> loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = info.version.trim().isNotEmpty
          ? info.version.trim()
          : kDefaultAppVersion;
      AppLogger.debug('App version loaded: $_appVersion');
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'Failed to load app version, using default',
        error,
        stackTrace,
      );
      _appVersion = kDefaultAppVersion;
    }
  }
}
