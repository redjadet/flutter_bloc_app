import 'dart:io';

/// Relative keys under [transcriptsRoot] keep continual-learning index small.
String transcriptIndexKey(String absolutePath, String transcriptsRoot) {
  final normalizedRoot = _normalizeDir(transcriptsRoot);
  final normalizedPath = absolutePath.replaceAll(r'\', '/');
  final rootPrefix = '${normalizedRoot.replaceAll(r'\', '/')}/';
  if (normalizedPath.startsWith(rootPrefix)) {
    return normalizedPath.substring(rootPrefix.length);
  }

  if (!normalizedPath.startsWith('/') && !normalizedPath.contains(':/')) {
    return normalizedPath;
  }

  const marker = '/agent-transcripts/';
  final markerIndex = normalizedPath.indexOf(marker);
  if (markerIndex != -1) {
    return normalizedPath.substring(markerIndex + marker.length);
  }

  final parts = normalizedPath.split('/');
  if (parts.length >= 2) {
    return '${parts[parts.length - 2]}/${parts.last}';
  }
  return parts.last;
}

String resolveTranscriptPath(String indexKey, String transcriptsRoot) {
  final key = indexKey.replaceAll(r'\', '/');
  if (key.startsWith('/') || key.contains(':/')) {
    return indexKey;
  }
  return '${_normalizeDir(transcriptsRoot)}${Platform.pathSeparator}$key'
      .replaceAll('/', Platform.pathSeparator);
}

bool isAbsoluteTranscriptIndexKey(String key) {
  final normalized = key.replaceAll(r'\', '/');
  return normalized.startsWith('/') || normalized.contains(':/');
}

String _normalizeDir(String dir) {
  var out = dir.trim();
  while (out.endsWith(Platform.pathSeparator)) {
    out = out.substring(0, out.length - 1);
  }
  return out;
}
