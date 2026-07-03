import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_result.dart';

/// Contract for picking an image from camera or gallery.
///
/// Implementations use platform plugins (e.g. image_picker); domain stays
/// Flutter-agnostic.
abstract interface class CameraGalleryRepository {
  /// Picks an image from the device camera.
  /// Returns [CameraGalleryResult.success] with path, [CameraGalleryResult.cancelled],
  /// or [CameraGalleryResult.failure] with an error key.
  Future<CameraGalleryResult> pickFromCamera();

  /// Picks an image from the photo library / gallery.
  Future<CameraGalleryResult> pickFromGallery();

  /// Recovers image picker data if the app was killed after picking (Android).
  /// Returns null if there is no lost data to recover.
  Future<CameraGalleryResult?> retrieveLostImage();
}
