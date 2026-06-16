import 'package:cross_file/cross_file.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_submit_exception.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_file_store.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Hive-backed proof bytes keyed by stable virtual paths for web demos.
class LocalStaffDemoProofFileStore implements StaffDemoProofFileStore {
  LocalStaffDemoProofFileStore({required this.hiveService});

  static const String boxName = 'staff_demo_proof_files';

  final HiveService hiveService;
  final Map<String, List<int>> _bytesByPath = <String, List<int>>{};
  Box<dynamic>? _cachedBox;

  Future<Box<dynamic>> _openBox() async {
    if (_cachedBox case final Box<dynamic> box? when box.isOpen) {
      return box;
    }
    final Box<dynamic> box = await hiveService.openBox(boxName);
    _cachedBox = box;
    return box;
  }

  List<int>? _decodeBytes(final Object? raw) {
    if (raw is List<int>) {
      return List<int>.from(raw);
    }
    if (raw is List && raw.every((final item) => item is int)) {
      return raw.cast<int>().toList(growable: false);
    }
    return null;
  }

  Future<void> _putBytes(final String path, final List<int> bytes) async {
    final List<int> copy = List<int>.from(bytes);
    _bytesByPath[path] = copy;
    final Box<dynamic> box = await _openBox();
    await box.put(path, copy);
  }

  @override
  Future<String> persistPhotoFile({
    required final String sourcePath,
  }) async {
    try {
      final List<int> bytes = await XFile(sourcePath).readAsBytes();
      final String destPath =
          'staff-demo-proof://photo/${DateTime.now().microsecondsSinceEpoch}';
      await _putBytes(destPath, bytes);
      return destPath;
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
    final String destPath =
        'staff-demo-proof://signature/${DateTime.now().microsecondsSinceEpoch}.png';
    await _putBytes(destPath, bytes);
    return destPath;
  }

  @override
  Future<bool> fileExists(final String path) async {
    if (_bytesByPath.containsKey(path)) {
      return true;
    }
    final Box<dynamic> box = await _openBox();
    return box.containsKey(path);
  }

  @override
  Future<List<int>> readFileBytes(final String path) async {
    final List<int>? bytes = _bytesByPath[path];
    if (bytes != null) {
      return List<int>.from(bytes);
    }

    final Box<dynamic> box = await _openBox();
    final List<int>? persisted = _decodeBytes(box.get(path));
    if (persisted == null) {
      throw StaffDemoProofFileMissingException(
        'Staff demo proof file missing: $path',
      );
    }
    _bytesByPath[path] = persisted;
    return List<int>.from(persisted);
  }

  @override
  Future<void> deleteFileAtPath(final String path) async {
    _bytesByPath.remove(path);
    final Box<dynamic> box = await _openBox();
    await box.delete(path);
  }
}
