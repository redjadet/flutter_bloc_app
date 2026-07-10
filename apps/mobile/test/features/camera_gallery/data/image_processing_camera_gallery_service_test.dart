import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bloc_app/features/camera_gallery/data/image_processing_camera_gallery_service.dart';
import 'package:flutter_bloc_app/features/camera_gallery/data/image_processor.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_result.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/image_processing_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;

void main() {
  group('ImageProcessingCameraGalleryService', () {
    test('original filter returns source path without re-encoding', () async {
      const ImageProcessingCameraGalleryService service =
          ImageProcessingCameraGalleryService();

      final CameraGalleryResult result = await service.process(
        filter: ImageProcessingFilter.original,
        sourcePath: '/tmp/source.jpg',
      );

      expect(result, const CameraGalleryResult.success('/tmp/source.jpg'));
    });

    test('grayscale filter returns jpeg data url from data source', () async {
      final Uint8List png = image.encodePng(
        image.Image(width: 2, height: 1)
          ..setPixelRgb(0, 0, 255, 0, 0)
          ..setPixelRgb(1, 0, 0, 255, 0),
      );
      final String source = 'data:image/png;base64,${base64Encode(png)}';
      const ImageProcessingCameraGalleryService service =
          ImageProcessingCameraGalleryService(processor: ImageProcessor());

      final CameraGalleryResult result = await service.process(
        filter: ImageProcessingFilter.grayscale,
        sourcePath: source,
      );

      result.when(
        success: (final path) {
          expect(path.startsWith('data:image/jpeg;base64,'), isTrue);
          final Uint8List bytes = base64Decode(
            path.substring(path.indexOf(',') + 1),
          );
          expect(image.decodeJpg(bytes), isNotNull);
        },
        cancelled: () => fail('expected success'),
        failure: (final _, final message) => fail('expected success: $message'),
      );
    });
  });
}
