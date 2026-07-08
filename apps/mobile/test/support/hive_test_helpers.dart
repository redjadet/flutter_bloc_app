import 'package:hive_flutter/hive_flutter.dart';

Future<void> setupHiveForTesting() async {
  try {
    await Hive.initFlutter();
  } on Object {
    // Web init may run multiple times across test suites; ignore.
  }
}
