import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/app/widgets/common_empty_state.dart';
import 'package:flutter_bloc_app/app/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/app/widgets/type_safe_bloc_selector.dart';
import 'package:flutter_bloc_app/features/scapes/domain/scape.dart';
import 'package:flutter_bloc_app/features/scapes/domain/scapes_repository.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/cubit/scapes_cubit.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/cubit/scapes_state.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/widgets/scapes_grid_view.dart';

/// Reusable scapes grid content that can be embedded in other pages.
/// Provides its own BlocProvider for the ScapesCubit.
class ScapesGridContent extends StatelessWidget {
  const ScapesGridContent({
    required this.repository,
    required this.timerService,
    super.key,
  });

  final ScapesRepository repository;
  final TimerService timerService;

  @override
  Widget build(final BuildContext context) => BlocProvider(
    create: (_) => ScapesCubit(
      repository: repository,
      timerService: timerService,
    ),
    child: const _ScapesGridContentBody(),
  );
}

class _ScapesGridContentBody extends StatelessWidget {
  const _ScapesGridContentBody();

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return TypeSafeBlocSelector<
      ScapesCubit,
      ScapesState,
      (bool, bool, String?, List<Scape>)
    >(
      selector: (final s) =>
          (s.isLoading, s.hasError, s.errorMessage, s.scapes),
      builder: (final context, final data) {
        if (data.$1) {
          return const CommonLoadingWidget();
        }

        if (data.$2) {
          return CommonErrorView(
            message: data.$3 ?? l10n.scapesErrorOccurred,
            onRetry: () => context.cubit<ScapesCubit>().reload(),
          );
        }

        if (data.$4.isEmpty) {
          return CommonEmptyState(
            message: l10n.noScapesAvailable,
          );
        }

        return ScapesGridView(
          scapes: data.$4,
          onFavoritePressed: (final id) =>
              context.cubit<ScapesCubit>().toggleFavorite(id),
          onMorePressed: (final id) {
            AppLogger.debug('options menu clicked');
          },
        );
      },
    );
  }
}

/// Sliver that shows scapes grid (or loading/error/empty) for use inside
/// [CustomScrollView]. Requires [ScapesCubit] from a parent [BlocProvider].
class ScapesGridSliverContent extends StatelessWidget {
  const ScapesGridSliverContent({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return TypeSafeBlocSelector<
      ScapesCubit,
      ScapesState,
      (bool, bool, String?, List<Scape>)
    >(
      selector: (final s) =>
          (s.isLoading, s.hasError, s.errorMessage, s.scapes),
      builder: (final context, final data) {
        if (data.$1) {
          return const SliverToBoxAdapter(
            child: CommonLoadingWidget(),
          );
        }

        if (data.$2) {
          return SliverToBoxAdapter(
            child: CommonErrorView(
              message: data.$3 ?? l10n.scapesErrorOccurred,
              onRetry: () => context.cubit<ScapesCubit>().reload(),
            ),
          );
        }

        if (data.$4.isEmpty) {
          return SliverToBoxAdapter(
            child: CommonEmptyState(
              message: l10n.noScapesAvailable,
            ),
          );
        }

        return ScapesGridSliver(
          scapes: data.$4,
          onFavoritePressed: (final id) =>
              context.cubit<ScapesCubit>().toggleFavorite(id),
          onMorePressed: (final id) {
            AppLogger.debug('options menu clicked');
          },
        );
      },
    );
  }
}
