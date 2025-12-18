import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';

class GraphqlFilterBarData extends Equatable {
  const GraphqlFilterBarData({
    required this.continents,
    required this.activeContinentCode,
    required this.isLoading,
  });

  final List<GraphqlContinent> continents;
  final String? activeContinentCode;
  final bool isLoading;

  @override
  List<Object?> get props => <Object?>[
    continents,
    activeContinentCode,
    isLoading,
  ];
}

class GraphqlBodyData extends Equatable {
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

  @override
  List<Object?> get props => <Object?>[
    isLoading,
    hasError,
    countries,
    errorType,
    errorMessage,
  ];
}
