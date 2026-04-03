import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart';

/// Signs clip URLs in small parallel batches to reduce wall-clock latency.
Future<Map<String, String>> signCaseStudyPlaybackUrlsInBatches({
  required final CaseStudyRemoteRepository remote,
  required final Map<String, String> keysByQuestion,
  required final Duration ttl,
  final int batchSize = 4,
}) async {
  final List<MapEntry<String, String>> entries = keysByQuestion.entries
      .where((final e) => e.value.isNotEmpty)
      .toList();
  final Map<String, String> out = <String, String>{};
  for (int i = 0; i < entries.length; i += batchSize) {
    final int end = i + batchSize > entries.length
        ? entries.length
        : i + batchSize;
    final List<MapEntry<String, String>> chunk = entries.sublist(i, end);
    final List<MapEntry<String, String>> signed =
        await Future.wait<MapEntry<String, String>>(
          chunk.map((e) async {
            final String url = await remote.createSignedPlaybackUrl(
              objectKey: e.value,
              ttl: ttl,
            );
            return MapEntry<String, String>(e.key, url);
          }),
        );
    for (final MapEntry<String, String> e in signed) {
      out[e.key] = e.value;
    }
  }
  return out;
}
