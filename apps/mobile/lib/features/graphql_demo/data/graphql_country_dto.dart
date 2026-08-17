import 'package:flutter_bloc_app/features/graphql_demo/data/graphql_json.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';

class GraphqlContinentDto({
  required final String code,
  required final String name,
}) {
  factory GraphqlContinentDto.fromJson(Map<String, dynamic> json) =>
      GraphqlContinentDto(
        code: requireGraphqlString(json, 'code'),
        name: requireGraphqlString(json, 'name'),
      );

  GraphqlContinent toDomain() => GraphqlContinent(code: code, name: name);
}

class GraphqlCountryDto({
  required final String code,
  required final String name,
  required final GraphqlContinentDto continent,
  final String? capital,
  final String? currency,
  final String? emoji,
}) {
  factory GraphqlCountryDto.fromJson(Map<String, dynamic> json) =>
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

  GraphqlCountry toDomain() => GraphqlCountry(
    code: code,
    name: name,
    continent: continent.toDomain(),
    capital: capital,
    currency: currency,
    emoji: emoji,
  );
}
