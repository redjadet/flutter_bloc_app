import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc_app/features/agent_comms_demo/data/bounded_ndjson_line_splitter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BoundedNdjsonLineSplitter', () {
    test('emits complete lines under the limit', () async {
      final Stream<String> lines = Stream<List<int>>.fromIterable(<List<int>>[
        utf8.encode('{"a":1}\n'),
        utf8.encode('{"b":2}\n'),
      ]).transform(const BoundedNdjsonLineSplitter(maxLineBytes: 64));

      expect(await lines.toList(), <String>['{"a":1}', '{"b":2}']);
    });

    test('errors when a line exceeds the byte limit', () async {
      final List<int> oversized = List<int>.filled(20, 0x61); // 'a' * 20
      final Stream<String> lines = Stream<List<int>>.value(oversized)
          .transform(const BoundedNdjsonLineSplitter(maxLineBytes: 8));

      await expectLater(lines, emitsError(isA<StateError>()));
    });
  });
}
