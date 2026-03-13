import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_list_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/pages/chat_list_page.dart';
import 'package:flutter_bloc_app/features/chat/presentation/pages/chat_page.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_messaging_service.dart';
import 'package:flutter_bloc_app/features/fcm_demo/presentation/cubit/fcm_demo_cubit.dart';
import 'package:flutter_bloc_app/features/fcm_demo/presentation/pages/fcm_demo_page.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_agent.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/cubit/genui_demo_cubit.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/pages/genui_demo_page.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance_repository.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/game_cubit.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/lobby_cubit.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/pages/game_page.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/pages/lobby_page.dart';
import 'package:flutter_bloc_app/features/iot_demo/iot_demo.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/widgets/iot_demo_auth_gate.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/audio_playback_service.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/vocabulary_repository.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/pages/playlearn_page.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/pages/vocabulary_list_page.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/utils/bloc_provider_helpers.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:go_router/go_router.dart';

/// Demo and feature routes: chat, genui, playlearn, FCM, igaming, IoT.
List<GoRoute> createDemoRoutes() => <GoRoute>[
  GoRoute(
    path: AppRoutes.chatPath,
    name: AppRoutes.chat,
    builder: (final context, final state) =>
        BlocProviderHelpers.withAsyncInit<ChatCubit>(
          create: () => ChatCubit(
            repository: getIt<ChatRepository>(),
            historyRepository: getIt<ChatHistoryRepository>(),
            initialModel: SecretConfig.huggingfaceModel,
          ),
          init: (final cubit) => cubit.loadHistory(),
          child: ChatPage(
            errorNotificationService: getIt<ErrorNotificationService>(),
            pendingSyncRepository: getIt<PendingSyncRepository>(),
          ),
        ),
  ),
  GoRoute(
    path: AppRoutes.chatListPath,
    name: AppRoutes.chatList,
    builder: (final context, final state) => ChatListPage(
      repository: getIt<ChatListRepository>(),
      chatRepository: getIt<ChatRepository>(),
      historyRepository: getIt<ChatHistoryRepository>(),
      errorNotificationService: getIt<ErrorNotificationService>(),
      pendingSyncRepository: getIt<PendingSyncRepository>(),
    ),
  ),
  GoRoute(
    path: AppRoutes.genuiDemoPath,
    name: AppRoutes.genuiDemo,
    builder: (final context, final state) {
      final apiKey = SecretConfig.geminiApiKey;
      if (apiKey == null || apiKey.isEmpty) {
        return CommonPageLayout(
          title: context.l10n.genuiDemoPageTitle,
          body: CommonErrorView(
            message: context.l10n.genuiDemoNoApiKey,
          ),
        );
      }
      return BlocProviderHelpers.withAsyncInit<GenUiDemoCubit>(
        create: () => GenUiDemoCubit(agent: getIt<GenUiDemoAgent>()),
        init: (final cubit) => cubit.initialize(),
        child: const GenUiDemoPage(),
      );
    },
  ),
  GoRoute(
    path: AppRoutes.playlearnPath,
    name: AppRoutes.playlearn,
    builder: (final context, final state) => PlaylearnPage(
      repository: getIt<VocabularyRepository>(),
      audioService: getIt<AudioPlaybackService>(),
    ),
    routes: <GoRoute>[
      GoRoute(
        path: 'vocabulary/:topicId',
        name: AppRoutes.playlearnVocabulary,
        builder: (final context, final state) {
          final topicId = state.pathParameters['topicId'] ?? '';
          return VocabularyListPage(
            topicId: topicId,
            repository: getIt<VocabularyRepository>(),
            audioService: getIt<AudioPlaybackService>(),
          );
        },
      ),
    ],
  ),
  GoRoute(
    path: AppRoutes.fcmDemoPath,
    name: AppRoutes.fcmDemo,
    builder: (final context, final state) {
      if (!FirebaseBootstrapService.isFirebaseInitialized) {
        return const _FcmDemoRedirectWhenUnavailable();
      }
      return BlocProviderHelpers.withAsyncInit<FcmDemoCubit>(
        create: () => FcmDemoCubit(
          messaging: getIt<FcmMessagingService>(),
          coordinator: getIt<BackgroundSyncCoordinator>(),
        ),
        init: (final cubit) => cubit.initialize(),
        child: const FcmDemoPage(),
      );
    },
  ),
  GoRoute(
    path: AppRoutes.igamingDemoPath,
    name: AppRoutes.igamingDemo,
    builder: (final context, final state) {
      final l10n = context.l10n;
      return BlocProviderHelpers.withAsyncInit<LobbyCubit>(
        create: () => LobbyCubit(
          repository: getIt<DemoBalanceRepository>(),
          l10n: l10n,
        ),
        init: (final cubit) => cubit.loadBalance(),
        child: const LobbyPage(),
      );
    },
    routes: <GoRoute>[
      GoRoute(
        path: 'game',
        name: AppRoutes.igamingDemoGame,
        builder: (final context, final state) {
          final l10n = context.l10n;
          return BlocProviderHelpers.withAsyncInit<GameCubit>(
            create: () => GameCubit(
              balanceRepository: getIt<DemoBalanceRepository>(),
              timerService: getIt<TimerService>(),
              l10n: l10n,
            ),
            init: (final cubit) => cubit.loadBalance(),
            child: const GamePage(),
          );
        },
      ),
    ],
  ),
  GoRoute(
    path: AppRoutes.iotDemoPath,
    name: AppRoutes.iotDemo,
    builder: (final context, final state) {
      final l10n = context.l10n;
      return IotDemoAuthGate(
        isSupabaseInitialized: SupabaseBootstrapService.isSupabaseInitialized,
        getCurrentUser: () => getIt<SupabaseAuthRepository>().currentUser,
        authStateChanges: getIt<SupabaseAuthRepository>().authStateChanges,
        counterPath: AppRoutes.counterPath,
        supabaseAuthPath: AppRoutes.supabaseAuthPath,
        redirectReturnPath: AppRoutes.iotDemoPath,
        child: BlocProviderHelpers.withAsyncInit<IotDemoCubit>(
          create: () => IotDemoCubit(
            repository: getIt<IotDemoRepository>(),
            l10n: l10n,
          ),
          init: (final cubit) => cubit.initialize(),
          child: const IotDemoPage(),
        ),
      );
    },
  ),
];

/// Shown when user reaches FCM demo route but Firebase is not initialized;
/// redirects to counter so the app does not crash.
class _FcmDemoRedirectWhenUnavailable extends StatefulWidget {
  const _FcmDemoRedirectWhenUnavailable();

  @override
  State<_FcmDemoRedirectWhenUnavailable> createState() =>
      _FcmDemoRedirectWhenUnavailableState();
}

class _FcmDemoRedirectWhenUnavailableState
    extends State<_FcmDemoRedirectWhenUnavailable> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go(AppRoutes.counterPath);
    });
  }

  @override
  Widget build(final BuildContext context) => const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );
}
