import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/use_cases/persist_case_study_submission_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'retries a partial write without duplicating the submitted record',
    () async {
      final _FailFirstFreshDraftSaveRepository local =
          _FailFirstFreshDraftSaveRepository();
      final PersistCaseStudySubmissionUseCase useCase =
          PersistCaseStudySubmissionUseCase(
            localRepository: local,
            newCaseId: () => 'fresh-case',
          );
      final CaseStudyDraft draft = CaseStudyDraft(
        caseId: 'submitted-case',
        doctorName: 'Dr. Ada',
        caseType: CaseStudyCaseType.implant,
        notes: 'notes',
        answers: const <String, String>{'question-1': '/tmp/clip.mp4'},
        remoteObjectKeysByQuestion: const <String, String>{},
        currentQuestionIndex: 0,
        phase: CaseStudyDraftPhase.reviewing,
      );

      final CaseStudyDraft fresh = await useCase(
        userId: 'user-1',
        draft: draft,
        submittedAtUtc: DateTime.utc(2026, 8, 1),
        caseType: CaseStudyCaseType.implant,
        retryDelay: (_) async {},
      );

      expect(fresh.caseId, 'fresh-case');
      expect(local.records, hasLength(1));
      expect(local.records.single.id, 'submitted-case');
    },
  );
}

final class _FailFirstFreshDraftSaveRepository
    implements CaseStudyLocalRepository {
  final List<CaseStudyRecord> records = <CaseStudyRecord>[];
  bool _failFreshDraftSave = true;

  @override
  Future<void> clearDraft(final String userId) async {}

  @override
  Future<void> ensureReady() async {}

  @override
  Future<CaseStudyRecord?> getRecord(
    final String userId,
    final String recordId,
  ) async {
    for (final CaseStudyRecord record in records) {
      if (record.id == recordId) {
        return record;
      }
    }
    return null;
  }

  @override
  Future<CaseStudyDraft?> loadDraft(final String userId) async => null;

  @override
  Future<List<CaseStudyRecord>> loadRecords(final String userId) async =>
      List<CaseStudyRecord>.from(records);

  @override
  Future<void> saveDraft(
    final String userId,
    final CaseStudyDraft draft,
  ) async {
    if (draft.caseId == 'fresh-case' && _failFreshDraftSave) {
      _failFreshDraftSave = false;
      throw StateError('fresh draft write failed');
    }
  }

  @override
  Future<void> saveRecords(
    final String userId,
    final List<CaseStudyRecord> nextRecords,
  ) async {
    records
      ..clear()
      ..addAll(nextRecords);
  }
}
