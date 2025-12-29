import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/presentation/cubit/chart_cubit.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_content_list.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_loading_list.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:intl/intl.dart';

class ChartPage extends StatelessWidget {
  const ChartPage({super.key, final ChartRepository? repository})
    : _repository = repository;

  final ChartRepository? _repository;

  @override
  Widget build(final BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = ChartCubit(
        repository: _repository ?? getIt<ChartRepository>(),
      );
      unawaited(cubit.load());
      return cubit;
    },
    child: const _ChartView(),
  );
}

@immutable
class _ChartViewData extends Equatable {
  const _ChartViewData({
    required this.showLoading,
    required this.showError,
    required this.showEmpty,
    required this.points,
    required this.zoomEnabled,
  });

  final bool showLoading;
  final bool showError;
  final bool showEmpty;
  final List<ChartPoint> points;
  final bool zoomEnabled;

  @override
  List<Object?> get props => [
    showLoading,
    showError,
    showEmpty,
    points,
    zoomEnabled,
  ];
}

class _ChartView extends StatelessWidget {
  const _ChartView();

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.chartPageTitle,
      body: RefreshIndicator(
        onRefresh: () => context.read<ChartCubit>().refresh(),
        child: ViewStatusSwitcher<ChartCubit, ChartState, _ChartViewData>(
          selector: (final state) => _ChartViewData(
            showLoading:
                (state.status.isInitial || state.status.isLoading) &&
                state.points.isEmpty,
            showError: state.status.isError,
            showEmpty: state.points.isEmpty,
            points: state.points,
            zoomEnabled: state.zoomEnabled,
          ),
          isLoading: (final data) => data.showLoading,
          isError: (final data) => data.showError,
          loadingBuilder: (final _) => const ChartLoadingList(),
          errorBuilder: (final context, final _) => CommonEmptyState(
            message: l10n.chartPageError,
            icon: Icons.error_outline,
          ),
          builder: (final context, final data) {
            if (data.showEmpty) {
              return CommonEmptyState(
                message: l10n.chartPageEmpty,
              );
            }

            final locale = Localizations.localeOf(context).toString();
            final dateFormat = DateFormat.Md(locale);
            return ChartContentList(
              l10n: l10n,
              points: data.points,
              dateFormat: dateFormat,
              zoomEnabled: data.zoomEnabled,
              onZoomChanged: (final value) =>
                  context.read<ChartCubit>().setZoomEnabled(isEnabled: value),
            );
          },
        ),
      ),
    );
  }
}
