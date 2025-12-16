import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/search/domain/search_repository.dart';
import 'package:flutter_bloc_app/features/search/domain/search_result.dart';
import 'package:flutter_bloc_app/features/search/presentation/search_cubit.dart';
import 'package:flutter_bloc_app/features/search/presentation/search_state.dart';
import 'package:flutter_bloc_app/features/search/presentation/widgets/search_app_bar.dart';
import 'package:flutter_bloc_app/features/search/presentation/widgets/search_results_grid.dart';
import 'package:flutter_bloc_app/features/search/presentation/widgets/search_sync_banner.dart';
import 'package:flutter_bloc_app/features/search/presentation/widgets/search_text_field.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_bloc_app/shared/widgets/common_empty_state.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_loading_widget.dart';
import 'package:flutter_bloc_app/shared/widgets/view_status_switcher.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({
    required this.repository,
    required this.timerService,
    super.key,
  });

  final SearchRepository repository;
  final TimerService timerService;

  @override
  Widget build(final BuildContext context) => BlocProvider(
    create: (final context) => SearchCubit(
      repository: repository,
      timerService: timerService,
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
                const SearchSyncBanner(),
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
            child:
                ViewStatusSwitcher<SearchCubit, SearchState, _SearchBodyData>(
                  selector: (final state) => _SearchBodyData(
                    isLoading: state.isLoading,
                    isError: state.status.isError,
                    hasResults: state.hasResults,
                    results: state.results,
                  ),
                  isLoading: (final data) => data.isLoading,
                  isError: (final data) => data.isError,
                  loadingBuilder: (final _) => const CommonLoadingWidget(),
                  errorBuilder: (final context, final _) => CommonErrorView(
                    message: 'Error loading results',
                    onRetry: () => context.read<SearchCubit>().search('dogs'),
                  ),
                  builder: (final context, final bodyData) {
                    if (!bodyData.hasResults) {
                      return const CommonEmptyState(
                        message: 'No results found',
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
