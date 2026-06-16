import 'package:flutter_bloc_app/core/domain/failure.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_error_keys.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_result.dart';

/// Maps [CameraGalleryResult] failure keys to domain [Failure] for Cubits.
Failure? failureFromCameraGalleryResult(final CameraGalleryResult result) =>
    result.whenOrNull(
      failure: (errorKey, message) =>
          failureFromCameraGalleryErrorKey(errorKey, message: message),
    );

Failure? failureFromCameraGalleryErrorKey(
  final String errorKey, {
  final String? message,
}) {
  return switch (errorKey) {
    CameraGalleryErrorKeys.permissionDenied => PermissionFailure(
      PermissionFailureReason.denied,
      cause: message,
    ),
    CameraGalleryErrorKeys.cameraUnavailable => PlatformFailure(
      PlatformFailureReason.unavailable,
      cause: message,
    ),
    CameraGalleryErrorKeys.cancelled => null,
    CameraGalleryErrorKeys.generic ||
    _ => UnknownFailure(message: message ?? errorKey),
  };
}
