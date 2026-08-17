import 'package:freezed_annotation/freezed_annotation.dart';

part 'graphql_country.freezed.dart';

@freezed
abstract class GraphqlContinent with _$GraphqlContinent {
  const factory GraphqlContinent({
    required String code,
    required String name,
  }) = _GraphqlContinent;
}

@freezed
abstract class GraphqlCountry with _$GraphqlCountry {
  const factory GraphqlCountry({
    required String code,
    required String name,
    required GraphqlContinent continent,
    String? capital,
    String? currency,
    String? emoji,
  }) = _GraphqlCountry;
}
