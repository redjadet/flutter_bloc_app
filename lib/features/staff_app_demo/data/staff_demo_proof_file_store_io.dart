import 'dart:io';

import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_file_store.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LocalStaffDemoProofFileStore implements StaffDemoProofFileStore {
  // ignore: avoid_unused_constructor_parameters - keeps DI parity with web.
  LocalStaffDemoProofFileStore({final HiveService? hiveService});

  Future<Directory> _baseDir() async {
    final Directory docs = await getApplicationDocumentsDirectory();
    return Directory(p.join(docs.path, 'staff_demo', 'proofs'));
  }

  @override
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
      AppLogger.error(
        'LocalStaffDemoProofFileStore.persistPhotoFile failed',
        e,
        st,
      );
      rethrow;
    }
  }

  @override
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
        'LocalStaffDemoProofFileStore.persistSignaturePngBytes failed',
        e,
        st,
      );
      rethrow;
    }
  }

  @override
  Future<bool> fileExists(final String path) async {
    // ignore: avoid_slow_async_io — sync-io gate blocks existsSync on UI isolate
    return File(path).exists();
  }

  @override
  Future<List<int>> readFileBytes(final String path) async {
    return File(path).readAsBytes();
  }

  @override
  Future<void> deleteFileAtPath(final String path) async {
    try {
      await File(path).delete();
    } on FileSystemException {
      // Missing file is fine — removal is idempotent.
    } on Exception catch (e, st) {
      AppLogger.error(
        'LocalStaffDemoProofFileStore.deleteFileAtPath failed',
        e,
        st,
      );
    }
  }
}
