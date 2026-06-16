import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_proof_file_store_web.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../integration_test/test_helpers_bridge.dart' as test_helpers;

Future<HiveService> _createHiveService() async {
  final hiveService = HiveService(
    keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
    initializeHiveStorage: () async => true,
  );
  await hiveService.initialize();
  return hiveService;
}

Future<void> _deleteBox(final String boxName) async {
  if (Hive.isBoxOpen(boxName)) {
    await Hive.box<dynamic>(boxName).close();
  }
  await Hive.deleteBoxFromDisk(boxName);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(test_helpers.setupHiveForTesting);

  setUp(() async {
    await _deleteBox(LocalStaffDemoProofFileStore.boxName);
  });

  tearDown(() async {
    await _deleteBox(LocalStaffDemoProofFileStore.boxName);
  });

  test('reads proof bytes from Hive after memory cache is lost', () async {
    final hiveService = await _createHiveService();
    final store = LocalStaffDemoProofFileStore(hiveService: hiveService);

    final path = await store.persistSignaturePngBytes(bytes: <int>[1, 2, 3]);
    await hiveService.closeBox(LocalStaffDemoProofFileStore.boxName);
    final freshStore = LocalStaffDemoProofFileStore(hiveService: hiveService);

    expect(await freshStore.fileExists(path), isTrue);
    expect(await freshStore.readFileBytes(path), <int>[1, 2, 3]);
  });
}
