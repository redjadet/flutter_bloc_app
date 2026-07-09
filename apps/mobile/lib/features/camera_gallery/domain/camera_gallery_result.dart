import 'package:app_shared_flutter/app_shared_flutter.dart'
    show MediaPickResult;

export 'package:app_shared_flutter/app_shared_flutter.dart'
    show MediaPickResult, MediaPickResultPatterns;

/// Back-compat alias for [MediaPickResult] used by the camera_gallery feature.
typedef CameraGalleryResult = MediaPickResult;
