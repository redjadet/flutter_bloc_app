import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/counter/counter.dart';
import 'package:flutter_bloc_app/features/remote_config/presentation/widgets/awesome_feature_widget.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CounterPageBody extends StatelessWidget {
  const CounterPageBody({
    required this.theme,
    required this.l10n,
    required this.showFlavorBadge,
    super.key,
  });

  final ThemeData theme;
  final AppLocalizations l10n;
  final bool showFlavorBadge;

  @override
  Widget build(final BuildContext context) =>
      TypeSafeBlocSelector<CounterCubit, CounterState, bool>(
        selector: (final state) => state.status.isLoading,
        builder: (final context, final isLoading) => Skeletonizer(
          enabled: isLoading,
          effect: ShimmerEffect(
            baseColor: theme.colorScheme.surfaceContainerHighest,
            highlightColor: theme.colorScheme.surface,
          ),
          child: _CounterContent(
            theme: theme,
            l10n: l10n,
            showFlavorBadge: showFlavorBadge,
          ),
        ),
      );
}

class _CounterContent extends StatelessWidget {
  const _CounterContent({
    required this.theme,
    required this.l10n,
    required this.showFlavorBadge,
  });

  final ThemeData theme;
  final AppLocalizations l10n;
  final bool showFlavorBadge;

  @override
  Widget build(final BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      if (showFlavorBadge) ...[
        const Padding(
          padding: EdgeInsets.all(1),
          child: Align(alignment: Alignment.centerRight, child: FlavorBadge()),
        ),
        SizedBox(height: context.responsiveGapS),
      ],
      Text(
        l10n.pushCountLabel,
        style: theme.textTheme.bodyMedium,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      SizedBox(height: context.responsiveGapS),
      const CounterDisplay(),
      SizedBox(height: context.responsiveGapM),
      const AwesomeFeatureWidget(),
      SizedBox(height: context.responsiveGapM),
      const CounterHint(),
    ],
  );
}
