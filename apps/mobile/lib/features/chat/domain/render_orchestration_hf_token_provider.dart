/// Hugging Face read token for Render `X-HF-Authorization` (per send).
abstract class RenderOrchestrationHfTokenProvider {
  Future<String?> readHfTokenForUpstream();

  /// Clears demo-scoped material cached for Render (e.g. after Firebase sign-out).
  Future<void> clearRenderOrchestrationTokenCache();
}
