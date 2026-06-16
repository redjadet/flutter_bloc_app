import 'package:flutter_bloc_app/shared/media/media_pick_result.dart';

/// Picks proof photos without exposing plugin types to presentation.
abstract class StaffDemoProofPhotoPicker {
  Future<MediaPickResult> pickFromCamera();

  Future<MediaPickResult> pickFromGallery();
}
