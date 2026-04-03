part of 'case_study_session_cubit.dart';

mixin _CaseStudySessionCubitVideo on _CaseStudySessionCubitBase {
  Future<void> tryPickFromCamera() async {
    await _pickAndCommit(_video.pickVideoFromCamera);
  }

  Future<void> tryPickFromGallery() async {
    await _pickAndCommit(_video.pickVideoFromGallery);
  }

  Future<void> _pickAndCommit(
    final Future<CameraGalleryResult> Function() pick,
  ) async {
    final String? userId = _requireUserId();
    if (userId == null) return;
    final int requestId = _pickGuard.next();
    final CameraGalleryResult result = await pick();
    if (isClosed || !_pickGuard.isCurrent(requestId)) return;
    result.when(
      success: (path) {
        unawaited(_commitVideoPath(path, userId));
      },
      cancelled: () {
        emit(state.copyWith(clearPickError: true));
      },
      failure: (errorKey, message) {
        emit(state.copyWith(pickErrorKey: errorKey));
      },
    );
  }

  Future<void> _commitVideoPath(final String path, final String userId) async {
    final int commitId = _commitGuard.next();
    final CaseStudyQuestionId qid = state.draft.currentQuestionId;
    final String? oldPath = state.draft.answers[qid];
    String? stagingPath;
    try {
      stagingPath = await _clipStore.persistClipToStaging(
        sourcePath: path,
        caseId: state.draft.caseId,
        questionId: qid,
        commitToken: commitId,
      );
      if (isClosed || !_commitGuard.isCurrent(commitId)) {
        await _clipStore.deleteFileIfExists(stagingPath);
        return;
      }
      final String finalPath = _clipStore.finalClipFilePathFromStaging(
        stagingPath,
      );
      final String dest = _clipStore.promoteStagingToFinalSync(
        stagingPath: stagingPath,
        finalPath: finalPath,
      );
      stagingPath = null;
      if (isClosed || !_commitGuard.isCurrent(commitId)) {
        return;
      }
      if (oldPath != null && oldPath.isNotEmpty && oldPath != dest) {
        await _clipStore.deleteFileIfExists(oldPath);
      }
      if (isClosed || !_commitGuard.isCurrent(commitId)) {
        return;
      }
      final Map<String, String> nextAnswers = Map<String, String>.from(
        state.draft.answers,
      )..[qid] = dest;
      final CaseStudyDraft updated = state.draft.copyWith(answers: nextAnswers);
      await _local.saveDraft(userId, updated);
      if (isClosed || !_commitGuard.isCurrent(commitId)) {
        return;
      }
      emit(state.copyWith(draft: updated, clearPickError: true));
    } on Object {
      await _clipStore.deleteFileIfExists(stagingPath);
      if (isClosed || !_commitGuard.isCurrent(commitId)) {
        return;
      }
      emit(
        state.copyWith(
          pickErrorKey: CameraGalleryErrorKeys.generic,
        ),
      );
    }
  }

  Future<void> tryRecoverLostVideo() async {
    final String? userId = _requireUserId();
    if (userId == null) return;
    final CameraGalleryResult? lost = await _video.retrieveLostVideo();
    if (lost == null) return;
    lost.when(
      success: (path) {
        unawaited(_commitVideoPath(path, userId));
      },
      cancelled: () {},
      failure: (errorKey, message) {
        if (isClosed) return;
        emit(state.copyWith(pickErrorKey: errorKey));
      },
    );
  }
}
