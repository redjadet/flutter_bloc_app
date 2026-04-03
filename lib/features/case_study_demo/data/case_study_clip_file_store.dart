import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Persists picked videos under app documents for stable paths across restarts.
class CaseStudyClipFileStore {
  /// Copies [sourcePath] to a unique staging file so concurrent commits cannot
  /// overwrite each other's destination until promotion to the final path.
  Future<String> persistClipToStaging({
    required final String sourcePath,
    required final String caseId,
    required final String questionId,
    required final int commitToken,
  }) async {
    final Directory dir = await _caseDir(caseId);
    await dir.create(recursive: true);
    final String ext = p.extension(sourcePath);
    final String safeExt = ext.isEmpty ? '.mp4' : ext;
    final String stagingName = '$questionId.staging.$commitToken$safeExt';
    final String stagingPath = p.join(dir.path, stagingName);
    await File(sourcePath).copy(stagingPath);
    return stagingPath;
  }

  /// Final path derived from a staging path.
  ///
  /// Uses a per-pick unique filename so re-picking a clip for the same question
  /// produces a new path, forcing any video preview widgets to reinitialize.
  String finalClipFilePathFromStaging(final String stagingPath) {
    // Staging paths are created by [persistClipToStaging] with:
    //   $questionId.staging.$commitToken.ext
    // Convert to:
    //   $questionId.final.$commitToken.ext
    final String out = stagingPath.replaceFirst('.staging.', '.final.');
    return out == stagingPath ? stagingPath : out;
  }

  /// Replaces the canonical clip. Call only after confirming the async commit
  /// id is still current, with no intervening `await`, so promotion cannot race
  /// a newer pick/commit for the same question.
  String promoteStagingToFinalSync({
    required final String stagingPath,
    required final String finalPath,
  }) {
    final File finalFile = File(finalPath);
    if (finalFile.existsSync()) {
      finalFile.deleteSync();
    }
    File(stagingPath).renameSync(finalPath);
    return finalPath;
  }

  Future<Directory> _caseDir(final String caseId) async {
    final Directory docs = await getApplicationDocumentsDirectory();
    return Directory(
      p.join(docs.path, 'case_study_clips', caseId),
    );
  }

  Future<String> persistClip({
    required final String sourcePath,
    required final String caseId,
    required final String questionId,
  }) async {
    final Directory dir = await _caseDir(caseId);
    await dir.create(recursive: true);
    final String ext = p.extension(sourcePath);
    final String destName = '$questionId${ext.isEmpty ? '.mp4' : ext}';
    final String destPath = p.join(dir.path, destName);
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  Future<void> deleteFileIfExists(final String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final File f = File(path);
      if (f.existsSync()) {
        f.deleteSync();
      }
    } on FileSystemException {
      // Best-effort cleanup.
    }
  }

  Future<void> deleteCaseFolder(final String caseId) async {
    if (caseId.isEmpty) return;
    final Directory docs = await getApplicationDocumentsDirectory();
    final Directory dir = Directory(
      p.join(docs.path, 'case_study_clips', caseId),
    );
    try {
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    } on FileSystemException {
      // Best-effort cleanup.
    }
  }
}
