part of 'case_study_history_detail_cubit.dart';

mixin _CaseStudyHistoryDetailCubitActions
    on _CaseStudyHistoryDetailCubitBase, _CaseStudyHistoryDetailCubitFetch {
  void clearTransientError() {
    if (isClosed || state.transientError == null) return;
    emit(state.copyWith(clearTransientError: true));
  }

  Future<void> load({final bool refresh = false}) async {
    if (isClosed) return;
    final int requestId = _loadGuard.next();

    if (recordId.isEmpty) {
      emit(
        state.copyWith(
          status: CaseStudyHistoryDetailStatus.notFound,
          clearRecord: true,
          clearErrorMessage: true,
        ),
      );
      return;
    }

    final bool keepVisibleContent =
        refresh && state.status == CaseStudyHistoryDetailStatus.loaded;
    if (!keepVisibleContent) {
      emit(
        state.copyWith(
          status: CaseStudyHistoryDetailStatus.loading,
          clearTransientError: true,
          clearErrorMessage: true,
          clearRecord: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          clearTransientError: true,
          clearErrorMessage: true,
        ),
      );
    }

    await CubitExceptionHandler.executeAsync<_DetailLoadResult>(
      operation: _fetchDetail,
      isAlive: () => !isClosed,
      logContext: 'CaseStudyHistoryDetailCubit.load',
      onSuccess: (result) {
        if (isClosed || !_loadGuard.isCurrent(requestId)) return;

        if (result.unavailable) {
          emit(
            state.copyWith(
              status: CaseStudyHistoryDetailStatus.unavailable,
              clearRecord: true,
            ),
          );
          return;
        }

        if (result.notFound) {
          emit(
            state.copyWith(
              status: CaseStudyHistoryDetailStatus.notFound,
              clearRecord: true,
            ),
          );
          return;
        }

        emit(
          CaseStudyHistoryDetailState(
            status: CaseStudyHistoryDetailStatus.loaded,
            record: result.record,
            usesExpiringCloudPlaybackUrls: result.usesExpiringCloudPlaybackUrls,
          ),
        );
      },
      onError: (message) {
        if (isClosed || !_loadGuard.isCurrent(requestId)) return;

        if (keepVisibleContent && state.record != null) {
          emit(
            state.copyWith(
              status: CaseStudyHistoryDetailStatus.loaded,
              errorMessage: message,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: CaseStudyHistoryDetailStatus.error,
            errorMessage: message,
            clearRecord: true,
          ),
        );
      },
    );
  }

  Future<void> refresh() => load(refresh: true);

  Future<bool> delete() async {
    if (isClosed || state.isDeleting || recordId.isEmpty) return false;

    final String? userId = authRepository.currentUser?.id;
    if (userId == null || userId.isEmpty) return false;

    emit(state.copyWith(isDeleting: true, clearTransientError: true));

    final bool isRemote =
        _remoteAuth.isConfigured && _remoteAuth.currentUser != null;

    try {
      if (isRemote) {
        await _remoteDelete.deleteCaseStudyRemote(caseId: recordId);
      } else {
        await _local.ensureReady();
        final List<CaseStudyRecord> records = await _local.loadRecords(userId);
        final List<CaseStudyRecord> next = records
            .where((final r) => r.id != recordId)
            .toList();
        await _local.saveRecords(userId, next);
        await clipStore.deleteCaseFolder(recordId);
      }
      if (isClosed) return false;
      emit(state.copyWith(isDeleting: false));
      return true;
    } on Object catch (error) {
      if (error is HttpRequestFailure && error.statusCode == 401) {
        try {
          await _remoteAuth.signOut();
        } on Object {
          // Best-effort only; still surface the error to the UI.
        }
      }
      if (isClosed) return false;
      emit(
        state.copyWith(
          isDeleting: false,
          transientError: error,
        ),
      );
      return false;
    }
  }
}
