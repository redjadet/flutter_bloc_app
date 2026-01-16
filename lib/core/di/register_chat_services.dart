import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_local_conversation_updater.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_local_data_source.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_sync_operation_factory.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_api_client.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_payload_builder.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_response_parser.dart';
import 'package:flutter_bloc_app/features/chat/data/mock_chat_list_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/offline_first_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_list_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/shared/http/resilient_http_client.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';

/// Registers all chat-related services and repositories.
void registerChatServices() {
  registerLazySingletonIfAbsent<HuggingFaceApiClient>(
    () => HuggingFaceApiClient(
      httpClient: getIt<ResilientHttpClient>(),
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
      useChatCompletions: SecretConfig.useChatCompletions,
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
      remoteRepository: getIt<HuggingfaceChatRepository>(),
      pendingSyncRepository: getIt<PendingSyncRepository>(),
      registry: getIt<SyncableRepositoryRegistry>(),
      syncOperationFactory: getIt<ChatSyncOperationFactory>(),
      localConversationUpdater: getIt<ChatLocalConversationUpdater>(),
    ),
  );
  registerLazySingletonIfAbsent<ChatListRepository>(
    MockChatListRepository.new,
  );
}
