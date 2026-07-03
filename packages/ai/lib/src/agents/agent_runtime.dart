import '../providers/streaming_chat_provider.dart';
import 'agent_context.dart';
import 'agent_plan.dart';

/// Executes agent plans using injected providers.
abstract interface class AgentRuntime {
  Stream<ChatStreamEvent> run({
    required AgentContext context,
    required AgentPlan plan,
  });
}
