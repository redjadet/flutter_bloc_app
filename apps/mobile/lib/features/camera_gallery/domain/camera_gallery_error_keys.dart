import 'package:flutter_bloc_app/shared/media/media_pick_error_keys.dart';

export 'package:flutter_bloc_app/shared/media/media_pick_error_keys.dart'
    show MediaPickErrorKeys;

/// Back-compat shim for [MediaPickErrorKeys] used by the camera_gallery feature.
abstract final class CameraGalleryErrorKeys {
  CameraGalleryErrorKeys._();

  static const String permissionDenied = MediaPickErrorKeys.permissionDenied;
  static const String cameraUnavailable = MediaPickErrorKeys.cameraUnavailable;
  static const String cancelled = MediaPickErrorKeys.cancelled;
  static const String generic = MediaPickErrorKeys.generic;
}
