part of 'case_study_session_cubit.dart';

mixin _CaseStudySessionCubitHistory on _CaseStudySessionCubitBase {
  Future<CaseStudyDraft> _persistSubmissionToLocalHistory({
    required final String userId,
    required final String caseId,
    required final DateTime submittedAtUtc,
    required final CaseStudyCaseType caseType,
  }) async {
    return _caseStudyLocalPersistRetryPolicy.executeWithRetry<CaseStudyDraft>(
      timerService: _timerService,
      action: () async {
        try {
          final List<CaseStudyRecord> records = await _local.loadRecords(
            userId,
          );
          final CaseStudyRecord record = CaseStudyRecord(
            id: caseId,
            submittedAt: submittedAtUtc,
            doctorName: state.draft.doctorName,
            caseType: caseType,
            notes: state.draft.notes,
            answers: Map<String, String>.from(state.draft.answers),
          );
          final List<CaseStudyRecord> nextRecords = <CaseStudyRecord>[
            record,
            ...records,
          ];
          await _local.saveRecords(userId, nextRecords);
          await _local.clearDraft(userId);
          final CaseStudyDraft fresh = CaseStudyDraft.fresh(
            caseId: _newCaseId(),
          );
          await _local.saveDraft(userId, fresh);
          return fresh;
        } on Object catch (error, stackTrace) {
          AppLogger.error(
            'CaseStudySessionCubit._persistSubmissionToLocalHistory',
            error,
            stackTrace,
          );
          rethrow;
        }
      },
    );
  }

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
      final CaseStudyDraft fresh = await _persistSubmissionToLocalHistory(
        userId: userId,
        caseId: state.draft.caseId,
        submittedAtUtc: submittedAtUtc,
        caseType: caseType,
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
