/// Narrow port supplying the Render chat orchestration dev HF read token
/// without coupling `chat` to the `remote_config` feature.
///
/// Implementations are wired in app DI composition. The chat-side provider
/// depends only on this port, so `chat` does not import remote_config feature
/// types.
abstract class RenderOrchestrationRemoteTokenPort {
  /// Returns the trimmed HF read token from remote config, or `null` when
  /// unset, empty, or the lookup failed.
  String? readDevToken();

  /// Forces a refresh of the underlying remote-config source.
  ///
  /// Implementations should swallow transient errors; callers retry the
  /// [readDevToken] read after this completes.
  Future<void> forceRefresh();
}
