import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

RandomAccessFile? _hiveProcessLockFile;

Future<bool> initHive() async {
  // iOS debug uses a dedicated Hive directory so stale boxes from prior
  // Keychain/ephemeral encryption keys are not opened (avoids "Recovering
  // corrupted box." noise on simulator restarts).
  if (Platform.isIOS && !kReleaseMode) {
    await _initHiveInSupportSubdirectory('hive_ios_debug');
    return true;
  }

  if (!Platform.isMacOS && !Platform.isLinux && !Platform.isWindows) {
    await Hive.initFlutter();
    return true;
  }

  final String hiveDirName = !kReleaseMode && Platform.isMacOS
      ? 'hive_macos_debug'
      : 'hive';
  final Directory hiveDir = await _ensureHiveDirectory(hiveDirName);
  final bool hasStorageOwnership = await _acquireHiveProcessLock(hiveDir);
  if (!hasStorageOwnership) {
    return false;
  }
  Hive.init(hiveDir.path);
  return true;
}

Future<void> _initHiveInSupportSubdirectory(final String hiveDirName) async {
  final Directory hiveDir = await _ensureHiveDirectory(hiveDirName);
  Hive.init(hiveDir.path);
  AppLogger.debug('Hive initialized in $hiveDirName (${hiveDir.path})');
}

Future<Directory> _ensureHiveDirectory(final String hiveDirName) async {
  final Directory supportDir = await getApplicationSupportDirectory();
  final Directory hiveDir = Directory('${supportDir.path}/$hiveDirName');
  if (!hiveDir.existsSync()) {
    hiveDir.createSync(recursive: true);
  }
  return hiveDir;
}

Future<bool> _acquireHiveProcessLock(final Directory hiveDir) async {
  if (_hiveProcessLockFile != null) {
    return true;
  }

  final File lockFile = File('${hiveDir.path}/flutter_bloc_app.lock');
  RandomAccessFile? file;
  try {
    // Exclusive lock requires a writable fd (dart:io). Append creates if missing
    // and does not truncate an existing file (unlike FileMode.write).
    file = await lockFile.open(mode: FileMode.append);
    await file.lock();
    _hiveProcessLockFile = file;
    return true;
  } on FileSystemException catch (error, stackTrace) {
    await file?.close();
    AppLogger.warning(
      'Hive storage is already locked by another process. '
      'This process will skip Hive writes to avoid corrupting local data.',
    );
    AppLogger.debug('Hive process lock failure: $error\n$stackTrace');
    return false;
  }
}
