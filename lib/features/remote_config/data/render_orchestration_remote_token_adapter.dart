import 'package:flutter_bloc_app/core/chat/render_orchestration_remote_token_port.dart';
import 'package:flutter_bloc_app/features/remote_config/data/repositories/remote_config_repository.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_service.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

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
        RemoteConfigRepository.renderChatDemoHfReadTokenKey,
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
