import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

final Map<String, String> _blobUrlByCaseStudyPath = <String, String>{};

/// Registers a blob object URL for [caseStudyPath] playback on web.
void registerCaseStudyVideoBlobUrl({
  required final String caseStudyPath,
  required final List<int> bytes,
  required final String mimeType,
}) {
  releaseCaseStudyVideoBlobForPath(caseStudyPath);
  final JSArrayBuffer data = Uint8List.fromList(bytes).buffer.toJS;
  final Blob blob = Blob(
    [data].toJS,
    BlobPropertyBag(type: mimeType),
  );
  final String blobUrl = URL.createObjectURL(blob);
  _blobUrlByCaseStudyPath[caseStudyPath] = blobUrl;
}

/// Revokes blob URL created for [videoPath], if any.
void releaseCaseStudyVideoBlobForPath(final String videoPath) {
  final String? blobUrl = _blobUrlByCaseStudyPath.remove(videoPath);
  if (blobUrl != null) {
    URL.revokeObjectURL(blobUrl);
  }
}

/// Blob URL registered for [caseStudyPath], or null if not in memory.
String? caseStudyVideoBlobUrlForPath(final String caseStudyPath) =>
    _blobUrlByCaseStudyPath[caseStudyPath];
