import 'dart:io';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:storage/storage.dart';

Future<void> setupHiveForTesting() async {
  final Directory testDir = Directory.systemTemp.createTempSync('hive_test_');
  Hive.init(testDir.path);
}

Future<HiveService> createHiveService() async {
  final InMemorySecretStorage storage = InMemorySecretStorage();
  final HiveKeyManager keyManager = HiveKeyManager(storage: storage);
  final HiveService hiveService = HiveService(
    keyManager: keyManager,
    initializeHiveStorage: () async => true,
  );
  await hiveService.initialize();
  return hiveService;
}

Future<void> cleanupHiveBoxes(final List<String> boxNames) async {
  for (final String boxName in boxNames) {
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box<dynamic>(boxName).deleteFromDisk();
      } else {
        await Hive.deleteBoxFromDisk(boxName);
      }
    } on Object {
      // Box may not exist; ignore.
    }
  }
}
