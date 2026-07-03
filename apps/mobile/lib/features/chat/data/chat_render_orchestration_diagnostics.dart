import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Dev-only diagnostics for why Render/FastAPI orchestration may be skipped.
void logChatRenderOrchestrationIfDebug(final String tag) {
  if (!kDebugMode) {
    return;
  }
  final bool enabled = SecretConfig.chatRenderDemoEnabled;
  final String base = SecretConfig.chatRenderDemoBaseUrl.trim();
  final bool isFastApiCloud = base.contains('fastapicloud');
  final bool surface = SecretConfig.isChatRenderDemoSurface;
  final String? block = _renderOrchestrationNotRunnableReason();
  final bool runnable = block == null;
  AppLogger.info(
    'Chat: Render/FastAPI diag[$tag] '
    'dartDefineEnabled=$enabled isFastApiCloud=$isFastApiCloud baseUrlChars=${base.length} '
    'surface=$surface attemptsRenderFirst=$runnable '
    '${runnable ? "" : "notRunnableBecause=$block "}'
    '(defines are compile-time; hot reload does not apply new dart-defines)',
  );
}

/// When non-null, Render orchestration would not run (composite path only).
String? _renderOrchestrationNotRunnableReason() {
  if (!SecretConfig.chatRenderDemoEnabled) {
    return 'CHAT_RENDER_DEMO_ENABLED=false';
  }
  final String base = SecretConfig.chatRenderDemoBaseUrl.trim();
  if (base.isEmpty) {
    return 'CHAT_RENDER_DEMO_BASE_URL_empty';
  }
  if (kReleaseMode) {
    final Uri? parsed = Uri.tryParse(base);
    if (parsed == null || parsed.scheme != 'https') {
      return 'release_requires_https_base_url';
    }
  }
  if (!getIt.isRegistered<FirebaseAuth>()) {
    return 'FirebaseAuth_not_registered';
  }
  if (Firebase.apps.isEmpty) {
    return 'Firebase_default_app_missing';
  }
  // Do not read [FirebaseAuth.currentUser] here: in widget/unit tests the auth
  // channel may be absent, and the pigeon stack reports failures on an async
  // gap that a synchronous try/catch does not reliably contain. Runtime gating
  // for Render still uses [_chatRenderOrchestrationRunnable] in
  // register_chat_services.dart (currentUser checked only when actually needed).
  return null;
}
