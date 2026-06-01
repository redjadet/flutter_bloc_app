part of 'case_study_session_cubit.dart';

mixin _CaseStudySessionCubitLifecycle on _CaseStudySessionCubitBase {
  Future<void> abandonCase() async {
    if (state.isSubmitting || state.submitLocalHistoryFailed) {
      return;
    }
    final String? userId = _requireUserId();
    if (userId == null) return;
    final String caseId = state.draft.caseId;
    await _clipStore.deleteCaseFolder(state.draft.caseId);
    if (isClosed) return;
    await _local.clearDraft(userId);
    if (isClosed) return;
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
    if (isClosed) return;
    final CaseStudyDraft next = CaseStudyDraft.fresh(caseId: _newCaseId());
    await _local.saveDraft(userId, next);
    if (isClosed) return;
    emit(state.copyWith(draft: next, clearPickError: true));
  }
}
