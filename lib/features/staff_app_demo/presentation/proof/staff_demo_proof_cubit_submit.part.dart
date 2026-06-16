part of 'staff_demo_proof_cubit.dart';

mixin _StaffDemoProofCubitSubmit on _StaffDemoProofCubitBase {
  Future<void> submit({
    required final String siteId,
    required final String? shiftId,
  }) async {
    if (_submitInFlight || state.status == StaffDemoProofStatus.submitting) {
      return;
    }
    final userId = _authRepository.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      emit(
        state.copyWith(
          status: StaffDemoProofStatus.error,
          errorMessage: 'Not signed in.',
        ),
      );
      return;
    }
    if (siteId.trim().isEmpty) {
      emit(
        state.copyWith(
          status: StaffDemoProofStatus.error,
          errorMessage: 'Site ID is required.',
        ),
      );
      return;
    }
    final signaturePath = state.signaturePath;
    if (signaturePath == null || signaturePath.isEmpty) {
      emit(
        state.copyWith(
          status: StaffDemoProofStatus.error,
          errorMessage: 'Signature is required.',
        ),
      );
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
      try {
        final proofId = await _repository.submitProof(
          userId: userId,
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
      } on Exception catch (error, stackTrace) {
        if (isClosed) return;
        await CubitExceptionHandler.executeAsync<void>(
          operation: () => Future<void>.error(error, stackTrace),
          isAlive: () => !isClosed,
          onSuccess: (_) {},
          onError: (final message) {
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
    } finally {
      _submitInFlight = false;
    }
  }
}
