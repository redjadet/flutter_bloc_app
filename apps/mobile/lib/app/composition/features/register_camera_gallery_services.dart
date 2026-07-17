import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/features/camera_gallery/data/image_picker_camera_gallery_repository.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_repository.dart';

/// Registers camera/gallery repository.
void registerCameraGalleryServices() {
  registerLazySingletonIfAbsent<CameraGalleryRepository>(
    ImagePickerCameraGalleryRepository.new,
  );
}
