import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_clip_file_store.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_question.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_delete_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_upload_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_video_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/use_cases/persist_case_study_submission_use_case.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/use_cases/submit_case_study_outcome.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/use_cases/submit_case_study_use_case.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_session_state.dart';
import 'package:ilkersevim_async_utils/ilkersevim_async_utils.dart';
import 'package:ilkersevim_retry/ilkersevim_retry.dart';

part 'case_study_session_cubit_history.part.dart';
part 'case_study_session_cubit_lifecycle.part.dart';
part 'case_study_session_cubit_submit.part.dart';
part 'case_study_session_cubit_video.part.dart';
part 'case_study_session_cubit_wizard.part.dart';

String newCaseStudyCaseId() => 'cs_${DateTime.now().microsecondsSinceEpoch}';

/// Session + wizard state for the dentist case-study demo.
class CaseStudySessionCubit extends _CaseStudySessionCubitBase
    with
        _CaseStudySessionCubitWizard,
        _CaseStudySessionCubitLifecycle,
        _CaseStudySessionCubitHistory,
        _CaseStudySessionCubitSubmit,
        _CaseStudySessionCubitVideo {
  CaseStudySessionCubit({
    required super.authRepository,
    required super.localRepository,
    required super.videoRepository,
    required super.uploadRepository,
    required super.clipStore,
    required super.remoteDeleteRepository,
    required super.remoteBackendAuth,
    required super.remoteRepository,
    required super.timerService,
    super.submitCaseStudy,
    super.persistSubmission,
  });
}

abstract class _CaseStudySessionCubitBase extends Cubit<CaseStudySessionState> {
  _CaseStudySessionCubitBase({
    required AuthRepository authRepository,
    required CaseStudyLocalRepository localRepository,
    required CaseStudyVideoRepository videoRepository,
    required CaseStudyUploadRepository uploadRepository,
    required this._clipStore,
    required CaseStudyRemoteDeleteRepository remoteDeleteRepository,
    required RemoteBackendAuthPort remoteBackendAuth,
    required CaseStudyRemoteRepository remoteRepository,
    required this._timerService,
    SubmitCaseStudyUseCase? submitCaseStudy,
    PersistCaseStudySubmissionUseCase? persistSubmission,
  }) : _authRepository = authRepository,
       _local = localRepository,
       _video = videoRepository,
       _remoteDelete = remoteDeleteRepository,
       _remoteAuth = remoteBackendAuth,
       _remote = remoteRepository,
       super(
         CaseStudySessionState(
           hydration: CaseStudyHydrationStatus.initial,
           draft: CaseStudyDraft.fresh(caseId: newCaseStudyCaseId()),
         ),
       ) {
    final PersistCaseStudySubmissionUseCase persist =
        persistSubmission ??
        PersistCaseStudySubmissionUseCase(
          localRepository: localRepository,
          newCaseId: newCaseStudyCaseId,
        );
    _persistSubmission = persist;
    _submitCaseStudy =
        submitCaseStudy ??
        SubmitCaseStudyUseCase(
          uploadRepository: uploadRepository,
          remoteRepository: remoteRepository,
          remoteDeleteRepository: remoteDeleteRepository,
          persistSubmission: persist,
        );
    _authUserId = authRepository.currentUser?.id;
    _authSub = authRepository.authStateChanges.listen(
      (user) {
        if (isClosed) return;
        final String? nextId = user?.id;
        if (nextId != _authUserId) {
          _authUserId = nextId;
          unawaited(hydrate());
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        AppLogger.error(
          'CaseStudySessionCubit.authStateChanges',
          error,
          stackTrace,
        );
      },
    );
  }
  final AuthRepository _authRepository;
  final CaseStudyLocalRepository _local;
  final CaseStudyVideoRepository _video;
  final CaseStudyClipFileStore _clipStore;
  final CaseStudyRemoteDeleteRepository _remoteDelete;
  final RemoteBackendAuthPort _remoteAuth;
  final CaseStudyRemoteRepository _remote;
  final TimerService _timerService;
  late final PersistCaseStudySubmissionUseCase _persistSubmission;
  late final SubmitCaseStudyUseCase _submitCaseStudy;
  final RequestIdGuard _pickGuard = RequestIdGuard();
  final RequestIdGuard _commitGuard = RequestIdGuard();
  StreamSubscription<dynamic>? _authSub;
  String? _authUserId;

  /// Adapts [_timerService] to [RetryDelay] for local persist backoff.
  Future<void> _retryDelayViaTimerService(Duration duration) {
    final Completer<void> completer = Completer<void>();
    final TimerDisposable handle = _timerService.runOnce(duration, () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    return completer.future.whenComplete(handle.dispose);
  }

  /// Timestamp for the local history row while submit is in flight; kept if local persist fails after remote OK.
  DateTime? _pendingSubmitSubmittedAtUtc;
  Future<void> hydrate() async {
    if (isClosed) return;
    emit(
      state.copyWith(
        hydration: CaseStudyHydrationStatus.loading,
        clearPickError: true,
      ),
    );
    final String? userId = _requireUserId();
    if (userId == null) {
      _pendingSubmitSubmittedAtUtc = null;
      emit(
        state.copyWith(
          hydration: CaseStudyHydrationStatus.ready,
          draft: CaseStudyDraft.fresh(caseId: newCaseStudyCaseId()),
          isSubmitting: false,
          submitError: false,
          clearSubmitLocalHistoryFailed: true,
          clearSubmitProgress: true,
        ),
      );
      return;
    }
    await _local.ensureReady();
    if (isClosed) return;
    if (_requireUserId() != userId) {
      if (!isClosed) {
        unawaited(hydrate());
      }
      return;
    }
    CaseStudyDraft? draft = await _local.loadDraft(userId);
    if (isClosed) return;
    if (_requireUserId() != userId) {
      if (!isClosed) {
        unawaited(hydrate());
      }
      return;
    }
    if (draft == null) {
      draft = CaseStudyDraft.fresh(caseId: newCaseStudyCaseId());
      await _local.saveDraft(userId, draft);
    }
    if (isClosed) return;
    if (_requireUserId() != userId) {
      if (!isClosed) {
        unawaited(hydrate());
      }
      return;
    }
    _pendingSubmitSubmittedAtUtc = null;
    emit(
      state.copyWith(
        hydration: CaseStudyHydrationStatus.ready,
        draft: draft,
        clearPickError: true,
        isSubmitting: false,
        submitError: false,
        clearSubmitLocalHistoryFailed: true,
        clearSubmitProgress: true,
      ),
    );
  }

  String? _requireUserId() {
    final String? id = _authRepository.currentUser?.id;
    if (id == null || id.isEmpty) return null;
    return id;
  }

  @override
  Future<void> close() async {
    await _authSub?.cancel();
    return super.close();
  }
}
