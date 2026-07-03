/// Provider-neutral AI contracts.
library;

export 'src/agents/agent_context.dart';
export 'src/agents/agent_memory.dart';
export 'src/agents/agent_plan.dart';
export 'src/agents/agent_runtime.dart';
export 'src/mcp/mcp_server_descriptor.dart';
export 'src/mcp/mcp_tool_adapter.dart';
export 'src/prompts/prompt_registry.dart';
export 'src/prompts/prompt_template.dart';
export 'src/prompts/prompt_version.dart';
export 'src/providers/embedding_provider.dart';
export 'src/providers/llm_provider.dart';
export 'src/providers/streaming_chat_provider.dart';
export 'src/rag/document_chunk.dart';
export 'src/rag/retriever.dart';
export 'src/rag/vector_store.dart';
export 'src/structured_outputs/decoder.dart';
export 'src/structured_outputs/schema.dart';
export 'src/structured_outputs/validation_error.dart';
export 'src/tools/tool_call.dart';
export 'src/tools/tool_descriptor.dart';
export 'src/tools/tool_registry.dart';
export 'src/tools/tool_result.dart';
