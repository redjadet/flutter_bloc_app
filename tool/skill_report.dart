import 'dart:convert';
import 'dart:io';

/// Compare two skill inventories and print deltas.
///
/// Usage:
///   `dart run tool/skill_report.dart <before.json> <after.json>`
///
/// Output: markdown-ish text on stdout.
Future<void> main(List<String> args) async {
  if (args.length < 2) {
    stderr.writeln(
      'Usage: dart run tool/skill_report.dart <before.json> <after.json>',
    );
    exitCode = 2;
    return;
  }

  final beforePath = args[0];
  final afterPath = args[1];

  final before = await _load(beforePath);
  final after = await _load(afterPath);

  final beforeByOrigin = _sumByOrigin(before);
  final afterByOrigin = _sumByOrigin(after);

  stdout
    ..writeln('## Skill inventory delta')
    ..writeln()
    ..writeln('- before: `$beforePath`')
    ..writeln('- after: `$afterPath`')
    ..writeln();

  for (final origin in <String>{
    ...beforeByOrigin.keys,
    ...afterByOrigin.keys,
  }..toList().sort()) {
    final b = beforeByOrigin[origin] ?? 0;
    final a = afterByOrigin[origin] ?? 0;
    final delta = a - b;
    final pct = b == 0 ? null : (delta * 100.0 / b);
    final pctText = pct == null ? '' : ' (${pct.toStringAsFixed(1)}%)';
    stdout.writeln('- $origin approxTokens: $b -> $a (delta $delta$pctText)');
  }

  stdout
    ..writeln()
    ..writeln('## Top cursorSkills (after)')
    ..writeln();

  final afterCursor = after.where((s) => s.origin == 'cursorSkills').toList()
    ..sort((a, b) => b.approxTokens.compareTo(a.approxTokens));

  for (final s in afterCursor.take(10)) {
    stdout.writeln('- ${s.approxTokens} `${s.path}`');
  }
}

Future<List<_Skill>> _load(String path) async {
  final inv =
      jsonDecode(await File(path).readAsString()) as Map<String, Object?>;
  final skills = (inv['skills']! as List).cast<Map<String, Object?>>();
  return skills
      .map(
        (s) => _Skill(
          path: s['path']! as String,
          origin: (s['origin'] as String?) ?? 'unknown',
          approxTokens: (s['approxTokens'] as int?) ?? 0,
        ),
      )
      .toList();
}

Map<String, int> _sumByOrigin(List<_Skill> skills) {
  final out = <String, int>{};
  for (final s in skills) {
    out[s.origin] = (out[s.origin] ?? 0) + s.approxTokens;
  }
  return out;
}

class _Skill {
  const _Skill({
    required this.path,
    required this.origin,
    required this.approxTokens,
  });

  final String path;
  final String origin;
  final int approxTokens;
}
