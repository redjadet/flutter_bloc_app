import 'package:core/core.dart';
import 'package:event_bus/event_bus.dart';
import 'package:feature_flags/feature_flags.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/analytics/analytics_consent_repository.dart';
import 'package:flutter_bloc_app/app/analytics/in_memory_product_analytics.dart';
import 'package:flutter_bloc_app/app/analytics/product_analytics.dart';
import 'package:flutter_bloc_app/app/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/app/bootstrap/firebase_crashlytics_bootstrap.dart';
import 'package:flutter_bloc_app/app/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/app/config/backend_availability.dart';
import 'package:flutter_bloc_app/app/config/secret_config.dart';
import 'package:flutter_bloc_app/app/diagnostics/frame_timing_monitor.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/router/routes_case_study_demo.dart';
import 'package:flutter_bloc_app/app/router/routes_certificate_pinning_demo.dart';
import 'package:flutter_bloc_app/app/router/routes_online_therapy_demo.dart';
import 'package:flutter_bloc_app/app/router/routes_staff_app_demo.dart';
import 'package:flutter_bloc_app/app/services/error_notification_service.dart';
import 'package:flutter_bloc_app/app/utils/bloc_provider_helpers.dart';
import 'package:flutter_bloc_app/app/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/ai_decision_demo.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_repository.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/presentation/cubit/ai_decision_cubit.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_auth_session_port.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_list_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_render_orchestration_diagnostics_port.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/render_orchestration_hf_token_provider.dart';
import 'package:flutter_bloc_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/cubit/chat_sync_status_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/pages/chat_list_page.dart';
import 'package:flutter_bloc_app/features/chat/presentation/pages/chat_page.dart';
import 'package:flutter_bloc_app/features/event_bus_demo/event_bus_demo.dart';
import 'package:flutter_bloc_app/features/fcm_demo/presentation/cubit/fcm_demo_cubit.dart';
import 'package:flutter_bloc_app/features/fcm_demo/presentation/pages/fcm_demo_page.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_agent.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/cubit/genui_demo_cubit.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/pages/genui_demo_page.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance_repository.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/cubit/game_cubit.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/cubit/lobby_cubit.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/pages/game_page.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/pages/lobby_page.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/data/fake_in_app_purchase_repository.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/data/flutter_in_app_purchase_repository.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/presentation/cubit/in_app_purchase_demo_cubit.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/presentation/pages/in_app_purchase_demo_page.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_cubit.dart';
import 'package:flutter_bloc_app/features/iot_demo/iot_demo.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/widgets/iot_demo_auth_gate.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/native_platform_showcase.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/audio_playback_service.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/vocabulary_repository.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/pages/playlearn_page.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/pages/vocabulary_list_page.dart';
import 'package:flutter_bloc_app/features/production_readiness/production_readiness.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:networking/networking.dart';
import 'package:storage/storage.dart';
import 'package:utilities/utilities.dart';

part 'routes_demos.part.dart';

/// Demo and feature routes: chat, genui, playlearn, FCM, igaming, IoT.
List<RouteBase> createDemoRoutes(DemoRouteFactory factory) =>
    factory.createRoutes();

class DemoRouteFactory({
  required final BackendAvailability backendAvailability,
  required final PendingSyncRepository pendingSyncRepository,
  required final ChatRepository chatRepository,
  required final ChatHistoryRepository chatHistoryRepository,
  required final ChatListRepository chatListRepository,
  required final RenderOrchestrationHfTokenProvider?
  renderOrchestrationHfTokenProvider,
  required final ChatAuthSessionPort chatAuthSessionPort,
  required final ChatRenderOrchestrationDiagnosticsPort
  chatRenderOrchestrationDiagnosticsPort,
  required final ErrorNotificationService errorNotificationService,
  required final GenUiDemoAgent genUiDemoAgent,
  required final VocabularyRepository vocabularyRepository,
  required final AudioPlaybackService Function() createAudioPlaybackService,
  required final DemoBalanceRepository demoBalanceRepository,
  required final TimerService timerService,
  required final FcmMessagingService fcmMessagingService,
  required final BackgroundSyncCoordinator backgroundSyncCoordinator,
  required final FcmSimulationController? fcmSimulationController,
  required final RemoteConfigService remoteConfigService,
  required final AnalyticsConsentRepository analyticsConsentRepository,
  required final ProductAnalytics productAnalytics,
  required final InMemoryProductAnalytics? memoryAnalytics,
  required final FrameTimingMonitor frameTimingMonitor,
  required final FcmDemoMode fcmDemoMode,
  required final SupabaseAuthRepository supabaseAuthRepository,
  required final IotDemoRepository iotDemoRepository,
  required final IotBleCubit Function() createIotBleCubit,
  required final FakeInAppPurchaseRepository Function()
  createFakeInAppPurchaseRepository,
  required final FlutterInAppPurchaseRepository Function()
  createFlutterInAppPurchaseRepository,
  required final AiDecisionRepository aiDecisionRepository,
  required final LoadNativePlatformShowcaseUseCase
  loadNativePlatformShowcaseUseCase,
  required final WatchNativeShowcaseTelemetryUseCase
  watchNativeShowcaseTelemetryUseCase,
  required final TriggerNativeShowcaseHapticUseCase
  triggerNativeShowcaseHapticUseCase,
  required final ShareNativeShowcaseTextUseCase shareNativeShowcaseTextUseCase,
  required final NativeSecurityShowcaseCubit Function()
  createNativeSecurityShowcaseCubit,
  required final EventBus eventBus,
  required final OnlineTherapyDemoRouteFactory onlineTherapyDemoRouteFactory,
  required final StaffAppDemoRouteFactory staffAppDemoRouteFactory,
  required final CaseStudyDemoRouteFactory caseStudyDemoRouteFactory,
  required final CertificatePinningDemoRouteFactory
  certificatePinningDemoRouteFactory,
}) {
  List<RouteBase> createRoutes() => <RouteBase>[
    ...createDemoRoutesHead(this),
    ...createDemoRoutesTail(this),
  ];

  ChatCubit _createChatCubit() => ChatCubit(
    repository: chatRepository,
    historyRepository: chatHistoryRepository,
    renderOrchestrationHfTokenProvider: renderOrchestrationHfTokenProvider,
    authSessionPort: chatAuthSessionPort,
    renderOrchestrationDiagnostics: chatRenderOrchestrationDiagnosticsPort,
    initialModel: SecretConfig.huggingfaceModel,
  );

  Widget _withChatSupabaseSessionGate({
    required GoRouterState state,
    required BackendAvailability availability,
    required Widget child,
  }) {
    if (availability.webNoBackendMode) {
      return child;
    }
    return IotDemoAuthGate(
      isSupabaseInitialized: supabaseAuthRepository.isConfigured,
      getCurrentUser: () => supabaseAuthRepository.currentUser,
      authStateChanges: supabaseAuthRepository.authStateChanges,
      counterPath: AppRoutes.counterPath,
      supabaseAuthPath: AppRoutes.supabaseAuthPath,
      redirectReturnPath: state.matchedLocation,
      child: child,
    );
  }

  Widget _listenBackendAvailability(
    Widget Function(BackendAvailability availability) builder,
  ) {
    return ListenableBuilder(
      listenable: BackendAvailabilityUpdates.instance,
      builder: (context, _) => builder(backendAvailability),
    );
  }
}
