/// In-memory clip bytes for web demos keyed by stable virtual paths.
///
/// Web keeps a full copy of each clip here and may duplicate into a blob URL
/// for playback. Keep demo clips short on web to avoid memory pressure.
final class CaseStudyClipBytesMemory {
  CaseStudyClipBytesMemory._();

  static final CaseStudyClipBytesMemory instance = CaseStudyClipBytesMemory._();

  final Map<String, List<int>> _bytesByPath = <String, List<int>>{};

  bool exists(final String path) => _bytesByPath.containsKey(path);

  void put(final String path, final List<int> bytes) {
    _bytesByPath[path] = List<int>.from(bytes);
  }

  List<int>? tryRead(final String path) {
    final List<int>? bytes = _bytesByPath[path];
    return bytes == null ? null : List<int>.from(bytes);
  }

  List<int> read(final String path) {
    final List<int>? bytes = _bytesByPath[path];
    if (bytes == null) {
      throw StateError('Case study clip missing: $path');
    }
    return List<int>.from(bytes);
  }

  void deleteIfExists(final String? path) {
    if (path == null || path.isEmpty) {
      return;
    }
    _bytesByPath.remove(path);
  }

  void deleteCase(final String caseId) {
    if (caseId.isEmpty) {
      return;
    }
    _bytesByPath.removeWhere(
      (final path, final _) => path.contains('/$caseId/'),
    );
  }
}
