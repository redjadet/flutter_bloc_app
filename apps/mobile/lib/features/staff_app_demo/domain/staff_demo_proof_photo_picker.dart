import 'package:app_shared_flutter/app_shared_flutter.dart'
    show MediaPickResult;

/// Picks proof photos without exposing plugin types to presentation.
abstract class StaffDemoProofPhotoPicker {
  Future<MediaPickResult> pickFromCamera();

  Future<MediaPickResult> pickFromGallery();
}
