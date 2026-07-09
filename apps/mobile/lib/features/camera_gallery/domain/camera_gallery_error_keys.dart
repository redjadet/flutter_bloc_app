import 'package:app_shared_flutter/app_shared_flutter.dart'
    show MediaPickErrorKeys;

export 'package:app_shared_flutter/app_shared_flutter.dart'
    show MediaPickErrorKeys;

/// Back-compat shim for [MediaPickErrorKeys] used by the camera_gallery feature.
abstract final class CameraGalleryErrorKeys {
  CameraGalleryErrorKeys._();

  static const String permissionDenied = MediaPickErrorKeys.permissionDenied;
  static const String cameraUnavailable = MediaPickErrorKeys.cameraUnavailable;
  static const String cancelled = MediaPickErrorKeys.cancelled;
  static const String generic = MediaPickErrorKeys.generic;
}
