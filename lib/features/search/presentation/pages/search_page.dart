import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/search/domain/search_repository.dart';
import 'package:flutter_bloc_app/features/search/domain/search_result.dart';
import 'package:flutter_bloc_app/features/search/presentation/search_cubit.dart';
import 'package:flutter_bloc_app/features/search/presentation/search_state.dart';
import 'package:flutter_bloc_app/features/search/presentation/widgets/search_app_bar.dart';
import 'package:flutter_bloc_app/features/search/presentation/widgets/search_results_grid.dart';
import 'package:flutter_bloc_app/features/search/presentation/widgets/search_text_field.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_loading_widget.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(final BuildContext context) => BlocProvider(
    create: (final context) => SearchCubit(
      repository: getIt<SearchRepository>(),
      timerService: getIt<TimerService>(),
    )..search('dogs'),
    child: const _SearchPageContent(),
  );
}

class _SearchPageContent extends StatelessWidget {
  const _SearchPageContent();

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _SearchPageAppBar(backgroundColor: colorScheme.surface),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.pageHorizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: context.responsiveGapL),
                const SearchTextField(),
                SizedBox(height: context.responsiveGapL),
                Text(
                  'ALL RESULTS',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: context.responsiveCaptionSize * 0.04,
                    fontSize: context.responsiveCaptionSize,
                  ),
                ),
                SizedBox(height: context.responsiveGapL),
              ],
            ),
          ),
          Expanded(
            child: BlocSelector<SearchCubit, SearchState, _SearchBodyData>(
              selector: (final state) => _SearchBodyData(
                isLoading: state.isLoading,
                isError: state.status.isError,
                hasResults: state.hasResults,
                results: state.results,
              ),
              builder: (final context, final bodyData) {
                if (bodyData.isLoading) {
                  return const CommonLoadingWidget();
                }

                if (bodyData.isError) {
                  return CommonErrorView(
                    message: 'Error loading results',
                    onRetry: () => context.read<SearchCubit>().search('dogs'),
                  );
                }

                if (!bodyData.hasResults) {
                  return Center(
                    child: Text(
                      'No results found',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: context.responsiveBodySize,
                      ),
                    ),
                  );
                }

                return RepaintBoundary(
                  child: SearchResultsGrid(results: bodyData.results),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

@immutable
class _SearchBodyData {
  const _SearchBodyData({
    required this.isLoading,
    required this.isError,
    required this.hasResults,
    required this.results,
  });

  final bool isLoading;
  final bool isError;
  final bool hasResults;
  final List<SearchResult> results;
}

class _SearchPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SearchPageAppBar({required this.backgroundColor});

  final Color backgroundColor;

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + UI.gapM,
  );

  @override
  Widget build(final BuildContext context) => Material(
    color: backgroundColor,
    child: const SafeArea(
      bottom: false,
      child: SearchAppBar(),
    ),
  );
}
