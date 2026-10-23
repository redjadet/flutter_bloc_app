/// Snapshot returned by the engine `ping` method.
final class AgentEngineInfo {
  const new({required this.engine, required this.version, required this.pid});

  final String engine;
  final String version;
  final int pid;
}

/// Streaming notification from the agent process (`agent/event`).
final class AgentEngineEvent {
  const new({
    required this.type,
    required this.message,
    this.index,
    this.total,
  });

  final String type;
  final String message;
  final int? index;
  final int? total;
}
