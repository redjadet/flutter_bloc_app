import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:app_shared_flutter/app_shared_flutter.dart' show AppLogger;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc_app/features/camera_gallery/data/image_processor.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_error_keys.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_result.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/image_processing_filter.dart';
import 'package:image_picker/image_picker.dart';

/// Data adapter for turning a picker result into a processed preview data URL.
class ImageProcessingCameraGalleryService {
  const ImageProcessingCameraGalleryService({
    this.processor = const ImageProcessor(),
  });

  final ImageProcessor processor;

  Future<CameraGalleryResult> process({
    required final ImageProcessingFilter filter,
    required final String sourcePath,
  }) async {
    try {
      // Original is already the source; skip codec round-trip.
      if (filter == ImageProcessingFilter.original) {
        return CameraGalleryResult.success(sourcePath);
      }

      final Uint8List sourceBytes = await _readImageBytes(sourcePath);
      final ImageProcessor activeProcessor = processor;
      final Uint8List processed = kIsWeb
          ? activeProcessor.process(sourceBytes: sourceBytes, filter: filter)
          : await Isolate.run(
              () => activeProcessor.process(
                sourceBytes: sourceBytes,
                filter: filter,
              ),
            );
      return CameraGalleryResult.success(
        'data:image/jpeg;base64,${base64Encode(processed)}',
      );
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'ImageProcessingCameraGalleryService.process',
        error,
        stackTrace,
      );
      return CameraGalleryResult.failure(
        errorKey: CameraGalleryErrorKeys.generic,
        message: error.toString(),
      );
    }
  }

  Future<Uint8List> _readImageBytes(final String sourcePath) async {
    if (sourcePath.startsWith('data:')) {
      final int separator = sourcePath.indexOf(',');
      if (separator == -1 || !sourcePath.contains(';base64,')) {
        throw const FormatException('Invalid image data URL.');
      }
      return base64Decode(sourcePath.substring(separator + 1));
    }
    return XFile(sourcePath).readAsBytes();
  }
}
