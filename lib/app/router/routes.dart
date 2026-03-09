import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/router/deferred_pages/chart_page.dart'
    deferred as chart_page;
import 'package:flutter_bloc_app/app/router/deferred_pages/markdown_editor_page.dart'
    deferred as markdown_editor_page;
import 'package:flutter_bloc_app/app/router/route_groups.dart';
import 'package:flutter_bloc_app/core/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/auth/presentation/pages/logged_out_page.dart';
import 'package:flutter_bloc_app/features/auth/presentation/pages/profile_page.dart';
import 'package:flutter_bloc_app/features/auth/presentation/pages/register_page.dart';
import 'package:flutter_bloc_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:flutter_bloc_app/features/calculator/calculator.dart';
import 'package:flutter_bloc_app/features/camera_gallery/camera_gallery.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_list_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/pages/chat_list_page.dart';
import 'package:flutter_bloc_app/features/chat/presentation/pages/chat_page.dart';
import 'package:flutter_bloc_app/features/counter/counter.dart';
import 'package:flutter_bloc_app/features/example/presentation/pages/example_page.dart';
import 'package:flutter_bloc_app/features/example/presentation/pages/whiteboard_page.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_messaging_service.dart';
import 'package:flutter_bloc_app/features/fcm_demo/presentation/cubit/fcm_demo_cubit.dart';
import 'package:flutter_bloc_app/features/fcm_demo/presentation/pages/fcm_demo_page.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_agent.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/cubit/genui_demo_cubit.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/pages/genui_demo_page.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_cache_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/graphql_demo_cubit.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/pages/graphql_demo_page.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance_repository.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/game_cubit.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/lobby_cubit.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/pages/game_page.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/pages/lobby_page.dart';
import 'package:flutter_bloc_app/features/iot_demo/iot_demo.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/widgets/iot_demo_auth_gate.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/pages/library_demo_page.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/audio_playback_service.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/vocabulary_repository.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/pages/playlearn_page.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/pages/vocabulary_list_page.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_cache_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_repository.dart';
import 'package:flutter_bloc_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_bloc_app/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_bloc_app/features/scapes/domain/scapes_repository.dart';
import 'package:flutter_bloc_app/features/scapes/scapes.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info_repository.dart';
import 'package:flutter_bloc_app/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/platform/biometric_authenticator.dart';
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/utils/bloc_provider_helpers.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/shared/widgets/deferred_page.dart';
import 'package:go_router/go_router.dart';

