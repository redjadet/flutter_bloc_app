part of 'case_study_session_cubit.dart';

mixin _CaseStudySessionCubitActions on _CaseStudySessionCubitBase {
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

  Future<void> startNewCase() async {
    final String? userId = _requireUserId();
    if (userId == null) return;
    await _local.ensureReady();
    await _clipStore.deleteCaseFolder(state.draft.caseId);
    await _local.clearDraft(userId);
    final CaseStudyDraft next = CaseStudyDraft.fresh(caseId: _newCaseId());
    await _local.saveDraft(userId, next);
    if (isClosed) return;
    emit(state.copyWith(draft: next, clearPickError: true));
  }

  Future<void> setMetadata({
    required final String doctorName,
    required final CaseStudyCaseType caseType,
    required final String notes,
  }) async {
    final String? userId = _requireUserId();
    if (userId == null) return;
    final CaseStudyDraft updated = state.draft.copyWith(
      doctorName: doctorName,
      caseType: caseType,
      notes: notes,
      phase: CaseStudyDraftPhase.recording,
      currentQuestionIndex: 0,
    );
    await _local.saveDraft(userId, updated);
    if (isClosed) return;
    emit(state.copyWith(draft: updated, clearPickError: true));
  }

  void goToReviewPhase() {
    final String? userId = _requireUserId();
    if (userId == null || !state.draft.isComplete) return;
    final CaseStudyDraft updated = state.draft.copyWith(
      phase: CaseStudyDraftPhase.reviewing,
    );
    // Intentionally unawaited: keep navigation responsive; draft is already in memory.
    unawaited(_local.saveDraft(userId, updated));
    emit(state.copyWith(draft: updated));
  }

  void setPhaseForRecord() {
    final String? userId = _requireUserId();
    if (userId == null) return;
    final CaseStudyDraft updated = state.draft.copyWith(
      phase: CaseStudyDraftPhase.recording,
    );
    unawaited(_local.saveDraft(userId, updated));
    emit(state.copyWith(draft: updated));
  }

  void nextQuestion() {
    if (state.draft.currentQuestionIndex >=
        CaseStudyQuestions.orderedIds.length - 1) {
      return;
    }
    final String? userId = _requireUserId();
    if (userId == null) return;
    final CaseStudyDraft updated = state.draft.copyWith(
      currentQuestionIndex: state.draft.currentQuestionIndex + 1,
    );
    unawaited(_local.saveDraft(userId, updated));
    emit(state.copyWith(draft: updated, clearPickError: true));
  }

  void previousQuestion() {
    if (state.draft.currentQuestionIndex <= 0) return;
    final String? userId = _requireUserId();
    if (userId == null) return;
    final CaseStudyDraft updated = state.draft.copyWith(
      currentQuestionIndex: state.draft.currentQuestionIndex - 1,
    );
    unawaited(_local.saveDraft(userId, updated));
    emit(state.copyWith(draft: updated, clearPickError: true));
  }

  Future<void> abandonCase() async {
    final String? userId = _requireUserId();
    if (userId == null) return;
    final String caseId = state.draft.caseId;
    await _clipStore.deleteCaseFolder(state.draft.caseId);
    await _local.clearDraft(userId);
    try {
      await _remoteDelete.deleteCaseStudyRemote(caseId: caseId);
    } on Object catch (error, stackTrace) {
      // Best-effort only: local clips and draft are already cleared; abandoning
      // must always recover to a fresh local draft even if the Edge call fails.
      AppLogger.error(
        'CaseStudySessionCubit.abandonCase: remote delete failed',
        error,
        stackTrace,
      );
    }
    final CaseStudyDraft next = CaseStudyDraft.fresh(caseId: _newCaseId());
    await _local.saveDraft(userId, next);
    if (isClosed) return;
    emit(state.copyWith(draft: next, clearPickError: true));
  }

  Future<void> submitMockUpload() async {
    final String? userId = _requireUserId();
    if (userId == null || !state.draft.isComplete || state.isSubmitting) {
      return;
    }
    final bool remoteSubmit =
        _supaAuth.isConfigured && _supaAuth.currentUser != null;
    var beganRemoteCaseStudyUpload = false;
    var remoteSubmitFinished = false;
    String? caseIdForSubmit;

    _pendingSubmitSubmittedAtUtc = null;
    emit(
      state.copyWith(
        isSubmitting: true,
        submitError: false,
        clearSubmitLocalHistoryFailed: true,
        submitProgress: 0,
        submitProgressDeterminate: remoteSubmit,
      ),
    );
    try {
      await _upload.submitCase();
      final CaseStudyCaseType? caseType = state.draft.caseType;
      if (caseType == null) {
        if (isClosed) return;
        emit(
          state.copyWith(
            isSubmitting: false,
            submitError: true,
            clearSubmitLocalHistoryFailed: true,
            clearSubmitProgress: true,
          ),
        );
        return;
      }

      caseIdForSubmit = state.draft.caseId;
      final DateTime submittedAtUtc = DateTime.now().toUtc();
      final String caseId = caseIdForSubmit;
      _pendingSubmitSubmittedAtUtc = submittedAtUtc;

      if (_supaAuth.isConfigured && _supaAuth.currentUser != null) {
        beganRemoteCaseStudyUpload = true;
        final int clipTotal = state.draft.answers.values
            .where((p) => p.isNotEmpty)
            .length;
        final int totalSteps = clipTotal + 2;
        var done = 0;
        void reportProgress() {
          if (isClosed) return;
          final double progress = totalSteps == 0
              ? 1
              : (done / totalSteps).clamp(0, 1);
          emit(state.copyWith(submitProgress: progress));
        }

        final Map<String, String> remoteKeys = Map<String, String>.from(
          state.draft.remoteObjectKeysByQuestion,
        );

        for (final MapEntry<String, String> entry
            in state.draft.answers.entries) {
          final String questionId = entry.key;
          final String localPath = entry.value;
          if (localPath.isEmpty) continue;
          if (remoteKeys[questionId]?.isNotEmpty == true) {
            done += 1;
            reportProgress();
            continue;
          }

          final String objectKey = await _remote.uploadClip(
            caseId: caseId,
            questionId: questionId,
            localPath: localPath,
          );
          remoteKeys[questionId] = objectKey;
          done += 1;
          reportProgress();
        }

        await _remote.upsertRemoteDraft(
          caseId: caseId,
          doctorName: state.draft.doctorName,
          caseType: caseType,
          notes: state.draft.notes,
          remoteObjectKeysByQuestion: remoteKeys,
        );
        done += 1;
        reportProgress();
        await _remote.finalizeRemoteSubmission(
          caseId: caseId,
          doctorName: state.draft.doctorName,
          caseType: caseType,
          notes: state.draft.notes,
          remoteObjectKeysByQuestion: remoteKeys,
          submittedAtUtc: submittedAtUtc,
        );
        done += 1;
        reportProgress();
        if (!isClosed) emit(state.copyWith(submitProgress: 1));
        remoteSubmitFinished = true;
      }

      final CaseStudyDraft fresh = await _persistSubmissionToLocalHistory(
        userId: userId,
        caseId: caseId,
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
        'CaseStudySessionCubit.submitMockUpload',
        error,
        stackTrace,
      );
      final String? cleanupCaseId = caseIdForSubmit;
      if (beganRemoteCaseStudyUpload &&
          !remoteSubmitFinished &&
          cleanupCaseId != null &&
          cleanupCaseId.isNotEmpty) {
        try {
          await _remoteDelete.deleteCaseStudyRemote(caseId: cleanupCaseId);
        } on Object catch (cleanupError, cleanupStack) {
          AppLogger.error(
            'CaseStudySessionCubit.submitMockUpload: remote cleanup failed',
            cleanupError,
            cleanupStack,
          );
        }
      }
      if (isClosed) return;
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
      if (_supaAuth.isConfigured && _supaAuth.currentUser != null) {
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

  void clearPickError() {
    emit(state.copyWith(clearPickError: true));
  }
}
