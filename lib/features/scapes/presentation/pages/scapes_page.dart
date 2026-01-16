// check-ignore: nonbuilder_lists - ScapesGridView is a custom widget, not GridView constructor
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_theme.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/scapes_cubit.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/scapes_state.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/widgets/scapes_grid_view.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

class ScapesPage extends StatelessWidget {
  const ScapesPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => ScapesCubit(),
      child: Scaffold(
        backgroundColor: EpochColors.darkGrey,
        appBar: AppBar(
          backgroundColor: EpochColors.darkGrey,
          foregroundColor: EpochColors.warmGreyLightest,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => NavigationUtils.popOrGoHome(context),
            tooltip: 'Back',
          ),
          title: Text(
            l10n.scapesPageTitle,
            style: theme.textTheme.titleLarge,
          ),
        ),
        body: ViewStatusSwitcher<ScapesCubit, ScapesState, ScapesState>(
          selector: (final state) => state,
          isLoading: (final state) => state.isLoading,
          isError: (final state) => state.hasError,
          loadingBuilder: (final _) => const CommonLoadingWidget(),
          errorBuilder: (final context, final state) => CommonErrorView(
            message: state.errorMessage ?? 'An error occurred',
            onRetry: () => context.read<ScapesCubit>().reload(),
          ),
          builder: (final context, final state) {
            if (state.scapes.isEmpty) {
              return const CommonEmptyState(
                message: 'No scapes available',
              );
            }

            return ScapesGridView(
              scapes: state.scapes,
              onFavoritePressed: (final id) =>
                  context.read<ScapesCubit>().toggleFavorite(id),
              onMorePressed: (final id) {
                AppLogger.debug('options menu clicked');
              },
            );
          },
        ),
      ),
    );
  }
}
