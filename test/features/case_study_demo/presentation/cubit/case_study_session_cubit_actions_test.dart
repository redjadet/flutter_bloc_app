import 'dart:async';

import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/auth/auth_user.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_result.dart';
import 'package:flutter_bloc_app/features/case_study_demo/data/case_study_clip_file_store.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_question.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_delete_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_upload_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_video_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_session_cubit.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubAuthRepository implements AuthRepository {
  _StubAuthRepository(this._currentUser);

  final AuthUser? _currentUser;
  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  Future<void> dispose() => _controller.close();
}

class _MemoryLocalRepository implements CaseStudyLocalRepository {
  final Map<String, CaseStudyDraft?> _drafts = <String, CaseStudyDraft?>{};
  final Map<String, List<CaseStudyRecord>> _records =
      <String, List<CaseStudyRecord>>{};

  @override
  Future<void> clearDraft(final String userId) async {
    _drafts.remove(userId);
  }

  @override
  Future<void> ensureReady() async {}

  @override
  Future<CaseStudyRecord?> getRecord(
    final String userId,
    final String recordId,
  ) async => null;

  @override
  Future<CaseStudyDraft?> loadDraft(final String userId) async =>
      _drafts[userId];

  @override
  Future<List<CaseStudyRecord>> loadRecords(final String userId) async =>
      _records[userId] ?? <CaseStudyRecord>[];

  @override
  Future<void> saveDraft(
    final String userId,
    final CaseStudyDraft draft,
  ) async {
    _drafts[userId] = draft;
  }

  @override
  Future<void> saveRecords(
    final String userId,
    final List<CaseStudyRecord> records,
  ) async {
    _records[userId] = records;
  }
}

class _StubVideoRepository implements CaseStudyVideoRepository {
  @override
  Future<CameraGalleryResult> pickVideoFromCamera() async =>
      const CameraGalleryResult.cancelled();

  @override
  Future<CameraGalleryResult> pickVideoFromGallery() async =>
      const CameraGalleryResult.cancelled();

  @override
  Future<CameraGalleryResult?> retrieveLostVideo() async => null;
}

class _StubUploadRepository implements CaseStudyUploadRepository {
  @override
  Future<void> submitCase() async {}
}

class _NoopClipFileStore extends CaseStudyClipFileStore {
  @override
  Future<void> deleteCaseFolder(final String caseId) async {}
}

class _NoopRemoteDeleteRepository implements CaseStudyRemoteDeleteRepository {
  @override
  Future<void> deleteCaseStudyRemote({required final String caseId}) async {}
}

class _SpyRemoteDeleteRepository implements CaseStudyRemoteDeleteRepository {
  int deleteCount = 0;
  String? lastCaseId;

  @override
  Future<void> deleteCaseStudyRemote({required final String caseId}) async {
    deleteCount += 1;
    lastCaseId = caseId;
  }
}

class _ThrowingRemoteDeleteRepository
    implements CaseStudyRemoteDeleteRepository {
  @override
  Future<void> deleteCaseStudyRemote({required final String caseId}) async {
    throw Exception('network');
  }
}

class _StubSupabaseAuthRepository implements SupabaseAuthRepository {
  _StubSupabaseAuthRepository({this.configured = false, this.user});

  final bool configured;
  final AuthUser? user;

  @override
  bool get isConfigured => configured;

  @override
  AuthUser? get currentUser => user;

  @override
  Stream<AuthUser?> get authStateChanges => const Stream<AuthUser?>.empty();

