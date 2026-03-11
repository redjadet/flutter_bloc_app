import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('boolFromDynamic', () {
    test('parses bool values', () {
      expect(boolFromDynamic(true, fallback: false), isTrue);
      expect(boolFromDynamic(false, fallback: true), isFalse);
    });

    test('parses numeric and string bool-like values', () {
      expect(boolFromDynamic(1, fallback: false), isTrue);
      expect(boolFromDynamic(0, fallback: true), isFalse);
      expect(boolFromDynamic('true', fallback: false), isTrue);
      expect(boolFromDynamic('false', fallback: true), isFalse);
      expect(boolFromDynamic(' 1 ', fallback: false), isTrue);
      expect(boolFromDynamic(' 0 ', fallback: true), isFalse);
    });

    test('returns fallback for unsupported values', () {
      expect(boolFromDynamic('maybe', fallback: true), isTrue);
      expect(boolFromDynamic(<String, dynamic>{}, fallback: false), isFalse);
      expect(boolFromDynamic(null, fallback: true), isTrue);
    });
  });

  group('parseMapOfMaps', () {
    test('returns empty list for null or non-map value', () {
      expect(
        parseMapOfMaps<int>(null, logContext: 'test', parseItem: (_, _) => 1),
        isEmpty,
      );
      expect(
        parseMapOfMaps<int>(
          <int>[],
          logContext: 'test',
          parseItem: (_, _) => 1,
        ),
        isEmpty,
      );
    });

    test('parses map entries and skips non-map values', () {
      final Map<String, dynamic> input = <String, dynamic>{
        'a': <String, dynamic>{'v': 1},
        'b': 99,
        'c': <String, dynamic>{'v': 2},
      };
      final List<int> out = parseMapOfMaps<int>(
        input,
        logContext: 'test',
        parseItem: (_, map) => map['v'] as int?,
      );
      expect(out, orderedEquals(<int>[1, 2]));
    });

    test('skips entries that return null', () {
      final Map<String, dynamic> input = <String, dynamic>{
        'a': <String, dynamic>{'v': 1},
        'b': <String, dynamic>{'skip': true},
      };
      final List<int> out = parseMapOfMaps<int>(
        input,
        logContext: 'test',
        parseItem: (_, map) => map['v'] != null ? map['v'] as int : null,
      );
      expect(out, orderedEquals(<int>[1]));
    });

    test('skips entries that throw non-Exception errors during parsing', () {
      final Map<String, dynamic> input = <String, dynamic>{
        'a': <String, dynamic>{'v': 1},
        'b': <String, dynamic>{'v': 'oops'},
      };
      final List<int> out = parseMapOfMaps<int>(
        input,
        logContext: 'test',
        parseItem: (_, map) => map['v'] as int,
      );
      expect(out, orderedEquals(<int>[1]));
    });
  });
}
