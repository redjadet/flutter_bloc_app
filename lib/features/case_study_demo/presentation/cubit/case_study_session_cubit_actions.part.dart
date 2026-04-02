part of 'case_study_session_cubit.dart';

mixin _CaseStudySessionCubitActions on _CaseStudySessionCubitBase {
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

    emit(
      state.copyWith(
        isSubmitting: true,
        submitError: false,
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
            clearSubmitProgress: true,
          ),
        );
        return;
      }

      caseIdForSubmit = state.draft.caseId;
      final DateTime submittedAtUtc = DateTime.now().toUtc();
      final String caseId = caseIdForSubmit;

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

      final List<CaseStudyRecord> records = await _local.loadRecords(userId);
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
      final CaseStudyDraft fresh = CaseStudyDraft.fresh(caseId: _newCaseId());
      await _local.saveDraft(userId, fresh);
      if (isClosed) return;
      emit(
        state.copyWith(
          isSubmitting: false,
          draft: fresh,
          submitError: false,
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
          clearSubmitProgress: true,
        ),
      );
    }
  }

  void clearPickError() {
    emit(state.copyWith(clearPickError: true));
  }
}
