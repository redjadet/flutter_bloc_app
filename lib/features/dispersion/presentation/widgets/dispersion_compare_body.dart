import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_comparison_result.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_dataset.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_point.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/cubit/dispersion_cubit.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/cubit/dispersion_state.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/widgets/dispersion_compare_graph.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_loading_widget.dart';
import 'package:flutter_bloc_app/shared/widgets/common_max_width.dart';

String _datasetName(
  final List<DispersionDataset> datasets,
  final String? id,
  final String fallback,
) {
  if (id == null) return fallback;
  for (final DispersionDataset d in datasets) {
    if (d.id == id) return d.name;
  }
  return fallback;
}

class DispersionCompareBody extends StatelessWidget {
  const DispersionCompareBody({
    required this.datasets,
    required this.selectedAId,
    required this.selectedBId,
    required this.alpha,
    required this.excludeOutliers,
    this.result,
    this.isLoading = false,
    this.pointsA = const [],
    this.pointsB = const [],
    super.key,
  });

  final List<DispersionDataset> datasets;
  final String? selectedAId;
  final String? selectedBId;
  final double alpha;
  final bool excludeOutliers;
  final DispersionComparisonResult? result;
  final bool isLoading;
  final List<DispersionPoint> pointsA;
  final List<DispersionPoint> pointsB;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    if (isLoading) {
      return const CommonLoadingWidget();
    }
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.responsiveGapM),
      child: CommonMaxWidth(
        maxWidth: context.contentMaxWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DropdownButtonFormField<String>(
              initialValue: selectedAId,
              decoration: InputDecoration(
                labelText: l10n.dispersionDatasetA,
              ),
              items: datasets
                  .map(
                    (final d) => DropdownMenuItem<String>(
                      value: d.id,
                      child: Text(d.name),
                    ),
                  )
                  .toList(),
              onChanged: (final v) =>
                  context.cubit<DispersionCubit>().setCompareDatasetA(v),
            ),
            SizedBox(height: context.responsiveGapS),
            DropdownButtonFormField<String>(
              initialValue: selectedBId,
              decoration: InputDecoration(
                labelText: l10n.dispersionDatasetB,
              ),
              items: datasets
                  .map(
                    (final d) => DropdownMenuItem<String>(
                      value: d.id,
                      child: Text(d.name),
                    ),
                  )
                  .toList(),
              onChanged: (final v) =>
                  context.cubit<DispersionCubit>().setCompareDatasetB(v),
            ),
            SizedBox(height: context.responsiveGapS),
            SliderListTile(
              title: l10n.dispersionAlpha,
              value: alpha,
              min: 0.01,
              max: 0.2,
              divisions: 19,
              onChanged: (final v) =>
                  context.cubit<DispersionCubit>().setCompareAlpha(v),
            ),
            SwitchListTile(
              title: Text(l10n.dispersionExcludeOutliers),
              value: excludeOutliers,
              onChanged: (final v) => context
                  .cubit<DispersionCubit>()
                  .setCompareExcludeOutliers(exclude: v),
            ),
            SizedBox(height: context.responsiveGapM),
            PlatformAdaptive.filledButton(
              context: context,
              onPressed: () => context.cubit<DispersionCubit>().runComparison(),
              child: Text(l10n.dispersionRunComparison),
            ),
            PlatformAdaptive.textButton(
              context: context,
              onPressed: () => context.cubit<DispersionCubit>().setScreen(
                DispersionScreen.home,
              ),
              child: Text(l10n.dispersionBack),
            ),
            if (result != null) ...[
              SizedBox(height: context.responsiveGapL),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(context.responsiveGapM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.dispersionComparisonResult,
                        style: theme.textTheme.titleMedium,
                      ),
                      SizedBox(height: context.responsiveGapS),
                      Text('n(A)=${result!.nA}, n(B)=${result!.nB}'),
                      Text('U = ${result!.uStatistic.toStringAsFixed(2)}'),
                      Text('z = ${result!.zScore.toStringAsFixed(3)}'),
                      Text(
                        'p (two-sided) = ${result!.pValueTwoSided.toStringAsFixed(4)}',
                      ),
                      Text(
                        result!.isSignificant
                            ? l10n.dispersionSignificant
                            : l10n.dispersionNotSignificant,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: result!.isSignificant
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      if (result!.smallSampleCaution)
                        Padding(
                          padding: EdgeInsets.only(top: context.responsiveGapS),
                          child: Text(
                            l10n.dispersionSmallSampleCaution,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            if (result != null && (pointsA.isNotEmpty || pointsB.isNotEmpty)) ...[
              SizedBox(height: context.responsiveGapL),
              Text(
                l10n.dispersionGraphTitle,
                style: theme.textTheme.titleSmall,
              ),
              SizedBox(height: context.responsiveGapS),
              DispersionCompareGraph(
                pointsA: pointsA,
                pointsB: pointsB,
                labelA: _datasetName(datasets, selectedAId, l10n.dispersionDatasetA),
                labelB: _datasetName(datasets, selectedBId, l10n.dispersionDatasetB),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SliderListTile extends StatelessWidget {
  const SliderListTile({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    super.key,
  });

  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(final BuildContext context) {
    return ListTile(
      title: Text('$title: ${value.toStringAsFixed(2)}'),
      subtitle: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }
}
