import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/graphql_demo/graphql_demo.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

class GraphqlDemoPage extends StatelessWidget {
  const GraphqlDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CommonPageLayout(
      title: l10n.graphqlSampleTitle,
      body: BlocBuilder<GraphqlDemoCubit, GraphqlDemoState>(
        builder: (context, state) {
          final bool showProgressBar =
              state.isLoading && state.countries.isNotEmpty;
          final theme = Theme.of(context);

          return Column(
            children: [
              if (showProgressBar) const LinearProgressIndicator(minHeight: 2),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: _FilterBar(state: state, l10n: l10n),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    CubitHelpers.safeExecute<
                      GraphqlDemoCubit,
                      GraphqlDemoState
                    >(context, (cubit) => cubit.refresh());
                  },
                  child: _buildBody(context, state, l10n, theme),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    GraphqlDemoState state,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    if (state.isLoading && state.countries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError && state.countries.isEmpty) {
      return AppMessage(
        title: l10n.graphqlSampleErrorTitle,
        message: _errorMessageForState(l10n, state),
        isError: true,
        actions: [
          ElevatedButton(
            onPressed: () =>
                CubitHelpers.safeExecute<GraphqlDemoCubit, GraphqlDemoState>(
                  context,
                  (cubit) => cubit.loadInitial(),
                ),
            child: Text(l10n.graphqlSampleRetryButton),
          ),
        ],
      );
    }

    if (state.countries.isEmpty) {
      return AppMessage(message: l10n.graphqlSampleEmpty);
    }

    final String capitalLabel = l10n.graphqlSampleCapitalLabel;
    final String currencyLabel = l10n.graphqlSampleCurrencyLabel;

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        final GraphqlCountry country = state.countries[index];
        return GraphqlCountryCard(
          country: country,
          capitalLabel: capitalLabel,
          currencyLabel: currencyLabel,
        );
      },
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemCount: state.countries.length,
    );
  }
}

String _errorMessageForState(AppLocalizations l10n, GraphqlDemoState state) {
  switch (state.errorType) {
    case GraphqlDemoErrorType.network:
      return l10n.graphqlSampleNetworkError;
    case GraphqlDemoErrorType.invalidRequest:
      return l10n.graphqlSampleInvalidRequestError;
    case GraphqlDemoErrorType.server:
      return l10n.graphqlSampleServerError;
    case GraphqlDemoErrorType.data:
      return l10n.graphqlSampleDataError;
    case GraphqlDemoErrorType.unknown:
      break;
    case null:
      break;
  }
  return state.errorMessage ?? l10n.graphqlSampleGenericError;
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.state, required this.l10n});

  final GraphqlDemoState state;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final continents = state.continents;
    final items = <DropdownMenuItem<String?>>[
      DropdownMenuItem<String?>(child: Text(l10n.graphqlSampleAllContinents)),
      ...continents.map(
        (continent) => DropdownMenuItem<String?>(
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
        const SizedBox(height: 8),
        InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              isExpanded: true,
              value: state.activeContinentCode,
              items: items,
              onChanged: state.isLoading
                  ? null
                  : (value) =>
                        CubitHelpers.safeExecute<
                          GraphqlDemoCubit,
                          GraphqlDemoState
                        >(context, (cubit) => cubit.selectContinent(value)),
            ),
          ),
        ),
      ],
    );
  }
}
