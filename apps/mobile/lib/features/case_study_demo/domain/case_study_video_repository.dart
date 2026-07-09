import 'package:app_shared_flutter/app_shared_flutter.dart'
    show MediaPickResult;

/// Video pick contract (camera / gallery / lost data), mirroring image flow.
abstract class CaseStudyVideoRepository {
  Future<MediaPickResult> pickVideoFromCamera();

  Future<MediaPickResult> pickVideoFromGallery();

  /// Android may restore a cancelled pick result; returns null if nothing lost.
  ///
  /// **Video limitation:** `retrieveLostData` may only restore image picks on
  /// some plugin/OS versions; when no file path is available, returns null.
  Future<MediaPickResult?> retrieveLostVideo();
}
