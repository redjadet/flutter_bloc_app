import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/app/widgets/view_status_switcher.dart';
import 'package:flutter_bloc_app/features/graphql_demo/graphql_demo.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';

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
          TypeSafeBlocSelector<GraphqlDemoCubit, GraphqlDemoState, bool>(
            selector: (final state) =>
                state.isLoading && state.countries.isNotEmpty,
            builder: (final context, final showProgressBar) => showProgressBar
                ? const LinearProgressIndicator(minHeight: 2)
                : const SizedBox.shrink(),
          ),
          // Only rebuild filter bar when continents or active continent changes
          TypeSafeBlocSelector<
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
              padding: context.pageHorizontalPaddingWithVertical(
                context.responsiveGapM,
              ),
              child: GraphqlFilterBar(
                continents: filterData.continents,
                activeContinentCode: filterData.activeContinentCode,
                isLoading: filterData.isLoading,
                l10n: l10n,
              ),
            ),
          ),
          TypeSafeBlocSelector<
            GraphqlDemoCubit,
            GraphqlDemoState,
            GraphqlDataSource
          >(
            selector: (final state) => state.dataSource,
            builder: (final context, final source) => Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  end: context.pageHorizontalPadding,
                  bottom: context.responsiveGapS,
                ),
                child: GraphqlDataSourceBadge(source: source),
              ),
            ),
          ),
          // Only rebuild body when countries/error/loading changes
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.cubit<GraphqlDemoCubit>().refresh(),
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
                      lastError: state.lastError,
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
