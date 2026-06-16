import 'package:flutter_bloc_app/features/case_study_demo/data/case_study_clip_file_store_web.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_clip_bytes_memory.dart';
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
    await _deleteBox(CaseStudyClipFileStoreImpl.boxName);
  });

  tearDown(() async {
    await _deleteBox(CaseStudyClipFileStoreImpl.boxName);
  });

  test('hydrates clip bytes from Hive after memory cache is lost', () async {
    final hiveService = await _createHiveService();
    const path = 'case-study://case-1/question-1.final.7.mp4';
    final box = await hiveService.openBox(CaseStudyClipFileStoreImpl.boxName);
    await box.put(path, <int>[4, 5, 6]);
    await hiveService.closeBox(CaseStudyClipFileStoreImpl.boxName);
    CaseStudyClipBytesMemory.instance.deleteIfExists(path);

    final store = CaseStudyClipFileStoreImpl(hiveService: hiveService);

    expect(await store.readClipBytes(path), <int>[4, 5, 6]);
    expect(CaseStudyClipBytesMemory.instance.exists(path), isTrue);
  });

  test(
    'reads final path from staging bytes when promotion is interrupted',
    () async {
      final hiveService = await _createHiveService();
      const stagingPath = 'case-study://case-1/question-1.staging.7.mp4';
      const finalPath = 'case-study://case-1/question-1.final.7.mp4';
      final box = await hiveService.openBox(CaseStudyClipFileStoreImpl.boxName);
      await box.put(stagingPath, <int>[7, 8, 9]);
      await hiveService.closeBox(CaseStudyClipFileStoreImpl.boxName);
      CaseStudyClipBytesMemory.instance.deleteIfExists(stagingPath);
      CaseStudyClipBytesMemory.instance.deleteIfExists(finalPath);

      final store = CaseStudyClipFileStoreImpl(hiveService: hiveService);

      expect(await store.readClipBytes(finalPath), <int>[7, 8, 9]);
      expect(CaseStudyClipBytesMemory.instance.exists(finalPath), isTrue);
    },
  );
}
