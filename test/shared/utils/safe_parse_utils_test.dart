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
}
