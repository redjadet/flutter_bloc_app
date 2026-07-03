import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_error_keys.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_failure_mapper.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';

void main() {
  group('failureFromCameraGalleryResult', () {
    test('returns null for success', () {
      const result = CameraGalleryResult.success('/tmp/photo.jpg');

      expect(failureFromCameraGalleryResult(result), isNull);
    });

    test('maps permissionDenied to PermissionFailure', () {
      const result = CameraGalleryResult.failure(
        errorKey: CameraGalleryErrorKeys.permissionDenied,
      );

      final failure = failureFromCameraGalleryResult(result);

      expect(failure, isA<PermissionFailure>());
    });

    test('maps cameraUnavailable to PlatformFailure', () {
      const result = CameraGalleryResult.failure(
        errorKey: CameraGalleryErrorKeys.cameraUnavailable,
      );

      final failure = failureFromCameraGalleryResult(result);

      expect(failure, isA<PlatformFailure>());
    });
  });

  group('failureFromCameraGalleryErrorKey', () {
    test('returns null for cancelled (user intent, not failure)', () {
      final failure = failureFromCameraGalleryErrorKey(
        CameraGalleryErrorKeys.cancelled,
      );

      expect(failure, isNull);
    });
  });
}
