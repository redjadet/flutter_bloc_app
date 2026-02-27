import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_error_keys.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_repository.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_result.dart';
import 'package:flutter_bloc_app/features/camera_gallery/presentation/cubit/camera_gallery_cubit.dart';
import 'package:flutter_bloc_app/features/camera_gallery/presentation/cubit/camera_gallery_state.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubCameraGalleryRepository implements CameraGalleryRepository {
  _StubCameraGalleryRepository({
    this.pickFromCameraResult,
    this.pickFromGalleryResult,
    this.retrieveLostImageResult,
    this.throwOnRetrieveLostImage = false,
  });

  final CameraGalleryResult? pickFromCameraResult;
  final CameraGalleryResult? pickFromGalleryResult;
  final CameraGalleryResult? retrieveLostImageResult;
  final bool throwOnRetrieveLostImage;

  @override
  Future<CameraGalleryResult> pickFromCamera() async =>
      pickFromCameraResult ?? const CameraGalleryResult.cancelled();

  @override
  Future<CameraGalleryResult> pickFromGallery() async =>
      pickFromGalleryResult ?? const CameraGalleryResult.cancelled();

  @override
  Future<CameraGalleryResult?> retrieveLostImage() async {
    if (throwOnRetrieveLostImage) {
      throw Exception('retrieveLostImage failed');
    }
    return retrieveLostImageResult;
  }
}

void main() {
  group('CameraGalleryCubit', () {
    blocTest<CameraGalleryCubit, CameraGalleryState>(
      'pickFromCamera emits loading then success with path',
      build: () => CameraGalleryCubit(
        repository: _StubCameraGalleryRepository(
          pickFromCameraResult: CameraGalleryResult.success('/tmp/photo.jpg'),
        ),
      ),
      act: (final cubit) => cubit.pickFromCamera(),
      expect: () => <CameraGalleryState>[
        const CameraGalleryState(status: ViewStatus.loading, errorKey: null),
        const CameraGalleryState(
          status: ViewStatus.success,
          imagePath: '/tmp/photo.jpg',
          errorKey: null,
        ),
      ],
    );

    blocTest<CameraGalleryCubit, CameraGalleryState>(
      'pickFromGallery emits loading then success with path',
      build: () => CameraGalleryCubit(
        repository: _StubCameraGalleryRepository(
          pickFromGalleryResult: CameraGalleryResult.success('/tmp/picked.jpg'),
        ),
      ),
      act: (final cubit) => cubit.pickFromGallery(),
      expect: () => <CameraGalleryState>[
        const CameraGalleryState(status: ViewStatus.loading, errorKey: null),
        const CameraGalleryState(
          status: ViewStatus.success,
          imagePath: '/tmp/picked.jpg',
          errorKey: null,
        ),
      ],
    );

    blocTest<CameraGalleryCubit, CameraGalleryState>(
      'pickFromCamera cancelled emits loading then initial',
      build: () => CameraGalleryCubit(
        repository: _StubCameraGalleryRepository(
          pickFromCameraResult: const CameraGalleryResult.cancelled(),
        ),
      ),
      act: (final cubit) => cubit.pickFromCamera(),
      expect: () => <CameraGalleryState>[
        const CameraGalleryState(status: ViewStatus.loading, errorKey: null),
        const CameraGalleryState(status: ViewStatus.initial, errorKey: null),
      ],
    );

    blocTest<CameraGalleryCubit, CameraGalleryState>(
      'pickFromCamera failure emits loading then error with errorKey',
      build: () => CameraGalleryCubit(
        repository: _StubCameraGalleryRepository(
          pickFromCameraResult: const CameraGalleryResult.failure(
            errorKey: 'cameraGalleryPermissionDenied',
          ),
        ),
      ),
      act: (final cubit) => cubit.pickFromCamera(),
      expect: () => <CameraGalleryState>[
        const CameraGalleryState(status: ViewStatus.loading, errorKey: null),
        const CameraGalleryState(
          status: ViewStatus.error,
          errorKey: 'cameraGalleryPermissionDenied',
        ),
      ],
    );

    blocTest<CameraGalleryCubit, CameraGalleryState>(
      'pickFromCamera cameraUnavailable emits error with cameraUnavailable key',
      build: () => CameraGalleryCubit(
        repository: _StubCameraGalleryRepository(
          pickFromCameraResult: const CameraGalleryResult.failure(
            errorKey: 'cameraGalleryCameraUnavailable',
          ),
        ),
      ),
      act: (final cubit) => cubit.pickFromCamera(),
      expect: () => <CameraGalleryState>[
        const CameraGalleryState(status: ViewStatus.loading, errorKey: null),
        const CameraGalleryState(
          status: ViewStatus.error,
          errorKey: 'cameraGalleryCameraUnavailable',
        ),
      ],
    );

    blocTest<CameraGalleryCubit, CameraGalleryState>(
      'clearSelection emits initial state',
      build: () => CameraGalleryCubit(
        repository: _StubCameraGalleryRepository(
          pickFromCameraResult: CameraGalleryResult.success('/tmp/photo.jpg'),
        ),
      ),
      seed: () => const CameraGalleryState(
        status: ViewStatus.success,
        imagePath: '/tmp/photo.jpg',
      ),
      act: (final cubit) => cubit.clearSelection(),
      expect: () => <CameraGalleryState>[const CameraGalleryState()],
    );

    blocTest<CameraGalleryCubit, CameraGalleryState>(
      'initialize applies recovered image when lost picker data exists',
      build: () => CameraGalleryCubit(
        repository: _StubCameraGalleryRepository(
          retrieveLostImageResult: const CameraGalleryResult.success(
            '/tmp/recovered.jpg',
          ),
        ),
      ),
      act: (final cubit) => cubit.initialize(),
      expect: () => <CameraGalleryState>[
        const CameraGalleryState(
          status: ViewStatus.success,
          imagePath: '/tmp/recovered.jpg',
          errorKey: null,
        ),
      ],
    );

    blocTest<CameraGalleryCubit, CameraGalleryState>(
      'initialize maps retrieve errors to generic error state without crash',
      build: () => CameraGalleryCubit(
        repository: _StubCameraGalleryRepository(
          throwOnRetrieveLostImage: true,
        ),
      ),
      act: (final cubit) => cubit.initialize(),
      expect: () => <CameraGalleryState>[
        const CameraGalleryState(
          status: ViewStatus.error,
          errorKey: CameraGalleryErrorKeys.generic,
        ),
      ],
    );
  });
}
