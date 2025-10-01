import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';

class GraphqlCountryCard extends StatelessWidget {
  const GraphqlCountryCard({
    super.key,
    required this.country,
    required this.capitalLabel,
    required this.currencyLabel,
  });

  final GraphqlCountry country;
  final String capitalLabel;
  final String currencyLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colors = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(country.emoji ?? '?', style: textTheme.headlineMedium),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(country.name, style: textTheme.titleMedium),
                      Text(
                        '${country.code} - ${country.continent.name}',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (country.capital != null && country.capital!.isNotEmpty)
                  _DetailChip(label: capitalLabel, value: country.capital!),
                if (country.currency != null && country.currency!.isNotEmpty)
                  _DetailChip(label: currencyLabel, value: country.currency!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Chip(
      label: Text('$label: $value', style: theme.textTheme.bodySmall),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
