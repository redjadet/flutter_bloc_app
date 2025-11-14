import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/graphql_demo/graphql_demo.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class GraphqlDemoPage extends StatelessWidget {
  const GraphqlDemoPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return CommonPageLayout(
      title: l10n.graphqlSampleTitle,
      body: Column(
        children: [
          // Only rebuild progress bar when loading state changes
          BlocSelector<GraphqlDemoCubit, GraphqlDemoState, bool>(
            selector: (final state) =>
                state.isLoading && state.countries.isNotEmpty,
            builder: (final context, final showProgressBar) => showProgressBar
                ? const LinearProgressIndicator(minHeight: 2)
                : const SizedBox.shrink(),
          ),
          // Only rebuild filter bar when continents or active continent changes
          BlocSelector<GraphqlDemoCubit, GraphqlDemoState, _FilterBarData>(
            selector: (final state) => _FilterBarData(
              continents: state.continents,
              activeContinentCode: state.activeContinentCode,
              isLoading: state.isLoading,
            ),
            builder: (final context, final filterData) => Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.pageHorizontalPadding,
                vertical: context.responsiveGapM,
              ),
              child: _FilterBar(
                continents: filterData.continents,
                activeContinentCode: filterData.activeContinentCode,
                isLoading: filterData.isLoading,
                l10n: l10n,
              ),
            ),
          ),
          // Only rebuild body when countries/error/loading changes
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                CubitHelpers.safeExecute<GraphqlDemoCubit, GraphqlDemoState>(
                  context,
                  (final cubit) => cubit.refresh(),
                );
              },
              child:
                  BlocSelector<GraphqlDemoCubit, GraphqlDemoState, _BodyData>(
                    selector: (final state) => _BodyData(
                      isLoading: state.isLoading,
                      hasError: state.hasError,
                      countries: state.countries,
                      errorType: state.errorType,
                      errorMessage: state.errorMessage,
                    ),
                    builder: (final context, final bodyData) => RepaintBoundary(
                      child: _buildBody(context, bodyData, l10n, theme),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    final BuildContext context,
    final _BodyData bodyData,
    final AppLocalizations l10n,
    final ThemeData theme,
  ) {
    if (bodyData.isLoading && bodyData.countries.isEmpty) {
      return const CommonLoadingWidget();
    }

    if (bodyData.hasError && bodyData.countries.isEmpty) {
      return AppMessage(
        title: l10n.graphqlSampleErrorTitle,
        message: _errorMessageForData(l10n, bodyData),
        isError: true,
        actions: [
          PlatformAdaptive.button(
            context: context,
            onPressed: () =>
                CubitHelpers.safeExecute<GraphqlDemoCubit, GraphqlDemoState>(
                  context,
                  (final cubit) => cubit.loadInitial(),
                ),
            child: Text(l10n.graphqlSampleRetryButton),
          ),
        ],
      );
    }

    if (bodyData.countries.isEmpty) {
      return AppMessage(message: l10n.graphqlSampleEmpty);
    }

    final String capitalLabel = l10n.graphqlSampleCapitalLabel;
    final String currencyLabel = l10n.graphqlSampleCurrencyLabel;

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: context.responsiveListPadding,
      itemBuilder: (final context, final index) {
        final GraphqlCountry country = bodyData.countries[index];
        return GraphqlCountryCard(
          country: country,
          capitalLabel: capitalLabel,
          currencyLabel: currencyLabel,
        );
      },
      separatorBuilder: (_, _) => SizedBox(height: context.responsiveGapM),
      itemCount: bodyData.countries.length,
    );
  }
}

String _errorMessageForData(
  final AppLocalizations l10n,
  final _BodyData bodyData,
) {
  switch (bodyData.errorType) {
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
  return bodyData.errorMessage ?? l10n.graphqlSampleGenericError;
}

@immutable
class _FilterBarData {
  const _FilterBarData({
    required this.continents,
    required this.activeContinentCode,
    required this.isLoading,
  });

  final List<GraphqlContinent> continents;
  final String? activeContinentCode;
  final bool isLoading;
}

@immutable
class _BodyData {
  const _BodyData({
    required this.isLoading,
    required this.hasError,
    required this.countries,
    required this.errorType,
    required this.errorMessage,
  });

  final bool isLoading;
  final bool hasError;
  final List<GraphqlCountry> countries;
  final GraphqlDemoErrorType? errorType;
  final String? errorMessage;
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.continents,
    required this.activeContinentCode,
    required this.isLoading,
    required this.l10n,
  });

  final List<GraphqlContinent> continents;
  final String? activeContinentCode;
  final bool isLoading;
  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    final items = <DropdownMenuItem<String?>>[
      DropdownMenuItem<String?>(child: Text(l10n.graphqlSampleAllContinents)),
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
