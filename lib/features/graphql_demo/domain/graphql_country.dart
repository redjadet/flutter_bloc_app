import 'package:freezed_annotation/freezed_annotation.dart';

part 'graphql_country.freezed.dart';
part 'graphql_country.g.dart';

@freezed
abstract class GraphqlContinent with _$GraphqlContinent {
  const factory GraphqlContinent({required String code, required String name}) =
      _GraphqlContinent;

  factory GraphqlContinent.fromJson(Map<String, dynamic> json) =>
      _$GraphqlContinentFromJson(json);
}

@freezed
abstract class GraphqlCountry with _$GraphqlCountry {
  const factory GraphqlCountry({
    required String code,
    required String name,
    String? capital,
    String? currency,
    String? emoji,
    required GraphqlContinent continent,
  }) = _GraphqlCountry;

  factory GraphqlCountry.fromJson(Map<String, dynamic> json) =>
      _$GraphqlCountryFromJson(json);
}
