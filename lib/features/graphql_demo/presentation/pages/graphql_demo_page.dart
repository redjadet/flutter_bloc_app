import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/graphql_demo/graphql_demo.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

class GraphqlDemoPage extends StatelessWidget {
  const GraphqlDemoPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
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
          BlocSelector<
            GraphqlDemoCubit,
            GraphqlDemoState,
            GraphqlFilterBarData
          >(
            selector: (final state) => GraphqlFilterBarData(
              continents: state.continents,
              activeContinentCode: state.activeContinentCode,
              isLoading: state.isLoading,
            ),
            builder: (final context, final filterData) => Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.pageHorizontalPadding,
                vertical: context.responsiveGapM,
              ),
              child: GraphqlFilterBar(
                continents: filterData.continents,
                activeContinentCode: filterData.activeContinentCode,
                isLoading: filterData.isLoading,
                l10n: l10n,
              ),
            ),
          ),
          BlocSelector<GraphqlDemoCubit, GraphqlDemoState, GraphqlDataSource>(
            selector: (final state) => state.dataSource,
            builder: (final context, final source) => Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(
                  right: context.pageHorizontalPadding,
                  bottom: context.responsiveGapS,
                ),
                child: GraphqlDataSourceBadge(source: source),
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
                  ViewStatusSwitcher<
                    GraphqlDemoCubit,
                    GraphqlDemoState,
                    GraphqlBodyData
                  >(
                    selector: (final state) => GraphqlBodyData(
                      isLoading: state.isLoading,
                      hasError: state.hasError,
                      countries: state.countries,
                      errorType: state.errorType,
                      errorMessage: state.errorMessage,
                    ),
                    isLoading: (final data) =>
                        data.isLoading && data.countries.isEmpty,
                    isError: (final data) =>
                        data.hasError && data.countries.isEmpty,
                    loadingBuilder: (final _) => const CommonLoadingWidget(),
                    errorBuilder: (final context, final data) =>
                        buildGraphqlErrorWidget(context, data, l10n),
                    builder: (final context, final bodyData) => RepaintBoundary(
                      child: GraphqlBody(bodyData: bodyData, l10n: l10n),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
