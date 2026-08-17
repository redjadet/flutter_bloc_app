import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_data_source.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:utilities/utilities.dart';

part 'graphql_demo_state.freezed.dart';

@freezed
abstract class GraphqlDemoState with _$GraphqlDemoState {
  const factory GraphqlDemoState({
    @Default(ViewStatus.initial) ViewStatus status,
    @Default(<GraphqlCountry>[]) List<GraphqlCountry> countries,
    @Default(<GraphqlContinent>[]) List<GraphqlContinent> continents,
    String? activeContinentCode,
    String? errorMessage,
    GraphqlDemoErrorType? errorType,
    AppError? lastError,
    @Default(GraphqlDataSource.unknown) GraphqlDataSource dataSource,
  }) = _GraphqlDemoState;

  const GraphqlDemoState._();

  bool get isLoading => status.isLoading;
  bool get hasError =>
      status.isError &&
      (errorMessage != null || errorType != null || lastError != null);
}
