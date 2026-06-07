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

  final lockPath = '$indexPath.lock';
  await _withFileLock(lockPath, () async {
    final indexFile = File(indexPath);
    final indexState = await _readIndexState(indexFile);

    final normalizedRoot = transcriptsRoot;
    final onDisk = await _listTranscriptFiles(transcriptsRoot);
    final onDiskByKey = <String, String>{
      for (final p in onDisk) transcriptIndexKey(p, normalizedRoot): p,
    };

    _migrateIndexKeysToRelative(indexState, normalizedRoot);

    // Remove deleted.
    indexState.transcripts.removeWhere(
      (key, _) => !onDiskByKey.containsKey(key),
    );

    // Add missing entries only. Keep existing mtimes so we can detect
    // “changed since last processed” by comparing on-disk mtime vs index mtime.
    var newerOnDiskCount = 0;
    var addedCount = 0;
    for (final entry in onDiskByKey.entries) {
      final key = entry.key;
      final path = entry.value;
      // ignore: avoid_slow_async_io -- async tool; avoid *Sync per harness guard.
      final stat = await File(path).stat();
      final mtimeMs = stat.modified.millisecondsSinceEpoch;
      final prev = indexState.transcripts[key];
      if (prev == null) {
        indexState.transcripts[key] = TranscriptIndexEntry(
          lastProcessedAt: null,
          mtimeMs: mtimeMs,
        );
        addedCount++;
      } else if (mtimeMs > prev.mtimeMs) {
        newerOnDiskCount++;
      }
    }

    indexState.transcripts.removeWhere(
      (key, _) => key.contains('/subagents/'),
    );

    await _writeIndexAtomic(indexFile, indexState);

    stdout.writeln(
      'index|paths=${indexState.transcripts.length}|added=$addedCount|newerOnDisk=$newerOnDiskCount',
    );
  });
}

Future<void> _withFileLock(String lockPath, Future<void> Function() fn) async {
  final lockFile = File(lockPath);
  await lockFile.parent.create(recursive: true);
  final raf = await lockFile.open(mode: FileMode.writeOnlyAppend);
  try {
    await raf.lock();
    await fn();
  } finally {
    await raf.unlock();
    await raf.close();
  }
}

Future<TranscriptIndexState> _readIndexState(File indexFile) async {
  // ignore: avoid_slow_async_io -- async tool; avoid *Sync per harness guard.
  if (!await indexFile.exists()) return TranscriptIndexState({});
  final decoded =
      jsonDecode(await indexFile.readAsString()) as Map<String, Object?>;
  final transcripts =
      (decoded['transcripts'] as Map<String, Object?>?) ?? const {};
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
  return TranscriptIndexState(out);
}

void _migrateIndexKeysToRelative(
  TranscriptIndexState state,
  String transcriptsRoot,
) {
  final migrated = <String, TranscriptIndexEntry>{};
  for (final entry in state.transcripts.entries) {
    final key = transcriptIndexKey(entry.key, transcriptsRoot);
    final existing = migrated[key];
    if (existing == null || entry.value.mtimeMs > existing.mtimeMs) {
      migrated[key] = entry.value;
    }
  }
  state.transcripts
    ..clear()
    ..addAll(migrated);
}

Future<void> _writeIndexAtomic(
  File indexFile,
  TranscriptIndexState state,
) async {
  final payload = <String, Object?>{
    'transcripts': {
      for (final e in state.transcripts.entries)
        e.key: {
          'lastProcessedAt': e.value.lastProcessedAt,
          'mtimeMs': e.value.mtimeMs,
        },
    },
  };

  final tmp = File('${indexFile.path}.tmp');
  await tmp.writeAsString(jsonEncode(payload));
  await tmp.rename(indexFile.path);
}

class TranscriptIndexState {
  TranscriptIndexState(this.transcripts);
  final Map<String, TranscriptIndexEntry> transcripts;
}

class TranscriptIndexEntry {
  TranscriptIndexEntry({required this.lastProcessedAt, required this.mtimeMs});

  final String? lastProcessedAt;
  final int mtimeMs;
}

Future<List<String>> _listTranscriptFiles(String root) async {
  final rootDir = Directory(root);
  // ignore: avoid_slow_async_io -- async tool; avoid *Sync per harness guard.
  if (!await rootDir.exists()) return [];

  final out = <String>[];
  await for (final entity in rootDir.list(
    recursive: true,
    followLinks: false,
  )) {
    if (entity is! File || !entity.path.endsWith('.jsonl')) continue;
    if (entity.path.contains('/subagents/')) continue;
    out.add(entity.path);
  }
  return out;
}
