import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_proof_file_store.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_submit_exception.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/proof/staff_demo_proof_state.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';

class StaffDemoProofCubit extends Cubit<StaffDemoProofState> {
  StaffDemoProofCubit({
    required final AuthRepository authRepository,
    required final StaffDemoEventProofRepository repository,
    required final StaffDemoProofFileStore fileStore,
  }) : _authRepository = authRepository,
       _repository = repository,
       _fileStore = fileStore,
       super(const StaffDemoProofState(status: StaffDemoProofStatus.editing));

  final AuthRepository _authRepository;
  final StaffDemoEventProofRepository _repository;
  final StaffDemoProofFileStore _fileStore;

  void setPhotos(final List<String> paths) {
    emit(state.copyWith(photoPaths: List<String>.from(paths)));
  }

  void addPhoto(final String path) {
    emit(state.copyWith(photoPaths: <String>[...state.photoPaths, path]));
  }

  Future<void> addPhotoFromPath(final String sourcePath) async {
    final String persisted = await _fileStore.persistPhotoFile(
      sourcePath: sourcePath,
    );
    if (isClosed) return;
    emit(state.copyWith(photoPaths: <String>[...state.photoPaths, persisted]));
  }

  void removePhotoAt(final int index) {
    final updated = List<String>.from(state.photoPaths);
    if (index < 0 || index >= updated.length) return;
    updated.removeAt(index);
    emit(state.copyWith(photoPaths: updated));
  }

  void setSignaturePath(final String? path) {
    emit(state.copyWith(signaturePath: path));
  }

  Future<void> saveSignaturePngBytes(final List<int> bytes) async {
    final String persisted = await _fileStore.persistSignaturePngBytes(
      bytes: bytes,
    );
    if (isClosed) return;
    emit(state.copyWith(signaturePath: persisted));
  }

  Future<void> submit({
    required final String siteId,
    required final String? shiftId,
  }) async {
    if (state.status == StaffDemoProofStatus.submitting) {
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
    if (!File(signaturePath).existsSync()) {
      emit(
        state.copyWith(
          status: StaffDemoProofStatus.error,
          errorMessage: 'Signature file missing.',
        ),
      );
      return;
    }

    for (final path in state.photoPaths) {
      if (!File(path).existsSync()) {
        emit(
          state.copyWith(
            status: StaffDemoProofStatus.error,
            errorMessage: 'A photo file is missing locally. Please re-add it.',
          ),
        );
        return;
      }
    }

    emit(state.copyWith(status: StaffDemoProofStatus.submitting));
    try {
      final proofId = await _repository.submitProof(
        userId: userId,
        siteId: siteId.trim(),
        shiftId: shiftId?.trim().isEmpty == true ? null : shiftId?.trim(),
        photoFilePaths: state.photoPaths,
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
        logContext: 'StaffDemoProofCubit.submit',
      );
    }
  }
}
