import 'dart:io';

import 'package:path/path.dart' as p;

/// Resolves how to spawn the out-of-process agent engine.
final class AgentEngineLaunchSpec {
  const new({
    required this.executable,
    required this.arguments,
    required this.description,
  });

  final String executable;
  final List<String> arguments;
  final String description;
}

/// Prefers `AGENT_ENGINE_PATH`, then a built Rust binary under
/// `native/agent_engine/target/{release,debug}/agent_engine`, else the labeled
/// Dart subprocess stub (same JSON-RPC protocol, still a separate process).
final class AgentEngineLauncher {
  const new({this.repoRootOverride});

  /// Optional repo root for tests; defaults to walking up from current directory.
  final String? repoRootOverride;

  AgentEngineLaunchSpec resolve() {
    final String? fromEnv = Platform.environment['AGENT_ENGINE_PATH'];
    if (fromEnv != null && fromEnv.trim().isNotEmpty) {
      final File file = File(fromEnv.trim());
      if (file.existsSync()) {
        return AgentEngineLaunchSpec(
          executable: file.absolute.path,
          arguments: const <String>[],
          description: 'env:AGENT_ENGINE_PATH → ${file.absolute.path}',
        );
      }
    }

    final String? root = _findRepoRoot();
    if (root != null) {
      for (final String rel in const <String>[
        'native/agent_engine/target/release/agent_engine',
        'native/agent_engine/target/debug/agent_engine',
      ]) {
        final File candidate = File(p.join(root, rel));
        if (candidate.existsSync()) {
          return AgentEngineLaunchSpec(
            executable: candidate.absolute.path,
            arguments: const <String>[],
            description: 'rust:${candidate.absolute.path}',
          );
        }
      }

      final String stub = p.join(
        root,
        'tool/agent_engine_dart_stub/bin/agent_engine_stub.dart',
      );
      if (File(stub).existsSync()) {
        final String dartExecutable = _resolveDartExecutable();
        return AgentEngineLaunchSpec(
          executable: dartExecutable,
          arguments: <String>[stub],
          description: 'dart-stub:$stub',
        );
      }
    }

    throw StateError(
      'No agent engine found. Build native/agent_engine or set AGENT_ENGINE_PATH.',
    );
  }

  String? _findRepoRoot() {
    if (repoRootOverride != null) {
      return repoRootOverride;
    }
    Directory dir = Directory.current;
    for (var i = 0; i < 12; i++) {
      final bool hasNative = Directory(
        p.join(dir.path, 'native', 'agent_engine'),
      ).existsSync();
      final bool hasPubspec = File(p.join(dir.path, 'pubspec.yaml'))
          .existsSync();
      if (hasNative && hasPubspec) {
        return dir.path;
      }
      final Directory parent = dir.parent;
      if (parent.path == dir.path) {
        break;
      }
      dir = parent;
    }
    return null;
  }

  /// Prefer a real `dart` SDK binary so the stub runs as a separate process.
  /// `Platform.resolvedExecutable` is often the Flutter/tester binary.
  static String _resolveDartExecutable() {
    try {
      final ProcessResult which = Process.runSync('which', const <String>[
        'dart',
      ]);
      if (which.exitCode == 0) {
        final String path = (which.stdout as String).trim();
        if (path.isNotEmpty && File(path).existsSync()) {
          return path;
        }
      }
    } on Object {
      // Fall through.
    }
    return Platform.resolvedExecutable;
  }
}
