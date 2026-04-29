import 'package:hive_flutter/hive_flutter.dart';

Future<void> initHive() async {
  // Default safe path: relies on platform plugin. Overridden on IO/web.
  await Hive.initFlutter();
}
