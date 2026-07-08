import 'dart:convert';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_submit_exception.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_file_store.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_pick_memory.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:storage/storage.dart';

/// Hive-backed proof bytes keyed by stable virtual paths for web demos.
class LocalStaffDemoProofFileStore implements StaffDemoProofFileStore {
  LocalStaffDemoProofFileStore({
    required this.hiveService,
    @visibleForTesting this.debugPutFailuresRemaining,
  });

  static const String boxName = 'staff_demo_proof_files';

  final HiveService hiveService;
  final Map<String, List<int>> _bytesByPath = <String, List<int>>{};
  Box<dynamic>? _cachedBox;

  /// When set, the next [debugPutFailuresRemaining] [_putBytes] calls throw.
  @visibleForTesting
  int? debugPutFailuresRemaining;

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
    final int? remaining = debugPutFailuresRemaining;
    if (remaining != null && remaining > 0) {
      debugPutFailuresRemaining = remaining - 1;
      throw StateError('debug simulated put failure');
    }
    final List<int> copy = List<int>.from(bytes);
    _bytesByPath[path] = copy;
    final Box<dynamic> box = await _openBox();
    await box.put(path, copy);
  }

  Future<List<int>> _readSourceBytes(final String sourcePath) async {
    final List<int>? staged = StaffDemoProofPickMemory.instance.peek(
      sourcePath,
    );
    if (staged != null) {
      return staged;
    }

    if (sourcePath.startsWith('data:')) {
      final int commaIndex = sourcePath.indexOf(',');
      if (commaIndex == -1) {
        throw const FormatException('Invalid data URL');
      }
      final String payload = sourcePath.substring(commaIndex + 1);
      return base64Decode(payload);
    }
    return XFile(sourcePath).readAsBytes();
  }

  @override
  Future<String> persistPhotoFile({
    required final String sourcePath,
  }) async {
    try {
      final List<int> bytes = await _readSourceBytes(sourcePath);
      final String destPath =
          'staff-demo-proof://photo/${DateTime.now().microsecondsSinceEpoch}';
      await _putBytes(destPath, bytes);
      if (StaffDemoProofPickMemory.instance.isPickPath(sourcePath)) {
        StaffDemoProofPickMemory.instance.take(sourcePath);
      }
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
