import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_dataset.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_group.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/cubit/dispersion_cubit.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/cubit/dispersion_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_loading_widget.dart';
import 'package:flutter_bloc_app/shared/widgets/common_max_width.dart';

class DispersionHomeBody extends StatelessWidget {
  const DispersionHomeBody({
    required this.datasets,
    required this.groups,
    required this.isLoading,
    this.errorMessage,
    super.key,
  });

  final List<DispersionDataset> datasets;
  final List<DispersionGroup> groups;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    if (isLoading) {
      return const CommonLoadingWidget();
    }
    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return CommonErrorView(
        message: errorMessage!,
        onRetry: () => context.cubit<DispersionCubit>().load(),
      );
    }
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.responsiveGapM),
      child: CommonMaxWidth(
        maxWidth: context.contentMaxWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            PlatformAdaptive.filledButton(
              context: context,
              onPressed: () {
                context.cubit<DispersionCubit>().clearCreateFlow();
                context.cubit<DispersionCubit>().setScreen(
                  DispersionScreen.createGroup,
                );
              },
              child: Text(l10n.dispersionCreateGroup),
            ),
            SizedBox(height: context.responsiveGapS),
            PlatformAdaptive.outlinedButton(
              context: context,
              onPressed: () {
                context.cubit<DispersionCubit>().setScreen(
                  DispersionScreen.compare,
                );
              },
              child: Text(l10n.dispersionCompare),
            ),
            SizedBox(height: context.responsiveGapS),
            PlatformAdaptive.outlinedButton(
              context: context,
              onPressed: () {
                context.cubit<DispersionCubit>().setScreen(
                  DispersionScreen.combineDatasets,
                );
              },
              child: Text(l10n.dispersionCombineDatasets),
            ),
            SizedBox(height: context.responsiveGapL),
            Text(
              l10n.dispersionDatasets(datasets.length),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: context.responsiveGapS),
            if (datasets.isEmpty)
              Padding(
                padding: EdgeInsets.all(context.responsiveGapM),
                child: Text(
                  l10n.dispersionNoDatasets,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              ...datasets.map<Widget>(
                (final ds) => ListTile(
                  title: Text(ds.name),
                  subtitle: Text(
                    '${ds.pointCount} ${l10n.dispersionPoints}',
                  ),
                  trailing: ds.isDerived
                      ? Chip(
                          label: Text(
                            l10n.dispersionDerived,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        )
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
