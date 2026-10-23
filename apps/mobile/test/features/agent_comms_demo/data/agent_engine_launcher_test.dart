import 'dart:io';

import 'package:flutter_bloc_app/features/agent_comms_demo/data/agent_engine_launcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('resolves rust binary or dart stub under repo root', () {
    final String root = _findRepoRoot();
    final AgentEngineLaunchSpec spec = AgentEngineLauncher(
      repoRootOverride: root,
    ).resolve();

    final bool isRust = spec.description.startsWith('rust:');
    final bool isStub = spec.description.startsWith('dart-stub:');
    expect(isRust || isStub, isTrue);

    if (isStub) {
      expect(spec.arguments.single, endsWith('agent_engine_stub.dart'));
      expect(File(spec.arguments.single).existsSync(), isTrue);
    } else {
      expect(File(spec.executable).existsSync(), isTrue);
      expect(spec.executable, contains('agent_engine'));
    }
  });
}

String _findRepoRoot() {
  Directory dir = Directory.current;
  for (var i = 0; i < 12; i++) {
    if (Directory(p.join(dir.path, 'native', 'agent_engine')).existsSync() &&
        File(p.join(dir.path, 'pubspec.yaml')).existsSync()) {
      return dir.path;
    }
    final Directory parent = dir.parent;
    if (parent.path == dir.path) {
      break;
    }
    dir = parent;
  }
  fail('repo root not found from ${Directory.current.path}');
}
