import 'package:flutter_bloc_app/features/chat/data/chat_render_orchestration_diagnostics.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_render_orchestration_diagnostics_port.dart';

class ChatRenderOrchestrationDiagnosticsAdapter
    implements ChatRenderOrchestrationDiagnosticsPort {
  ChatRenderOrchestrationDiagnosticsAdapter({
    required this._isFirebaseAuthRegistered,
  });

  final bool Function() _isFirebaseAuthRegistered;

  @override
  void logIfDebug(final String tag) =>
      logChatRenderOrchestrationIfDebug(tag, _isFirebaseAuthRegistered);
}
