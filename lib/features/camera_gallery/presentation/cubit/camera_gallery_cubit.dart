import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_error_keys.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_repository.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_result.dart';
import 'package:flutter_bloc_app/features/camera_gallery/presentation/cubit/camera_gallery_state.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/request_id_guard.dart';

/// Cubit for the Camera & Gallery demo: pick from camera/gallery and show preview.
class CameraGalleryCubit extends Cubit<CameraGalleryState> {
  CameraGalleryCubit({required final CameraGalleryRepository repository})
    : _repository = repository,
      super(const CameraGalleryState());

  final CameraGalleryRepository _repository;
  final RequestIdGuard _pickGuard = RequestIdGuard();

  /// Call once when the page opens to recover lost picker data on Android.
  Future<void> initialize() async {
    if (isClosed) return;
    await CubitExceptionHandler.executeAsync<CameraGalleryResult?>(
      operation: _repository.retrieveLostImage,
      isAlive: () => !isClosed,
      onSuccess: (final recovered) {
        if (isClosed || recovered == null) return;
        _applyPickResult(recovered);
      },
      onError: (_) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: ViewStatus.error,
            errorKey: CameraGalleryErrorKeys.generic,
          ),
        );
      },
      logContext: 'CameraGalleryCubit.initialize',
    );
  }

  void _emitLoading() {
    if (isClosed) return;
    emit(
      state.copyWith(
        status: ViewStatus.loading,
        errorKey: null,
      ),
    );
  }

  void _applyPickResult(final CameraGalleryResult result) {
    if (isClosed) return;
    result.when(
      success: (final path) {
        emit(
          state.copyWith(
            status: ViewStatus.success,
            imagePath: path,
            errorKey: null,
          ),
        );
      },
      cancelled: () {
        emit(
          state.copyWith(
            status: ViewStatus.initial,
            errorKey: null,
          ),
        );
      },
      failure: (final errorKey, final _) {
        emit(
          state.copyWith(
            status: ViewStatus.error,
            errorKey: errorKey,
          ),
        );
      },
    );
  }

  Future<void> pickFromCamera() async {
    if (isClosed) return;
    final int requestId = _pickGuard.next();
    _emitLoading();
    try {
      final CameraGalleryResult result = await _repository.pickFromCamera();
      if (isClosed || !_pickGuard.isCurrent(requestId)) return;
      _applyPickResult(result);
    } on Object catch (error, stackTrace) {
      AppLogger.error('CameraGalleryCubit.pickFromCamera', error, stackTrace);
      if (isClosed || !_pickGuard.isCurrent(requestId)) return;
      emit(
        state.copyWith(
          status: ViewStatus.error,
          errorKey: CameraGalleryErrorKeys.generic,
        ),
      );
    }
  }

  Future<void> pickFromGallery() async {
    if (isClosed) return;
    final int requestId = _pickGuard.next();
    _emitLoading();
    try {
      final CameraGalleryResult result = await _repository.pickFromGallery();
      if (isClosed || !_pickGuard.isCurrent(requestId)) return;
      _applyPickResult(result);
    } on Object catch (error, stackTrace) {
      AppLogger.error('CameraGalleryCubit.pickFromGallery', error, stackTrace);
      if (isClosed || !_pickGuard.isCurrent(requestId)) return;
      emit(
        state.copyWith(
          status: ViewStatus.error,
          errorKey: CameraGalleryErrorKeys.generic,
        ),
      );
    }
  }

  void clearSelection() {
    if (isClosed) return;
    emit(const CameraGalleryState());
  }
}
