import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lib trees must not unconditionally accept bad certificates', () {
    final Directory root = Directory.current;
    // Resolve apps/mobile or monorepo root.
    final List<Directory> scanRoots = <Directory>[
      Directory('${root.path}/lib'),
      Directory('${root.path}/../../packages'),
    ];

    final RegExp bypass = RegExp(r'badCertificateCallback\s*=\s*\([^)]*\)\s*=>\s*true');

    final List<String> offenders = <String>[];
    for (final Directory dir in scanRoots) {
      if (!dir.existsSync()) {
        continue;
      }
      for (final FileSystemEntity entity in dir.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }
        if (entity.path.contains('.freezed.dart') || entity.path.contains('.g.dart')) {
          continue;
        }
        final String source = entity.readAsStringSync();
        if (bypass.hasMatch(source)) {
          offenders.add(entity.path);
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Unconditional TLS bypass found in:\n${offenders.join('\n')}',
    );
  });
}
