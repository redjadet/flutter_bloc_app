#!/usr/bin/env dart

// Demo fallback: Dart subprocess that preserves the process boundary when the
// Rust agent_engine binary is not built. Labeled clearly — prefer the Rust
// engine under native/agent_engine when rustc/cargo are available.
//
// Protocol: newline-delimited JSON-RPC 2.0 on stdio (same as Rust stub).

import 'dart:async';
import 'dart:convert';
import 'dart:io';

const String engineName = 'dart-agent-engine-stub';
const String engineVersion = '0.1.0';

Future<void> main() async {
  stderr.writeln(
    'agent_engine_stub ready name=$engineName version=$engineVersion '
    'pid=${pid}',
  );

  await for (final line
      in stdin.transform(utf8.decoder).transform(const LineSplitter())) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) {
      continue;
    }
    Map<String, Object?> request;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is! Map) {
        _writeError(null, -32700, 'parse error: expected object');
        continue;
      }
      request = Map<String, Object?>.from(decoded);
    } on FormatException catch (e) {
      _writeError(null, -32700, 'parse error: $e');
      continue;
    }

    if (request['jsonrpc'] != '2.0') {
      _writeError(request['id'], -32600, 'invalid jsonrpc version');
      continue;
    }

    final method = request['method'];
    final id = request['id'];
    final params = request['params'];

    switch (method) {
      case 'ping':
        _writeResult(id, <String, Object?>{
          'ok': true,
          'engine': engineName,
          'version': engineVersion,
          'pid': pid,
        });
      case 'agent/streamDemo':
        var count = 3;
        if (params is Map && params['count'] is num) {
          count = (params['count'] as num).toInt().clamp(1, 8);
        }
        unawaited(_streamDemo(id, count));
      case 'shutdown':
        _writeResult(id, <String, Object?>{'shuttingDown': true});
        return;
      default:
        _writeError(id, -32601, 'method not found: $method');
    }
  }
}

Future<void> _streamDemo(Object? id, int count) async {
  for (var i = 1; i <= count; i++) {
    _writeNotification(<String, Object?>{
      'type': 'progress',
      'index': i,
      'total': count,
      'message': 'stub tick $i/$count',
    });
    await Future<void>.delayed(const Duration(milliseconds: 40));
  }
  _writeResult(id, <String, Object?>{'streamed': count, 'engine': engineName});
}

void _writeResult(Object? id, Map<String, Object?> result) {
  if (id == null) {
    return;
  }
  stdout.writeln(
    jsonEncode(<String, Object?>{'jsonrpc': '2.0', 'id': id, 'result': result}),
  );
}

void _writeError(Object? id, int code, String message) {
  stdout.writeln(
    jsonEncode(<String, Object?>{
      'jsonrpc': '2.0',
      'id': id,
      'error': <String, Object?>{'code': code, 'message': message},
    }),
  );
}

void _writeNotification(Map<String, Object?> params) {
  stdout.writeln(
    jsonEncode(<String, Object?>{
      'jsonrpc': '2.0',
      'method': 'agent/event',
      'params': params,
    }),
  );
}
