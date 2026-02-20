import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class GraphqlCountryCard extends StatelessWidget {
  const GraphqlCountryCard({
    required this.country,
    required this.capitalLabel,
    required this.currencyLabel,
    super.key,
  });

  final GraphqlCountry country;
  final String capitalLabel;
  final String currencyLabel;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colors = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerHighest,
      child: Padding(
        padding: context.allCardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(country.emoji ?? '?', style: textTheme.headlineMedium),
                SizedBox(width: context.responsiveHorizontalGapM),
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
            SizedBox(height: context.responsiveGapM),
            Wrap(
              spacing: context.responsiveHorizontalGapM,
              runSpacing: context.responsiveGapS,
              children: [
                if (country.capital case final capital?)
                  if (capital.isNotEmpty)
                    _DetailChip(label: capitalLabel, value: capital),
                if (country.currency case final currency?)
                  if (currency.isNotEmpty)
                    _DetailChip(label: currencyLabel, value: currency),
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
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Chip(
      label: Text('$label: $value', style: theme.textTheme.bodySmall),
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveHorizontalGapS,
      ),
    );
  }
}
