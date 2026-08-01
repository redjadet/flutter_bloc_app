part of 'case_study_session_cubit.dart';

mixin _CaseStudySessionCubitHistory on _CaseStudySessionCubitBase {
  /// Retries local history + fresh draft when submitLocalHistoryFailed is set.
  ///
  /// When Supabase is active, this also reads the remote row to align
  /// `submittedAtUtc` with the server (read-only).
  Future<void> retryPersistLocalHistoryAfterRemote() async {
    final String? userId = _requireUserId();
    if (userId == null ||
        !state.submitLocalHistoryFailed ||
        !state.draft.isComplete ||
        state.isSubmitting) {
      return;
    }
    final CaseStudyCaseType? caseType = state.draft.caseType;
    if (caseType == null) return;
    if (isClosed) return;

    emit(
      state.copyWith(
        isSubmitting: true,
        submitError: false,
        clearSubmitLocalHistoryFailed: true,
        submitProgress: 0,
        submitProgressDeterminate: false,
      ),
    );
    try {
      DateTime submittedAtUtc =
          _pendingSubmitSubmittedAtUtc ?? DateTime.now().toUtc();
      if (_remoteAuth.isConfigured && _remoteAuth.currentUser != null) {
        try {
          final RemoteCaseStudyDetail? detail = await _remote.getSubmittedCase(
            caseId: state.draft.caseId,
          );
          if (detail != null) {
            submittedAtUtc = detail.submittedAtUtc;
          }
        } on Object catch (error, stackTrace) {
          AppLogger.error(
            'CaseStudySessionCubit.retryPersistLocalHistoryAfterRemote:'
            ' getSubmittedCase',
            error,
            stackTrace,
          );
        }
      }
      if (isClosed) return;
      final CaseStudyDraft fresh = await _persistSubmission(
        userId: userId,
        draft: state.draft,
        submittedAtUtc: submittedAtUtc,
        caseType: caseType,
        retryDelay: _retryDelayViaTimerService,
      );
      _pendingSubmitSubmittedAtUtc = null;
      if (isClosed) return;
      emit(
        state.copyWith(
          isSubmitting: false,
          draft: fresh,
          submitError: false,
          clearSubmitLocalHistoryFailed: true,
          clearSubmitProgress: true,
        ),
      );
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'CaseStudySessionCubit.retryPersistLocalHistoryAfterRemote',
        error,
        stackTrace,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          isSubmitting: false,
          submitError: true,
          submitLocalHistoryFailed: true,
          clearSubmitProgress: true,
        ),
      );
    }
  }
}
