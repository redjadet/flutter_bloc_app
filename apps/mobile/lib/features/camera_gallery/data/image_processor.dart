import 'dart:typed_data';

import 'package:flutter_bloc_app/features/camera_gallery/domain/image_processing_filter.dart';
import 'package:image/image.dart' as image;

/// Decodes, bounds, filters, and JPEG-encodes a user-selected image in memory.
class ImageProcessor {
  const ImageProcessor();

  static const int maxPreviewWidth = 1200;
  static const int maxPreviewHeight = 1200;
  static const int maxSourceBytes = 20 * 1024 * 1024;

  Uint8List process({
    required final Uint8List sourceBytes,
    required final ImageProcessingFilter filter,
  }) {
    if (sourceBytes.length > maxSourceBytes) {
      throw const FormatException('Image source is too large.');
    }
    final image.Image? decoded = image.decodeImage(sourceBytes);
    if (decoded == null) {
      throw const FormatException('Unsupported image data.');
    }

    image.Image transformed = decoded;
    if (decoded.width > maxPreviewWidth || decoded.height > maxPreviewHeight) {
      transformed = decoded.width >= decoded.height
          ? image.copyResize(decoded, width: maxPreviewWidth)
          : image.copyResize(decoded, height: maxPreviewHeight);
    }
    transformed = switch (filter) {
      ImageProcessingFilter.original => transformed,
      ImageProcessingFilter.grayscale => image.grayscale(transformed),
      ImageProcessingFilter.sepia => image.sepia(transformed),
      ImageProcessingFilter.invert => image.invert(transformed),
    };

    return image.encodeJpg(transformed, quality: 88);
  }
}
