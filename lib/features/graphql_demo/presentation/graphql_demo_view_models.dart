import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'graphql_demo_view_models.freezed.dart';

@freezed
abstract class GraphqlFilterBarData with _$GraphqlFilterBarData {
  const factory GraphqlFilterBarData({
    required final List<GraphqlContinent> continents,
    required final String? activeContinentCode,
    required final bool isLoading,
  }) = _GraphqlFilterBarData;
}

@freezed
abstract class GraphqlBodyData with _$GraphqlBodyData {
  const factory GraphqlBodyData({
    required final bool isLoading,
    required final bool hasError,
    required final List<GraphqlCountry> countries,
    required final GraphqlDemoErrorType? errorType,
    required final String? errorMessage,
  }) = _GraphqlBodyData;
}
