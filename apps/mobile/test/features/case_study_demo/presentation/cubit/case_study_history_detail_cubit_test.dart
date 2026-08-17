import 'package:auth/auth.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_clip_file_store.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_delete_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_history_detail_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = AuthUser(id: 'user-1', isAnonymous: false);

CaseStudyRecord _record({String id = 'r1', String notes = 'notes'}) =>
    CaseStudyRecord(
      id: id,
      submittedAt: DateTime.utc(2026, 4, 1, 12),
      doctorName: 'Dr. Test',
      caseType: CaseStudyCaseType.implant,
      notes: notes,
      answers: const <String, String>{},
    );

class _StubAuthRepository implements AuthRepository {
  const _StubAuthRepository(this._currentUser);

  final AuthUser? _currentUser;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> get authStateChanges => const Stream<AuthUser?>.empty();
}

class _StubRemoteBackendAuth implements RemoteBackendAuthPort {
  @override
  bool get isConfigured => false;

  @override
  AuthUser? get currentUser => null;

  @override
  Stream<AuthUser?> get authStateChanges => const Stream<AuthUser?>.empty();

  @override
  Future<void> signOut() async {}
}

class _MutableLocalRepository implements CaseStudyLocalRepository {
  _MutableLocalRepository({
    required List<CaseStudyRecord> initialRecords,
    this.onGetRecord,
    this.onSaveRecords,
  }) : _records = List<CaseStudyRecord>.from(initialRecords);

  List<CaseStudyRecord> _records;
  final Future<CaseStudyRecord?> Function(String userId, String recordId)?
  onGetRecord;
  final Future<void> Function(String userId, List<CaseStudyRecord> records)?
  onSaveRecords;

  @override
  Future<void> ensureReady() async {}

  @override
  Future<CaseStudyDraft?> loadDraft(String userId) async => null;

  @override
  Future<void> saveDraft(String userId, CaseStudyDraft draft) async {}

  @override
  Future<void> clearDraft(String userId) async {}

  @override
  Future<List<CaseStudyRecord>> loadRecords(String userId) async =>
      List<CaseStudyRecord>.from(_records);

  @override
  Future<void> saveRecords(String userId, List<CaseStudyRecord> records) async {
    if (onSaveRecords != null) {
      await onSaveRecords!(userId, records);
    }
    _records = List<CaseStudyRecord>.from(records);
  }

  @override
  Future<CaseStudyRecord?> getRecord(String userId, String recordId) async {
    if (onGetRecord != null) {
      return onGetRecord!(userId, recordId);
    }
    for (final CaseStudyRecord r in _records) {
      if (r.id == recordId) return r;
    }
    return null;
  }
}

class _ThrowingLocalRepository extends _MutableLocalRepository {
  _ThrowingLocalRepository({required super.initialRecords})
    : super(
        onGetRecord: (userId, recordId) async {
          throw Exception('load failed for $recordId ($userId)');
        },
      );
}

class _SlowDeleteRepository implements CaseStudyRemoteDeleteRepository {
  _SlowDeleteRepository(this.onDeleteStarted);

  final void Function() onDeleteStarted;

