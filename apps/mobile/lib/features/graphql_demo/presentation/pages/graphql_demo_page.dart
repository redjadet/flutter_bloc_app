import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/app/widgets/view_status_switcher.dart';
import 'package:flutter_bloc_app/features/graphql_demo/graphql_demo.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';
import 'package:material_ui/material_ui.dart';

class GraphqlDemoPage extends StatelessWidget {
  const GraphqlDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.graphqlSampleTitle,
      body: Column(
        children: [
          // Only rebuild progress bar when loading state changes
          TypeSafeBlocSelector<GraphqlDemoCubit, GraphqlDemoState, bool>(
            selector: (state) => state.isLoading && state.countries.isNotEmpty,
            builder: (context, showProgressBar) => showProgressBar
                ? const LinearProgressIndicator(minHeight: 2)
                : const SizedBox.shrink(),
          ),
          // Only rebuild filter bar when continents or active continent changes
          TypeSafeBlocSelector<
            GraphqlDemoCubit,
            GraphqlDemoState,
            GraphqlFilterBarData
          >(
            selector: (state) => GraphqlFilterBarData(
              continents: state.continents,
              activeContinentCode: state.activeContinentCode,
              isLoading: state.isLoading,
            ),
            builder: (context, filterData) => Padding(
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
            selector: (state) => state.dataSource,
            builder: (context, source) => Align(
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
                    selector: (state) => GraphqlBodyData(
                      isLoading: state.isLoading,
                      hasError: state.hasError,
                      countries: state.countries,
                      errorType: state.errorType,
                      errorMessage: state.errorMessage,
                      lastError: state.lastError,
                    ),
                    isLoading: (data) =>
                        data.isLoading && data.countries.isEmpty,
                    isError: (data) => data.hasError && data.countries.isEmpty,
                    loadingBuilder: (_) => const CommonLoadingWidget(),
                    errorBuilder: (context, data) =>
                        buildGraphqlErrorWidget(context, data, l10n),
                    builder: (context, bodyData) => RepaintBoundary(
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
