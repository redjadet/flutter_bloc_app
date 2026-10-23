part of 'json_rpc_agent_session.dart';

extension on JsonRpcAgentSession {
  Future<AgentEngineInfo> _pingRpc() async {
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

  Future<int> _streamDemoRpc({required int count}) async {
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
    // check-ignore: small payload (<8KB) - single JSON-RPC request line
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
      // check-ignore: small payload (<8KB) - single NDJSON agent line
      decoded = jsonDecode(trimmed);
    } on FormatException {
      throw const AgentCommsTransportFailure('Malformed JSON from agent');
    }
    if (decoded is! Map) {
      throw const AgentCommsTransportFailure('Agent message was not an object');
    }
    final Map<String, Object?> map = Map<String, Object?>.from(decoded);
    _dispatchDecoded(map);
  }

  void _dispatchDecoded(Map<String, Object?> map) {
    final Object? method = map['method'];
    if (method == 'agent/event') {
      _handleAgentEvent(map['params']);
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

  void _handleAgentEvent(Object? params) {
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
  }

  void _onTransportError(Object error) {
    final AgentCommsFailure failure = error is AgentCommsFailure
        ? error
        : AgentCommsTransportFailure('$error');
    final Process? process = _process;
    final int epoch = _processEpoch;
    _failAllPending(failure);
    _emitFault(failure);
    if (process != null) {
      process.kill();
      _clearProcess(epoch: epoch);
    }
  }

  void _emitFault(AgentCommsFailure failure) {
    if (!_faults.isClosed) {
      _faults.add(failure);
    }
  }

  void _failAllPending(AgentCommsFailure failure) {
    for (final Completer<Map<String, Object?>> c in _pending.values.toList()) {
      if (!c.isCompleted) {
        c.completeError(failure);
      }
    }
    _pending.clear();
  }
}
