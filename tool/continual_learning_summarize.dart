import 'dart:convert';
import 'dart:io';

const int _defaultMaxReadBytes = 64 * 1024;

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

  final maxReadBytes =
      int.tryParse(Platform.environment['CONTINUAL_LEARNING_MAX_READ_BYTES'] ?? '') ??
      _defaultMaxReadBytes;

  final apply = args.contains('--apply');
  final outPath =
      _argValue(args, '--out') ??
      '${Directory.current.path}/docs/audits/continual_learning_suggestions_${DateTime.now().toUtc().toIso8601String().substring(0, 10)}.md';

  final lockPath = '$indexPath.lock';
  await _withFileLock(lockPath, () async {
    final indexFile = File(indexPath);
    final index = await _readIndex(indexFile);

    final onDisk = await _listTranscriptFiles(transcriptsRoot);
    final onDiskSet = onDisk.toSet();

    // Remove deleted.
    index.removeWhere((p, _) => !onDiskSet.contains(p));

    final changed = <String>[];
    for (final p in onDisk) {
      final stat = await File(p).stat();
      final mtimeMs = stat.modified.millisecondsSinceEpoch;
      final entry = index[p];
      // Include never-seen paths, content newer than indexed mtime, or first
      // scan after index_refresh (mtime recorded but lastProcessedAt still null).
      if (entry == null ||
          mtimeMs > entry.mtimeMs ||
          entry.lastProcessedAt == null) {
        changed.add(p);
      }
    }

    if (changed.isEmpty) {
      stdout.writeln('No high-signal memory updates.');
      // Still write cleaned index (deleted removed) if needed.
      await _writeIndexAtomic(indexFile, index);
      return;
    }

    final findings = <Finding>[];
    for (final path in changed) {
      final redactedText = await _readTranscriptTailRedacted(path, maxReadBytes);
      final extracted = _extractHighSignalFromRedactedText(redactedText);
      if (extracted.isEmpty) continue;
      findings.add(Finding(path: path, items: extracted));
    }

    final md = _renderMarkdown(findings);
    await File(outPath).parent.create(recursive: true);
    await File(outPath).writeAsString(md);

    _markTranscriptsProcessed(index, changed);
    await _writeIndexAtomic(indexFile, index);

    if (findings.isEmpty) {
      stdout.writeln('No high-signal memory updates.');
      return;
    }

    if (apply) {
      // Conservative: only update tasks/lessons.md with dedup keys.
      await _applyToLessons(findings);
    }

    stdout.writeln(
      'ok|suggestions|out=$outPath|changed=${changed.length}|findings=${findings.length}|apply=$apply',
    );
  });
}

String? _argValue(List<String> args, String key) {
  final i = args.indexOf(key);
  if (i == -1) return null;
  if (i + 1 >= args.length) return null;
  return args[i + 1];
}

Future<void> _withFileLock(String lockPath, Future<void> Function() fn) async {
  final lockFile = File(lockPath);
  await lockFile.parent.create(recursive: true);
  final raf = await lockFile.open(mode: FileMode.writeOnlyAppend);
  try {
    await raf.lock(FileLock.exclusive);
    await fn();
  } finally {
    await raf.unlock();
    await raf.close();
  }
}

Future<List<String>> _listTranscriptFiles(String root) async {
  final rootDir = Directory(root);
  if (!await rootDir.exists()) return [];
  final out = <String>[];
  await for (final entity in rootDir.list(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('.jsonl')) out.add(entity.path);
  }
  return out;
}

class TranscriptIndexEntry {
  TranscriptIndexEntry({required this.lastProcessedAt, required this.mtimeMs});
  final String? lastProcessedAt;
  final int mtimeMs;
}

