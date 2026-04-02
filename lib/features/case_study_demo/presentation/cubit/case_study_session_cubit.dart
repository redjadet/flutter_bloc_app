import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_error_keys.dart';
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
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_session_state.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/request_id_guard.dart';

part 'case_study_session_cubit_actions.part.dart';
part 'case_study_session_cubit_video.part.dart';

String _newCaseId() => 'cs_${DateTime.now().microsecondsSinceEpoch}';

/// Session + wizard state for the dentist case-study demo.
class CaseStudySessionCubit extends _CaseStudySessionCubitBase
    with _CaseStudySessionCubitActions, _CaseStudySessionCubitVideo {
  CaseStudySessionCubit({
    required super.authRepository,
    required super.localRepository,
    required super.videoRepository,
    required super.uploadRepository,
    required super.clipStore,
    required super.remoteDeleteRepository,
    required super.supabaseAuthRepository,
    required super.remoteRepository,
  });
}

abstract class _CaseStudySessionCubitBase extends Cubit<CaseStudySessionState> {
  _CaseStudySessionCubitBase({
    required final AuthRepository authRepository,
    required final CaseStudyLocalRepository localRepository,
    required final CaseStudyVideoRepository videoRepository,
    required final CaseStudyUploadRepository uploadRepository,
    required final CaseStudyClipFileStore clipStore,
    required final CaseStudyRemoteDeleteRepository remoteDeleteRepository,
    required final SupabaseAuthRepository supabaseAuthRepository,
    required final CaseStudyRemoteRepository remoteRepository,
  }) : _authRepository = authRepository,
       _local = localRepository,
       _video = videoRepository,
       _upload = uploadRepository,
       _clipStore = clipStore,
       _remoteDelete = remoteDeleteRepository,
       _supaAuth = supabaseAuthRepository,
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
  final SupabaseAuthRepository _supaAuth;
  final CaseStudyRemoteRepository _remote;
  final RequestIdGuard _pickGuard = RequestIdGuard();
  final RequestIdGuard _commitGuard = RequestIdGuard();
  StreamSubscription<dynamic>? _authSub;
  String? _authUserId;
  Future<void> hydrate() async {
    emit(
      state.copyWith(
        hydration: CaseStudyHydrationStatus.loading,
        clearPickError: true,
      ),
    );
    final String? userId = _requireUserId();
    if (userId == null) {
      emit(
        state.copyWith(
          hydration: CaseStudyHydrationStatus.ready,
          draft: CaseStudyDraft.fresh(caseId: _newCaseId()),
        ),
      );
      return;
    }
    await _local.ensureReady();
    CaseStudyDraft? draft = await _local.loadDraft(userId);
    if (draft == null) {
      draft = CaseStudyDraft.fresh(caseId: _newCaseId());
      await _local.saveDraft(userId, draft);
    }
    if (isClosed) return;
    emit(
      state.copyWith(
        hydration: CaseStudyHydrationStatus.ready,
        draft: draft,
        clearPickError: true,
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
