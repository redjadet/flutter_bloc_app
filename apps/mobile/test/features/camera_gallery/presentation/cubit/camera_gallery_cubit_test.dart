import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_error_keys.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_repository.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_result.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/image_processing_filter.dart';
import 'package:flutter_bloc_app/features/camera_gallery/presentation/cubit/camera_gallery_cubit.dart';
import 'package:flutter_bloc_app/features/camera_gallery/presentation/cubit/camera_gallery_state.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubCameraGalleryRepository implements CameraGalleryRepository {
  const _StubCameraGalleryRepository({
    this.pickFromCameraResult,
    this.pickFromGalleryResult,
    this.retrieveLostImageResult,
    this.processImageResult,
    this.throwOnRetrieveLostImage = false,
  });

  final CameraGalleryResult? pickFromCameraResult;
  final CameraGalleryResult? pickFromGalleryResult;
  final CameraGalleryResult? retrieveLostImageResult;
  final CameraGalleryResult? processImageResult;
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

  @override
  Future<CameraGalleryResult> processImage({
    required final ImageProcessingFilter filter,
    required final String sourcePath,
  }) async => processImageResult ?? const CameraGalleryResult.cancelled();
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
          sourceImagePath: '/tmp/photo.jpg',
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
          sourceImagePath: '/tmp/picked.jpg',
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
        sourceImagePath: '/tmp/photo.jpg',
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
          sourceImagePath: '/tmp/recovered.jpg',
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

    blocTest<CameraGalleryCubit, CameraGalleryState>(
      'applyFilter emits processed image while retaining original source',
      build: () => CameraGalleryCubit(
        repository: _StubCameraGalleryRepository(
          processImageResult: const CameraGalleryResult.success(
            'data:image/jpeg;base64,processed',
          ),
        ),
      ),
      seed: () => const CameraGalleryState(
        status: ViewStatus.success,
        sourceImagePath: '/tmp/original.jpg',
        imagePath: '/tmp/original.jpg',
      ),
      act: (final cubit) => cubit.applyFilter(ImageProcessingFilter.sepia),
      expect: () => <CameraGalleryState>[
        const CameraGalleryState(
          status: ViewStatus.loading,
          sourceImagePath: '/tmp/original.jpg',
          imagePath: '/tmp/original.jpg',
        ),
        const CameraGalleryState(
          status: ViewStatus.success,
          sourceImagePath: '/tmp/original.jpg',
          imagePath: 'data:image/jpeg;base64,processed',
          selectedFilter: ImageProcessingFilter.sepia,
        ),
      ],
    );

    blocTest<CameraGalleryCubit, CameraGalleryState>(
      'applyFilter cancelled keeps source selection',
      build: () => CameraGalleryCubit(
        repository: const _StubCameraGalleryRepository(
          processImageResult: CameraGalleryResult.cancelled(),
        ),
      ),
      seed: () => const CameraGalleryState(
        status: ViewStatus.success,
        sourceImagePath: '/tmp/original.jpg',
        imagePath: '/tmp/original.jpg',
        selectedFilter: ImageProcessingFilter.grayscale,
      ),
      act: (final cubit) => cubit.applyFilter(ImageProcessingFilter.invert),
      expect: () => <CameraGalleryState>[
        const CameraGalleryState(
          status: ViewStatus.loading,
          sourceImagePath: '/tmp/original.jpg',
          imagePath: '/tmp/original.jpg',
          selectedFilter: ImageProcessingFilter.grayscale,
        ),
        const CameraGalleryState(
          status: ViewStatus.success,
          sourceImagePath: '/tmp/original.jpg',
          imagePath: '/tmp/original.jpg',
          selectedFilter: ImageProcessingFilter.grayscale,
        ),
      ],
    );

    blocTest<CameraGalleryCubit, CameraGalleryState>(
      'applyFilter failure keeps source and surfaces error',
      build: () => CameraGalleryCubit(
        repository: const _StubCameraGalleryRepository(
          processImageResult: CameraGalleryResult.failure(
            errorKey: CameraGalleryErrorKeys.generic,
          ),
        ),
      ),
      seed: () => const CameraGalleryState(
        status: ViewStatus.success,
        sourceImagePath: '/tmp/original.jpg',
        imagePath: '/tmp/original.jpg',
      ),
      act: (final cubit) => cubit.applyFilter(ImageProcessingFilter.sepia),
      expect: () => <CameraGalleryState>[
        const CameraGalleryState(
          status: ViewStatus.loading,
          sourceImagePath: '/tmp/original.jpg',
          imagePath: '/tmp/original.jpg',
        ),
        const CameraGalleryState(
          status: ViewStatus.error,
          sourceImagePath: '/tmp/original.jpg',
          imagePath: '/tmp/original.jpg',
          errorKey: CameraGalleryErrorKeys.generic,
        ),
      ],
    );
  });
}
