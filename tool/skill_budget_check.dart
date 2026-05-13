import 'dart:convert';
import 'dart:io';

/// Soft budget checker for skills inventory JSON.
///
/// Default: report-only (exit 0).
/// Enforce: pass --enforce to exit non-zero on threshold breach.
///
/// Usage:
///   `dart tool/skill_budget_check.dart <inventory.json> [--enforce]`
///
/// Thresholds (env vars, optional):
///   SKILL_BUDGET_REPO_TOKENS=12000
///   SKILL_BUDGET_CURSOR_TOKENS=120000
///   SKILL_BUDGET_MAX_SINGLE_REPO_TOKENS=3000
///
/// Notes:
/// - repoTemplates budget is the only one we can guarantee via git.
/// - cursorSkills budget is local; still useful as signal.
Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart tool/skill_budget_check.dart <inventory.json> [--enforce]',
    );
    exitCode = 2;
    return;
  }

  final inventoryPath = args.first;
  final enforce = args.contains('--enforce');

  final repoBudget =
      int.tryParse(Platform.environment['SKILL_BUDGET_REPO_TOKENS'] ?? '') ??
      12000;
  final cursorBudget =
      int.tryParse(Platform.environment['SKILL_BUDGET_CURSOR_TOKENS'] ?? '') ??
      120000;
  final maxSingleRepo =
      int.tryParse(
        Platform.environment['SKILL_BUDGET_MAX_SINGLE_REPO_TOKENS'] ?? '',
      ) ??
      3000;

  final inv =
      jsonDecode(await File(inventoryPath).readAsString())
          as Map<String, Object?>;
  final skills = (inv['skills']! as List).cast<Map<String, Object?>>();

  int sumRepo = 0;
  int sumCursor = 0;
  int sumVendor = 0;

  final repoTop = <Map<String, Object?>>[];

  for (final s in skills) {
    final origin = (s['origin'] as String?) ?? 'unknown';
    final tokens = (s['approxTokens'] as int?) ?? 0;
    if (origin == 'repoTemplates') {
      sumRepo += tokens;
      repoTop.add(s);
    } else if (origin == 'cursorSkills') {
      sumCursor += tokens;
    } else if (origin == 'pluginCache') {
      sumVendor += tokens;
    }
  }

  repoTop.sort(
    (a, b) => (b['approxTokens']! as int).compareTo(a['approxTokens']! as int),
  );

  final repoMax = repoTop.isEmpty ? 0 : (repoTop.first['approxTokens']! as int);
  final repoMaxPath = repoTop.isEmpty ? '' : (repoTop.first['path']! as String);

  final report = StringBuffer()
    ..writeln('skill_budget_check')
    ..writeln('- inventory: $inventoryPath')
    ..writeln('- repoTemplates approxTokens: $sumRepo (budget $repoBudget)')
    ..writeln('- cursorSkills approxTokens: $sumCursor (budget $cursorBudget)')
    ..writeln('- pluginCache approxTokens: $sumVendor (read-only)')
    ..writeln(
      '- largest repoTemplates skill: $repoMax ($repoMaxPath) (max $maxSingleRepo)',
    );

  stdout.writeln(report.toString().trimRight());

  final breaches = <String>[];
  if (sumRepo > repoBudget) {
    breaches.add('repoTemplates sum $sumRepo > $repoBudget');
  }
  if (sumCursor > cursorBudget) {
    breaches.add('cursorSkills sum $sumCursor > $cursorBudget');
  }
  if (repoMax > maxSingleRepo) {
    breaches.add(
      'repoTemplates max single $repoMax > $maxSingleRepo ($repoMaxPath)',
    );
  }

  if (breaches.isNotEmpty) {
    stderr.writeln('BUDGET BREACHES:');
    for (final b in breaches) {
      stderr.writeln('- $b');
    }
    if (enforce) {
      exitCode = 1;
    }
  }
}
