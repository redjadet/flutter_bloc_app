import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/presentation/cubit/chart_cubit.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_content_list.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_loading_list.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'chart_page.freezed.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({
    required final ChartRepository repository,
    super.key,
  }) : _repository = repository;

  final ChartRepository _repository;

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  late final ChartCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ChartCubit(repository: widget._repository);
    unawaited(_cubit.load());
  }

  @override
  void dispose() {
    unawaited(_cubit.close());
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => BlocProvider.value(
    value: _cubit,
    child: const _ChartView(),
  );
}

@freezed
abstract class _ChartViewData with _$ChartViewData {
  const factory _ChartViewData({
    required final bool showLoading,
    required final bool showError,
    required final bool showEmpty,
    required final List<ChartPoint> points,
    required final bool zoomEnabled,
  }) = __ChartViewData;
}

class _ChartView extends StatelessWidget {
  const _ChartView();

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.chartPageTitle,
      body: RefreshIndicator(
        onRefresh: () => context.cubit<ChartCubit>().refresh(),
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
                  context.cubit<ChartCubit>().setZoomEnabled(isEnabled: value),
            );
          },
        ),
      ),
    );
  }
}
