import 'dart:typed_data';

import 'package:flutter_bloc_app/features/camera_gallery/data/image_processor.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/image_processing_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;

void main() {
  const ImageProcessor processor = ImageProcessor();

  test('grayscale processing encodes a grayscale JPEG preview', () {
    final image.Image source = image.Image(width: 2, height: 1)
      ..setPixelRgb(0, 0, 255, 0, 0)
      ..setPixelRgb(1, 0, 0, 255, 0);

    final image.Image decoded = image.decodeJpg(
      processor.process(
        sourceBytes: image.encodePng(source),
        filter: ImageProcessingFilter.grayscale,
      ),
    )!;
    final image.Pixel pixel = decoded.getPixel(0, 0);

    expect(pixel.r, closeTo(pixel.g, 3));
    expect(pixel.g, closeTo(pixel.b, 3));
  });

  test('processing bounds oversized source width for mobile preview', () {
    final image.Image source = image.Image(width: 1400, height: 2);

    final image.Image decoded = image.decodeJpg(
      processor.process(
        sourceBytes: image.encodePng(source),
        filter: ImageProcessingFilter.original,
      ),
    )!;

    expect(decoded.width, ImageProcessor.maxPreviewWidth);
  });

  test('processing bounds oversized source height for mobile preview', () {
    final image.Image source = image.Image(width: 2, height: 1400);

    final image.Image decoded = image.decodeJpg(
      processor.process(
        sourceBytes: image.encodePng(source),
        filter: ImageProcessingFilter.original,
      ),
    )!;

    expect(decoded.height, ImageProcessor.maxPreviewHeight);
  });

  test('original filter still encodes when called directly on processor', () {
    final image.Image source = image.Image(width: 4, height: 2)
      ..setPixelRgb(0, 0, 10, 20, 30);

    final Uint8List bytes = processor.process(
      sourceBytes: image.encodePng(source),
      filter: ImageProcessingFilter.original,
    );

    expect(image.decodeJpg(bytes), isNotNull);
  });
}
