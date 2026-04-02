import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/core/auth/auth_user.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
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
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_session_state.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/pages/case_study_metadata_page.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/pages/case_study_record_page.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/pages/case_study_review_page.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _StubAuthRepository implements AuthRepository {
  _StubAuthRepository()
    : _controller = StreamController<AuthUser?>.broadcast(),
      _currentUser = const AuthUser(id: 'user-1', isAnonymous: false);

  final StreamController<AuthUser?> _controller;
  final AuthUser? _currentUser;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  Future<void> dispose() => _controller.close();
}

class _StubLocalRepository implements CaseStudyLocalRepository {
  @override
  Future<void> clearDraft(final String userId) async {}

  @override
  Future<void> ensureReady() async {}

  @override
  Future<CaseStudyRecord?> getRecord(
    final String userId,
    final String recordId,
  ) async => null;

  @override
  Future<CaseStudyDraft?> loadDraft(final String userId) async => null;

  @override
  Future<List<CaseStudyRecord>> loadRecords(final String userId) async =>
      <CaseStudyRecord>[];

  @override
  Future<void> saveDraft(
    final String userId,
    final CaseStudyDraft draft,
  ) async {}

  @override
  Future<void> saveRecords(
    final String userId,
    final List<CaseStudyRecord> records,
  ) async {}
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

class _StubRemoteDeleteRepository implements CaseStudyRemoteDeleteRepository {
  @override
  Future<void> deleteCaseStudyRemote({required final String caseId}) async {}
}

class _StubSupabaseAuthRepository implements SupabaseAuthRepository {
  @override
  bool get isConfigured => false;

  @override
  AuthUser? get currentUser => null;

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

class _TestCaseStudySessionCubit extends CaseStudySessionCubit {
  _TestCaseStudySessionCubit({required super.authRepository})
    : super(
        localRepository: _StubLocalRepository(),
        videoRepository: _StubVideoRepository(),
        uploadRepository: _StubUploadRepository(),
        clipStore: CaseStudyClipFileStore(),
        remoteDeleteRepository: _StubRemoteDeleteRepository(),
        supabaseAuthRepository: _StubSupabaseAuthRepository(),
        remoteRepository: _StubRemoteRepository(),
        timerService: DefaultTimerService(),
      );

  void emitState(final CaseStudySessionState state) => emit(state);
}

Widget _buildApp({
  required final _TestCaseStudySessionCubit cubit,
  required final String initialLocation,
}) {
  final GoRouter router = GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.caseStudyDemoNewPath,
        name: AppRoutes.caseStudyDemoNew,
        builder: (context, state) => const CaseStudyMetadataPage(),
      ),
      GoRoute(
        path: AppRoutes.caseStudyDemoRecordPath,
        name: AppRoutes.caseStudyDemoRecord,
        builder: (context, state) => const CaseStudyRecordPage(),
      ),
      GoRoute(
        path: AppRoutes.caseStudyDemoReviewPath,
        name: AppRoutes.caseStudyDemoReview,
        builder: (context, state) => const CaseStudyReviewPage(),
      ),
    ],
  );

  return BlocProvider<CaseStudySessionCubit>.value(
    value: cubit,
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      routerConfig: router,
    ),
  );
}

void main() {
  group('case study step guards', () {
    late _StubAuthRepository authRepository;
    late _TestCaseStudySessionCubit cubit;

    setUp(() {
      authRepository = _StubAuthRepository();
      cubit = _TestCaseStudySessionCubit(authRepository: authRepository);
    });

    tearDown(() async {
      await cubit.close();
      await authRepository.dispose();
    });

    testWidgets('record page redirects back to metadata without metadata', (
      final tester,
    ) async {
      cubit.emitState(
        CaseStudySessionState(
          hydration: CaseStudyHydrationStatus.ready,
          draft: CaseStudyDraft.fresh(caseId: 'case-1'),
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          cubit: cubit,
          initialLocation: AppRoutes.caseStudyDemoRecordPath,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Case details'), findsOneWidget);
    });

    testWidgets('review page redirects back to record when incomplete', (
      final tester,
    ) async {
      cubit.emitState(
        CaseStudySessionState(
          hydration: CaseStudyHydrationStatus.ready,
          draft: CaseStudyDraft(
            caseId: 'case-1',
            doctorName: 'Dr. Ada',
            caseType: CaseStudyCaseType.implant,
            notes: 'notes',
            answers: <String, String>{
              for (final CaseStudyQuestionId id
                  in CaseStudyQuestions.orderedIds.take(9))
                id: '/tmp/$id.mp4',
            },
            currentQuestionIndex: 9,
            phase: CaseStudyDraftPhase.reviewing,
            remoteObjectKeysByQuestion: {},
          ),
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          cubit: cubit,
          initialLocation: AppRoutes.caseStudyDemoReviewPath,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Record responses'), findsOneWidget);
    });
  });
}
