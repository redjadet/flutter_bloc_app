// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graphql_country.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GraphqlContinent _$GraphqlContinentFromJson(Map<String, dynamic> json) =>
    _GraphqlContinent(
      code: json['code'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$GraphqlContinentToJson(_GraphqlContinent instance) =>
    <String, dynamic>{'code': instance.code, 'name': instance.name};

_GraphqlCountry _$GraphqlCountryFromJson(Map<String, dynamic> json) =>
    _GraphqlCountry(
      code: json['code'] as String,
      name: json['name'] as String,
      continent: GraphqlContinent.fromJson(
        json['continent'] as Map<String, dynamic>,
      ),
      capital: json['capital'] as String?,
      currency: json['currency'] as String?,
      emoji: json['emoji'] as String?,
    );

Map<String, dynamic> _$GraphqlCountryToJson(_GraphqlCountry instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'continent': instance.continent,
      'capital': instance.capital,
      'currency': instance.currency,
      'emoji': instance.emoji,
    };
