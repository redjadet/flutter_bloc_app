import 'package:flutter_bloc_app/features/case_study_demo/data/case_study_hive_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storage/storage.dart';

import '../../../test_helpers.dart' as test_helpers;

void main() {
  late HiveService hiveService;
  late CaseStudyHiveLocalRepository repository;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await test_helpers.setupHiveForTesting();
  });

  setUp(() async {
    hiveService = await test_helpers.createHiveService();
    repository = CaseStudyHiveLocalRepository(hiveService: hiveService);
  });

  tearDown(() async {
    await test_helpers.cleanupHiveBoxes(<String>[
      CaseStudyHiveLocalRepository.boxName,
    ]);
  });

  test('rejects empty userId', () async {
    expect(() => repository.loadDraft(''), throwsA(isA<ArgumentError>()));
  });

  test('draft round-trip and clear', () async {
    final CaseStudyDraft draft = CaseStudyDraft.fresh(
      caseId: 'case-1',
    ).copyWith(doctorName: 'Dr X');

    expect(await repository.loadDraft('u1'), isNull);
    await repository.saveDraft('u1', draft);
    final CaseStudyDraft? loaded = await repository.loadDraft('u1');
    expect(loaded?.doctorName, 'Dr X');
    expect(loaded?.caseId, 'case-1');

    await repository.clearDraft('u1');
    expect(await repository.loadDraft('u1'), isNull);
  });

  test('records round-trip and getRecord', () async {
    final CaseStudyRecord record = CaseStudyRecord(
      id: 'r1',
      submittedAt: DateTime.utc(2026, 1, 2),
      doctorName: 'Dr Y',
      caseType: CaseStudyCaseType.ortho,
      notes: 'n',
      answers: const <String, String>{'q1': 'a1'},
    );

    expect(await repository.loadRecords('u1'), isEmpty);
    await repository.saveRecords('u1', <CaseStudyRecord>[record]);
    expect(await repository.loadRecords('u1'), hasLength(1));
    expect(await repository.getRecord('u1', 'r1'), isNotNull);
    expect(await repository.getRecord('u1', 'missing'), isNull);
  });

  test('ensureReady migrates schema by clearing stale box', () async {
    await repository.ensureReady();
    final box = await hiveService.openBox(CaseStudyHiveLocalRepository.boxName);
    await box.put(CaseStudyHiveLocalRepository.schemaKey, 0);
    await box.put('draft_v1_u1', 'stale');

    await repository.ensureReady();
    expect(box.get(CaseStudyHiveLocalRepository.schemaKey), 1);
    expect(await repository.loadDraft('u1'), isNull);
  });
}
