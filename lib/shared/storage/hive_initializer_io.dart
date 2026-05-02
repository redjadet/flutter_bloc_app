import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

RandomAccessFile? _hiveProcessLockFile;

Future<bool> initHive() async {
  if (!Platform.isMacOS && !Platform.isLinux && !Platform.isWindows) {
    await Hive.initFlutter();
    return true;
  }

  final Directory supportDir = await getApplicationSupportDirectory();
  final String hiveDirName = !kReleaseMode && Platform.isMacOS
      ? 'hive_macos_debug'
      : 'hive';
  final Directory hiveDir = Directory('${supportDir.path}/$hiveDirName');
  if (!hiveDir.existsSync()) {
    hiveDir.createSync(recursive: true);
  }
  final bool hasStorageOwnership = await _acquireHiveProcessLock(hiveDir);
  if (!hasStorageOwnership) {
    return false;
  }
  Hive.init(hiveDir.path);
  return true;
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
