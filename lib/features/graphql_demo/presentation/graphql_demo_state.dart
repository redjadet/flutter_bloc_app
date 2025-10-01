import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'graphql_demo_state.freezed.dart';

enum GraphqlDemoStatus { initial, loading, success, error }

@freezed
abstract class GraphqlDemoState with _$GraphqlDemoState {
  const factory GraphqlDemoState({
    @Default(GraphqlDemoStatus.initial) GraphqlDemoStatus status,
    @Default(<GraphqlCountry>[]) List<GraphqlCountry> countries,
    @Default(<GraphqlContinent>[]) List<GraphqlContinent> continents,
    String? activeContinentCode,
    String? errorMessage,
  }) = _GraphqlDemoState;

  const GraphqlDemoState._();

  bool get isLoading => status == GraphqlDemoStatus.loading;
  bool get hasError =>
      status == GraphqlDemoStatus.error && errorMessage != null;
}
