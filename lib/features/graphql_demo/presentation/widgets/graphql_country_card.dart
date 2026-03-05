import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/shared/design_system/app_styles.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/widgets/cached_network_image_widget.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';
import 'package:mix/mix.dart';

String? _flagImageUrl(final String countryCode) {
  // Most Countries API codes are ISO 3166-1 alpha-2 (e.g. "TR").
  // Use a deterministic CDN URL so flags render even when emoji glyphs are missing.
  if (countryCode.length != 2) {
    return null;
  }
  return 'https://flagcdn.com/w80/${countryCode.toLowerCase()}.png';
}

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
              _CountryFlag(
                countryName: country.name,
                countryCode: country.code,
                emojiFallback: country.emoji,
              ),
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

class _CountryFlag extends StatelessWidget {
  const _CountryFlag({
    required this.countryName,
    required this.countryCode,
    required this.emojiFallback,
  });

  final String countryName;
  final String countryCode;
  final String? emojiFallback;

  @override
  Widget build(final BuildContext context) {
    final String fallbackText = emojiFallback ?? '?';
    // Use an existing responsive token that scales for phone/tablet/desktop.
    // This keeps flags visually prominent in the list.
    final double size = context.responsiveErrorIconSize;

    final String? url = _flagImageUrl(countryCode);
    if (url == null) {
      return Semantics(
        label: 'Flag of $countryName',
        child: Text(
          fallbackText,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      );
    }

    return Semantics(
      image: true,
      label: 'Flag of $countryName',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius),
        child: CachedNetworkImageWidget(
          imageUrl: url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          memCacheWidth: 80,
          memCacheHeight: 80,
          // In widget tests / offline, show emoji fallback instead of a spinner.
          placeholder: (final context, final url) => ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Center(
              child: Text(
                fallbackText,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          errorWidget: (final context, final url, final error) => ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Center(
              child: Text(
                fallbackText,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
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
