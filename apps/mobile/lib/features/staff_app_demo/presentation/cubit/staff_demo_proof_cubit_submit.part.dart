part of 'staff_demo_proof_cubit.dart';

mixin _StaffDemoProofCubitSubmit on _StaffDemoProofCubitBase {
  Future<void> submit({
    required String siteId,
    required String? shiftId,
  }) async {
    if (isClosed ||
        _submitInFlight ||
        state.status == StaffDemoProofStatus.submitting) {
      return;
    }
    final userId = _authRepository.currentUser?.id;
    final StaffDemoProofSubmitBlockReason? blockReason =
        StaffDemoProofSubmitEligibility.validateDraft(
          userId: userId,
          siteId: siteId,
          signaturePath: state.signaturePath,
        );
    if (blockReason != null) {
      emit(
        state.copyWith(
          status: StaffDemoProofStatus.error,
          errorMessage: StaffDemoProofSubmitEligibility.messageFor(blockReason),
        ),
      );
      return;
    }

    final String? signaturePath = state.signaturePath?.trim();
    final String? resolvedUserId = userId;
    if (signaturePath == null || resolvedUserId == null) {
      return;
    }
    final photoPaths = List<String>.unmodifiable(state.photoPaths);
    _submitInFlight = true;
    try {
      if (!await _fileStore.fileExists(signaturePath)) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: StaffDemoProofStatus.error,
            errorMessage: 'Signature file missing.',
          ),
        );
        return;
      }

      final photoExistence = await Future.wait<bool>(
        photoPaths.map(_fileStore.fileExists),
      );
      if (photoExistence.contains(false)) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: StaffDemoProofStatus.error,
            errorMessage: 'A photo file is missing locally. Please re-add it.',
          ),
        );
        return;
      }

      if (isClosed) return;
      emit(state.copyWith(status: StaffDemoProofStatus.submitting));
      final proofId = await _repository.submitProof(
        userId: resolvedUserId,
        siteId: siteId.trim(),
        shiftId: shiftId?.trim().isEmpty == true ? null : shiftId?.trim(),
        photoFilePaths: photoPaths,
        signaturePngFilePath: signaturePath,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          status: StaffDemoProofStatus.success,
          errorMessage: null,
          lastProofId: proofId,
        ),
      );
    } on StaffDemoEventProofOfflineEnqueuedException {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: StaffDemoProofStatus.offlineQueued,
          errorMessage: null,
        ),
      );
    } on Object catch (error, stackTrace) {
      await _emitSubmitFailure(error, stackTrace);
    } finally {
      _submitInFlight = false;
    }
  }

  Future<void> _emitSubmitFailure(Object error, StackTrace stackTrace) async {
    if (isClosed) return;
    await CubitExceptionHandler.executeAsync<void>(
      operation: () => Future<void>.error(error, stackTrace),
      isAlive: () => !isClosed,
      onSuccess: (_) {},
      onError: (message) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: StaffDemoProofStatus.error,
            errorMessage: message,
          ),
        );
      },
      logContext: IntegrationLogMessages.staffDemoProofSubmit,
    );
  }
}
