import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/camera_gallery/data/image_picker_camera_gallery_repository.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_error_keys.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_result.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockImagePicker extends Mock implements ImagePicker {}

void main() {
  group('ImagePickerCameraGalleryRepository', () {
    late _MockImagePicker picker;
    late ImagePickerCameraGalleryRepository repository;

    setUp(() {
      picker = _MockImagePicker();
      repository = ImagePickerCameraGalleryRepository(
        picker: picker,
        isAndroid: () => true,
      );
    });

    test(
      'maps no available camera to cameraUnavailable for camera pick',
      () async {
        when(() => picker.pickImage(source: ImageSource.camera)).thenThrow(
          PlatformException(
            code: 'no_available_camera',
            message: 'No cameras available',
          ),
        );

        final CameraGalleryResult result = await repository.pickFromCamera();

        expect(
          result,
          const CameraGalleryResult.failure(
            errorKey: CameraGalleryErrorKeys.cameraUnavailable,
          ),
        );
      },
    );

    test('maps camera_not_available code to cameraUnavailable', () async {
      when(() => picker.pickImage(source: ImageSource.camera)).thenThrow(
        PlatformException(
          code: 'camera_not_available',
          message: 'Camera is not available',
        ),
      );

      final CameraGalleryResult result = await repository.pickFromCamera();

      expect(
        result,
        const CameraGalleryResult.failure(
          errorKey: CameraGalleryErrorKeys.cameraUnavailable,
        ),
      );
    });

    test('maps denied camera permission to permissionDenied key', () async {
      when(() => picker.pickImage(source: ImageSource.camera)).thenThrow(
        PlatformException(
          code: 'camera_access_denied',
          message: 'The user did not allow camera access.',
        ),
      );

      final CameraGalleryResult result = await repository.pickFromCamera();

      expect(
        result,
        const CameraGalleryResult.failure(
          errorKey: CameraGalleryErrorKeys.permissionDenied,
        ),
      );
    });

    test(
      'maps no-camera generic exception text to cameraUnavailable',
      () async {
        when(
          () => picker.pickImage(source: ImageSource.camera),
        ).thenThrow(Exception('Camera is not available on this simulator'));

        final CameraGalleryResult result = await repository.pickFromCamera();

        expect(
          result,
          const CameraGalleryResult.failure(
            errorKey: CameraGalleryErrorKeys.cameraUnavailable,
          ),
        );
      },
    );

    test('returns cancelled when gallery pick returns null', () async {
      when(
        () => picker.pickImage(source: ImageSource.gallery),
      ).thenAnswer((_) async => null);

      final CameraGalleryResult result = await repository.pickFromGallery();

      expect(result, const CameraGalleryResult.cancelled());
    });

    test(
      'retrieveLostImage returns recovered image path when available',
      () async {
        when(() => picker.retrieveLostData()).thenAnswer(
          (_) async => LostDataResponse(file: XFile('/tmp/recovered.jpg')),
        );

        final CameraGalleryResult? result = await repository
            .retrieveLostImage();

        expect(result, const CameraGalleryResult.success('/tmp/recovered.jpg'));
      },
    );

    test(
      'retrieveLostImage maps lost-data platform exception to cameraUnavailable',
      () async {
        when(() => picker.retrieveLostData()).thenAnswer(
          (_) async => LostDataResponse(
            exception: PlatformException(
              code: 'camera_not_available',
              message: 'Camera is not available',
            ),
          ),
        );

        final CameraGalleryResult? result = await repository
            .retrieveLostImage();

        expect(
          result,
          const CameraGalleryResult.failure(
            errorKey: CameraGalleryErrorKeys.cameraUnavailable,
          ),
        );
      },
    );

    test(
      'retrieveLostImage returns generic failure when retrieveLostData throws',
      () async {
        when(() => picker.retrieveLostData()).thenThrow(Exception('boom'));

        final CameraGalleryResult? result = await repository
            .retrieveLostImage();

        expect(result, isA<CameraGalleryResult>());
        expect(
          result,
          const CameraGalleryResult.failure(
            errorKey: CameraGalleryErrorKeys.generic,
            message: 'Exception: boom',
          ),
        );
      },
    );

    test(
      'retrieveLostImage returns null when platform is not Android',
      () async {
        final nonAndroidRepository = ImagePickerCameraGalleryRepository(
          picker: picker,
          isAndroid: () => false,
        );

        final CameraGalleryResult? result = await nonAndroidRepository
            .retrieveLostImage();

        expect(result, isNull);
        verifyNever(() => picker.retrieveLostData());
      },
    );
  });
}