  @override
  Future<void> signInWithPassword({
    required final String email,
    required final String password,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signUp({
    required final String email,
    required final String password,
    final String? displayName,
  }) async {}
}

class _StubRemoteRepository implements CaseStudyRemoteRepository {
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
      <RemoteCaseStudySummary>[];

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

class _SpyRemoteRepository implements CaseStudyRemoteRepository {
  int uploadCount = 0;
  int upsertCount = 0;
  int finalizeCount = 0;

  @override
  Future<String> uploadClip({
    required final String caseId,
    required final String questionId,
    required final String localPath,
  }) async {
    uploadCount += 1;
    return 'user/u/case/$caseId/$questionId.mp4';
  }

  @override
  Future<void> upsertRemoteDraft({
    required final String caseId,
    required final String doctorName,
    required final CaseStudyCaseType caseType,
    required final String notes,
    required final Map<String, String> remoteObjectKeysByQuestion,
  }) async {
    upsertCount += 1;
  }

  @override
  Future<void> finalizeRemoteSubmission({
    required final String caseId,
    required final String doctorName,
    required final CaseStudyCaseType caseType,
    required final String notes,
    required final Map<String, String> remoteObjectKeysByQuestion,
    required final DateTime submittedAtUtc,
  }) async {
    finalizeCount += 1;
  }

  @override
  Future<List<RemoteCaseStudySummary>> listSubmittedCases() async =>
      <RemoteCaseStudySummary>[];

  @override
  Future<RemoteCaseStudyDetail?> getSubmittedCase({
    required final String caseId,
  }) async => null;

  @override
  Future<String> createSignedPlaybackUrl({
    required final String objectKey,
    required final Duration ttl,
  }) async => '';
}

/// Remote clips already "uploaded" — [upsertRemoteDraft] throws (simulated failure).
class _RemoteRepositoryFailsOnUpsert implements CaseStudyRemoteRepository {
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
      <RemoteCaseStudySummary>[];

  @override
  Future<String> uploadClip({
    required final String caseId,
    required final String questionId,
    required final String localPath,
  }) async => 'user/u/case/$caseId/$questionId.mp4';

  @override
  Future<void> upsertRemoteDraft({
    required final String caseId,
    required final String doctorName,
    required final CaseStudyCaseType caseType,
    required final String notes,
    required final Map<String, String> remoteObjectKeysByQuestion,
  }) async {
    throw StateError('upsert failed');
  }
}

void main() {
  group('CaseStudySessionCubit.abandonCase', () {
    test('clears local draft and replaces it with a fresh case', () async {
      final _StubAuthRepository auth = _StubAuthRepository(
        const AuthUser(id: 'user-1', isAnonymous: false),
      );
      final _MemoryLocalRepository local = _MemoryLocalRepository();

      final CaseStudySessionCubit cubit = CaseStudySessionCubit(
        authRepository: auth,
        localRepository: local,
        videoRepository: _StubVideoRepository(),
        uploadRepository: _StubUploadRepository(),
        clipStore: _NoopClipFileStore(),
        remoteDeleteRepository: _NoopRemoteDeleteRepository(),
        supabaseAuthRepository: _StubSupabaseAuthRepository(),
        remoteRepository: _StubRemoteRepository(),
      );

      final CaseStudyDraft draft = CaseStudyDraft.fresh(caseId: 'case-1');
      await local.saveDraft('user-1', draft);
      await cubit.hydrate();

      await cubit.abandonCase();

      final CaseStudyDraft? next = await local.loadDraft('user-1');
      expect(next, isNotNull);
      expect(next!.caseId, isNot('case-1'));

      await cubit.close();
      await auth.dispose();
    });

    test('still replaces draft when remote delete fails', () async {
      final _StubAuthRepository auth = _StubAuthRepository(
        const AuthUser(id: 'user-1', isAnonymous: false),
      );
      final _MemoryLocalRepository local = _MemoryLocalRepository();

      final CaseStudySessionCubit cubit = CaseStudySessionCubit(
        authRepository: auth,
        localRepository: local,
        videoRepository: _StubVideoRepository(),
        uploadRepository: _StubUploadRepository(),
        clipStore: _NoopClipFileStore(),
        remoteDeleteRepository: _ThrowingRemoteDeleteRepository(),
        supabaseAuthRepository: _StubSupabaseAuthRepository(),
        remoteRepository: _StubRemoteRepository(),
      );

      final CaseStudyDraft draft = CaseStudyDraft.fresh(caseId: 'case-1');
      await local.saveDraft('user-1', draft);
      await cubit.hydrate();

      await cubit.abandonCase();

      final CaseStudyDraft? next = await local.loadDraft('user-1');
      expect(next, isNotNull);
      expect(next!.caseId, isNot('case-1'));

      await cubit.close();
      await auth.dispose();
    });
  });

  group('CaseStudySessionCubit.submitMockUpload', () {
    test(
      'uses draft.caseId for local record id and writes remote when Supabase active',
      () async {
        final _StubAuthRepository auth = _StubAuthRepository(
          const AuthUser(id: 'user-1', isAnonymous: false),
        );
        final _MemoryLocalRepository local = _MemoryLocalRepository();
        final _SpyRemoteRepository remote = _SpyRemoteRepository();

        final CaseStudySessionCubit cubit = CaseStudySessionCubit(
          authRepository: auth,
          localRepository: local,
          videoRepository: _StubVideoRepository(),
          uploadRepository: _StubUploadRepository(),
          clipStore: _NoopClipFileStore(),
          remoteDeleteRepository: _NoopRemoteDeleteRepository(),
          supabaseAuthRepository: _StubSupabaseAuthRepository(
            configured: true,
            user: const AuthUser(id: 'supa-1', isAnonymous: false),
          ),
          remoteRepository: remote,
        );

        final CaseStudyDraft draft = CaseStudyDraft(
          caseId: 'case-123',
          doctorName: 'Dr. Ada',
          caseType: CaseStudyCaseType.implant,
          notes: 'notes',
          answers: <String, String>{
            for (final CaseStudyQuestionId id in CaseStudyQuestions.orderedIds)
              id: '/tmp/$id.mp4',
          },
          phase: CaseStudyDraftPhase.reviewing,
          currentQuestionIndex: 0,
          remoteObjectKeysByQuestion: const <String, String>{},
        );
        await local.saveDraft('user-1', draft);
        await cubit.hydrate();

        await cubit.submitMockUpload();

        final List<CaseStudyRecord> records = await local.loadRecords('user-1');
        expect(records, hasLength(1));
        expect(records.first.id, 'case-123');
        expect(remote.uploadCount, CaseStudyQuestions.orderedIds.length);
        expect(remote.upsertCount, 1);
        expect(remote.finalizeCount, 1);

        await cubit.close();
        await auth.dispose();
      },
    );

    test(
      'best-effort remote delete when remote submit fails mid-flight',
      () async {
        final _StubAuthRepository auth = _StubAuthRepository(
          const AuthUser(id: 'user-1', isAnonymous: false),
        );
        final _MemoryLocalRepository local = _MemoryLocalRepository();
        final _SpyRemoteDeleteRepository remoteDelete =
            _SpyRemoteDeleteRepository();
        final _RemoteRepositoryFailsOnUpsert remote =
            _RemoteRepositoryFailsOnUpsert();

        final CaseStudySessionCubit cubit = CaseStudySessionCubit(
          authRepository: auth,
          localRepository: local,
          videoRepository: _StubVideoRepository(),
          uploadRepository: _StubUploadRepository(),
          clipStore: _NoopClipFileStore(),
          remoteDeleteRepository: remoteDelete,
          supabaseAuthRepository: _StubSupabaseAuthRepository(
            configured: true,
            user: const AuthUser(id: 'supa-1', isAnonymous: false),
          ),
          remoteRepository: remote,
        );

        final Map<String, String> preUploaded = <String, String>{
          for (final CaseStudyQuestionId id in CaseStudyQuestions.orderedIds)
            id: 'user/u/pre/$id.mp4',
        };
        final CaseStudyDraft draft = CaseStudyDraft(
          caseId: 'case-fail-upsert',
          doctorName: 'Dr. Ada',
          caseType: CaseStudyCaseType.implant,
          notes: 'notes',
          answers: <String, String>{
            for (final CaseStudyQuestionId id in CaseStudyQuestions.orderedIds)
              id: '/tmp/$id.mp4',
          },
          phase: CaseStudyDraftPhase.reviewing,
          currentQuestionIndex: 0,
          remoteObjectKeysByQuestion: preUploaded,
        );
        await local.saveDraft('user-1', draft);
        await cubit.hydrate();

        await cubit.submitMockUpload();

        expect(remoteDelete.deleteCount, 1);
        expect(remoteDelete.lastCaseId, 'case-fail-upsert');
        expect(cubit.state.submitError, isTrue);
        expect(await local.loadRecords('user-1'), isEmpty);

        await cubit.close();
        await auth.dispose();
      },
    );
  });
}
