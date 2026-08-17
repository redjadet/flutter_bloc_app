part of 'case_study_session_cubit.dart';

mixin _CaseStudySessionCubitSubmit
    on _CaseStudySessionCubitBase, _CaseStudySessionCubitHistory {
  Future<void> submitMockUpload() async {
    final String? userId = _requireUserId();
    if (userId == null || !state.draft.isComplete || state.isSubmitting) {
      return;
    }
    final bool remoteSubmit =
        _remoteAuth.isConfigured && _remoteAuth.currentUser != null;

    _pendingSubmitSubmittedAtUtc = null;
    if (isClosed) return;
    emit(
      state.copyWith(
        isSubmitting: true,
        submitError: false,
        clearSubmitLocalHistoryFailed: true,
        submitProgress: 0,
        submitProgressDeterminate: remoteSubmit,
      ),
    );

    final SubmitCaseStudyOutcome outcome = await _submitCaseStudy(
      userId: userId,
      draft: state.draft,
      remoteSubmit: remoteSubmit,
      retryDelay: _retryDelayViaTimerService,
      onProgress: (progress) {
        if (isClosed) return;
        emit(state.copyWith(submitProgress: progress));
      },
    );

    if (isClosed) return;
    switch (outcome) {
      case SubmitCaseStudySuccess(:final CaseStudyDraft freshDraft):
        _pendingSubmitSubmittedAtUtc = null;
        emit(
          state.copyWith(
            isSubmitting: false,
            draft: freshDraft,
            submitError: false,
            clearSubmitLocalHistoryFailed: true,
            clearSubmitProgress: true,
          ),
        );
      case SubmitCaseStudyFailure(
        :final Object error,
        :final StackTrace stackTrace,
        :final bool remoteSubmitFinished,
        :final DateTime? submittedAtUtc,
      ):
        AppLogger.error(
          'CaseStudySessionCubit.submitMockUpload',
          error,
          stackTrace,
        );
        if (remoteSubmitFinished) {
          _pendingSubmitSubmittedAtUtc = submittedAtUtc;
        }
        emit(
          state.copyWith(
            isSubmitting: false,
            submitError: true,
            submitLocalHistoryFailed: remoteSubmitFinished,
            clearSubmitProgress: true,
          ),
        );
    }
  }
}
