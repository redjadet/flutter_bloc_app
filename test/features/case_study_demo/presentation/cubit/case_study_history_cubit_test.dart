import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/auth/auth_user.dart';
import 'package:flutter_bloc_app/core/auth/remote_backend_auth_port.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_clip_file_store.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_delete_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_history_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = AuthUser(id: 'user-1', isAnonymous: false);

CaseStudyRecord _record({final String id = 'r1'}) => CaseStudyRecord(
  id: id,
  submittedAt: DateTime.utc(2026, 4, 1, 12),
  doctorName: 'Dr. Test',
  caseType: CaseStudyCaseType.implant,
  notes: 'notes',
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
    required final List<CaseStudyRecord> initialRecords,
    this.onSaveRecords,
    this.onLoadRecords,
  }) : _records = List<CaseStudyRecord>.from(initialRecords);

  List<CaseStudyRecord> _records;
  int loadRecordsCallCount = 0;
  final Future<void> Function(String userId, List<CaseStudyRecord> records)?
  onSaveRecords;
  final Future<List<CaseStudyRecord>> Function(String userId)? onLoadRecords;

  @override
  Future<void> ensureReady() async {}

  @override
  Future<CaseStudyDraft?> loadDraft(final String userId) async => null;

  @override
  Future<void> saveDraft(
    final String userId,
    final CaseStudyDraft draft,
  ) async {}

  @override
  Future<void> clearDraft(final String userId) async {}

  @override
  Future<List<CaseStudyRecord>> loadRecords(final String userId) async {
    loadRecordsCallCount += 1;
    if (onLoadRecords != null) {
      return onLoadRecords!(userId);
    }
    return List<CaseStudyRecord>.from(_records);
  }

  @override
  Future<void> saveRecords(
    final String userId,
    final List<CaseStudyRecord> records,
  ) async {
    if (onSaveRecords != null) {
      await onSaveRecords!(userId, records);
    }
    _records = List<CaseStudyRecord>.from(records);
  }

  @override
  Future<CaseStudyRecord?> getRecord(
    final String userId,
    final String recordId,
  ) async => null;
}

class _SlowDeleteRepository implements CaseStudyRemoteDeleteRepository {
  _SlowDeleteRepository(this.onDeleteStarted);

  final void Function() onDeleteStarted;

