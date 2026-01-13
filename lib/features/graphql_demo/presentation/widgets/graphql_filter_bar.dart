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
    // Create list of items for picker (null for "All", then continents)
    final List<String?> allItems = [
      null,
      ...continents.map((final c) => c.code),
    ];

    return CommonDropdownField<String?>(
      value: activeContinentCode,
      items: [
        DropdownMenuItem<String?>(
          child: Text(l10n.graphqlSampleAllContinents),
        ),
        ...continents.map(
          (final continent) => DropdownMenuItem<String?>(
            value: continent.code,
            child: Text('${continent.name} (${continent.code})'),
          ),
        ),
      ],
      onChanged: isLoading
          ? null
          : (final value) =>
                CubitHelpers.safeExecute<GraphqlDemoCubit, GraphqlDemoState>(
                  context,
                  (final cubit) => cubit.selectContinent(value),
                ),
      labelText: l10n.graphqlSampleFilterLabel,
      enabled: !isLoading,
      customPickerItems: allItems,
      customItemLabel: (final String? code) {
        if (code == null) {
          return l10n.graphqlSampleAllContinents;
        }
        final continent = continents.firstWhere(
          (final c) => c.code == code,
        );
        return '${continent.name} (${continent.code})';
      },
    );
  }
}
