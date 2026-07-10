import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/image_processing_filter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'camera_gallery_state.freezed.dart';

@freezed
abstract class CameraGalleryState with _$CameraGalleryState {
  const factory CameraGalleryState({
    @Default(ViewStatus.initial) final ViewStatus status,
    final String? sourceImagePath,
    final String? imagePath,
    @Default(ImageProcessingFilter.original)
    final ImageProcessingFilter selectedFilter,

    /// L10n key for user-visible error (e.g. cameraGalleryPermissionDenied).
    final String? errorKey,
  }) = _CameraGalleryState;

  const CameraGalleryState._();

  bool get isLoading => status.isLoading;
  bool get hasError => status.isError;
  bool get hasImage => imagePath?.isNotEmpty ?? false;
  bool get canProcess => sourceImagePath?.isNotEmpty ?? false;
}
