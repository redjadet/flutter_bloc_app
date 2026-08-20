import 'package:auth/auth.dart' show RemoteBackendAuthPort;
import 'package:core/core.dart';
import 'package:event_bus/event_bus.dart';
import 'package:feature_flags/feature_flags.dart';
import 'package:flutter_bloc_app/app/analytics/analytics_consent_repository.dart';
import 'package:flutter_bloc_app/app/analytics/in_memory_product_analytics.dart';
import 'package:flutter_bloc_app/app/analytics/product_analytics.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_factories.dart';
import 'package:flutter_bloc_app/app/composition/native_security_showcase_cubit_factory.dart';
import 'package:flutter_bloc_app/app/config/backend_availability.dart';
import 'package:flutter_bloc_app/app/diagnostics/frame_timing_monitor.dart';
import 'package:flutter_bloc_app/app/router/routes_case_study_demo.dart';
import 'package:flutter_bloc_app/app/router/routes_certificate_pinning_demo.dart';
import 'package:flutter_bloc_app/app/router/routes_demos.dart';
import 'package:flutter_bloc_app/app/router/routes_online_therapy_demo.dart';
import 'package:flutter_bloc_app/app/router/routes_staff_app_demo.dart';
import 'package:flutter_bloc_app/app/services/error_notification_service.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_repository.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_clip_file_store.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_delete_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_upload_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_video_repository.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/use_cases/reset_mock_scenario.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/use_cases/select_mock_scenario.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/use_cases/trigger_secure_probe.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_auth_session_port.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_list_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_render_orchestration_diagnostics_port.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/render_orchestration_hf_token_provider.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_agent.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance_repository.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/data/fake_in_app_purchase_repository.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/data/flutter_in_app_purchase_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/iot_demo.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/native_platform_showcase.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_fake_api.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/appointment_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/audit_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/therapist_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/therapy_admin_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/therapy_auth_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/therapy_call_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/therapy_messaging_repository.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/audio_playback_service.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/vocabulary_repository.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_realtime_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_repository.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_scenario_controller.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_content_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_forms_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_inbox_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_messaging_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_file_store.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_photo_picker.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_push_token_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entries_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_timeclock_local_store.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_timeclock_repository.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:networking/networking.dart';
import 'package:storage/storage.dart' show PendingSyncRepository;
import 'package:utilities/utilities.dart'
    show FcmDemoMode, FcmMessagingService, FcmSimulationController;

