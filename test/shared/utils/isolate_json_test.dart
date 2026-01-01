import 'dart:convert';

import 'package:flutter_bloc_app/shared/utils/isolate_json.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('decodeJsonMap', () {
    test('decodes small JSON map synchronously', () async {
      const jsonString = '{"key": "value", "number": 42}';
      final result = await decodeJsonMap(jsonString);

      expect(result, isA<Map<String, dynamic>>());
      expect(result['key'], 'value');
      expect(result['number'], 42);
    });

    test('decodes large JSON map in isolate', () async {
      // Create a JSON string larger than 8KB threshold
      final largeMap = <String, String>{};
      for (int i = 0; i < 1000; i++) {
        largeMap['key_$i'] = _repeat('value_$i', 10); // Pad to make it larger
      }
      final jsonString = jsonEncode(largeMap);
      expect(jsonString.length, greaterThan(8 * 1024));

      final result = await decodeJsonMap(jsonString);

      expect(result, isA<Map<String, dynamic>>());
      expect(result.length, 1000);
      expect(result['key_0'], _repeat('value_0', 10));
      expect(result['key_999'], _repeat('value_999', 10));
    });

    test('throws FormatException for non-map JSON', () async {
      const jsonString = '[1, 2, 3]';

      expect(() => decodeJsonMap(jsonString), throwsA(isA<FormatException>()));
    });

    test('throws FormatException for invalid JSON', () async {
      const jsonString = '{invalid json}';

      expect(() => decodeJsonMap(jsonString), throwsA(isA<FormatException>()));
    });

    test('handles empty map', () async {
      const jsonString = '{}';
      final result = await decodeJsonMap(jsonString);

      expect(result, isA<Map<String, dynamic>>());
      expect(result, isEmpty);
    });

    test('handles nested maps and lists', () async {
      const jsonString = '''
        {
          "nested": {
            "key": "value",
            "list": [1, 2, 3]
          }
        }
      ''';

      final result = await decodeJsonMap(jsonString);

      expect(result, isA<Map<String, dynamic>>());
      expect(result['nested'], isA<Map<String, dynamic>>());
      final nested = result['nested'] as Map<String, dynamic>;
      expect(nested['key'], 'value');
      expect(nested['list'], isA<List<dynamic>>());
      expect(nested['list'], [1, 2, 3]);
    });
  });

  group('decodeJsonList', () {
    test('decodes small JSON list synchronously', () async {
      const jsonString = '[1, 2, 3, "four"]';
      final result = await decodeJsonList(jsonString);

      expect(result, isA<List<dynamic>>());
      expect(result.length, 4);
      expect(result[0], 1);
      expect(result[3], 'four');
    });

    test('decodes large JSON list in isolate', () async {
      // Create a JSON string larger than 8KB threshold
      final largeList = List.generate(
        1000,
        (i) => {
          'id': i,
          'data': _repeat('item_$i', 20), // Pad to make it larger
        },
      );
      final jsonString = jsonEncode(largeList);
      expect(jsonString.length, greaterThan(8 * 1024));

      final result = await decodeJsonList(jsonString);

      expect(result, isA<List<dynamic>>());
      expect(result.length, 1000);
      final firstItem = result[0] as Map<String, dynamic>;
      expect(firstItem['id'], 0);
      expect(firstItem['data'], _repeat('item_0', 20));
    });

    test('throws FormatException for non-list JSON', () async {
      const jsonString = '{"key": "value"}';

      expect(() => decodeJsonList(jsonString), throwsA(isA<FormatException>()));
    });

    test('throws FormatException for invalid JSON', () async {
      const jsonString = '[invalid json';

      expect(() => decodeJsonList(jsonString), throwsA(isA<FormatException>()));
    });

    test('handles empty list', () async {
      const jsonString = '[]';
      final result = await decodeJsonList(jsonString);

      expect(result, isA<List<dynamic>>());
      expect(result, isEmpty);
    });

    test('handles nested structures', () async {
      const jsonString = '''
        [
          {"key": "value1"},
          {"key": "value2", "nested": [1, 2]}
        ]
      ''';

      final result = await decodeJsonList(jsonString);

      expect(result, isA<List<dynamic>>());
      expect(result.length, 2);
      final first = result[0] as Map<String, dynamic>;
      expect(first['key'], 'value1');
      final second = result[1] as Map<String, dynamic>;
      expect(second['nested'], isA<List<dynamic>>());
    });
  });

  group('encodeJsonIsolate', () {
    test('encodes small string synchronously', () async {
      const input = 'small string';
      final result = await encodeJsonIsolate(input);

      expect(result, jsonEncode(input));
    });

    test('encodes large string in isolate', () async {
      // Create a string larger than 8KB
      final largeString = 'x' * (8 * 1024 + 1);
      final result = await encodeJsonIsolate(largeString);

      // All strings are JSON-encoded (adds quotes)
      expect(result, jsonEncode(largeString));
      // Verify it's the JSON-encoded version (with quotes)
      expect(result.startsWith('"'), isTrue);
      expect(result.endsWith('"'), isTrue);
    });

    test('encodes small list synchronously', () async {
      final input = [1, 2, 3, 'four'];
      final result = await encodeJsonIsolate(input);

      expect(result, jsonEncode(input));
      final decoded = jsonDecode(result);
      expect(decoded, input);
    });

    test('encodes small map synchronously', () async {
      final input = {'key1': 'value1', 'key2': 42};
      final result = await encodeJsonIsolate(input);

      expect(result, jsonEncode(input));
      final decoded = jsonDecode(result);
      expect(decoded, input);
    });

    test('encodes large list in isolate', () async {
      // Create a list with more than 20 items
      final largeList = List.generate(50, (i) => {'id': i, 'data': 'item_$i'});
      final result = await encodeJsonIsolate(largeList);

      expect(result, jsonEncode(largeList));
      final decoded = jsonDecode(result);
      expect(decoded, isA<List<dynamic>>());
      expect((decoded as List<dynamic>).length, 50);
    });

    test('encodes large map in isolate', () async {
      // Create a map with more than 20 entries
      final largeMap = <String, dynamic>{};
      for (int i = 0; i < 50; i++) {
        largeMap['key_$i'] = 'value_$i';
      }
      final result = await encodeJsonIsolate(largeMap);

      expect(result, jsonEncode(largeMap));
      final decoded = jsonDecode(result);
      expect(decoded, isA<Map<String, dynamic>>());
      expect((decoded as Map<String, dynamic>).length, 50);
    });

    test('encodes complex nested structures', () async {
      final input = {
        'users': [
          {'id': 1, 'name': 'Alice'},
          {
            'id': 2,
            'name': 'Bob',
            'tags': ['admin', 'developer'],
          },
        ],
        'metadata': {'count': 2, 'timestamp': '2024-01-01T00:00:00Z'},
      };

      final result = await encodeJsonIsolate(input);
      final decoded = jsonDecode(result);

      expect(decoded, isA<Map<String, dynamic>>());
      final decodedMap = decoded as Map<String, dynamic>;
      expect(decodedMap['users'], isA<List<dynamic>>());
      expect((decodedMap['users'] as List<dynamic>).length, 2);
      expect(decodedMap['metadata'], isA<Map<String, dynamic>>());
    });

    test('handles null values', () async {
      final input = {'key1': 'value', 'key2': null, 'key3': 42};
      final result = await encodeJsonIsolate(input);

      final decoded = jsonDecode(result);
      expect(decoded['key1'], 'value');
      expect(decoded['key2'], isNull);
      expect(decoded['key3'], 42);
    });

    test('handles numbers and booleans', () async {
      final input = {
        'integer': 42,
        'double': 3.14,
        'boolean': true,
        'negative': -10,
      };
      final result = await encodeJsonIsolate(input);

      final decoded = jsonDecode(result);
      expect(decoded['integer'], 42);
      expect(decoded['double'], 3.14);
      expect(decoded['boolean'], true);
      expect(decoded['negative'], -10);
    });
  });
}

String _repeat(final String value, final int count) {
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < count; i++) {
    buffer.write(value);
  }
  return buffer.toString();
}
