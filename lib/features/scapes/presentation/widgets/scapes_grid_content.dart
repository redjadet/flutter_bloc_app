import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/scapes_cubit.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/scapes_state.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/widgets/scapes_grid_view.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

/// Reusable scapes grid content that can be embedded in other pages.
/// Provides its own BlocProvider for the ScapesCubit.
class ScapesGridContent extends StatelessWidget {
  const ScapesGridContent({super.key});

  @override
  Widget build(final BuildContext context) => BlocProvider(
    create: (_) => ScapesCubit(),
    child: const _ScapesGridContentBody(),
  );
}

class _ScapesGridContentBody extends StatelessWidget {
  const _ScapesGridContentBody();

  @override
  Widget build(final BuildContext context) =>
      TypeSafeBlocBuilder<ScapesCubit, ScapesState>(
        builder: (final context, final state) {
          if (state.isLoading) {
            return const CommonLoadingWidget();
          }

          if (state.hasError) {
            return CommonErrorView(
              message: state.errorMessage ?? 'An error occurred',
              onRetry: () => context.read<ScapesCubit>().reload(),
            );
          }

          if (state.scapes.isEmpty) {
            return const CommonEmptyState(
              message: 'No scapes available',
            );
          }

          return ScapesGridView(
            scapes: state.scapes,
            shrinkWrap: true,
            onFavoritePressed: (final id) =>
                context.read<ScapesCubit>().toggleFavorite(id),
            onMorePressed: (final id) {
              AppLogger.debug('options menu clicked');
            },
          );
        },
      );
}
