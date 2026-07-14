import 'dart:convert';
import 'dart:io';

/// Aggregated inventory for Cursor Marketplace plugin skills (plugin cache only).
///
/// Use when deciding which plugins to disable under Cursor Settings → Plugins.
/// Does not modify the cache; report-only.
///
/// Usage:
///   `dart run tool/skill_vendor_plugin_inventory.dart [out.json]`
///
/// Default output: docs/audits/vendor_plugin_inventory_latest.json
Future<void> main(List<String> args) async {
  final outPath = args.isNotEmpty
      ? args.first
      : 'docs/audits/vendor_plugin_inventory_latest.json';

  final home = Platform.environment['HOME'] ?? '';
  final pluginCacheRoot = home.isEmpty ? '' : '$home/.cursor/plugins/cache';
  if (pluginCacheRoot.isEmpty || !await Directory(pluginCacheRoot).exists()) {
    stderr.writeln(
      'vendor plugin inventory: no plugin cache at $pluginCacheRoot',
    );
    exitCode = 2;
    return;
  }

  const flutterKeepPlugins = <String>{
    'context7-plugin',
    'firebase',
    'supabase',
    'dart', // if present as plugin slug
  };

  final skills = <Map<String, Object?>>[];
  final rootDir = Directory(pluginCacheRoot);

  await for (final entity in rootDir.list(
    recursive: true,
    followLinks: false,
  )) {
    if (entity is! File) continue;
    if (!entity.path.endsWith('${Platform.pathSeparator}SKILL.md')) continue;
    if (_isIgnoredPath(entity.path)) continue;

    final content = await entity.readAsString();
    final stat = await entity.stat();
    final chars = content.length;
    final approxTokens = (chars / 4).ceil();
    final frontmatter = _parseFrontmatter(content);
    final pluginKey = _pluginKeyFromPath(entity.path, pluginCacheRoot);

    skills.add({
      'path': entity.path,
      'pluginKey': pluginKey,
      'bytes': stat.size,
      'lines': '\n'.allMatches(content).length + 1,
      'chars': chars,
      'approxTokens': approxTokens,
      'name': frontmatter['name'],
      'description': frontmatter['description'],
    });
  }

  final byPlugin = <String, Map<String, Object?>>{};
  for (final s in skills) {
    final key = s['pluginKey']! as String;
    final bucket = byPlugin.putIfAbsent(
      key,
      () => <String, Object?>{
        'pluginKey': key,
        'skillCount': 0,
        'approxTokens': 0,
        'topSkills': <Map<String, Object?>>[],
      },
    );
    bucket['skillCount'] = (bucket['skillCount']! as int) + 1;
    bucket['approxTokens'] =
        (bucket['approxTokens']! as int) + (s['approxTokens']! as int);
    final tops = (bucket['topSkills']! as List).cast<Map<String, Object?>>();
    tops.add({
      'name': s['name'],
      'approxTokens': s['approxTokens'],
      'path': s['path'],
    });
  }

  final plugins = <Map<String, Object?>>[];
  for (final entry in byPlugin.entries) {
    final slug = _pluginSlug(entry.key);
    final tops = (entry.value['topSkills']! as List)
        .cast<Map<String, Object?>>();
    tops.sort(
      (a, b) =>
          (b['approxTokens']! as int).compareTo(a['approxTokens']! as int),
    );
    final keepForFlutter =
        flutterKeepPlugins.contains(slug) ||
        slug.contains('context7') ||
        slug == 'firebase';
    plugins.add({
      ...entry.value,
      'pluginSlug': slug,
      'recommendedForFlutter': keepForFlutter,
      'topSkills': tops.take(5).toList(),
    });
  }

  plugins.sort(
    (a, b) => (b['approxTokens']! as int).compareTo(a['approxTokens']! as int),
  );

  final totalTokens = plugins.fold<int>(
    0,
    (sum, p) => sum + (p['approxTokens']! as int),
  );

  final disableCandidates = plugins
      .where((p) => p['recommendedForFlutter'] != true)
      .toList();

  final payload = <String, Object?>{
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'pluginCacheRoot': pluginCacheRoot,
    'skillCount': skills.length,
    'pluginCount': plugins.length,
    'approxTokensTotal': totalTokens,
    'plugins': plugins,
    'disableCandidatesForFlutter': disableCandidates
        .map(
          (p) => <String, Object?>{
            'pluginSlug': p['pluginSlug'],
            'approxTokens': p['approxTokens'],
            'skillCount': p['skillCount'],
          },
        )
        .toList(),
    'action':
        'Disable unused plugins in Cursor Settings → Plugins (marketplace). '
        'This report does not remove cache files.',
  };

  final outFile = File(outPath);
  await outFile.parent.create(recursive: true);
  await outFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(payload),
  );

  stdout.writeln('vendor_plugin_inventory');
  stdout.writeln('- skills: ${skills.length}');
  stdout.writeln('- plugins: ${plugins.length}');
  stdout.writeln('- approxTokens: $totalTokens');
  stdout.writeln('- disableCandidates (Flutter): ${disableCandidates.length}');
  stdout.writeln('- wrote: $outPath');
  for (final p in plugins.take(12)) {
    final keep = p['recommendedForFlutter'] == true ? 'keep' : 'cut?';
    stdout.writeln(
      '  ${p['approxTokens']} tok ${p['skillCount']} skills [$keep] ${p['pluginSlug']}',
    );
  }
}

String _pluginKeyFromPath(String skillPath, String cacheRoot) {
  final rel = skillPath.startsWith(cacheRoot)
      ? skillPath.substring(cacheRoot.length)
      : skillPath;
  final parts = rel.split(Platform.pathSeparator).where((p) => p.isNotEmpty);
  final list = parts.toList();
  if (list.length >= 2) {
    return '${list[0]}/${list[1]}';
  }
  return list.isEmpty ? 'unknown' : list.first;
}

String _pluginSlug(String pluginKey) {
  final parts = pluginKey.split('/');
  return parts.length >= 2 ? parts[1] : pluginKey;
}

bool _isIgnoredPath(String path) {
  final sep = Platform.pathSeparator;
  final ignoreSegments = <String>[
    '$sep.dart_tool$sep',
    '${sep}build$sep',
    '$sep.venv$sep',
    '${sep}node_modules$sep',
    '${sep}.git$sep',
    '${sep}.archived$sep',
  ];
  for (final seg in ignoreSegments) {
    if (path.contains(seg)) return true;
  }
  return false;
}

Map<String, String?> _parseFrontmatter(String content) {
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