/// Creates the list of application routes with async init where needed.
List<GoRoute> createAppRoutes() => <GoRoute>[
  GoRoute(
    path: AppRoutes.authPath,
    name: AppRoutes.auth,
    builder: (final context, final state) => const SignInPage(),
  ),
  GoRoute(
    path: AppRoutes.counterPath,
    name: AppRoutes.counter,
    builder: (final context, final state) =>
        BlocProviderHelpers.withAsyncInit<CounterCubit>(
          create: () => CounterCubit(
            repository: getIt<CounterRepository>(),
            timerService: getIt<TimerService>(),
            loadDelay: getIt<AppRuntimeConfig>().skeletonDelay,
          ),
          init: (final cubit) => cubit.loadInitial(),
          child: CounterPage(
            title: context.l10n.homeTitle,
            errorNotificationService: getIt<ErrorNotificationService>(),
            biometricAuthenticator: getIt<BiometricAuthenticator>(),
          ),
        ),
  ),
  GoRoute(
    path: AppRoutes.calculatorPath,
    name: AppRoutes.calculator,
    builder: (final context, final state) => BlocProvider(
      create: (_) => CalculatorCubit(
        calculator: getIt<PaymentCalculator>(),
      ),
      child: const CalculatorPage(),
    ),
    routes: [
      GoRoute(
        path: 'payment',
        name: AppRoutes.calculatorPayment,
        builder: (final context, final state) {
          final Object? extra = state.extra;
          if (extra is CalculatorCubit) {
            return BlocProvider.value(
              value: extra,
              child: const CalculatorPaymentPage(),
            );
          }
          return BlocProvider(
            create: (_) => CalculatorCubit(
              calculator: getIt<PaymentCalculator>(),
            ),
            child: const CalculatorPaymentPage(),
          );
        },
      ),
    ],
  ),
  GoRoute(
    path: AppRoutes.examplePath,
    name: AppRoutes.example,
    builder: (final context, final state) => const ExamplePage(),
  ),
  GoRoute(
    path: AppRoutes.whiteboardPath,
    name: AppRoutes.whiteboard,
    builder: (final context, final state) => const WhiteboardPage(),
  ),
  GoRoute(
    path: AppRoutes.cameraGalleryPath,
    name: AppRoutes.cameraGallery,
    builder: (final context, final state) => BlocProvider<CameraGalleryCubit>(
      create: (_) => CameraGalleryCubit(
        repository: getIt<CameraGalleryRepository>(),
      ),
      child: const CameraGalleryPage(),
    ),
  ),
  GoRoute(
    path: AppRoutes.scapesPath,
    name: AppRoutes.scapes,
    builder: (final context, final state) => ScapesPage(
      repository: getIt<ScapesRepository>(),
      timerService: getIt<TimerService>(),
    ),
  ),
  GoRoute(
    path: AppRoutes.markdownEditorPath,
    name: AppRoutes.markdownEditor,
    builder: (final context, final state) => DeferredPage(
      loadLibrary: markdown_editor_page.loadLibrary,
      builder: (final context) =>
          markdown_editor_page.buildMarkdownEditorPage(),
    ),
  ),
  GoRoute(
    path: AppRoutes.graphqlPath,
    name: AppRoutes.graphql,
    builder: (final context, final state) =>
        BlocProviderHelpers.withAsyncInit<GraphqlDemoCubit>(
          create: () => GraphqlDemoCubit(
            repository: getIt<GraphqlDemoRepository>(),
          ),
          init: (final cubit) => cubit.loadInitial(),
          child: const GraphqlDemoPage(),
        ),
  ),
  GoRoute(
    path: AppRoutes.chartsPath,
    name: AppRoutes.charts,
    builder: (final context, final state) => DeferredPage(
      loadLibrary: chart_page.loadLibrary,
      builder: (final context) => chart_page.buildChartPage(),
    ),
  ),
  GoRoute(
    path: AppRoutes.settingsPath,
    name: AppRoutes.settings,
    builder: (final context, final state) => SettingsPage(
      appInfoRepository: getIt<AppInfoRepository>(),
      graphqlCacheRepository: getIt<GraphqlCacheRepository>(),
      profileCacheRepository: getIt<ProfileCacheRepository>(),
    ),
  ),
  GoRoute(
    path: AppRoutes.manageAccountPath,
    name: AppRoutes.manageAccount,
    builder: (final context, final state) => const AuthProfilePage(),
  ),
  GoRoute(
    path: AppRoutes.profilePath,
    name: AppRoutes.profile,
    builder: (final context, final state) =>
        BlocProviderHelpers.withAsyncInit<ProfileCubit>(
          create: () => ProfileCubit(
            repository: getIt<ProfileRepository>(),
          ),
          init: (final cubit) => cubit.loadProfile(),
          child: const ProfilePage(),
        ),
  ),
  GoRoute(
    path: AppRoutes.registerPath,
    name: AppRoutes.register,
    builder: (final context, final state) => const RegisterPage(),
  ),
  GoRoute(
    path: AppRoutes.loggedOutPath,
    name: AppRoutes.loggedOut,
    builder: (final context, final state) => const LoggedOutPage(),
  ),
  GoRoute(
    path: AppRoutes.libraryDemoPath,
    name: AppRoutes.libraryDemo,
    builder: (final context, final state) => LibraryDemoPage(
      scapesRepository: getIt<ScapesRepository>(),
      timerService: getIt<TimerService>(),
    ),
  ),
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
        create: () => FcmDemoCubit(messaging: getIt<FcmMessagingService>()),
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
  ...createAuxiliaryRoutes(),
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
