import 'dart:async';
import 'package:core/core.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/auth/remote_backend_auth_port.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_clip_file_store.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_question.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_delete_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_upload_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_video_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_session_state.dart';
import 'package:flutter_bloc_app/shared/media/media_pick_error_keys.dart';
import 'package:flutter_bloc_app/shared/media/media_pick_result.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/retry_policy.dart';
import 'package:utilities/utilities.dart';

part 'case_study_session_cubit_history.part.dart';
part 'case_study_session_cubit_lifecycle.part.dart';
part 'case_study_session_cubit_submit.part.dart';
part 'case_study_session_cubit_video.part.dart';
part 'case_study_session_cubit_wizard.part.dart';

String _newCaseId() => 'cs_${DateTime.now().microsecondsSinceEpoch}';

const RetryPolicy _caseStudyLocalPersistRetryPolicy = RetryPolicy(
  baseDelay: Duration(milliseconds: 50),
  maxDelay: Duration(milliseconds: 200),
  jitter: false,
);

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
  });
}

abstract class _CaseStudySessionCubitBase extends Cubit<CaseStudySessionState> {
  _CaseStudySessionCubitBase({
    required final AuthRepository authRepository,
    required final CaseStudyLocalRepository localRepository,
    required final CaseStudyVideoRepository videoRepository,
    required final CaseStudyUploadRepository uploadRepository,
    required this._clipStore,
    required final CaseStudyRemoteDeleteRepository remoteDeleteRepository,
    required final RemoteBackendAuthPort remoteBackendAuth,
    required final CaseStudyRemoteRepository remoteRepository,
    required this._timerService,
  }) : _authRepository = authRepository,
       _local = localRepository,
       _video = videoRepository,
       _upload = uploadRepository,
       _remoteDelete = remoteDeleteRepository,
       _remoteAuth = remoteBackendAuth,
       _remote = remoteRepository,
       super(
         CaseStudySessionState(
           hydration: CaseStudyHydrationStatus.initial,
           draft: CaseStudyDraft.fresh(caseId: _newCaseId()),
         ),
       ) {
    _authUserId = authRepository.currentUser?.id;
    _authSub = authRepository.authStateChanges.listen(
      (user) {
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
  final CaseStudyUploadRepository _upload;
  final CaseStudyClipFileStore _clipStore;
  final CaseStudyRemoteDeleteRepository _remoteDelete;
  final RemoteBackendAuthPort _remoteAuth;
  final CaseStudyRemoteRepository _remote;
  final TimerService _timerService;
  final RequestIdGuard _pickGuard = RequestIdGuard();
  final RequestIdGuard _commitGuard = RequestIdGuard();
  StreamSubscription<dynamic>? _authSub;
  String? _authUserId;

  /// Timestamp for the local history row while submit is in flight; kept if local persist fails after remote OK.
  DateTime? _pendingSubmitSubmittedAtUtc;
  Future<void> hydrate() async {
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
          draft: CaseStudyDraft.fresh(caseId: _newCaseId()),
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
      draft = CaseStudyDraft.fresh(caseId: _newCaseId());
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
