import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc_app/features/agent_comms_demo/data/agent_engine_launcher.dart';
import 'package:flutter_bloc_app/features/agent_comms_demo/domain/agent_comms_failure.dart';
import 'package:flutter_bloc_app/features/agent_comms_demo/domain/agent_engine_info.dart';
import 'package:flutter_bloc_app/features/agent_comms_demo/domain/agent_engine_session.dart';

/// JSON-RPC 2.0 client over a child process stdio (newline-delimited).
///
/// Keeps the agent in a **separate OS process** for fault isolation.
final class JsonRpcAgentSession implements AgentEngineSession {
  new({AgentEngineLauncher? launcher})
    : _launcher = launcher ?? const AgentEngineLauncher();

  final AgentEngineLauncher _launcher;
  final StreamController<AgentEngineEvent> _events =
      StreamController<AgentEngineEvent>.broadcast();
  final StreamController<AgentCommsFailure> _faults =
      StreamController<AgentCommsFailure>.broadcast();

  Process? _process;
  int _processEpoch = 0;
  Future<void>? _starting;
  bool _disposeRequested = false;
  StreamSubscription<String>? _stdoutSub;
  StreamSubscription<String>? _stderrSub;
  StreamSubscription<void>? _stdinDoneSub;
  final Map<int, Completer<Map<String, Object?>>> _pending =
      <int, Completer<Map<String, Object?>>>{};
  int _nextId = 1;
  String? _launcherDescription;

  @override
  Stream<AgentEngineEvent> get events => _events.stream;

  @override
  Stream<AgentCommsFailure> get faults => _faults.stream;

  @override
  bool get isConnected => _process != null;

  @override
  String? get launcherDescription => _launcherDescription;

