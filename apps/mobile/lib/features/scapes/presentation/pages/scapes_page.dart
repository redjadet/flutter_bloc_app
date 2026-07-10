// check-ignore: nonbuilder_lists - ScapesGridView is a custom widget, not GridView constructor
import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/app/widgets/common_empty_state.dart';
import 'package:flutter_bloc_app/app/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/scapes/domain/scapes_repository.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/cubit/scapes_cubit.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/cubit/scapes_state.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/widgets/scapes_grid_view.dart';

class ScapesPage extends StatelessWidget {
  const ScapesPage({
    required this.repository,
    required this.timerService,
    super.key,
  });

  final ScapesRepository repository;
  final TimerService timerService;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final EpochThemeExtension epoch = context.epoch;
    final ThemeData pageTheme = theme.copyWith(
      scaffoldBackgroundColor: epoch.darkGrey,
      extensions: () {
        final List<ThemeExtension<dynamic>> list = [
          epoch,
          ...theme.extensions.values,
        ];
        return list;
      }(),
    );

    return BlocProvider(
      create: (_) => ScapesCubit(
        repository: repository,
        timerService: timerService,
      ),
      child: Theme(
        data: pageTheme,
        child: CommonPageLayout(
          title: l10n.scapesPageTitle,
          appBarBackgroundColor: epoch.darkGrey,
          appBarForegroundColor: epoch.warmGreyLightest,
          titleTextStyle: pageTheme.textTheme.titleLarge?.copyWith(
            color: epoch.warmGreyLightest,
          ),
          appBarElevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          useResponsiveBody: false,
          body: CommonMaxWidth(
            child: BlocBuilder<ScapesCubit, ScapesState>(
              builder: (final context, final state) => switch (state) {
                ScapesInitial() || ScapesLoading() =>
                  const CommonLoadingWidget(),
                ScapesError(:final error) => CommonErrorView(
                  message: error.message ?? l10n.scapesErrorOccurred,
                  onRetry: () => context.cubit<ScapesCubit>().reload(),
                ),
                ScapesReady(:final scapes) when scapes.isEmpty =>
                  CommonEmptyState(
                    message: l10n.noScapesAvailable,
                  ),
                ScapesReady(:final scapes) => ScapesGridView(
                  scapes: scapes,
                  onFavoritePressed: (final id) =>
                      context.cubit<ScapesCubit>().toggleFavorite(id),
                  onMorePressed: (final id) {
                    AppLogger.debug('options menu clicked');
                  },
                ),
              },
            ),
          ),
        ),
      ),
    );
  }
}
