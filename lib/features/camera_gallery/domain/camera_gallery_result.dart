import 'package:freezed_annotation/freezed_annotation.dart';

part 'camera_gallery_result.freezed.dart';

/// Result of a camera or gallery pick operation.
///
/// Keeps permission and plugin-specific details out of the UI layer.
@freezed
sealed class CameraGalleryResult with _$CameraGalleryResult {
  const CameraGalleryResult._();

  /// User took or selected a photo; [imagePath] is the temporary file path.
  const factory CameraGalleryResult.success(final String imagePath) =
      _CameraGalleryResultSuccess;

  /// User cancelled the picker (no photo selected).
  const factory CameraGalleryResult.cancelled() = _CameraGalleryResultCancelled;

  /// Operation failed; [errorKey] is an l10n key for user-facing message.
  const factory CameraGalleryResult.failure({
    required final String errorKey,
    final String? message,
  }) = _CameraGalleryResultFailure;
}
