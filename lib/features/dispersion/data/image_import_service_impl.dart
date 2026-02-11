import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc_app/features/dispersion/data/image_import_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

const String _dispersionImagesSubdir = 'dispersion_images';

/// Minimal 1x1 gray PNG (base64) for test image so tests don't need camera/gallery.
const String _testImageBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

class ImageImportServiceImpl implements ImageImportService {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<String?> pickFromCamera() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.camera);
      if (file == null) {
        return null;
      }
      return _copyToAppDir(file.path);
    } on Exception {
      return null;
    }
  }

  @override
  Future<String?> pickFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) {
        return null;
      }
      return _copyToAppDir(file.path);
    } on Exception {
      return null;
    }
  }

  @override
  Future<String?> loadTestImage() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory targetDir = Directory(
        '${appDir.path}/$_dispersionImagesSubdir',
      );
      if (!targetDir.existsSync()) {
        targetDir.createSync(recursive: true);
      }
      final String path =
          '${targetDir.path}/test_sample_${DateTime.now().microsecondsSinceEpoch}.png';
      final List<int> bytes = base64Decode(_testImageBase64);
      await File(path).writeAsBytes(bytes);
      return path;
    } on Exception {
      return null;
    }
  }

  Future<String?> _copyToAppDir(final String sourcePath) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory targetDir = Directory(
        '${appDir.path}/$_dispersionImagesSubdir',
      );
      if (!targetDir.existsSync()) {
        targetDir.createSync(recursive: true);
      }
      final String name = '${DateTime.now().microsecondsSinceEpoch}.jpg';
      final String destPath = '${targetDir.path}/$name';
      await File(sourcePath).copy(destPath);
      return destPath;
    } on Exception {
      return null;
    }
  }
}
