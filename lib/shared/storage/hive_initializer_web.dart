import 'package:hive_flutter/hive_flutter.dart';

Future<bool> initHive() async {
  await Hive.initFlutter();
  return true;
}
