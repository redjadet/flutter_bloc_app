/// Dev-only Render/FastAPI orchestration diagnostics (no-op in release).
abstract interface class ChatRenderOrchestrationDiagnosticsPort {
  void logIfDebug(String tag);
}
