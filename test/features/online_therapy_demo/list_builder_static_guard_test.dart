import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('online therapy builders do not index live state lists', () {
    final presentationDirs = <Directory>[
      Directory('lib/features/online_therapy_demo/presentation/pages'),
      Directory('lib/features/online_therapy_demo/presentation/widgets'),
    ];
    final offenders = <String>[];

    final files = presentationDirs
        .expand((dir) => dir.listSync(recursive: true))
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var index = 0; index < lines.length; index += 1) {
        final line = lines[index];
        if (RegExp(r'state\.\w+\[index(?:\s*-\s*1)?\]').hasMatch(line)) {
          offenders.add('${file.path}:${index + 1}: ${line.trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'List builders must snapshot state lists into a local immutable list '
          'and guard stale indexes before indexing. Offenders:\n'
          '${offenders.join('\n')}',
    );
  });
}
