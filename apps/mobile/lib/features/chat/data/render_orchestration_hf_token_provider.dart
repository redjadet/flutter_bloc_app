import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:feature_flags/feature_flags.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/app/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/app/config/app_runtime_config.dart';
import 'package:flutter_bloc_app/app/config/secret_config.dart';
import 'package:flutter_bloc_app/app/firebase/auth_helpers.dart';
import 'package:flutter_bloc_app/features/chat/domain/render_orchestration_hf_token_provider.dart';
import 'package:utilities/utilities.dart';

part 'render_orchestration_hf_token_provider_layered.part.dart';

/// Reads only compile-time / asset Hugging Face key (tests / minimal wiring).
class SecretConfigRenderOrchestrationHfTokenProvider
    implements RenderOrchestrationHfTokenProvider {
  const SecretConfigRenderOrchestrationHfTokenProvider();

  @override
  Future<void> clearRenderOrchestrationTokenCache() async {}

  @override
  Future<String?> readHfTokenForUpstream() async {
    final String? t = SecretConfig.huggingfaceApiKey?.trim();
    if (t == null || t.isEmpty) {
      return null;
    }
    return t;
  }
}
