import 'dart:convert';
import 'dart:io';

import 'transcript_index_path.dart';

class TranscriptEntry {
  TranscriptEntry({
    required this.path,
    required this.bytes,
    required this.mtimeMs,
    required this.approxTokens,
    required this.indexedMtimeMs,
  });

  final String path;
  final int bytes;
  final int mtimeMs;
  final int approxTokens;
  final int? indexedMtimeMs;

  bool get changedSinceIndex =>
      indexedMtimeMs == null || mtimeMs > indexedMtimeMs!;

  Map<String, Object?> toJson() => {
    'path': path,
    'bytes': bytes,
    'mtimeMs': mtimeMs,
    'approxTokens': approxTokens,
    'indexedMtimeMs': indexedMtimeMs,
    'changedSinceIndex': changedSinceIndex,
  };
}

Future<void> main(List<String> args) async {
  final transcriptsRoot = Platform.environment['CURSOR_AGENT_TRANSCRIPTS_ROOT'];
  if (transcriptsRoot == null || transcriptsRoot.trim().isEmpty) {
    stderr.writeln(
      'missing-env|CURSOR_AGENT_TRANSCRIPTS_ROOT|'
      'Set to Cursor transcript root, e.g. '
      '"/Users/<you>/.cursor/projects/<workspace>/agent-transcripts"',
    );
    exitCode = 2;
    return;
  }

  final indexPath =
      Platform.environment['CONTINUAL_LEARNING_INDEX_PATH'] ??
      '${Directory.current.path}/.cursor/hooks/state/continual-learning-index.json';

  final outPath = args.isNotEmpty ? args.first : null;

  final index = await _readIndex(indexPath);
  final entries = await _scanTranscripts(transcriptsRoot, index);

  entries.sort((a, b) => b.bytes.compareTo(a.bytes));

  final totals = _totals(entries);
  final topByBytes = entries.take(20).toList();
  final topByTokens = [...entries]
    ..sort((a, b) => b.approxTokens.compareTo(a.approxTokens));
  final changed = entries.where((e) => e.changedSinceIndex).toList()
    ..sort((a, b) => b.mtimeMs.compareTo(a.mtimeMs));

  final payload = <String, Object?>{
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'transcriptsRoot': transcriptsRoot,
    'indexPath': indexPath,
    'totals': totals,
    'topByBytes': topByBytes.map((e) => e.toJson()).toList(),
    'topByApproxTokens': topByTokens.take(20).map((e) => e.toJson()).toList(),
    'changedSinceIndex': changed.map((e) => e.toJson()).toList(),
  };

  if (outPath != null) {
    final outFile = File(outPath);
    await outFile.parent.create(recursive: true);
    await outFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
  }

  _printSummary(
    totals: totals,
    changedCount: changed.length,
    top: topByBytes.take(5).toList(),
  );
}

Future<Map<String, int>> _readIndex(String indexPath) async {
  final file = File(indexPath);
  // ignore: avoid_slow_async_io -- async tool; avoid *Sync per harness guard.
  if (!await file.exists()) return {};

  final decoded = jsonDecode(await file.readAsString()) as Map<String, Object?>;
  final transcripts =
      (decoded['transcripts'] as Map<String, Object?>?) ?? const {};

  final out = <String, int>{};
  for (final entry in transcripts.entries) {
    final v = entry.value;
    if (v is Map<String, Object?>) {
      final mtimeMs = v['mtimeMs'];
      if (mtimeMs is num) out[entry.key] = mtimeMs.toInt();
    }
  }
  return out;
}

Future<List<TranscriptEntry>> _scanTranscripts(
  String root,
  Map<String, int> index,
) async {
  final rootDir = Directory(root);
  // ignore: avoid_slow_async_io -- async tool; avoid *Sync per harness guard.
  if (!await rootDir.exists()) {
    stderr.writeln('missing-dir|$root');
    exitCode = 2;
    return [];
  }

  final entries = <TranscriptEntry>[];
  await for (final entity in rootDir.list(
    recursive: true,
    followLinks: false,
  )) {
    if (entity is! File) continue;
    if (!entity.path.endsWith('.jsonl')) continue;

    // ignore: avoid_slow_async_io -- async tool; avoid *Sync per harness guard.
    final stat = await entity.stat();
    final bytes = stat.size;
    final approxTokens = (bytes / 4).ceil();
    final mtimeMs = stat.modified.millisecondsSinceEpoch;
    final indexedMtimeMs =
        index[transcriptIndexKey(entity.path, root)] ?? index[entity.path];

    entries.add(
      TranscriptEntry(
        path: entity.path,
        bytes: bytes,
        mtimeMs: mtimeMs,
        approxTokens: approxTokens,
        indexedMtimeMs: indexedMtimeMs,
      ),
    );
  }
  return entries;
}

Map<String, Object?> _totals(List<TranscriptEntry> entries) {
  var bytes = 0;
  var approxTokens = 0;
  for (final e in entries) {
    bytes += e.bytes;
    approxTokens += e.approxTokens;
  }
  return {
    'files': entries.length,
    'bytes': bytes,
    'approxTokens': approxTokens,
  };
}

void _printSummary({
  required Map<String, Object?> totals,
  required int changedCount,
  required List<TranscriptEntry> top,
}) {
  final files = totals['files'];
  final bytes = totals['bytes'];
  final tokens = totals['approxTokens'];
  stdout
    ..writeln('transcripts|files=$files|bytes=$bytes|approxTokens=$tokens')
    ..writeln('transcripts|changedSinceIndex=$changedCount');
  for (final e in top) {
    stdout.writeln(
      'top|${_sanitizeId(e.path)}|bytes=${e.bytes}|approxTokens=${e.approxTokens}',
    );
  }
}

String _sanitizeId(String path) {
  // Avoid leaking full local paths in logs; keep a stable-ish identifier.
  final base = path.split(Platform.pathSeparator).last;
  final parent = Directory(path).parent.path.split(Platform.pathSeparator).last;
  return '$parent/$base';
}
