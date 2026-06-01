import 'dart:convert';
import 'dart:io';

/// Lightweight skill inventory for Cursor-visible SKILL.md files.
///
/// Output JSON: { generatedAt, roots, skills:[{path,origin,bytes,lines,chars,approxTokens,name,description}] }
///
/// approxTokens: rough estimate (chars / 4). Good enough for ranking.
Future<void> main(List<String> args) async {
  final outPath = args.isNotEmpty
      ? args.first
      : 'docs/audits/skill_inventory_latest.json';

  final home = Platform.environment['HOME'] ?? '';
  final cursorSkillsRoot = home.isEmpty ? '' : '$home/.cursor/skills';
  final agentsSkillsRoot = home.isEmpty ? '' : '$home/.agents/skills';
  final pluginCacheRoot = home.isEmpty ? '' : '$home/.cursor/plugins/cache';

  final roots = <String, String>{
    // repo-managed (templates are source of truth)
    'repoTemplates': '${Directory.current.path}/tool/agent_host_templates',
    if (cursorSkillsRoot.isNotEmpty) 'cursorSkills': cursorSkillsRoot,
    if (agentsSkillsRoot.isNotEmpty) 'agentsSkills': agentsSkillsRoot,
    if (pluginCacheRoot.isNotEmpty) 'pluginCache': pluginCacheRoot,
  };

  final skills = <Map<String, Object?>>[];

  for (final entry in roots.entries) {
    final rootDir = Directory(entry.value);
    if (!await rootDir.exists()) continue;

    await for (final entity in rootDir.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;
      if (!entity.path.endsWith('${Platform.pathSeparator}SKILL.md')) continue;
      if (_isIgnoredPath(entity.path)) continue;

      final content = await entity.readAsString();
      final stat = await entity.stat();
      final lines = '\n'.allMatches(content).length + 1;
      final chars = content.length;
      final approxTokens = (chars / 4).ceil();

      final frontmatter = _parseFrontmatter(content);

      skills.add({
        'path': entity.path,
        'origin': entry.key,
        'bytes': stat.size,
        'lines': lines,
        'chars': chars,
        'approxTokens': approxTokens,
        'name': frontmatter['name'],
        'description': frontmatter['description'],
      });
    }
  }

  skills.sort(
    (a, b) => (b['approxTokens'] as int).compareTo(a['approxTokens'] as int),
  );

  final payload = <String, Object?>{
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'roots': roots,
    'skills': skills,
  };

  final outFile = File(outPath);
  await outFile.parent.create(recursive: true);
  await outFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(payload),
  );

  stdout.writeln('Wrote ${skills.length} skills -> $outPath');
}

bool _isIgnoredPath(String path) {
  // Avoid scanning vendored envs/build artifacts if they exist under roots.
  final sep = Platform.pathSeparator;
  final ignoreSegments = <String>[
    '$sep.dart_tool$sep',
    '${sep}build$sep',
    '$sep.venv$sep',
    '${sep}node_modules$sep',
    '${sep}.archived$sep',
  ];
  for (final seg in ignoreSegments) {
    if (path.contains(seg)) return true;
  }
  return false;
}

Map<String, String?> _parseFrontmatter(String content) {
  // Minimal YAML frontmatter parse: only `name:` and `description:` keys.
  // We avoid full YAML dep; most skills follow "key: value" one-liners.
  if (!content.startsWith('---')) return const {};
  final end = content.indexOf('\n---', 3);
  if (end == -1) return const {};
  final fm = content.substring(3, end).trim();
  String? name;
  String? desc;
  for (final line in fm.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.startsWith('name:')) {
      name = trimmed.substring('name:'.length).trim();
    } else if (trimmed.startsWith('description:')) {
      desc = trimmed.substring('description:'.length).trim();
    }
  }
  return {'name': name, 'description': desc};
}
