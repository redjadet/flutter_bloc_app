import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/app/utils/bloc/cubit_helpers.dart';
import 'package:flutter_bloc_app/features/graphql_demo/graphql_demo.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

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
  Widget build(BuildContext context) {
    final String? selectedContinentCode =
        activeContinentCode != null &&
            continents.any((c) => c.code == activeContinentCode)
        ? activeContinentCode
        : null;

    // Create list of items for picker (null for "All", then continents)
    final List<String?> allItems = [
      null,
      ...continents.map((c) => c.code),
    ];

    return CommonDropdownField<String?>(
      value: selectedContinentCode,
      items: [
        DropdownMenuItem<String?>(
          child: Text(l10n.graphqlSampleAllContinents),
        ),
        ...continents.map(
          (continent) => DropdownMenuItem<String?>(
            value: continent.code,
            child: Text('${continent.name} (${continent.code})'),
          ),
        ),
      ],
      onChanged: isLoading
          ? null
          : (value) =>
                CubitHelpers.safeExecute<GraphqlDemoCubit, GraphqlDemoState>(
                  context,
                  (cubit) => cubit.selectContinent(value),
                ),
      labelText: l10n.graphqlSampleFilterLabel,
      enabled: !isLoading,
      customPickerItems: allItems,
      customItemLabel: (code) {
        if (code == null) {
          return l10n.graphqlSampleAllContinents;
        }
        final continent = continents.firstWhere(
          (c) => c.code == code,
          orElse: () => GraphqlContinent(code: code, name: code),
        );
        return '${continent.name} (${continent.code})';
      },
    );
  }
}
