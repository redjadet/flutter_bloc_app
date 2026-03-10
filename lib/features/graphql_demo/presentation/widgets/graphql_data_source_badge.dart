import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_data_source.dart';
import 'package:flutter_bloc_app/shared/design_system/app_styles.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:mix/mix.dart';

/// Badge widget that displays the data source (Cache, Supabase, or Remote).
///
/// Uses [AppStyles.chip] for consistent chip styling with design tokens.
/// Labels come from localized strings
/// (`graphqlSampleDataSourceCache` / `graphqlSampleDataSourceSupabaseEdge`
/// / `graphqlSampleDataSourceSupabaseTables` / `graphqlSampleDataSourceRemote`).
class GraphqlDataSourceBadge extends StatelessWidget {
  const GraphqlDataSourceBadge({required this.source, super.key});

  final GraphqlDataSource source;

  @override
  Widget build(final BuildContext context) {
    if (source == GraphqlDataSource.unknown) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final String label = switch (source) {
      GraphqlDataSource.cache => l10n.graphqlSampleDataSourceCache,
      GraphqlDataSource.supabaseEdge =>
        l10n.graphqlSampleDataSourceSupabaseEdge,
      GraphqlDataSource.supabaseTables =>
        l10n.graphqlSampleDataSourceSupabaseTables,
      GraphqlDataSource.remote => l10n.graphqlSampleDataSourceRemote,
      GraphqlDataSource.unknown => '',
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
