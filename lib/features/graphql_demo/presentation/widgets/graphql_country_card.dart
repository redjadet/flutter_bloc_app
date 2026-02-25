import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/shared/design_system/app_styles.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';
import 'package:mix/mix.dart';

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

    return CommonCard(
      elevation: 0,
      color: colors.surfaceContainerHighest,
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
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Box(
      style: AppStyles.chip,
      child: Text(
        '$label: $value',
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}
