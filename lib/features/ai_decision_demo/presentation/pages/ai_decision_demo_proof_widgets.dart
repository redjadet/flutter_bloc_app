import 'package:flutter/material.dart';

typedef AiDecisionPillBuilder =
    Widget Function({
      required BuildContext context,
      required String label,
      required Color color,
    });

Widget buildAiDecisionPill({
  required final BuildContext context,
  required final String label,
  required final Color color,
}) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  decoration: BoxDecoration(
    color: color.withValues(alpha: 0.12),
    border: Border.all(color: color.withValues(alpha: 0.35)),
    borderRadius: BorderRadius.circular(999),
  ),
  child: Text(
    label,
    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
  ),
);

Widget buildAiDecisionProofPanel({
  required final BuildContext context,
  required final Map<String, dynamic> proof,
  required final AiDecisionPillBuilder pill,
}) {
  final rows = (proof['rule_trace'] as List<dynamic>? ?? const <dynamic>[])
      .cast<Map<String, dynamic>>();
  final inputSnapshot =
      proof['input_snapshot'] as Map<String, dynamic>? ?? const {};
  final thresholds =
      proof['band_thresholds'] as Map<String, dynamic>? ?? const {};
  final similarCase =
      proof['similar_case'] as Map<String, dynamic>? ?? const {};
  final colors = Theme.of(context).colorScheme;
  final confidence = (proof['confidence'] as String?) ?? 'unknown';
  final finalScore = (proof['final_score'] as num?)?.toDouble();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          pill(
            context: context,
            label: 'Confidence: $confidence',
            color: colors.primary,
          ),
          if (finalScore != null)
            pill(
              context: context,
              label: 'Explained score: ${finalScore.toStringAsFixed(2)}',
              color: colors.secondary,
            ),
        ],
      ),
      const SizedBox(height: 8),
      if (inputSnapshot.isNotEmpty)
        Text(
          'Inputs: ${inputSnapshot.entries.map((final e) => '${e.key}=${e.value}').join(', ')}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      if (thresholds.isNotEmpty)
        Text(
          'Band thresholds: low ${thresholds['low']}, medium ${thresholds['medium']}, high ${thresholds['high']}; selected ${thresholds['selected']}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      if (similarCase.isNotEmpty)
        Text(
          similarCase['used'] == true
              ? 'Similar case: ${similarCase['case_id']} (${similarCase['label']}, similarity ${similarCase['similarity']})'
              : 'Similar case: not used',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      const SizedBox(height: 8),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Pass')),
            DataColumn(label: Text('Rule')),
            DataColumn(label: Text('Contrib')),
          ],
          rows: rows
              .take(8)
              .map((final r) {
                final passed = r['passed'] == true;
                final contrib = (r['contribution'] as num?)?.toDouble() ?? 0.0;
                return DataRow(
                  cells: [
                    DataCell(
                      Icon(
                        passed ? Icons.check_circle : Icons.cancel,
                        size: 18,
                        color: passed ? colors.tertiary : colors.outline,
                      ),
                    ),
                    DataCell(Text('${r['label']}')),
                    DataCell(Text(contrib.toStringAsFixed(2))),
                  ],
                );
              })
              .toList(growable: false),
        ),
      ),
      const SizedBox(height: 8),
      ...rows.take(8).map((final r) {
        final passed = r['passed'] == true;
        final evidence = (r['evidence'] as String?) ?? '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            '${passed ? '✓' : '✗'} ${r['id']}: $evidence',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      }),
    ],
  );
}
