/// Staging bytes for web proof photo picks when `XFile.path` is empty.
///
/// Avoids encoding picked bytes as a `data:` URL (base64 inflates memory and
/// forces a second decode in `LocalStaffDemoProofFileStore`). Demo-only.
final class StaffDemoProofPickMemory {
  StaffDemoProofPickMemory._();

  static final StaffDemoProofPickMemory instance = StaffDemoProofPickMemory._();

  static const String pickPathPrefix = 'staff-demo-proof://pick/';

  final Map<String, List<int>> _bytesByPath = <String, List<int>>{};

  bool isPickPath(final String path) => path.startsWith(pickPathPrefix);

  String stage(final List<int> bytes) {
    final String path =
        '$pickPathPrefix${DateTime.now().microsecondsSinceEpoch}';
    _bytesByPath[path] = List<int>.from(bytes);
    return path;
  }

  /// Returns staged bytes for [path] without removing them.
  List<int>? peek(final String path) {
    if (!isPickPath(path)) {
      return null;
    }
    final List<int>? bytes = _bytesByPath[path];
    return bytes == null ? null : List<int>.from(bytes);
  }

  /// Removes and returns staged bytes for [path], or null if not staged.
  List<int>? take(final String path) {
    if (!isPickPath(path)) {
      return null;
    }
    final List<int>? bytes = _bytesByPath.remove(path);
    return bytes == null ? null : List<int>.from(bytes);
  }

  /// Drops staged bytes for [path] without returning them (abandon / cleanup).
  void release(final String path) {
    if (isPickPath(path)) {
      _bytesByPath.remove(path);
    }
  }
}
