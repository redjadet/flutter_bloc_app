/// Abstraction for capturing or picking an image for dispersion groups.
/// Returns a stable file path under the app's dispersion image directory,
/// or null if the user cancelled or an error occurred.
abstract class ImageImportService {
  /// Picks an image from the device camera. Returns path or null.
  Future<String?> pickFromCamera();

  /// Picks an image from the device gallery. Returns path or null.
  Future<String?> pickFromGallery();

  /// Loads a built-in test image into the app directory and returns its path.
  /// For manual testing without camera/gallery. Returns null on failure.
  Future<String?> loadTestImage();
}
