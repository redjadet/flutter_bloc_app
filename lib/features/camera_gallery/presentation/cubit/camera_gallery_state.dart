import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'camera_gallery_state.freezed.dart';

@freezed
abstract class CameraGalleryState with _$CameraGalleryState {
  const factory CameraGalleryState({
    @Default(ViewStatus.initial) final ViewStatus status,
    final String? imagePath,

    /// L10n key for user-visible error (e.g. cameraGalleryPermissionDenied).
    final String? errorKey,
  }) = _CameraGalleryState;

  const CameraGalleryState._();

  bool get isLoading => status.isLoading;
  bool get hasError => status.isError;
  bool get hasImage => imagePath?.isNotEmpty ?? false;
}
