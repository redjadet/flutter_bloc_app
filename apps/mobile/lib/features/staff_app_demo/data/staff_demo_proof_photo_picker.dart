import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_photo_picker.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_pick_memory.dart';
import 'package:flutter_bloc_app/shared/media/media_pick_error_keys.dart';
import 'package:flutter_bloc_app/shared/media/media_pick_result.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerStaffDemoProofPhotoPicker
    implements StaffDemoProofPhotoPicker {
  ImagePickerStaffDemoProofPhotoPicker({final ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  /// Demo guardrail for web gallery picks with empty `path`.
  static const int maxWebPickBytes = 6 * 1024 * 1024;

  final ImagePicker _picker;

  @override
  Future<MediaPickResult> pickFromCamera() async =>
      _pickImage(source: ImageSource.camera, isCamera: true);

  @override
  Future<MediaPickResult> pickFromGallery() async =>
      _pickImage(source: ImageSource.gallery, isCamera: false);

  Future<MediaPickResult> _pickImage({
    required final ImageSource source,
    required final bool isCamera,
  }) async {
    try {
      final XFile? file = await _picker.pickImage(source: source);
      if (file == null) return const MediaPickResult.cancelled();

      final String path = file.path;
      if (path.isEmpty) {
        // Web can return empty `path`. Stage bytes in memory and hand the
        // file store a virtual pick path (no base64 `data:` round-trip).
        final Uint8List bytes = await file.readAsBytes();
        if (bytes.isEmpty) {
          return const MediaPickResult.failure(
            errorKey: MediaPickErrorKeys.generic,
          );
        }
        if (bytes.length > maxWebPickBytes) {
          return const MediaPickResult.failure(
            errorKey: MediaPickErrorKeys.fileTooLarge,
          );
        }

        final String stagedPath = StaffDemoProofPickMemory.instance.stage(
          bytes,
        );
        return MediaPickResult.success(stagedPath);
      }

      return MediaPickResult.success(path);
    } on PlatformException catch (error) {
      return _mapPlatformException(error);
    } on Object catch (error) {
      if (isCamera) {
        return _mapCameraException(error);
      }
      return MediaPickResult.failure(
        errorKey: MediaPickErrorKeys.generic,
        message: error.toString(),
      );
    }
  }

  MediaPickResult _mapPlatformException(final PlatformException error) {
    final String code = error.code.toLowerCase();
    final String message = (error.message ?? '').toLowerCase();

    final bool isPermissionDenied =
        code.contains('permission') ||
        code.contains('access_denied') ||
        code.contains('restricted') ||
        code == 'photo_access_denied' ||
        code == 'camera_access_denied' ||
        message.contains('permission denied') ||
        message.contains('access denied') ||
        message.contains('not allowed') ||
        message.contains('restricted');
    if (isPermissionDenied) {
      return const MediaPickResult.failure(
        errorKey: MediaPickErrorKeys.permissionDenied,
      );
    }

    if (_isCameraUnavailableCodeOrMessage(code, error.message)) {
      return const MediaPickResult.failure(
        errorKey: MediaPickErrorKeys.cameraUnavailable,
      );
    }

    return MediaPickResult.failure(
      errorKey: MediaPickErrorKeys.generic,
      message: error.message,
    );
  }

  static bool _isCameraUnavailableCodeOrMessage(
    final String code,
    final String? message,
  ) {
    final String lowerCode = code.toLowerCase();
    if (lowerCode == 'no_available_camera' ||
        lowerCode == 'camera_not_available' ||
        lowerCode == 'camera_unavailable' ||
        lowerCode.contains('camera_unavailable') ||
        lowerCode.contains('camera_not_available')) {
      return true;
    }

    final String lower = message?.toLowerCase() ?? '';
    return lower.contains('no cameras available') ||
        lower.contains('no camera available') ||
        lower.contains('camera not available') ||
        lower.contains('camera unavailable') ||
        lower.contains('camera is not available') ||
        lower.contains('no camera found');
  }

  MediaPickResult _mapCameraException(final Object error) {
    final String message = error.toString();
    if (_isCameraUnavailableCodeOrMessage('', message)) {
      return const MediaPickResult.failure(
        errorKey: MediaPickErrorKeys.cameraUnavailable,
      );
    }

    return MediaPickResult.failure(
      errorKey: MediaPickErrorKeys.generic,
      message: message,
    );
  }
}
