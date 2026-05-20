import 'dart:convert';
import 'dart:io';

/// Rank skills by approxTokens and a cheap invocation-likelihood proxy.
///
/// Proxy:
/// - +3 if description contains many triggers ("Use when", "Triggers", etc)
/// - +2 if body contains "Use when" or "Triggers on" (broad trigger lists)
/// - +2 if body contains "MUST" or "MANDATORY" (often causes eager attachment)
/// - +1 if origin == cursorSkills or agentsSkills (user-facing; likely invoked)
/// - +0 if origin == pluginCache (vendor; still can dominate, but we won't edit)
///
/// Score = approxTokens * (1 + proxy/10).
///
/// Output includes separate lists:
/// - editableRanked: repoTemplates + cursorSkills (things we can actually change)
/// - vendorRanked: pluginCache (read-only signals)
Future<void> main(List<String> args) async {
  if (args.length < 2) {
    stderr.writeln(
      'Usage: dart run tool/skill_rank.dart <inventory.json> <out.json>',
    );
    exitCode = 2;
    return;
  }

  final invPath = args[0];
  final outPath = args[1];

  final inv =
      jsonDecode(await File(invPath).readAsString()) as Map<String, Object?>;
  final skills = (inv['skills'] as List).cast<Map<String, Object?>>();

  final editableRanked = <Map<String, Object?>>[];
  final vendorRanked = <Map<String, Object?>>[];

  for (final s in skills) {
    final path = s['path'] as String;
    final origin = (s['origin'] as String?) ?? 'unknown';
    final approxTokens = (s['approxTokens'] as int?) ?? 0;
    final description = (s['description'] as String?) ?? '';

    String body = '';
    try {
      body = await File(path).readAsString();
    } catch (_) {
      // ignore unreadable
    }

    var proxy = 0;
    final text = '$description\n$body';
    // Avoid word-boundary surprises; keep it simple.
    if (RegExp(r'(use when|triggers?)', caseSensitive: false).hasMatch(text))
      proxy += 2;
    if (RegExp(
      r'(triggers on|trigger:|trigger phrases)',
      caseSensitive: false,
    ).hasMatch(text))
      proxy += 1;
    if (RegExp(r'(must|mandatory)', caseSensitive: false).hasMatch(text))
      proxy += 2;
    if (origin == 'cursorSkills' || origin == 'agentsSkills') proxy += 1;

    final score = approxTokens * (1.0 + (proxy / 10.0));

    final row = <String, Object?>{
      ...s,
      'proxy': proxy,
      'score': score,
    };

    if (origin == 'pluginCache') {
      vendorRanked.add(row);
    } else {
      editableRanked.add(row);
    }
  }

  editableRanked.sort(
    (a, b) => (b['score'] as double).compareTo(a['score'] as double),
  );
  vendorRanked.sort(
    (a, b) => (b['score'] as double).compareTo(a['score'] as double),
  );

  final payload = <String, Object?>{
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'inventoryPath': invPath,
    'editableRanked': editableRanked,
    'vendorRanked': vendorRanked,
  };

  final outFile = File(outPath);
  await outFile.parent.create(recursive: true);
  await outFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(payload),
  );
  stdout.writeln(
    'Wrote ranked ${editableRanked.length}+${vendorRanked.length} -> $outPath',
  );
}
