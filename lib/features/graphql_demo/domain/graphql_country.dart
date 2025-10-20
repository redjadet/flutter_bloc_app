import 'package:freezed_annotation/freezed_annotation.dart';

part 'graphql_country.freezed.dart';
part 'graphql_country.g.dart';

@freezed
abstract class GraphqlContinent with _$GraphqlContinent {
  const factory GraphqlContinent({
    required final String code,
    required final String name,
  }) = _GraphqlContinent;

  factory GraphqlContinent.fromJson(final Map<String, dynamic> json) =>
      _$GraphqlContinentFromJson(json);
}

@freezed
abstract class GraphqlCountry with _$GraphqlCountry {
  const factory GraphqlCountry({
    required final String code,
    required final String name,
    required final GraphqlContinent continent,
    final String? capital,
    final String? currency,
    final String? emoji,
  }) = _GraphqlCountry;

  factory GraphqlCountry.fromJson(final Map<String, dynamic> json) =>
      _$GraphqlCountryFromJson(json);
}
