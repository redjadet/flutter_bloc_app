import 'dart:io';

import 'package:video_player/video_player.dart';

Future<VideoPlayerController> createCaseStudyVideoController(
  final String videoPath,
) async {
  final Uri? uri = Uri.tryParse(videoPath);
  if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
    return VideoPlayerController.networkUrl(uri);
  }
  return VideoPlayerController.file(File(videoPath));
}
