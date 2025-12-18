import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/graphql_demo/graphql_demo.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

/// Filter bar for selecting continents in the GraphQL demo.
class GraphqlFilterBar extends StatelessWidget {
  const GraphqlFilterBar({
    required this.continents,
    required this.activeContinentCode,
    required this.isLoading,
    required this.l10n,
    super.key,
  });

  final List<GraphqlContinent> continents;
  final String? activeContinentCode;
  final bool isLoading;
  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    final items = <DropdownMenuItem<String?>>[
      DropdownMenuItem<String?>(
        child: Text(l10n.graphqlSampleAllContinents),
      ),
      ...continents.map(
        (final continent) => DropdownMenuItem<String?>(
          value: continent.code,
          child: Text('${continent.name} (${continent.code})'),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.graphqlSampleFilterLabel,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        SizedBox(height: context.responsiveGapS),
        InputDecorator(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.responsiveCardRadius),
            ),
            isDense: true,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              isExpanded: true,
              value: activeContinentCode,
              items: items,
              onChanged: isLoading
                  ? null
                  : (final value) =>
                        CubitHelpers.safeExecute<
                          GraphqlDemoCubit,
                          GraphqlDemoState
                        >(
                          context,
                          (final cubit) => cubit.selectContinent(value),
                        ),
            ),
          ),
        ),
      ],
    );
  }
}
