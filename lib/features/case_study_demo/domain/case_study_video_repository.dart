import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_result.dart';

/// Video pick contract (camera / gallery / lost data), mirroring image flow.
abstract class CaseStudyVideoRepository {
  Future<CameraGalleryResult> pickVideoFromCamera();

  Future<CameraGalleryResult> pickVideoFromGallery();

  /// Android may restore a cancelled pick result; returns null if nothing lost.
  ///
  /// **Video limitation:** `retrieveLostData` may only restore image picks on
  /// some plugin/OS versions; when no file path is available, returns null.
  Future<CameraGalleryResult?> retrieveLostVideo();
}
