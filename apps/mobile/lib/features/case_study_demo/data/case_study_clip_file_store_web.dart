import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_clip_bytes_memory.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_clip_file_store.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:storage/storage.dart';

/// Web implementation storing clip bytes in memory and Hive with virtual paths.
class CaseStudyClipFileStoreImpl implements CaseStudyClipFileStore {
  CaseStudyClipFileStoreImpl({required this.hiveService});

  static const String boxName = 'case_study_clip_bytes';

  final HiveService hiveService;
  Box<dynamic>? _cachedBox;

  CaseStudyClipBytesMemory get _memory => CaseStudyClipBytesMemory.instance;

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
    _memory.put(path, copy);
    final Box<dynamic> box = await _openBox();
    await box.put(path, copy);
  }

  Future<List<int>?> _tryReadBytesFromHive(final String path) async {
    final Box<dynamic> box = await _openBox();
    final List<int>? bytes = _decodeBytes(box.get(path));
    if (bytes == null) {
      return null;
    }
    _memory.put(path, bytes);
    return bytes;
  }

  Future<List<int>> _readBytesFromHive(final String path) async {
    final List<int>? bytes = await _tryReadBytesFromHive(path);
    if (bytes == null) {
      throw StateError('Case study clip missing: $path');
    }
    return bytes;
  }

  Future<void> _replaceBytes({
    required final String stagingPath,
    required final String finalPath,
    required final List<int> bytes,
  }) async {
    final Box<dynamic> box = await _openBox();
    await box.put(finalPath, List<int>.from(bytes));
    await box.delete(stagingPath);
  }

  String _extensionFromPath(final String sourcePath) {
    final int dot = sourcePath.lastIndexOf('.');
    if (dot == -1 || dot == sourcePath.length - 1) {
      return '.mp4';
    }
    return sourcePath.substring(dot);
  }

  String _virtualPath({
    required final String caseId,
    required final String questionId,
    required final String suffix,
    required final String ext,
  }) => 'case-study://$caseId/$questionId.$suffix$ext';

  String? _stagingPathFromFinal(final String finalPath) {
    final String stagingPath = finalPath.replaceFirst('.final.', '.staging.');
    return stagingPath == finalPath ? null : stagingPath;
  }

  @override
  Future<String> persistClipToStaging({
    required final String sourcePath,
    required final String caseId,
    required final String questionId,
    required final int commitToken,
  }) async {
    final List<int> bytes = await XFile(sourcePath).readAsBytes();
    final String ext = _extensionFromPath(sourcePath);
    final String stagingPath = _virtualPath(
      caseId: caseId,
      questionId: questionId,
      suffix: 'staging.$commitToken',
      ext: ext,
    );
    await _putBytes(stagingPath, bytes);
    return stagingPath;
  }

  @override
  String finalClipFilePathFromStaging(final String stagingPath) {
    final String out = stagingPath.replaceFirst('.staging.', '.final.');
    return out == stagingPath ? stagingPath : out;
  }

  @override
  String promoteStagingToFinalSync({
    required final String stagingPath,
    required final String finalPath,
  }) {
    final List<int> bytes = _memory.read(stagingPath);
    _memory
      ..deleteIfExists(stagingPath)
      ..put(finalPath, bytes);
    unawaited(
      _replaceBytes(
        stagingPath: stagingPath,
        finalPath: finalPath,
        bytes: bytes,
      ),
    );
    return finalPath;
  }

  @override
  Future<String> persistClip({
    required final String sourcePath,
    required final String caseId,
    required final String questionId,
  }) async {
    final List<int> bytes = await XFile(sourcePath).readAsBytes();
    final String ext = _extensionFromPath(sourcePath);
    final String destPath = _virtualPath(
      caseId: caseId,
      questionId: questionId,
      suffix: 'clip',
      ext: ext,
    );
    await _putBytes(destPath, bytes);
    return destPath;
  }

  @override
  Future<void> deleteFileIfExists(final String? path) async {
    _memory.deleteIfExists(path);
    if (path == null || path.isEmpty) {
      return;
    }
    final Box<dynamic> box = await _openBox();
    await box.delete(path);
  }

  @override
  Future<void> deleteCaseFolder(final String caseId) async {
    _memory.deleteCase(caseId);
    if (caseId.isEmpty) {
      return;
    }
    final Box<dynamic> box = await _openBox();
    final String prefix = 'case-study://$caseId/';
    final keys = box.keys
        .whereType<String>()
        .where((final key) => key.startsWith(prefix))
        .toList(growable: false);
    await box.deleteAll(keys);
  }

  @override
  Future<List<int>> readClipBytes(final String path) async {
    final List<int>? memoryBytes = _memory.tryRead(path);
    if (memoryBytes != null) {
      return memoryBytes;
    }
    final List<int>? bytes = await _tryReadBytesFromHive(path);
    if (bytes != null) {
      return bytes;
    }
    final String? stagingPath = _stagingPathFromFinal(path);
    if (stagingPath != null) {
      final List<int>? stagingBytes = await _tryReadBytesFromHive(stagingPath);
      if (stagingBytes != null) {
        await _putBytes(path, stagingBytes);
        return stagingBytes;
      }
    }
    return _readBytesFromHive(path);
  }
}
