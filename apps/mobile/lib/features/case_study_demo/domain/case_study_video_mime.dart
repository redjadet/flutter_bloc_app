/// MIME type for in-memory case-study clip paths (extension from virtual path).
String mimeTypeForCaseStudyVideoPath(final String path) {
  final int dot = path.lastIndexOf('.');
  if (dot == -1 || dot == path.length - 1) {
    return 'video/mp4';
  }
  return switch (path.substring(dot + 1).toLowerCase()) {
    'mp4' || 'm4v' => 'video/mp4',
    'webm' => 'video/webm',
    'mov' => 'video/quicktime',
    'mkv' => 'video/x-matroska',
    'ogv' || 'ogg' => 'video/ogg',
    _ => 'video/mp4',
  };
}

/// File extension without dot for storage object keys (default mp4).
String fileExtensionForCaseStudyVideoPath(final String path) {
  final int dot = path.lastIndexOf('.');
  if (dot == -1 || dot == path.length - 1) {
    return 'mp4';
  }
  return path.substring(dot + 1).toLowerCase();
}
