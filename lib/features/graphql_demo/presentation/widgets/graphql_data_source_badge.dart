import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_data_source.dart';

/// Badge widget that displays the data source (Cache or Remote).
class GraphqlDataSourceBadge extends StatelessWidget {
  const GraphqlDataSourceBadge({required this.source, super.key});

  final GraphqlDataSource source;

  @override
  Widget build(final BuildContext context) {
    if (source == GraphqlDataSource.unknown) {
      return const SizedBox.shrink();
    }
    final bool isCache = source == GraphqlDataSource.cache;
    return Chip(
      label: Text(isCache ? 'Cache' : 'Remote'),
      visualDensity: VisualDensity.compact,
    );
  }
}
