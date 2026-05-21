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

      if (_remoteAuth.isConfigured && _remoteAuth.currentUser != null) {
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
}
