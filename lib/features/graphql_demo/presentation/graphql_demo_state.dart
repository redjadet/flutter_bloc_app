import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_data_source.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'graphql_demo_state.freezed.dart';

@freezed
abstract class GraphqlDemoState with _$GraphqlDemoState {
  const factory GraphqlDemoState({
    @Default(ViewStatus.initial) final ViewStatus status,
    @Default(<GraphqlCountry>[]) final List<GraphqlCountry> countries,
    @Default(<GraphqlContinent>[]) final List<GraphqlContinent> continents,
    final String? activeContinentCode,
    final String? errorMessage,
    final GraphqlDemoErrorType? errorType,
    @Default(GraphqlDataSource.unknown) final GraphqlDataSource dataSource,
  }) = _GraphqlDemoState;

  const GraphqlDemoState._();

  bool get isLoading => status.isLoading;
  bool get hasError =>
      status.isError && (errorMessage != null || errorType != null);
}
