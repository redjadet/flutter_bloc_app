import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initHive() async {
  if (!Platform.isMacOS && !Platform.isLinux && !Platform.isWindows) {
    await Hive.initFlutter();
    return;
  }

  final Directory supportDir = await getApplicationSupportDirectory();
  final String hiveDirName = !kReleaseMode && Platform.isMacOS
      ? 'hive_macos_debug'
      : 'hive';
  final Directory hiveDir = Directory('${supportDir.path}/$hiveDirName');
  if (!hiveDir.existsSync()) {
    hiveDir.createSync(recursive: true);
  }
  Hive.init(hiveDir.path);
}