Future<Map<String, TranscriptIndexEntry>> _readIndex(File indexFile) async {
  if (!await indexFile.exists()) return {};
  final decoded = jsonDecode(await indexFile.readAsString()) as Map<String, Object?>;
  final transcripts = (decoded['transcripts'] as Map<String, Object?>?) ?? const {};
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

Future<void> _writeIndexAtomic(File indexFile, Map<String, TranscriptIndexEntry> index) async {
  final payload = <String, Object?>{
    'transcripts': {
      for (final e in index.entries)
        e.key: {
          'lastProcessedAt': e.value.lastProcessedAt,
          'mtimeMs': e.value.mtimeMs,
        },
    },
  };
  final tmp = File('${indexFile.path}.tmp');
  await tmp.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
  await tmp.rename(indexFile.path);
}

void _markTranscriptsProcessed(Map<String, TranscriptIndexEntry> index, Iterable<String> paths) {
  final nowIso = DateTime.now().toUtc().toIso8601String();
  for (final p in paths) {
    final stat = File(p).statSync();
    index[p] = TranscriptIndexEntry(
      lastProcessedAt: nowIso,
      mtimeMs: stat.modified.millisecondsSinceEpoch,
    );
  }
}

Future<String> _readTranscriptTailRedacted(String path, int maxBytes) async {
  final f = File(path);
  final raf = await f.open();
  try {
    final len = await raf.length();
    final start = (len - maxBytes) > 0 ? (len - maxBytes) : 0;
    await raf.setPosition(start);
    final bytes = await raf.read(len - start);
    final text = utf8.decode(bytes, allowMalformed: true);
    return _redact(text);
  } finally {
    await raf.close();
  }
}

String _redact(String text) {
  var out = text;
  out = out.replaceAll(
    RegExp(r'Authorization:\s*[^\n]+', caseSensitive: false),
    'Authorization: [REDACTED]',
  );
  out = out.replaceAll(RegExp(r'Bearer\s+[A-Za-z0-9\-_.=]+'), 'Bearer [REDACTED]');
  out = out.replaceAll(RegExp(r'cookie:\s*[^\n]+', caseSensitive: false), 'Cookie: [REDACTED]');
  // Very loose API key-ish tokens.
  out = out.replaceAll(
    RegExp(r'(api[_-]?key|token|secret)\s*[:=]\s*[^\s\n]+', caseSensitive: false),
    r'$1: [REDACTED]',
  );
  return out;
}

class Finding {
  Finding({required this.path, required this.items});
  final String path;
  final List<String> items;
}

List<String> _extractHighSignalFromRedactedText(String text) {
  final out = <String>[];
  for (final line in const LineSplitter().convert(text)) {
    final l = line.trim();
    if (l.isEmpty) continue;
    // Transcript tails are JSONL; avoid extracting from raw JSON noise.
    if (l.startsWith('{') || l.startsWith('[')) continue;
    if (l.contains('"type"') || l.contains('"role"') || l.contains('"content"')) continue;
    if (l.contains(r'\u') || l.contains(r'\"')) continue;

    // Only extract user-level “correction-like” statements.
    final lower = l.toLowerCase();
    final looksLikeCorrection =
        lower.contains('do not') ||
        lower.contains("don't") ||
        lower.contains('never ') ||
        lower.contains('must ') ||
        lower.contains('should ') ||
        lower.contains('prefer ');

    if (!looksLikeCorrection) continue;

    // Filter obvious noise.
    if (lower.contains('lorem ipsum')) continue;
    if (l.length < 12) continue;

    // Keep short-ish.
    out.add(l.length > 240 ? '${l.substring(0, 240)}…' : l);
    if (out.length >= 20) break;
  }
  return out;
}

String _renderMarkdown(List<Finding> findings) {
  final b = StringBuffer();
  b.writeln('# Continual learning suggestions');
  b.writeln();
  b.writeln('Generated at: `${DateTime.now().toUtc().toIso8601String()}`');
  b.writeln();
  if (findings.isEmpty) {
    b.writeln('No high-signal memory updates.');
    return b.toString();
  }

  for (final f in findings) {
    b.writeln('## ${_sanitizeId(f.path)}');
    b.writeln();
    for (final item in f.items) {
      b.writeln('- $item');
    }
    b.writeln();
  }
  return b.toString();
}

String _sanitizeId(String path) {
  final base = path.split(Platform.pathSeparator).last;
  final parent = Directory(path).parent.path.split(Platform.pathSeparator).last;
  return '$parent/$base';
}

Future<void> _applyToLessons(List<Finding> findings) async {
  final lessonsPath = '${Directory.current.path}/tasks/lessons.md';
  final file = File(lessonsPath);
  final existing = await file.exists() ? await file.readAsString() : '';

  final additions = <String>[];
  for (final f in findings) {
    for (final item in f.items) {
      final key = _stableKey(item);
      if (existing.contains(key)) continue;
      additions.add('- $key');
      if (additions.length >= 20) break;
    }
    if (additions.length >= 20) break;
  }

  if (additions.isEmpty) return;

  const header = '## Agent continual-learning (auto)';
  final trimmed = existing.trimRight();
  final next = StringBuffer();

  if (trimmed.isEmpty) {
    next.writeln(header);
    for (final a in additions) {
      next.writeln(a);
    }
    next.writeln();
    await file.parent.create(recursive: true);
    await file.writeAsString(next.toString());
    return;
  }

  if (trimmed.contains(header)) {
    // Simple append without repeating the header.
    next.writeln(trimmed);
    next.writeln();
    for (final a in additions) {
      next.writeln(a);
    }
    next.writeln();
  } else {
    next.writeln(trimmed);
    next.writeln();
    next.writeln(header);
    for (final a in additions) {
      next.writeln(a);
    }
    next.writeln();
  }
  await file.parent.create(recursive: true);
  await file.writeAsString(next.toString());
}

String _stableKey(String line) {
  // Stable-ish dedupe key: normalize whitespace.
  final norm = line.replaceAll(RegExp(r'\\s+'), ' ').trim();
  return norm;
}
