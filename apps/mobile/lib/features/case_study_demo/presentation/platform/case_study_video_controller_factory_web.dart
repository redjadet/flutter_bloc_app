import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_clip_bytes_memory.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_video_mime.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/platform/case_study_video_blob_lifecycle_web.dart';
import 'package:video_player/video_player.dart';

Future<VideoPlayerController> createCaseStudyVideoController(
  final String videoPath,
) async {
  final Uri? uri = Uri.tryParse(videoPath);
  if (uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https' || uri.scheme == 'blob')) {
    return VideoPlayerController.networkUrl(uri);
  }
  if (uri != null && uri.scheme == 'case-study') {
    final List<int> bytes = CaseStudyClipBytesMemory.instance.read(videoPath);
    final String mime = mimeTypeForCaseStudyVideoPath(videoPath);
    registerCaseStudyVideoBlobUrl(
      caseStudyPath: videoPath,
      bytes: bytes,
      mimeType: mime,
    );
    final String? blobUrl = caseStudyVideoBlobUrlForPath(videoPath);
    if (blobUrl == null) {
      throw StateError('Failed to create blob URL for: $videoPath');
    }
    return VideoPlayerController.networkUrl(Uri.parse(blobUrl));
  }
  throw StateError('Unsupported video path on web: $videoPath');
}
