part of 'secret_config.dart';

// ---------------------------------------------------------------------------
// FastAPI Cloud orchestration demo (preferred).
//
// Back-compat: keep reading the legacy `CHAT_RENDER_*` defines so older local
// launch scripts still work.
// ---------------------------------------------------------------------------

final class _ChatOrchestrationDefines {
  const _ChatOrchestrationDefines._();

  static const bool fastApiCloudEnabled = bool.fromEnvironment(
    'CHAT_FASTAPICLOUD_DEMO_ENABLED',
  );
  static const bool fastApiCloudStrict = bool.fromEnvironment(
    'CHAT_FASTAPICLOUD_DEMO_STRICT',
  );
  static const String fastApiCloudBaseUrl = String.fromEnvironment(
    'CHAT_FASTAPICLOUD_DEMO_BASE_URL',
  );
  static const String fastApiCloudSecret = String.fromEnvironment(
    'CHAT_FASTAPICLOUD_DEMO_SECRET',
  );
  static const String fastApiCloudHfReadTokenCallable = String.fromEnvironment(
    'CHAT_FASTAPICLOUD_HF_READ_TOKEN_CALLABLE',
  );
  static const String fastApiCloudHfReadTokenCallableRegion =
      String.fromEnvironment(
        'CHAT_FASTAPICLOUD_HF_READ_TOKEN_CALLABLE_REGION',
        defaultValue: 'us-central1',
      );

  // Legacy Render-named defines (still supported).
  static const bool renderEnabled = bool.fromEnvironment(
    'CHAT_RENDER_DEMO_ENABLED',
  );
  static const bool renderStrict = bool.fromEnvironment(
    'CHAT_RENDER_DEMO_STRICT',
  );
  static const String renderBaseUrl = String.fromEnvironment(
    'CHAT_RENDER_DEMO_BASE_URL',
  );
  static const String renderSecret = String.fromEnvironment(
    'CHAT_RENDER_DEMO_SECRET',
  );
  static const String renderHfReadTokenCallable = String.fromEnvironment(
    'CHAT_RENDER_HF_READ_TOKEN_CALLABLE',
  );
  static const String renderHfReadTokenCallableRegion = String.fromEnvironment(
    'CHAT_RENDER_HF_READ_TOKEN_CALLABLE_REGION',
    defaultValue: 'us-central1',
  );
}
