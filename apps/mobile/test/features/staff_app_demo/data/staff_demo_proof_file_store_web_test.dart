import 'dart:convert';

import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_proof_file_store_web.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_pick_memory.dart';
import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:storage/storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../support/hive_test_helpers.dart' as test_helpers;

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

  test('persistPhotoFile reads staged web pick path bytes', () async {
    final hiveService = await _createHiveService();
    final store = LocalStaffDemoProofFileStore(hiveService: hiveService);
    const bytes = <int>[0x89, 0x50, 0x4E, 0x47];
    final stagedPath = StaffDemoProofPickMemory.instance.stage(bytes);

    final path = await store.persistPhotoFile(sourcePath: stagedPath);

    expect(await store.fileExists(path), isTrue);
    expect(await store.readFileBytes(path), bytes);
  });

  test('persistPhotoFile decodes legacy web data URL bytes', () async {
    final hiveService = await _createHiveService();
    final store = LocalStaffDemoProofFileStore(hiveService: hiveService);
    const bytes = <int>[0xFF, 0xD8, 0xFF, 0x00];
    final dataUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';

    final path = await store.persistPhotoFile(sourcePath: dataUrl);

    expect(await store.fileExists(path), isTrue);
    expect(await store.readFileBytes(path), bytes);
  });

  test('persistPhotoFile retries staged pick after put failure', () async {
    final hiveService = await _createHiveService();
    final store = LocalStaffDemoProofFileStore(
      hiveService: hiveService,
      debugPutFailuresRemaining: 1,
    );
    const bytes = <int>[0x01, 0x02, 0x03];
    final stagedPath = StaffDemoProofPickMemory.instance.stage(bytes);

    await expectLater(
      store.persistPhotoFile(sourcePath: stagedPath),
      throwsA(isA<StateError>()),
    );
    expect(StaffDemoProofPickMemory.instance.peek(stagedPath), bytes);

    final path = await store.persistPhotoFile(sourcePath: stagedPath);
    expect(await store.readFileBytes(path), bytes);
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
