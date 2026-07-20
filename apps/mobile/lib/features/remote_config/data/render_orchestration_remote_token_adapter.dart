import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:feature_flags/feature_flags.dart';

/// Adapts [RemoteConfigService] to the chat-scoped
/// [RenderOrchestrationRemoteTokenPort] so `lib/features/chat/` does not import
/// `lib/features/remote_config/`.
class RemoteConfigRenderOrchestrationTokenAdapter
    implements RenderOrchestrationRemoteTokenPort {
  const RemoteConfigRenderOrchestrationTokenAdapter({
    required this._remoteConfig,
  });

  final RemoteConfigService _remoteConfig;

  @override
  Future<void> forceRefresh() => _remoteConfig.forceFetch();

  @override
  String? readDevToken() {
    try {
      final String raw = _remoteConfig.getString(
        RemoteConfigKeys.renderChatDemoHfReadToken,
      );
      final String trimmed = raw.trim();
      if (trimmed.isEmpty) {
        return null;
      }
      return trimmed;
    } on Exception catch (e, _) {
      AppLogger.debug(
        'RemoteConfigRenderOrchestrationTokenAdapter.readDevToken: $e',
      );
      return null;
    }
  }
}
