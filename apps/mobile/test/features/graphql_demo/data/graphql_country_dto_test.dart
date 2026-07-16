import 'package:flutter_bloc_app/features/graphql_demo/data/graphql_country_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GraphqlCountryDto', () {
    test('maps valid JSON to domain', () {
      final GraphqlCountryDto dto = GraphqlCountryDto.fromJson(
        <String, dynamic>{
          'code': 'TR',
          'name': 'Turkey',
          'continent': <String, dynamic>{'code': 'AS', 'name': 'Asia'},
          'capital': 'Ankara',
          'currency': 'TRY',
          'emoji': '🇹🇷',
          'unexpected_field': true,
        },
      );

      final domain = dto.toDomain();
      expect(domain.code, 'TR');
      expect(domain.continent.code, 'AS');
      expect(domain.capital, 'Ankara');
    });

    test('throws FormatException when continent is missing', () {
      expect(
        () => GraphqlCountryDto.fromJson(<String, dynamic>{
          'code': 'TR',
          'name': 'Turkey',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when continent shape is malformed', () {
      expect(
        () => GraphqlCountryDto.fromJson(<String, dynamic>{
          'code': 'TR',
          'name': 'Turkey',
          'continent': 'Asia',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('does not include untrusted payload values in parse failures', () {
      const String sensitiveValue = 'customer@example.com';

      expect(
        () => GraphqlCountryDto.fromJson(<String, dynamic>{
          'code': 'TR',
          'name': 'Turkey',
          'continent': sensitiveValue,
        }),
        throwsA(
          isA<FormatException>().having(
            (final error) => error.message,
            'message',
            allOf(contains('String'), isNot(contains(sensitiveValue))),
          ),
        ),
      );
    });
  });
}