DemoRouteFactory resolveDemoRouteFactory({
  AuthRepository? authRepository,
  TimerService? timerService,
}) {
  final AuthRepository resolvedAuthRepository =
      authRepository ?? getIt<AuthRepository>();
  final TimerService resolvedTimerService =
      timerService ?? getIt<TimerService>();

  return DemoRouteFactory(
    backendAvailability: getIt<BackendAvailability>(),
    pendingSyncRepository: getIt<PendingSyncRepository>(),
    chatRepository: getIt<ChatRepository>(),
    chatHistoryRepository: getIt<ChatHistoryRepository>(),
    chatListRepository: getIt<ChatListRepository>(),
    renderOrchestrationHfTokenProvider:
        getIt.isRegistered<RenderOrchestrationHfTokenProvider>()
        ? getIt<RenderOrchestrationHfTokenProvider>()
        : null,
    chatAuthSessionPort: getIt<ChatAuthSessionPort>(),
    chatRenderOrchestrationDiagnosticsPort:
        getIt<ChatRenderOrchestrationDiagnosticsPort>(),
    errorNotificationService: getIt<ErrorNotificationService>(),
    genUiDemoAgent: getIt<GenUiDemoAgent>(),
    vocabularyRepository: getIt<VocabularyRepository>(),
    createAudioPlaybackService: () => getIt<AudioPlaybackService>(),
    demoBalanceRepository: getIt<DemoBalanceRepository>(),
    timerService: resolvedTimerService,
    fcmMessagingService: getIt<FcmMessagingService>(),
    backgroundSyncCoordinator: getIt<BackgroundSyncCoordinator>(),
    fcmSimulationController: getIt.isRegistered<FcmSimulationController>()
        ? getIt<FcmSimulationController>()
        : null,
    remoteConfigService: getIt<RemoteConfigService>(),
    analyticsConsentRepository: getIt<AnalyticsConsentRepository>(),
    productAnalytics: getIt<ProductAnalytics>(),
    memoryAnalytics: getIt.isRegistered<InMemoryProductAnalytics>()
        ? getIt<InMemoryProductAnalytics>()
        : null,
    frameTimingMonitor: getIt<FrameTimingMonitor>(),
    fcmDemoMode: getIt.isRegistered<FcmDemoMode>()
        ? getIt<FcmDemoMode>()
        : FcmDemoMode.simulated,
    supabaseAuthRepository: getIt<SupabaseAuthRepository>(),
    iotDemoRepository: getIt<IotDemoRepository>(),
    createIotBleCubit: createIotBleCubit,
    createFakeInAppPurchaseRepository: () =>
        getIt<FakeInAppPurchaseRepository>(),
    createFlutterInAppPurchaseRepository: () =>
        getIt<FlutterInAppPurchaseRepository>(),
    aiDecisionRepository: getIt<AiDecisionRepository>(),
    loadNativePlatformShowcaseUseCase:
        getIt<LoadNativePlatformShowcaseUseCase>(),
    watchNativeShowcaseTelemetryUseCase:
        getIt<WatchNativeShowcaseTelemetryUseCase>(),
    triggerNativeShowcaseHapticUseCase:
        getIt<TriggerNativeShowcaseHapticUseCase>(),
    shareNativeShowcaseTextUseCase: getIt<ShareNativeShowcaseTextUseCase>(),
    createNativeSecurityShowcaseCubit: createNativeSecurityShowcaseCubit,
    eventBus: getIt<EventBus>(),
    socialFeedRepository: getIt<SocialFeedRepository>(),
    socialFeedRealtimeSource: getIt<SocialFeedRealtimeSource>(),
    socialFeedScenarioController: getIt<SocialFeedScenarioController>(),
    onlineTherapyDemoRouteFactory: OnlineTherapyDemoRouteFactory(
      appAuthRepository: resolvedAuthRepository,
      therapyAuthRepository: getIt<TherapyAuthRepository>(),
      networkModeController: getIt<OnlineTherapyFakeApi>(),
      therapists: getIt<TherapistRepository>(),
      appointments: getIt<AppointmentRepository>(),
      admin: getIt<TherapyAdminRepository>(),
      audit: getIt<AuditRepository>(),
      messaging: getIt<TherapyMessagingRepository>(),
      calls: getIt<TherapyCallRepository>(),
    ),
    staffAppDemoRouteFactory: StaffAppDemoRouteFactory(
      authRepository: resolvedAuthRepository,
      profileRepository: getIt<StaffDemoProfileRepository>(),
      pushTokenRepository: getIt<StaffDemoPushTokenRepository>(),
      siteRepository: getIt<StaffDemoSiteRepository>(),
      timeclockRepository: getIt<StaffDemoTimeclockRepository>(),
      timeclockLocalStore: getIt<StaffDemoTimeclockLocalStore>(),
      inboxRepository: getIt<StaffDemoInboxRepository>(),
      messagingRepository: getIt<StaffDemoMessagingRepository>(),
      contentRepository: getIt<StaffDemoContentRepository>(),
      formsRepository: getIt<StaffDemoFormsRepository>(),
      eventProofRepository: getIt<StaffDemoEventProofRepository>(),
      proofFileStore: getIt<StaffDemoProofFileStore>(),
      photoPicker: getIt<StaffDemoProofPhotoPicker>(),
      timeEntriesRepository: getIt<StaffDemoTimeEntriesRepository>(),
    ),
    caseStudyDemoRouteFactory: CaseStudyDemoRouteFactory(
      authRepository: resolvedAuthRepository,
      localRepository: getIt<CaseStudyLocalRepository>(),
      remoteDeleteRepository: getIt<CaseStudyRemoteDeleteRepository>(),
      remoteRepository: getIt<CaseStudyRemoteRepository>(),
      uploadRepository: getIt<CaseStudyUploadRepository>(),
      videoRepository: getIt<CaseStudyVideoRepository>(),
      clipStore: getIt<CaseStudyClipFileStore>(),
      remoteAuth: getIt<RemoteBackendAuthPort>(),
      timerService: resolvedTimerService,
    ),
    certificatePinningDemoRouteFactory: CertificatePinningDemoRouteFactory(
      config: getIt<CertificatePinningConfig>(),
      scenarioController: getIt<MockCertificateScenarioController>(),
      logger: getIt<CertificatePinningLogger>(),
      triggerSecureProbe: getIt<TriggerSecureProbe>(),
      selectMockScenario: getIt<SelectMockScenario>(),
      resetMockScenario: getIt<ResetMockScenario>(),
    ),
  );
}