  @override
  Future<void> deleteCaseStudyRemote({required final String caseId}) async {
    onDeleteStarted();
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

class _NoopClipStore implements CaseStudyClipFileStore {
  @override
  Future<void> deleteCaseFolder(final String caseId) async {}

  @override
  Future<void> deleteFileIfExists(final String? path) async {}

  @override
  String finalClipFilePathFromStaging(final String stagingPath) => stagingPath;

  @override
  Future<String> persistClip({
    required final String sourcePath,
    required final String caseId,
    required final String questionId,
  }) async => sourcePath;

  @override
  Future<String> persistClipToStaging({
    required final String sourcePath,
    required final String caseId,
    required final String questionId,
    required final int commitToken,
  }) async => sourcePath;

  @override
  String promoteStagingToFinalSync({
    required final String stagingPath,
    required final String finalPath,
  }) => finalPath;

  @override
  Future<List<int>> readClipBytes(final String path) async => const <int>[];
}

class _NoopRemoteRepository implements CaseStudyRemoteRepository {
  @override
  Future<String> createSignedPlaybackUrl({
    required final String objectKey,
    required final Duration ttl,
  }) async => '';

  @override
  Future<void> finalizeRemoteSubmission({
    required final String caseId,
    required final String doctorName,
    required final CaseStudyCaseType caseType,
    required final String notes,
    required final Map<String, String> remoteObjectKeysByQuestion,
    required final DateTime submittedAtUtc,
  }) async {}

  @override
  Future<RemoteCaseStudyDetail?> getSubmittedCase({
    required final String caseId,
  }) async => null;

  @override
  Future<List<RemoteCaseStudySummary>> listSubmittedCases() async =>
      const <RemoteCaseStudySummary>[];

  @override
  Future<String> uploadClip({
    required final String caseId,
    required final String questionId,
    required final String localPath,
  }) async => '';

  @override
  Future<void> upsertRemoteDraft({
    required final String caseId,
    required final String doctorName,
    required final CaseStudyCaseType caseType,
    required final String notes,
    required final Map<String, String> remoteObjectKeysByQuestion,
  }) async {}
}

void main() {
  group('CaseStudyHistoryCubit', () {
    late _MutableLocalRepository localRepository;

    CaseStudyHistoryCubit buildCubit({
      final CaseStudyRemoteDeleteRepository? remoteDelete,
    }) {
      localRepository = _MutableLocalRepository(
        initialRecords: <CaseStudyRecord>[_record()],
      );
      return CaseStudyHistoryCubit(
        authRepository: const _StubAuthRepository(_user),
        localRepository: localRepository,
        remoteRepository: _NoopRemoteRepository(),
        remoteDeleteRepository: remoteDelete ?? _SlowDeleteRepository(() {}),
        clipStore: _NoopClipStore(),
        remoteBackendAuth: _StubRemoteBackendAuth(),
      );
    }

    blocTest<CaseStudyHistoryCubit, CaseStudyHistoryState>(
      'deleteRecord sets deletingRecordId while delete is in flight',
      build: buildCubit,
      seed: () => CaseStudyHistoryState(
        status: CaseStudyHistoryStatus.loaded,
        records: <CaseStudyRecord>[_record()],
      ),
      act: (final cubit) async {
        final Future<void> deleteFuture = cubit.deleteRecord(recordId: 'r1');
        await Future<void>.delayed(Duration.zero);
        await deleteFuture;
      },
      expect: () => <dynamic>[
        isA<CaseStudyHistoryState>().having(
          (final s) => s.deletingRecordId,
          'deletingRecordId',
          'r1',
        ),
        isA<CaseStudyHistoryState>().having(
          (final s) => s.deletingRecordId,
          'deletingRecordId cleared',
          isNull,
        ),
        isA<CaseStudyHistoryState>().having(
          (final s) => s.status,
          'reload status',
          CaseStudyHistoryStatus.loading,
        ),
        isA<CaseStudyHistoryState>().having(
          (final s) => s.status,
          'reload complete',
          CaseStudyHistoryStatus.loaded,
        ),
      ],
    );

    test('deleteRecord ignores empty recordId', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.deleteRecord(recordId: '');

      expect(cubit.state.deletingRecordId, isNull);
    });

    test(
      'later load wins when overlapping loads complete out of order',
      () async {
        var loadCount = 0;
        final cubit = CaseStudyHistoryCubit(
          authRepository: const _StubAuthRepository(_user),
          localRepository: _MutableLocalRepository(
            initialRecords: <CaseStudyRecord>[_record()],
            onLoadRecords: (final _) async {
              loadCount += 1;
              if (loadCount == 1) {
                await Future<void>.delayed(const Duration(milliseconds: 50));
                return <CaseStudyRecord>[_record(id: 'stale')];
              }
              return <CaseStudyRecord>[_record(id: 'fresh')];
            },
          ),
          remoteRepository: _NoopRemoteRepository(),
          remoteDeleteRepository: _SlowDeleteRepository(() {}),
          clipStore: _NoopClipStore(),
          remoteBackendAuth: _StubRemoteBackendAuth(),
        );
        addTearDown(cubit.close);

        final Future<void> slowLoad = cubit.load();
        await cubit.load();
        await slowLoad;

        expect(cubit.state.records.single.id, 'fresh');
        expect(cubit.state.status, CaseStudyHistoryStatus.loaded);
      },
    );

    test('refresh during delete does not resurrect deleted row', () async {
      var deleteCommitted = false;
      final cubit = CaseStudyHistoryCubit(
        authRepository: const _StubAuthRepository(_user),
        localRepository: _MutableLocalRepository(
          initialRecords: <CaseStudyRecord>[_record()],
          onSaveRecords: (final _, final records) async {
            await Future<void>.delayed(const Duration(milliseconds: 30));
            deleteCommitted = true;
          },
          onLoadRecords: (final _) async {
            if (deleteCommitted) {
              return const <CaseStudyRecord>[];
            }
            await Future<void>.delayed(const Duration(milliseconds: 60));
            return <CaseStudyRecord>[_record()];
          },
        ),
        remoteRepository: _NoopRemoteRepository(),
        remoteDeleteRepository: _SlowDeleteRepository(() {}),
        clipStore: _NoopClipStore(),
        remoteBackendAuth: _StubRemoteBackendAuth(),
      );
      addTearDown(cubit.close);
      await cubit.load();

      final Future<void> deleteFuture = cubit.deleteRecord(recordId: 'r1');
      await Future<void>.delayed(Duration.zero);
      final Future<void> refreshFuture = cubit.refresh();
      await deleteFuture;
      await refreshFuture;

      expect(cubit.state.records, isEmpty);
      expect(cubit.state.status, CaseStudyHistoryStatus.loaded);
    });

    test('deleteRecord blocks concurrent deletes', () async {
      var deleteStarted = false;
      final cubit = CaseStudyHistoryCubit(
        authRepository: const _StubAuthRepository(_user),
        localRepository: _MutableLocalRepository(
          initialRecords: <CaseStudyRecord>[
            _record(),
            _record(id: 'r2'),
          ],
          onSaveRecords: (final _, final records) async {
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

      final Future<void> first = cubit.deleteRecord(recordId: 'r1');
      await Future<void>.delayed(Duration.zero);
      expect(deleteStarted, isTrue);
      expect(cubit.state.deletingRecordId, 'r1');

      await cubit.deleteRecord(recordId: 'r2');
      expect(cubit.state.deletingRecordId, 'r1');

      await first;
    });
  });
}
