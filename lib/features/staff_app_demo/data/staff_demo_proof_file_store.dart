import 'dart:io';

import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StaffDemoProofFileStore {
  Future<Directory> _baseDir() async {
    final Directory docs = await getApplicationDocumentsDirectory();
    return Directory(p.join(docs.path, 'staff_demo', 'proofs'));
  }

  Future<String> persistPhotoFile({
    required final String sourcePath,
  }) async {
    final Directory base = await _baseDir();
    await base.create(recursive: true);
    final String ext = p.extension(sourcePath).isNotEmpty
        ? p.extension(sourcePath)
        : '.jpg';
    final String destPath = p.join(
      base.path,
      'photo_${DateTime.now().millisecondsSinceEpoch}$ext',
    );
    try {
      return (await File(sourcePath).copy(destPath)).path;
    } on Exception catch (e, st) {
      AppLogger.error('StaffDemoProofFileStore.persistPhotoFile failed', e, st);
      rethrow;
    }
  }

  Future<String> persistSignaturePngBytes({
    required final List<int> bytes,
  }) async {
    final Directory base = await _baseDir();
    await base.create(recursive: true);
    final String destPath = p.join(
      base.path,
      'signature_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    try {
      final File file = File(destPath);
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } on Exception catch (e, st) {
      AppLogger.error(
        'StaffDemoProofFileStore.persistSignaturePngBytes failed',
        e,
        st,
      );
      rethrow;
    }
  }
}
