import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_submit_exception.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_file_store.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_photo_picker.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_pick_memory.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/proof/staff_demo_proof_state.dart';
import 'package:flutter_bloc_app/shared/diagnostics/integration_log_messages.dart';
import 'package:flutter_bloc_app/shared/media/media_pick_error_keys.dart';
import 'package:flutter_bloc_app/shared/media/media_pick_result.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';

part 'staff_demo_proof_cubit_submit.part.dart';

class StaffDemoProofCubit extends _StaffDemoProofCubitBase
    with _StaffDemoProofCubitSubmit {
  StaffDemoProofCubit({
    required super.authRepository,
    required super.repository,
    required super.fileStore,
    required super.photoPicker,
  });
}

abstract class _StaffDemoProofCubitBase extends Cubit<StaffDemoProofState> {
  _StaffDemoProofCubitBase({
    required this._authRepository,
    required this._repository,
    required this._fileStore,
    required this._photoPicker,
  }) : super(const StaffDemoProofState(status: StaffDemoProofStatus.editing));

  final AuthRepository _authRepository;
  final StaffDemoEventProofRepository _repository;
  final StaffDemoProofFileStore _fileStore;
  final StaffDemoProofPhotoPicker _photoPicker;
  bool _submitInFlight = false;
  bool _pickInFlight = false;
  bool _isClosing = false;
  String? _pendingStagedPickPath;
  Future<void>? _activePersistOperation;

  @override
  Future<void> close() async {
    _isClosing = true;
    final Future<void>? persist = _activePersistOperation;
    if (persist != null) {
      try {
        await persist;
      } on Object {
        // Cubit is closing; swallow persist errors.
      }
    }
    _releasePendingStagedPick();
    await super.close();
  }

  void setPhotos(final List<String> paths) {
    emit(state.copyWith(photoPaths: List<String>.from(paths)));
  }

  void addPhoto(final String path) {
    emit(state.copyWith(photoPaths: <String>[...state.photoPaths, path]));
  }

  Future<void> addPhotoFromPath(final String sourcePath) async {
    final Future<void> operation = _persistPhotoFromPath(sourcePath);
    _activePersistOperation = operation;
    try {
      await operation;
    } finally {
      if (identical(_activePersistOperation, operation)) {
        _activePersistOperation = null;
      }
    }
  }

  Future<void> _persistPhotoFromPath(final String sourcePath) async {
    final String persisted = await _fileStore.persistPhotoFile(
      sourcePath: sourcePath,
    );
    if (isClosed || _isClosing) return;
    emit(state.copyWith(photoPaths: <String>[...state.photoPaths, persisted]));
  }

  /// Returns an l10n error key when pick fails; `null` on success or cancel.
  Future<String?> pickPhotoFromCamera() =>
      _pickPhoto(_photoPicker.pickFromCamera);

  /// Returns an l10n error key when pick fails; `null` on success or cancel.
  Future<String?> pickPhotoFromGallery() =>
      _pickPhoto(_photoPicker.pickFromGallery);

  Future<String?> _pickPhoto(
    final Future<MediaPickResult> Function() pick,
  ) async {
    if (_pickInFlight) {
      return null;
    }
    _pickInFlight = true;
    try {
      return await _pickPhotoBody(pick);
    } finally {
      _pickInFlight = false;
    }
  }

  Future<String?> _pickPhotoBody(
    final Future<MediaPickResult> Function() pick,
  ) async {
    final MediaPickResult result = await pick();
    if (isClosed || _isClosing) {
      _releaseStagedFromResult(result);
      return null;
    }
    return result.when(
      success: (path) async {
        _trackPendingStagedPick(path);
        try {
          await addPhotoFromPath(path);
          _releasePendingStagedPick();
          return null;
        } on Object {
          _releasePendingStagedPick();
          return MediaPickErrorKeys.generic;
        }
      },
      cancelled: () async => null,
      failure: (errorKey, _) async => errorKey,
    );
  }

  void _trackPendingStagedPick(final String path) {
    if (!StaffDemoProofPickMemory.instance.isPickPath(path)) {
      return;
    }
    _releasePendingStagedPick();
    _pendingStagedPickPath = path;
  }

  void _releasePendingStagedPick() {
    final String? path = _pendingStagedPickPath;
    if (path == null) {
      return;
    }
    StaffDemoProofPickMemory.instance.release(path);
    _pendingStagedPickPath = null;
  }

  void _releaseStagedFromResult(final MediaPickResult result) {
    result.when(
      success: (path) {
        if (StaffDemoProofPickMemory.instance.isPickPath(path)) {
          StaffDemoProofPickMemory.instance.release(path);
        }
      },
      cancelled: () {},
      failure: (_, _) {},
    );
  }

  void removePhotoAt(final int index) {
    final updated = List<String>.from(state.photoPaths);
    if (index < 0 || index >= updated.length) return;
    final String removed = updated.removeAt(index);
    emit(state.copyWith(photoPaths: updated));
    unawaited(_fileStore.deleteFileAtPath(removed));
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
}
