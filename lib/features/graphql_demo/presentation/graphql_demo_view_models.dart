import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';

class GraphqlFilterBarData {
  const GraphqlFilterBarData({
    required this.continents,
    required this.activeContinentCode,
    required this.isLoading,
  });

  final List<GraphqlContinent> continents;
  final String? activeContinentCode;
  final bool isLoading;
}

class GraphqlBodyData {
  const GraphqlBodyData({
    required this.isLoading,
    required this.hasError,
    required this.countries,
    required this.errorType,
    required this.errorMessage,
  });

  final bool isLoading;
  final bool hasError;
  final List<GraphqlCountry> countries;
  final GraphqlDemoErrorType? errorType;
  final String? errorMessage;
}
