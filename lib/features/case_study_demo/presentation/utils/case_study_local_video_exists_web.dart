import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_clip_bytes_memory.dart';

/// Whether a picked or persisted clip path is playable on web.
Future<bool> caseStudyLocalVideoExists(final String path) async {
  final Uri? uri = Uri.tryParse(path);
  if (uri == null) {
    return false;
  }
  return switch (uri.scheme) {
    'http' || 'https' || 'blob' => true,
    'case-study' => CaseStudyClipBytesMemory.instance.exists(path),
    _ => false,
  };
}
