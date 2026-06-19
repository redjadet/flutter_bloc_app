import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';

class GraphqlContinentDto {
  GraphqlContinentDto({required this.code, required this.name});

  factory GraphqlContinentDto.fromJson(final Map<String, dynamic> json) =>
      GraphqlContinentDto(
        code: json['code'] as String,
        name: json['name'] as String,
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
        code: json['code'] as String,
        name: json['name'] as String,
        continent: GraphqlContinentDto.fromJson(
          json['continent'] as Map<String, dynamic>,
        ),
        capital: json['capital'] as String?,
        currency: json['currency'] as String?,
        emoji: json['emoji'] as String?,
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
