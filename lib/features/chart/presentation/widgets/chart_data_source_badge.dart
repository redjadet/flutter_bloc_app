import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/shared/design_system/app_styles.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:mix/mix.dart';

/// Badge widget that displays the chart data source (Cache, Supabase, or Remote).
///
/// Uses [AppStyles.chip] for consistent chip styling with design tokens.
/// Labels come from localized strings
/// (`chartDataSourceCache` / `chartDataSourceSupabaseEdge`
/// / `chartDataSourceSupabaseTables` / `chartDataSourceRemote`).
class ChartDataSourceBadge extends StatelessWidget {
  const ChartDataSourceBadge({required this.source, super.key});

  final ChartDataSource source;

  @override
  Widget build(final BuildContext context) {
    if (source == ChartDataSource.unknown) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final String label = switch (source) {
      ChartDataSource.cache => l10n.chartDataSourceCache,
      ChartDataSource.supabaseEdge => l10n.chartDataSourceSupabaseEdge,
      ChartDataSource.supabaseTables => l10n.chartDataSourceSupabaseTables,
      ChartDataSource.firebaseCloud => l10n.chartDataSourceFirebaseCloud,
      ChartDataSource.firebaseFirestore =>
        l10n.chartDataSourceFirebaseFirestore,
      ChartDataSource.remote => l10n.chartDataSourceRemote,
      ChartDataSource.unknown => '',
    };
    final theme = Theme.of(context);
    return Box(
      style: AppStyles.chip,
      child: Text(
        label,
        style: theme.textTheme.labelMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
