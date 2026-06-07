import 'dart:convert';
import 'dart:io';

import 'transcript_index_path.dart';

Future<void> main(List<String> args) async {
  final transcriptsRoot = Platform.environment['CURSOR_AGENT_TRANSCRIPTS_ROOT'];
  if (transcriptsRoot == null || transcriptsRoot.trim().isEmpty) {
    stderr.writeln('missing-env|CURSOR_AGENT_TRANSCRIPTS_ROOT');
    exitCode = 2;
    return;
  }

  final indexPath =
      Platform.environment['CONTINUAL_LEARNING_INDEX_PATH'] ??
      '${Directory.current.path}/.cursor/hooks/state/continual-learning-index.json';

  final days = int.tryParse(_argValue(args, '--days') ?? '') ?? 30;
  final outPath =
      _argValue(args, '--out') ??
      '${Directory.current.path}/docs/audits/transcript_cleanup_candidates_${DateTime.now().toUtc().toIso8601String().substring(0, 10)}.json';

  final cutoff = DateTime.now()
      .toUtc()
      .subtract(Duration(days: days))
      .millisecondsSinceEpoch;

  final index = await _readIndex(File(indexPath));
  final candidates = <Map<String, Object?>>[];

  for (final entry in index.entries) {
    final path = resolveTranscriptPath(entry.key, transcriptsRoot);
    final meta = entry.value;
    final f = File(path);
    // ignore: avoid_slow_async_io -- async tool; avoid *Sync per harness guard.
    if (!await f.exists()) continue;
    // ignore: avoid_slow_async_io -- async tool; avoid *Sync per harness guard.
    final stat = await f.stat();
    final mtimeMs = stat.modified.millisecondsSinceEpoch;
    if (mtimeMs >= cutoff) continue;

    // Only suggest if indexed and old; never delete automatically.
    candidates.add({
      'path': path,
      'bytes': stat.size,
      'mtimeMs': mtimeMs,
      'indexedMtimeMs': meta.mtimeMs,
      'lastProcessedAt': meta.lastProcessedAt,
    });
  }

  candidates.sort(
    (a, b) => ((b['bytes'] as int?) ?? 0).compareTo((a['bytes'] as int?) ?? 0),
  );

  final payload = <String, Object?>{
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'cutoffDays': days,
    'cutoffMtimeMs': cutoff,
    'candidates': candidates,
  };

  final outFile = File(outPath);
  await outFile.parent.create(recursive: true);
  await outFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(payload),
  );

  stdout.writeln('cleanup_candidates|count=${candidates.length}|out=$outPath');
}

String? _argValue(List<String> args, String key) {
  final i = args.indexOf(key);
  if (i == -1) return null;
  if (i + 1 >= args.length) return null;
  return args[i + 1];
}

class TranscriptIndexEntry {
  TranscriptIndexEntry({required this.lastProcessedAt, required this.mtimeMs});
  final String? lastProcessedAt;
  final int mtimeMs;
}

Future<Map<String, TranscriptIndexEntry>> _readIndex(File indexFile) async {
  // ignore: avoid_slow_async_io -- async tool; avoid *Sync per harness guard.
  if (!await indexFile.exists()) return {};
  final decoded =
      jsonDecode(await indexFile.readAsString()) as Map<String, Object?>;
  final transcripts =
      (decoded['transcripts'] as Map<String, Object?>?) ??
      const <String, Object?>{};
  final out = <String, TranscriptIndexEntry>{};
  for (final entry in transcripts.entries) {
    final v = entry.value;
    if (v is Map<String, Object?>) {
      final lastProcessedAt = v['lastProcessedAt'] as String?;
      final mtimeMs = v['mtimeMs'];
      if (mtimeMs is num) {
        out[entry.key] = TranscriptIndexEntry(
          lastProcessedAt: lastProcessedAt,
          mtimeMs: mtimeMs.toInt(),
        );
      }
    }
  }
  return out;
}
