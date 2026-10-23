import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc_app/features/agent_comms_demo/data/agent_engine_launcher.dart';
import 'package:flutter_bloc_app/features/agent_comms_demo/domain/agent_comms_failure.dart';
import 'package:flutter_bloc_app/features/agent_comms_demo/domain/agent_engine_info.dart';
import 'package:flutter_bloc_app/features/agent_comms_demo/domain/agent_engine_session.dart';

part 'json_rpc_agent_session_io.part.dart';

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
      await _startProcess(started);
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

  Future<void> _startProcess(Completer<void> started) async {
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
    _attachIo(process, epoch);
    started.complete();
  }

  void _attachIo(Process process, int epoch) {
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

  @override
  Future<AgentEngineInfo> ping() => _pingRpc();

  @override
  Future<int> streamDemo({int count = 3}) => _streamDemoRpc(count: count);

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

  @override
  Future<void> dispose() async {
    await disconnect();
    await _events.close();
    await _faults.close();
  }
}