  @override
  Future<void> deleteCaseStudyRemote({required String caseId}) async {
    onDeleteStarted();
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

class _NoopClipStore implements CaseStudyClipFileStore {
  @override
  Future<void> deleteCaseFolder(String caseId) async {}

  @override
  Future<void> deleteFileIfExists(String? path) async {}

  @override
  String finalClipFilePathFromStaging(String stagingPath) => stagingPath;

  @override
  Future<String> persistClip({
    required String sourcePath,
    required String caseId,
    required String questionId,
  }) async => sourcePath;

  @override
  Future<String> persistClipToStaging({
    required String sourcePath,
    required String caseId,
    required String questionId,
    required int commitToken,
  }) async => sourcePath;

  @override
  String promoteStagingToFinalSync({
    required String stagingPath,
    required String finalPath,
  }) => finalPath;

  @override
  Future<List<int>> readClipBytes(String path) async => const <int>[];
}

class _NoopRemoteRepository implements CaseStudyRemoteRepository {
  @override
  Future<String> createSignedPlaybackUrl({
    required String objectKey,
    required Duration ttl,
  }) async => '';

  @override
  Future<void> finalizeRemoteSubmission({
    required String caseId,
    required String doctorName,
    required CaseStudyCaseType caseType,
    required String notes,
    required Map<String, String> remoteObjectKeysByQuestion,
    required DateTime submittedAtUtc,
  }) async {}

  @override
  Future<RemoteCaseStudyDetail?> getSubmittedCase({
    required String caseId,
  }) async => null;

  @override
  Future<List<RemoteCaseStudySummary>> listSubmittedCases() async =>
      const <RemoteCaseStudySummary>[];

  @override
  Future<String> uploadClip({
    required String caseId,
    required String questionId,
    required String localPath,
  }) async => '';

  @override
  Future<void> upsertRemoteDraft({
    required String caseId,
    required String doctorName,
    required CaseStudyCaseType caseType,
    required String notes,
    required Map<String, String> remoteObjectKeysByQuestion,
  }) async {}
}

void main() {
  group('CaseStudyHistoryDetailCubit', () {
    CaseStudyHistoryDetailCubit buildCubit({
      required String recordId,
      CaseStudyLocalRepository? localRepository,
      CaseStudyRemoteDeleteRepository? remoteDelete,
    }) => CaseStudyHistoryDetailCubit(
      recordId: recordId,
      authRepository: const _StubAuthRepository(_user),
      localRepository:
          localRepository ??
          _MutableLocalRepository(initialRecords: <CaseStudyRecord>[_record()]),
      remoteRepository: _NoopRemoteRepository(),
      remoteDeleteRepository: remoteDelete ?? _SlowDeleteRepository(() {}),
      clipStore: _NoopClipStore(),
      remoteBackendAuth: _StubRemoteBackendAuth(),
    );

    blocTest<CaseStudyHistoryDetailCubit, CaseStudyHistoryDetailState>(
      'load with empty recordId emits notFound',
      build: () => buildCubit(recordId: ''),
      act: (cubit) => cubit.load(),
      expect: () => <dynamic>[
        isA<CaseStudyHistoryDetailState>()
            .having(
              (s) => s.status,
              'status',
              CaseStudyHistoryDetailStatus.notFound,
            )
            .having((s) => s.record, 'record', isNull),
      ],
    );

    blocTest<CaseStudyHistoryDetailCubit, CaseStudyHistoryDetailState>(
      'load loads local record',
      build: () => buildCubit(recordId: 'r1'),
      act: (cubit) => cubit.load(),
      expect: () => <dynamic>[
        isA<CaseStudyHistoryDetailState>().having(
          (s) => s.status,
          'loading',
          CaseStudyHistoryDetailStatus.loading,
        ),
        isA<CaseStudyHistoryDetailState>()
            .having(
              (s) => s.status,
              'loaded',
              CaseStudyHistoryDetailStatus.loaded,
            )
            .having((s) => s.record?.id, 'record id', 'r1'),
      ],
    );

    blocTest<CaseStudyHistoryDetailCubit, CaseStudyHistoryDetailState>(
      'load surfaces repository errors',
      build: () => buildCubit(
        recordId: 'r1',
        localRepository: _ThrowingLocalRepository(
          initialRecords: <CaseStudyRecord>[_record()],
        ),
      ),
      act: (cubit) => cubit.load(),
      expect: () => <dynamic>[
        isA<CaseStudyHistoryDetailState>().having(
          (s) => s.status,
          'loading',
          CaseStudyHistoryDetailStatus.loading,
        ),
        isA<CaseStudyHistoryDetailState>()
            .having(
              (s) => s.status,
              'error',
              CaseStudyHistoryDetailStatus.error,
            )
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    test(
      'later load wins when overlapping loads complete out of order',
      () async {
        var loadCount = 0;
        final cubit = CaseStudyHistoryDetailCubit(
          recordId: 'r1',
          authRepository: const _StubAuthRepository(_user),
          localRepository: _MutableLocalRepository(
            initialRecords: <CaseStudyRecord>[_record()],
            onGetRecord: (_, recordId) async {
              loadCount += 1;
              if (loadCount == 1) {
                await Future<void>.delayed(const Duration(milliseconds: 50));
                return _record(id: recordId, notes: 'stale');
              }
              return _record(id: recordId, notes: 'fresh');
            },
          ),
          remoteRepository: _NoopRemoteRepository(),
          remoteDeleteRepository: _SlowDeleteRepository(() {}),
          clipStore: _NoopClipStore(),
          remoteBackendAuth: _StubRemoteBackendAuth(),
        );
        addTearDown(cubit.close);

        final Future<void> slowLoad = cubit.load();
        await cubit.load(refresh: true);
        await slowLoad;

        expect(cubit.state.record?.notes, 'fresh');
        expect(cubit.state.status, CaseStudyHistoryDetailStatus.loaded);
      },
    );

    test('stale in-flight refresh does not resurrect deleted record', () async {
      var fetchCount = 0;
      final cubit = CaseStudyHistoryDetailCubit(
        recordId: 'r1',
        authRepository: const _StubAuthRepository(_user),
        localRepository: _MutableLocalRepository(
          initialRecords: <CaseStudyRecord>[_record()],
          onSaveRecords: (_, records) async {
            await Future<void>.delayed(const Duration(milliseconds: 30));
          },
          onGetRecord: (_, recordId) async {
            fetchCount += 1;
            if (fetchCount == 2) {
              final CaseStudyRecord stale = _record(id: recordId);
              await Future<void>.delayed(const Duration(milliseconds: 60));
              return stale;
            }
            return null;
          },
        ),
        remoteRepository: _NoopRemoteRepository(),
        remoteDeleteRepository: _SlowDeleteRepository(() {}),
        clipStore: _NoopClipStore(),
        remoteBackendAuth: _StubRemoteBackendAuth(),
      );
      addTearDown(cubit.close);
      await cubit.load();

      final Future<void> staleRefresh = cubit.load(refresh: true);
      await Future<void>.delayed(const Duration(milliseconds: 35));
      await cubit.load(refresh: true);
      await staleRefresh;

      expect(cubit.state.record, isNull);
      expect(cubit.state.status, CaseStudyHistoryDetailStatus.notFound);
    });

    test('delete sets isDeleting and blocks concurrent delete', () async {
      var deleteStarted = false;
      final cubit = CaseStudyHistoryDetailCubit(
        recordId: 'r1',
        authRepository: const _StubAuthRepository(_user),
        localRepository: _MutableLocalRepository(
          initialRecords: <CaseStudyRecord>[_record()],
          onSaveRecords: (_, records) async {
            deleteStarted = true;
            await Future<void>.delayed(const Duration(milliseconds: 50));
          },
        ),
        remoteRepository: _NoopRemoteRepository(),
        remoteDeleteRepository: _SlowDeleteRepository(() {}),
        clipStore: _NoopClipStore(),
        remoteBackendAuth: _StubRemoteBackendAuth(),
      );
      addTearDown(cubit.close);
      await cubit.load();

      final Future<bool> first = cubit.delete();
      await Future<void>.delayed(Duration.zero);
      expect(deleteStarted, isTrue);
      expect(cubit.state.isDeleting, isTrue);

      final bool second = await cubit.delete();
      expect(second, isFalse);
      expect(cubit.state.isDeleting, isTrue);

      await first;
      expect(cubit.state.isDeleting, isFalse);
    });

    test('delete returns false for empty recordId', () async {
      final cubit = buildCubit(recordId: '');
      addTearDown(cubit.close);

      final bool deleted = await cubit.delete();

      expect(deleted, isFalse);
      expect(cubit.state.isDeleting, isFalse);
    });
  });
}
