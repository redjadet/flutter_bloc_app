import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/config/app_runtime_config.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_local_conversation_updater.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_local_data_source.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_render_orchestration_diagnostics.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_sync_operation_factory.dart';
import 'package:flutter_bloc_app/features/chat/data/composite_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/demo_first_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_api_client.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_payload_builder.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_response_parser.dart';
import 'package:flutter_bloc_app/features/chat/data/mock_chat_list_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/offline_first_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/render_caller_auth_header_provider.dart';
import 'package:flutter_bloc_app/features/chat/data/render_chat_dio_factory.dart';
import 'package:flutter_bloc_app/features/chat/data/render_fastapi_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/render_orchestration_hf_token_provider.dart';
import 'package:flutter_bloc_app/features/chat/data/supabase_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_list_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_service.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String _renderChatDioName = 'renderChatDio';

bool _chatRenderOrchestrationRunnable() {
  if (!SecretConfig.chatRenderDemoEnabled) {
    return false;
  }
  final String base = SecretConfig.chatRenderDemoBaseUrl.trim();
  if (base.isEmpty) {
    return false;
  }
  if (kReleaseMode) {
    final Uri? parsed = Uri.tryParse(base);
    if (parsed == null || parsed.scheme != 'https') {
      return false;
    }
  }
  if (!getIt.isRegistered<FirebaseAuth>()) {
    return false;
  }
  return getIt<FirebaseAuth>().currentUser != null;
}

/// Registers all chat-related services and repositories.
void registerChatServices() {
  final String? hfKey = SecretConfig.huggingfaceApiKey;
  final bool hfConfigured = hfKey != null && hfKey.trim().isNotEmpty;
  if (!kReleaseMode) {
    AppLogger.info(
      'Chat: Hugging Face configured=$hfConfigured '
      '(model=${SecretConfig.huggingfaceModel ?? 'HuggingFaceH4/zephyr-7b-beta'}, '
      'secretChatCompletions=${SecretConfig.useChatCompletions}, '
      'repositoryChatCompletions=true)',
    );
  }

  registerLazySingletonIfAbsent<HuggingFaceApiClient>(
    () => HuggingFaceApiClient(
      dio: getIt<Dio>(),
      apiKey: SecretConfig.huggingfaceApiKey,
    ),
    dispose: (final client) => client.dispose(),
  );
  registerLazySingletonIfAbsent<HuggingFacePayloadBuilder>(
    () => const HuggingFacePayloadBuilder(),
  );
  registerLazySingletonIfAbsent<HuggingFaceResponseParser>(
    () => const HuggingFaceResponseParser(
      fallbackMessage: HuggingfaceChatRepository.fallbackMessage,
    ),
  );
  registerLazySingletonIfAbsent<HuggingfaceChatRepository>(
    () => HuggingfaceChatRepository(
      apiClient: getIt<HuggingFaceApiClient>(),
      payloadBuilder: getIt<HuggingFacePayloadBuilder>(),
      responseParser: getIt<HuggingFaceResponseParser>(),
      model: SecretConfig.huggingfaceModel,
    ),
  );
  registerLazySingletonIfAbsent<SupabaseChatRepository>(
    () => SupabaseChatRepository(
      payloadBuilder: getIt<HuggingFacePayloadBuilder>(),
    ),
  );
  registerLazySingletonIfAbsent<CompositeChatRepository>(
    () => CompositeChatRepository(
      supabaseRepository: getIt<SupabaseChatRepository>(),
      directRepository: getIt<HuggingfaceChatRepository>(),
      networkStatusService: getIt<NetworkStatusService>(),
      isSupabaseProxyRunnable: () {
        if (!SupabaseBootstrapService.isSupabaseInitialized) {
          return false;
        }
        final String? token =
            Supabase.instance.client.auth.currentSession?.accessToken;
        return token != null && token.isNotEmpty;
      },
      isDirectPolicyAllowed: () => hfConfigured,
    ),
  );
  if (!getIt.isRegistered<Dio>(instanceName: _renderChatDioName)) {
    getIt.registerLazySingleton<Dio>(
      () {
        final String raw = SecretConfig.chatRenderDemoBaseUrl.trim();
        return createRenderChatDio(
          baseUrl: raw.isEmpty ? 'http://127.0.0.1' : raw,
        );
      },
      instanceName: _renderChatDioName,
      dispose: (dio) => dio.close(),
    );
  }
  registerLazySingletonIfAbsent<RenderCallerAuthHeaderProvider>(
    () => DefaultRenderCallerAuthHeaderProvider(() => getIt<FirebaseAuth>()),
  );
  registerLazySingletonIfAbsent<RenderOrchestrationHfTokenProvider>(
    () => LayeredRenderOrchestrationHfTokenProvider(
      runtime: getIt<AppRuntimeConfig>(),
      remoteConfig: getIt<RemoteConfigService>(),
      storage: SecretConfig.storage ?? FlutterSecureSecretStorage(),
      firebaseAuth: getIt.isRegistered<FirebaseAuth>() && Firebase.apps.isNotEmpty
          ? getIt<FirebaseAuth>()
          : null,
    ),
  );
  registerLazySingletonIfAbsent<RenderFastApiChatRepository>(
    () => RenderFastApiChatRepository(
      dio: getIt<Dio>(instanceName: _renderChatDioName),
      payloadBuilder: getIt<HuggingFacePayloadBuilder>(),
      responseParser: getIt<HuggingFaceResponseParser>(),
      callerAuth: getIt<RenderCallerAuthHeaderProvider>(),
      hfTokenProvider: getIt<RenderOrchestrationHfTokenProvider>(),
      isRunnable: _chatRenderOrchestrationRunnable,
    ),
  );
  registerLazySingletonIfAbsent<DemoFirstChatRepository>(
    () => DemoFirstChatRepository(
      renderRepository: getIt<RenderFastApiChatRepository>(),
      compositeRepository: getIt<CompositeChatRepository>(),
      isRenderAttemptedFirst: _chatRenderOrchestrationRunnable,
      isRenderStrict: () => SecretConfig.chatRenderDemoStrict,
    ),
  );
  registerLazySingletonIfAbsent<ChatHistoryRepository>(
    () => ChatLocalDataSource(hiveService: getIt<HiveService>()),
  );
  registerLazySingletonIfAbsent<ChatSyncOperationFactory>(
    () => ChatSyncOperationFactory(
      entityType: OfflineFirstChatRepository.chatEntity,
    ),
  );
  registerLazySingletonIfAbsent<ChatLocalConversationUpdater>(
    () => ChatLocalConversationUpdater(
      localDataSource: getIt<ChatHistoryRepository>(),
    ),
  );
  registerLazySingletonIfAbsent<ChatRepository>(
    () => OfflineFirstChatRepository(
      remoteRepository: getIt<DemoFirstChatRepository>(),
      pendingSyncRepository: getIt<PendingSyncRepository>(),
      registry: getIt<SyncableRepositoryRegistry>(),
      syncOperationFactory: getIt<ChatSyncOperationFactory>(),
      localConversationUpdater: getIt<ChatLocalConversationUpdater>(),
    ),
  );
  registerLazySingletonIfAbsent<ChatListRepository>(
    MockChatListRepository.new,
  );
  logChatRenderOrchestrationIfDebug('register_chat_services_done');
}
