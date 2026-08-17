import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:utilities/utilities.dart';

part 'graphql_demo_view_models.freezed.dart';

@freezed
abstract class GraphqlFilterBarData with _$GraphqlFilterBarData {
  const factory GraphqlFilterBarData({
    required List<GraphqlContinent> continents,
    required String? activeContinentCode,
    required bool isLoading,
  }) = _GraphqlFilterBarData;
}

@freezed
abstract class GraphqlBodyData with _$GraphqlBodyData {
  const factory GraphqlBodyData({
    required bool isLoading,
    required bool hasError,
    required List<GraphqlCountry> countries,
    required GraphqlDemoErrorType? errorType,
    required String? errorMessage,
    AppError? lastError,
  }) = _GraphqlBodyData;
}
