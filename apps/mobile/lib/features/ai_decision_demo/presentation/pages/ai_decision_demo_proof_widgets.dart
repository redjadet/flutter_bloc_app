import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_models.dart';

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
  required final AiDecisionProof proof,
  required final AiDecisionPillBuilder pill,
}) {
  final List<AiDecisionProofRule> rows = proof.ruleTrace;
  final Map<String, dynamic> inputSnapshot = proof.inputSnapshot;
  final AiDecisionBandThresholds? thresholds = proof.bandThresholds;
  final AiDecisionSimilarCase? similarCase = proof.similarCase;
  final colors = Theme.of(context).colorScheme;
  final String confidence = proof.confidence;
  final double? finalScore = proof.finalScore;

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
      if (thresholds != null && !thresholds.isEmpty)
        Text(
          'Band thresholds: low ${thresholds.low}, medium ${thresholds.medium}, high ${thresholds.high}; selected ${thresholds.selected}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      if (similarCase != null)
        Text(
          similarCase.used
              ? 'Similar case: ${similarCase.caseId} (${similarCase.label}, similarity ${similarCase.similarity})'
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
          rows: () {
            final limited = rows.take(8).toList(growable: false);
            return List<DataRow>.generate(limited.length, (final i) {
              final r = limited[i];
              return DataRow.byIndex(
                index: i,
                cells: [
                  DataCell(
                    Icon(
                      r.passed ? Icons.check_circle : Icons.cancel,
                      size: 18,
                      color: r.passed ? colors.tertiary : colors.outline,
                    ),
                  ),
                  DataCell(Text(r.label)),
                  DataCell(Text(r.contribution.toStringAsFixed(2))),
                ],
              );
            });
          }(),
        ),
      ),
      const SizedBox(height: 8),
      ...rows.take(8).map((final r) {
        final evidence = r.evidence ?? '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            '${r.passed ? '✓' : '✗'} ${r.id}: $evidence',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      }),
    ],
  );
}
