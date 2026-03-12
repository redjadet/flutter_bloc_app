import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';

/// Parses raw Supabase response into continents; skips invalid items and logs.
List<GraphqlContinent> parseGraphqlContinentsFromRaw(final Object? raw) {
  final List<dynamic>? list = listFromDynamic(raw);
  if (list == null || list.isEmpty) {
    return const <GraphqlContinent>[];
  }
  final List<GraphqlContinent> out = <GraphqlContinent>[];
  for (final dynamic item in list) {
    final Map<String, dynamic>? map = mapFromDynamic(item);
    if (map == null) continue;
    try {
      out.add(GraphqlContinent.fromJson(map));
    } on Object catch (error, stackTrace) {
      AppLogger.warning(
        'SupabaseGraphqlDemoRepository skip invalid continent row',
      );
      AppLogger.error(
        'supabase_graphql_demo_parsers.parseGraphqlContinentsFromRaw',
        error,
        stackTrace,
      );
    }
  }
  return List<GraphqlContinent>.unmodifiable(out);
}

/// Parses raw Supabase response into countries; skips invalid items and logs.
List<GraphqlCountry> parseGraphqlCountriesFromRaw(final Object? raw) {
  final List<dynamic>? list = listFromDynamic(raw);
  if (list == null || list.isEmpty) {
    return const <GraphqlCountry>[];
  }
  final List<GraphqlCountry> out = <GraphqlCountry>[];
  for (final dynamic item in list) {
    final Map<String, dynamic>? map = mapFromDynamic(item);
    if (map == null) continue;
    try {
      out.add(GraphqlCountry.fromJson(map));
    } on Object catch (error, stackTrace) {
      AppLogger.warning(
        'SupabaseGraphqlDemoRepository skip invalid country row',
      );
      AppLogger.error(
        'supabase_graphql_demo_parsers.parseGraphqlCountriesFromRaw',
        error,
        stackTrace,
      );
    }
  }
  return List<GraphqlCountry>.unmodifiable(out);
}
