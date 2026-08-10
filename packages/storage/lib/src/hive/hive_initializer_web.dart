import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<bool> initHive() async {
  WidgetsFlutterBinding.ensureInitialized();

  // hive_flutter's [Hive.initFlutter] is a no-op on web (`if (kIsWeb) return`)
  // and never calls [Hive.init]. Always pass an explicit IndexedDB namespace.
  //
  // Debug uses a dedicated namespace so stale payloads encrypted with prior
  // ephemeral keys are not opened after hot restart / key rotation.
  // Release uses a stable namespace so persisted counters survive deploys.
  final String hiveNamespace = kReleaseMode
      ? 'hive_web_v1'
      : 'hive_web_debug_v4';
  Hive.init(hiveNamespace);
  AppLogger.debug('Hive initialized in $hiveNamespace');
  return true;
}
