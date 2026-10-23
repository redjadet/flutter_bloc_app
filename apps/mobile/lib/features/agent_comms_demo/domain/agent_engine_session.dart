import 'package:flutter_bloc_app/features/agent_comms_demo/domain/agent_engine_info.dart';

/// Port for an out-of-process agent session (JSON-RPC client).
abstract interface class AgentEngineSession {
  Stream<AgentEngineEvent> get events;

  bool get isConnected;

  /// Last resolved launcher description (binary path or dart stub).
  String? get launcherDescription;

  Future<void> connect();

  Future<AgentEngineInfo> ping();

  /// Requests a short demo stream of `agent/event` notifications.
  Future<int> streamDemo({int count = 3});

  Future<void> disconnect();
}
