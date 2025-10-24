import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/presentation/cubit/chart_cubit.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_content_list.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_loading_list.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_message_list.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:intl/intl.dart';

class ChartPage extends StatelessWidget {
  const ChartPage({super.key, final ChartRepository? repository})
    : _repository = repository;

  final ChartRepository? _repository;

  @override
  Widget build(final BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = ChartCubit(repository: _repository ?? getIt<ChartRepository>());
      unawaited(cubit.load());
      return cubit;
    },
    child: const _ChartView(),
  );
}

class _ChartView extends StatelessWidget {
  const _ChartView();

  @override
  Widget build(final BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CommonPageLayout(
      title: l10n.chartPageTitle,
      body: RefreshIndicator(
        onRefresh: () => context.read<ChartCubit>().refresh(),
        child: BlocBuilder<ChartCubit, ChartState>(
          builder: (final context, final state) {
            if ((state.status == ChartStatus.initial ||
                    state.status == ChartStatus.loading) &&
                state.points.isEmpty) {
              return const ChartLoadingList();
            }

            if (state.status == ChartStatus.failure) {
              return ChartMessageList(message: l10n.chartPageError);
            }

            if (state.points.isEmpty) {
              return ChartMessageList(message: l10n.chartPageEmpty);
            }

            final locale = Localizations.localeOf(context).toString();
            final dateFormat = DateFormat.Md(locale);
            return ChartContentList(
              l10n: l10n,
              points: state.points,
              dateFormat: dateFormat,
              zoomEnabled: state.zoomEnabled,
              onZoomChanged: (final value) =>
                  context.read<ChartCubit>().setZoomEnabled(isEnabled: value),
            );
          },
        ),
      ),
    );
  }
}
