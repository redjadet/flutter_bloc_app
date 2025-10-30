import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/search/domain/search_repository.dart';
import 'package:flutter_bloc_app/features/search/presentation/search_cubit.dart';
import 'package:flutter_bloc_app/features/search/presentation/search_state.dart';
import 'package:flutter_bloc_app/features/search/presentation/widgets/search_app_bar.dart';
import 'package:flutter_bloc_app/features/search/presentation/widgets/search_results_grid.dart';
import 'package:flutter_bloc_app/features/search/presentation/widgets/search_text_field.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';

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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SearchAppBar(),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.pageHorizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: UI.gapL),
                  const SearchTextField(),
                  SizedBox(height: UI.gapL),
                  Text(
                    'ALL RESULTS',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: context.responsiveCaptionSize * 0.04,
                      fontSize: context.responsiveCaptionSize,
                    ),
                  ),
                  SizedBox(height: UI.gapL),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (final context, final state) {
                  if (state.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.onSurface,
                      ),
                    );
                  }

                  if (state.status.isError) {
                    return Center(
                      child: Text(
                        'Error loading results',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: context.responsiveBodySize,
                        ),
                      ),
                    );
                  }

                  if (!state.hasResults) {
                    return Center(
                      child: Text(
                        'No results found',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: context.responsiveBodySize,
                        ),
                      ),
                    );
                  }

                  return SearchResultsGrid(results: state.results);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