  @override
  Future<void> connect() async {
    if (_process != null) {
      return;
    }
    if (_starting != null) {
      await _starting;
      return;
    }
    _disposeRequested = false;
    final Completer<void> started = Completer<void>();
    _starting = started.future;
    try {
      final AgentEngineLaunchSpec spec = _launcher.resolve();
      _launcherDescription = spec.description;
      final Process process = await Process.start(
        spec.executable,
        spec.arguments,
      );
      if (_disposeRequested) {
        process.kill();
        unawaited(
          process.exitCode.timeout(
            const Duration(seconds: 2),
            onTimeout: () {
              process.kill(ProcessSignal.sigkill);
              return -1;
            },
          ),
        );
        throw const AgentCommsUnavailableFailure(
          'Connect cancelled (session disposed during startup)',
        );
      }
      final int epoch = ++_processEpoch;
      _process = process;
      _stdoutSub = process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            try {
              _onStdoutLine(line);
            } on Object catch (error) {
              _onTransportError(error);
            }
          }, onError: _onTransportError);
      _stderrSub = process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((_) {}, onError: (_) {});
      _stdinDoneSub = process.stdin.done.asStream().listen(
        (_) {},
        onError: (Object error) {
          _onTransportError(
            AgentCommsTransportFailure('Agent stdin closed: $error'),
          );
        },
      );
      unawaited(
        process.exitCode.then((code) {
          if (_processEpoch != epoch || !identical(_process, process)) {
            return;
          }
          final AgentCommsTransportFailure failure = AgentCommsTransportFailure(
            'Agent process exited ($code)',
          );
          _failAllPending(failure);
          _emitFault(failure);
          _clearProcess(epoch: epoch);
        }),
      );
      started.complete();
    } on AgentCommsFailure {
      started.complete();
      rethrow;
    } on Object catch (e) {
      started.complete();
      _clearProcess();
      throw AgentCommsUnavailableFailure('Failed to start agent engine: $e');
    } finally {
      _starting = null;
    }
  }

  @override
  Future<AgentEngineInfo> ping() async {
    final Map<String, Object?> result = await _request('ping');
    final Object? engine = result['engine'];
    final Object? version = result['version'];
    final Object? pid = result['pid'];
    if (engine is! String || version is! String || pid is! num) {
      throw const AgentCommsTransportFailure(
        'ping result missing string engine/version or numeric pid',
      );
    }
    return AgentEngineInfo(engine: engine, version: version, pid: pid.toInt());
  }

  @override
  Future<int> streamDemo({int count = 3}) async {
    final Map<String, Object?> result = await _request(
      'agent/streamDemo',
      params: <String, Object?>{'count': count},
    );
    final Object? streamed = result['streamed'];
    if (streamed is! num) {
      throw const AgentCommsTransportFailure(
        'streamDemo result missing numeric streamed',
      );
    }
    return streamed.toInt();
  }

  @override
  Future<void> disconnect() async {
    _disposeRequested = true;
    final Process? process = _process;
    final int epoch = _processEpoch;
    if (process == null) {
      return;
    }
    try {
      await _request('shutdown').timeout(const Duration(milliseconds: 400));
    } on Object {
      // Best-effort; kill below.
    }
    process.kill();
    try {
      await process.exitCode.timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          process.kill(ProcessSignal.sigkill);
          return -1;
        },
      );
    } on Object {
      // Already exited or kill failed.
    }
    _clearProcess(epoch: epoch);
  }

  Future<Map<String, Object?>> _request(
    String method, {
    Map<String, Object?> params = const <String, Object?>{},
  }) async {
    final Process? process = _process;
    if (process == null) {
      throw const AgentCommsNotConnectedFailure();
    }
    final int id = _nextId++;
    final Completer<Map<String, Object?>> completer =
        Completer<Map<String, Object?>>();
    _pending[id] = completer;
    final String payload = jsonEncode(<String, Object?>{
      'jsonrpc': '2.0',
      'id': id,
      'method': method,
      'params': params,
    });
    try {
      process.stdin.writeln(payload);
    } on Object catch (e) {
      _pending.remove(id);
      throw AgentCommsTransportFailure('Failed to write RPC request: $e');
    }
    try {
      return await completer.future.timeout(const Duration(seconds: 5));
    } on TimeoutException {
      _pending.remove(id);
      throw const AgentCommsTransportFailure('RPC timed out');
    }
  }

  void _onStdoutLine(String line) {
    final String trimmed = line.trim();
    if (trimmed.isEmpty) {
      return;
    }
    late final Object? decoded;
    try {
      decoded = jsonDecode(trimmed);
    } on FormatException {
      throw const AgentCommsTransportFailure('Malformed JSON from agent');
    }
    if (decoded is! Map) {
      throw const AgentCommsTransportFailure('Agent message was not an object');
    }
    final Map<String, Object?> map = Map<String, Object?>.from(decoded);

    final Object? method = map['method'];
    if (method == 'agent/event') {
      final Object? params = map['params'];
      if (params is! Map) {
        throw const AgentCommsTransportFailure(
          'agent/event params must be an object',
        );
      }
      final Map<String, Object?> p = Map<String, Object?>.from(params);
      final Object? type = p['type'];
      final Object? message = p['message'];
      if (type is! String || message is! String) {
        throw const AgentCommsTransportFailure(
          'agent/event requires string type and message',
        );
      }
      if (!_events.isClosed) {
        _events.add(
          AgentEngineEvent(
            type: type,
            message: message,
            index: (p['index'] as num?)?.toInt(),
            total: (p['total'] as num?)?.toInt(),
          ),
        );
      }
      return;
    }

    final Object? id = map['id'];
    if (id is! int) {
      return;
    }
    final Completer<Map<String, Object?>>? completer = _pending.remove(id);
    if (completer == null || completer.isCompleted) {
      return;
    }
    final Object? error = map['error'];
    if (error is Map) {
      final Map<String, Object?> err = Map<String, Object?>.from(error);
      completer.completeError(
        AgentCommsRpcFailure(
          err['message'] as String? ?? 'RPC error',
          code: (err['code'] as num?)?.toInt(),
        ),
      );
      return;
    }
    final Object? result = map['result'];
    if (result is Map) {
      completer.complete(Map<String, Object?>.from(result));
    } else {
      completer.complete(<String, Object?>{});
    }
  }

  void _onTransportError(Object error) {
    final AgentCommsFailure failure = error is AgentCommsFailure
        ? error
        : AgentCommsTransportFailure('$error');
    _failAllPending(failure);
    _emitFault(failure);
  }

  void _emitFault(AgentCommsFailure failure) {
    if (!_faults.isClosed) {
      _faults.add(failure);
    }
  }

  void _failAllPending(AgentCommsFailure failure) {
    for (final Completer<Map<String, Object?>> c in _pending.values) {
      if (!c.isCompleted) {
        c.completeError(failure);
      }
    }
    _pending.clear();
  }

  void _clearProcess({int? epoch}) {
    if (epoch != null && epoch != _processEpoch) {
      return;
    }
    unawaited(_stdoutSub?.cancel() ?? Future<void>.value());
    unawaited(_stderrSub?.cancel() ?? Future<void>.value());
    unawaited(_stdinDoneSub?.cancel() ?? Future<void>.value());
    _stdoutSub = null;
    _stderrSub = null;
    _stdinDoneSub = null;
    _process = null;
  }
}
