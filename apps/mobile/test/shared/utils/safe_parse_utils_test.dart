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

  group('intFromDynamic', () {
    test('parses int, num, and trimmed strings', () {
      expect(intFromDynamic(7), 7);
      expect(intFromDynamic(3.9), 3);
      expect(intFromDynamic(' 12 '), 12);
      expect(intFromDynamic('not-a-number'), isNull);
      expect(intFromDynamic(null), isNull);
      expect(intFromDynamic(true), isNull);
    });
  });

  group('doubleFromDynamic', () {
    test('parses num and strings or returns fallback', () {
      expect(doubleFromDynamic(2.5, 0), 2.5);
      expect(doubleFromDynamic('3.14', 0), closeTo(3.14, 0.001));
      expect(doubleFromDynamic('bad', 1.5), 1.5);
      expect(doubleFromDynamic(null, 9), 9);
    });
  });

  group('mapFromDynamic', () {
    test('returns typed map or coerces object-key map', () {
      expect(mapFromDynamic(<String, dynamic>{'a': 1}), <String, dynamic>{
        'a': 1,
      });
      expect(mapFromDynamic(<Object?, Object?>{'b': 2}), <String, dynamic>{
        'b': 2,
      });
      expect(mapFromDynamic(<int>[1]), isNull);
    });
  });

  group('stringFromDynamic', () {
    test('returns string or null', () {
      expect(stringFromDynamic('x'), 'x');
      expect(stringFromDynamic(1), isNull);
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
