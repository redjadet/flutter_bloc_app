import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<bool> initHive() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Web debug uses a dedicated Hive namespace so stale IndexedDB payloads
  // encrypted with prior ephemeral keys are not opened (avoids pad-block
  // errors after hot restart / encryption-key rotation).
  if (!kReleaseMode) {
    Hive.init('hive_web_debug_v4');
    AppLogger.debug('Hive initialized in hive_web_debug_v4');
    return true;
  }

  await Hive.initFlutter();
  return true;
}
