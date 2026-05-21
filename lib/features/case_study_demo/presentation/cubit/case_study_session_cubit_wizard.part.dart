part of 'case_study_session_cubit.dart';

mixin _CaseStudySessionCubitWizard on _CaseStudySessionCubitBase {
  Future<void> startNewCase() async {
    final String? userId = _requireUserId();
    if (userId == null) return;
    await _local.ensureReady();
    if (isClosed) return;
    await _clipStore.deleteCaseFolder(state.draft.caseId);
    if (isClosed) return;
    await _local.clearDraft(userId);
    if (isClosed) return;
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
    if (isClosed) return;
    emit(state.copyWith(draft: updated));
  }

  void setPhaseForRecord() {
    final String? userId = _requireUserId();
    if (userId == null) return;
    final CaseStudyDraft updated = state.draft.copyWith(
      phase: CaseStudyDraftPhase.recording,
    );
    unawaited(_local.saveDraft(userId, updated));
    if (isClosed) return;
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
    if (isClosed) return;
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
    if (isClosed) return;
    emit(state.copyWith(draft: updated, clearPickError: true));
  }

  void clearPickError() {
    if (isClosed) return;
    emit(state.copyWith(clearPickError: true));
  }
}
