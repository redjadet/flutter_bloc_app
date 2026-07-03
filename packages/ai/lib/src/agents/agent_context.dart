/// Opaque agent session context (provider-neutral).
class AgentContext {
  const AgentContext({this.sessionId, this.metadata = const {}});

  final String? sessionId;
  final Map<String, String> metadata;
}
