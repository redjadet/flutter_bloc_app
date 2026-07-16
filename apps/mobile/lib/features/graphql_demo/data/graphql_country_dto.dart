import 'package:flutter_bloc_app/features/graphql_demo/data/graphql_json.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';

class GraphqlContinentDto {
  GraphqlContinentDto({required this.code, required this.name});

  factory GraphqlContinentDto.fromJson(final Map<String, dynamic> json) =>
      GraphqlContinentDto(
        code: requireGraphqlString(json, 'code'),
        name: requireGraphqlString(json, 'name'),
      );

  final String code;
  final String name;

  GraphqlContinent toDomain() => GraphqlContinent(code: code, name: name);
}

class GraphqlCountryDto {
  GraphqlCountryDto({
    required this.code,
    required this.name,
    required this.continent,
    this.capital,
    this.currency,
    this.emoji,
  });

  factory GraphqlCountryDto.fromJson(final Map<String, dynamic> json) =>
      GraphqlCountryDto(
        code: requireGraphqlString(json, 'code'),
        name: requireGraphqlString(json, 'name'),
        continent: GraphqlContinentDto.fromJson(
          requireGraphqlMap(json, 'continent'),
        ),
        capital: optionalGraphqlString(json, 'capital'),
        currency: optionalGraphqlString(json, 'currency'),
        emoji: optionalGraphqlString(json, 'emoji'),
      );

  final String code;
  final String name;
  final GraphqlContinentDto continent;
  final String? capital;
  final String? currency;
  final String? emoji;

  GraphqlCountry toDomain() => GraphqlCountry(
    code: code,
    name: name,
    continent: continent.toDomain(),
    capital: capital,
    currency: currency,
    emoji: emoji,
  );
}
