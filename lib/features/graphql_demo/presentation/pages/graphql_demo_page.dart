import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/graphql_demo_cubit.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/graphql_demo_state.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/widgets/graphql_country_card.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class GraphqlDemoPage extends StatelessWidget {
  const GraphqlDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.graphqlSampleTitle)),
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
                  onRefresh: () => context.read<GraphqlDemoCubit>().refresh(),
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
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Text(
                  l10n.graphqlSampleErrorTitle,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage ?? l10n.graphqlSampleGenericError,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<GraphqlDemoCubit>().loadInitial(),
                  child: Text(l10n.graphqlSampleRetryButton),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (state.countries.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(32),
            child: Text(l10n.graphqlSampleEmpty, textAlign: TextAlign.center),
          ),
        ],
      );
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
                        context.read<GraphqlDemoCubit>().selectContinent(value),
            ),
          ),
        ),
      ],
    );
  }
}
