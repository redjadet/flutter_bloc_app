import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_question.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_delete_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_upload_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/use_cases/persist_case_study_submission_use_case.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/use_cases/submit_case_study_outcome.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/use_cases/submit_case_study_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit proof for the multi-port submit workflow (upload → remote clips →
/// finalize → local persist) with in-memory fakes for every domain port.
void main() {
  final DateTime fixedNow = DateTime.utc(2026, 10, 22, 12);

  late _FakeUploadRepository upload;
  late _FakeRemoteRepository remote;
  late _FakeRemoteDeleteRepository remoteDelete;
  late _FakeLocalRepository local;
  late SubmitCaseStudyUseCase useCase;

  CaseStudyDraft completeDraft({
    Map<String, String> remoteKeys = const <String, String>{},
  }) => CaseStudyDraft(
    caseId: 'case-1',
    doctorName: 'Dr. Ada',
    caseType: CaseStudyCaseType.implant,
    notes: 'notes',
    answers: <String, String>{
      for (final String id in CaseStudyQuestions.orderedIds) id: '/tmp/$id.mp4',
    },
    remoteObjectKeysByQuestion: remoteKeys,
    currentQuestionIndex: CaseStudyQuestions.orderedIds.length - 1,
    phase: CaseStudyDraftPhase.reviewing,
  );

  Future<SubmitCaseStudyOutcome> submit(
    CaseStudyDraft draft, {
    required bool remoteSubmit,
    List<double>? progress,
  }) => useCase(
    userId: 'user-1',
    draft: draft,
    remoteSubmit: remoteSubmit,
    retryDelay: (_) async {},
    onProgress: progress?.add,
    now: () => fixedNow,
  );

  setUp(() {
    upload = _FakeUploadRepository();
    remote = _FakeRemoteRepository();
    remoteDelete = _FakeRemoteDeleteRepository();
    local = _FakeLocalRepository();
    useCase = SubmitCaseStudyUseCase(
      uploadRepository: upload,
      remoteRepository: remote,
      remoteDeleteRepository: remoteDelete,
      persistSubmission: PersistCaseStudySubmissionUseCase(
        localRepository: local,
        newCaseId: () => 'fresh-case',
      ),
    );
  });

  test('incomplete draft fails without touching any port', () async {
    final SubmitCaseStudyOutcome outcome = await submit(
      CaseStudyDraft.fresh(caseId: 'case-1'),
      remoteSubmit: true,
    );

    expect(outcome, isA<SubmitCaseStudyFailure>());
    final SubmitCaseStudyFailure failure = outcome as SubmitCaseStudyFailure;
    expect(failure.error, isA<StateError>());
    expect(failure.remoteSubmitFinished, isFalse);
    expect(upload.calls, 0);
    expect(remote.uploadedQuestions, isEmpty);
    expect(local.records, isEmpty);
  });

  test('local-only submit persists history and skips remote ports', () async {
    final SubmitCaseStudyOutcome outcome = await submit(
      completeDraft(),
      remoteSubmit: false,
    );

    expect(outcome, isA<SubmitCaseStudySuccess>());
    final SubmitCaseStudySuccess success = outcome as SubmitCaseStudySuccess;
    expect(success.freshDraft.caseId, 'fresh-case');
    expect(success.submittedAtUtc, fixedNow);
    expect(upload.calls, 1);
    expect(remote.uploadedQuestions, isEmpty);
    expect(remote.finalized, isFalse);
    expect(local.records.single.id, 'case-1');
  });

  test(
    'remote submit uploads only missing clips, finalizes, reports progress',
    () async {
      final String alreadyUploaded = CaseStudyQuestions.orderedIds.first;
      final List<double> progress = <double>[];

      final SubmitCaseStudyOutcome outcome = await submit(
        completeDraft(
          remoteKeys: <String, String>{alreadyUploaded: 'existing-key'},
        ),
        remoteSubmit: true,
        progress: progress,
      );

      expect(outcome, isA<SubmitCaseStudySuccess>());
      expect(
        remote.uploadedQuestions,
        CaseStudyQuestions.orderedIds.skip(1).toList(),
      );
      expect(remote.lastRemoteKeys[alreadyUploaded], 'existing-key');
      expect(
        remote.lastRemoteKeys.length,
        CaseStudyQuestions.orderedIds.length,
      );
      expect(remote.finalized, isTrue);
      expect(remote.finalizedAtUtc, fixedNow);
      expect(progress.last, 1);
      expect(remoteDelete.deletedCaseIds, isEmpty);
      expect(local.records.single.id, 'case-1');
    },
  );

  test(
    'remote failure before finalize cleans up remote data and reports failure',
    () async {
      remote.failUploadAfter = 1;

      final SubmitCaseStudyOutcome outcome = await submit(
        completeDraft(),
        remoteSubmit: true,
      );

      expect(outcome, isA<SubmitCaseStudyFailure>());
      final SubmitCaseStudyFailure failure = outcome as SubmitCaseStudyFailure;
      expect(failure.remoteSubmitFinished, isFalse);
      expect(failure.submittedAtUtc, fixedNow);
      expect(remoteDelete.deletedCaseIds, <String>['case-1']);
      expect(remote.finalized, isFalse);
      expect(local.records, isEmpty);
    },
  );

  test('cleanup failure does not mask the original submit error', () async {
    remote.failUploadAfter = 0;
    remoteDelete.throwOnDelete = true;

    final SubmitCaseStudyOutcome outcome = await submit(
      completeDraft(),
      remoteSubmit: true,
    );

    final SubmitCaseStudyFailure failure = outcome as SubmitCaseStudyFailure;
    expect(failure.error, isA<_RemoteUploadFailure>());
    expect(remoteDelete.deletedCaseIds, <String>['case-1']);
  });

  test(
    'local persist failure after remote finalize keeps remote data',
    () async {
      local.failSaveRecords = true;

      final SubmitCaseStudyOutcome outcome = await submit(
        completeDraft(),
        remoteSubmit: true,
      );

      expect(outcome, isA<SubmitCaseStudyFailure>());
      final SubmitCaseStudyFailure failure = outcome as SubmitCaseStudyFailure;
      expect(failure.remoteSubmitFinished, isTrue);
      expect(failure.submittedAtUtc, fixedNow);
      expect(remote.finalized, isTrue);
      expect(remoteDelete.deletedCaseIds, isEmpty);
    },
  );
}

final class _RemoteUploadFailure implements Exception {
  const _RemoteUploadFailure();
}

final class _FakeUploadRepository implements CaseStudyUploadRepository {
  int calls = 0;

  @override
  Future<void> submitCase() async {
    calls += 1;
  }
}

final class _FakeRemoteRepository implements CaseStudyRemoteRepository {
  final List<String> uploadedQuestions = <String>[];
  Map<String, String> lastRemoteKeys = const <String, String>{};
  bool finalized = false;
  DateTime? finalizedAtUtc;

  /// Throw on the upload after this many successful uploads (null = never).
  int? failUploadAfter;

  @override
  Future<String> uploadClip({
    required String caseId,
    required String questionId,
    required String localPath,
  }) async {
    final int? limit = failUploadAfter;
    if (limit != null && uploadedQuestions.length >= limit) {
      throw const _RemoteUploadFailure();
    }
    uploadedQuestions.add(questionId);
    return 'remote/$caseId/$questionId';
  }

  @override
  Future<void> upsertRemoteDraft({
    required String caseId,
    required String doctorName,
    required CaseStudyCaseType caseType,
    required String notes,
    required Map<String, String> remoteObjectKeysByQuestion,
  }) async {
    lastRemoteKeys = Map<String, String>.from(remoteObjectKeysByQuestion);
  }

  @override
  Future<void> finalizeRemoteSubmission({
    required String caseId,
    required String doctorName,
    required CaseStudyCaseType caseType,
    required String notes,
    required Map<String, String> remoteObjectKeysByQuestion,
    required DateTime submittedAtUtc,
  }) async {
    finalized = true;
    finalizedAtUtc = submittedAtUtc;
  }

  @override
  Future<List<RemoteCaseStudySummary>> listSubmittedCases() async =>
      const <RemoteCaseStudySummary>[];

  @override
  Future<RemoteCaseStudyDetail?> getSubmittedCase({
    required String caseId,
  }) async => null;

  @override
  Future<String> createSignedPlaybackUrl({
    required String objectKey,
    required Duration ttl,
  }) async => 'https://example.invalid/$objectKey';
}

final class _FakeRemoteDeleteRepository
    implements CaseStudyRemoteDeleteRepository {
  final List<String> deletedCaseIds = <String>[];
  bool throwOnDelete = false;

  @override
  Future<void> deleteCaseStudyRemote({required String caseId}) async {
    deletedCaseIds.add(caseId);
    if (throwOnDelete) {
      throw StateError('cleanup failed');
    }
  }
}

final class _FakeLocalRepository implements CaseStudyLocalRepository {
  final List<CaseStudyRecord> records = <CaseStudyRecord>[];
  bool failSaveRecords = false;

  @override
  Future<void> clearDraft(String userId) async {}

  @override
  Future<void> ensureReady() async {}

  @override
  Future<CaseStudyRecord?> getRecord(String userId, String recordId) async =>
      null;

  @override
  Future<CaseStudyDraft?> loadDraft(String userId) async => null;

  @override
  Future<List<CaseStudyRecord>> loadRecords(String userId) async =>
      List<CaseStudyRecord>.from(records);

  @override
  Future<void> saveDraft(String userId, CaseStudyDraft draft) async {}

  @override
  Future<void> saveRecords(
    String userId,
    List<CaseStudyRecord> nextRecords,
  ) async {
    if (failSaveRecords) {
      throw StateError('local history write failed');
    }
    records
      ..clear()
      ..addAll(nextRecords);
  }
}
