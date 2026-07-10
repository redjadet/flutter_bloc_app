import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/app/composition/features/register_ai_decision_demo_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_case_study_demo_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_event_bus_demo_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_genui_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_igaming_demo_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_in_app_purchase_demo_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_native_platform_showcase_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_online_therapy_demo_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_realtime_market_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_staff_app_demo_services.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/http/supabase/supabase_session_manager.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_api_client.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_repository.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_repository.dart'
    as domain;
import 'package:flutter_bloc_app/features/case_study_demo/data/case_study_hive_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/data/case_study_mock_upload_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_upload_repository.dart';
import 'package:flutter_bloc_app/features/genui_demo/data/genui_demo_agent_impl.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_agent.dart';
import 'package:flutter_bloc_app/features/igaming_demo/data/demo_game_repository_impl.dart';
import 'package:flutter_bloc_app/features/igaming_demo/data/hive_demo_balance_repository.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance_repository.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_game_repository.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/data/fake_in_app_purchase_repository.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/load_native_platform_showcase_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/watch_native_showcase_telemetry_use_case.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/fake_repositories.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories.dart';
import 'package:flutter_bloc_app/features/realtime_market/data/realtime_market_local_data_source.dart';
import 'package:flutter_bloc_app/features/realtime_market/data/simulated_market_feed.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_content_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_forms_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_inbox_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_messaging_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_open_entry_snapshot.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_push_token_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_shift_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entries_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_timeclock_local_store.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_timeclock_repository.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:storage/storage.dart';

class _MockHiveService extends Mock implements HiveService {}

class _MockPendingSyncRepository extends Mock
    implements PendingSyncRepository {}

class _MockSyncableRepositoryRegistry extends Mock
    implements SyncableRepositoryRegistry {}

class _MockTimerService extends Mock implements TimerService {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockSupabaseSessionManager extends Mock
    implements SupabaseSessionManager {}

class _MockStaffDemoTimeclockLocalStore extends Mock
    implements StaffDemoTimeclockLocalStore {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      StaffDemoOpenEntrySnapshot(
        entryId: 'fallback-entry',
        clockInAtUtc: DateTime.utc(2026),
        shiftId: null,
        siteId: null,
        payload: const <String, dynamic>{},
      ),
    );
  });

  setUp(() async {
    await getIt.reset(dispose: true);
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
  });

  void registerCoreDeps() {
    getIt.registerSingleton<HiveService>(_MockHiveService());
    getIt.registerSingleton<PendingSyncRepository>(
      _MockPendingSyncRepository(),
    );
    getIt.registerSingleton<SyncableRepositoryRegistry>(
      _MockSyncableRepositoryRegistry(),
    );
    getIt.registerSingleton<TimerService>(_MockTimerService());
    getIt.registerSingleton<AuthRepository>(_MockAuthRepository());
    getIt.registerSingleton<SupabaseSessionManager>(
      _MockSupabaseSessionManager(),
    );
    getIt.registerSingleton<Dio>(Dio());
    getIt.registerSingleton<StaffDemoTimeclockLocalStore>(
      _MockStaffDemoTimeclockLocalStore(),
    );
  }

  test('registerGenUiServices registers agent implementation', () {
    registerGenUiServices();
    expect(getIt<GenUiDemoAgent>(), isA<GenUiDemoAgentImpl>());
  });

  test('registerEventBusDemoServices registers EventBus', () {
    registerEventBusDemoServices();
    expect(getIt<EventBus>(), isA<EventBus>());
  });

  test('registerAiDecisionDemoServices registers repository stack', () {
    registerCoreDeps();
    registerAiDecisionDemoServices();
    expect(getIt<AiDecisionApiClient>(), isA<AiDecisionApiClient>());
    expect(
      getIt<domain.AiDecisionRepository>(),
      isA<AiDecisionRepositoryImpl>(),
    );
  });

  test('registerIgamingDemoServices registers balance and game repos', () {
    registerCoreDeps();
    registerIgamingDemoServices();
    expect(getIt<DemoBalanceRepository>(), isA<HiveDemoBalanceRepository>());
    expect(getIt<DemoGameRepository>(), isA<DemoGameRepositoryImpl>());
  });

  test('registerInAppPurchaseDemoServices registers fake purchase repo', () {
    registerCoreDeps();
    registerInAppPurchaseDemoServices();
    expect(
      getIt<FakeInAppPurchaseRepository>(),
      isA<FakeInAppPurchaseRepository>(),
    );
  });

  test('registerOnlineTherapyDemoServices registers fake therapy repos', () {
    registerOnlineTherapyDemoServices();
    expect(getIt<TherapyAuthRepository>(), isA<FakeTherapyAuthRepository>());
    expect(getIt<TherapistRepository>(), isA<FakeTherapistRepository>());
    expect(getIt<AppointmentRepository>(), isA<FakeAppointmentRepository>());
  });

  test(
    'registerRealtimeMarketServices registers feed and local data source',
    () {
      registerCoreDeps();
      registerRealtimeMarketServices();
      expect(
        getIt<RealtimeMarketLocalDataSource>(),
        isA<RealtimeMarketLocalDataSource>(),
      );
      expect(getIt<SimulatedMarketFeed>(), isA<SimulatedMarketFeed>());
    },
  );

  test('registerNativePlatformShowcaseServices registers use cases', () {
    registerNativePlatformShowcaseServices();
    expect(
      getIt<LoadNativePlatformShowcaseUseCase>(),
      isA<LoadNativePlatformShowcaseUseCase>(),
    );
    expect(
      getIt<WatchNativeShowcaseTelemetryUseCase>(),
      isA<WatchNativeShowcaseTelemetryUseCase>(),
    );
  });

  test('registerCaseStudyDemoServices registers local and upload repos', () {
    registerCoreDeps();
    registerCaseStudyDemoServices();
    expect(
      getIt<CaseStudyLocalRepository>(),
      isA<CaseStudyHiveLocalRepository>(),
    );
    expect(
      getIt<CaseStudyUploadRepository>(),
      isA<CaseStudyMockUploadRepository>(),
    );
  });

  test(
    'registerStaffAppDemoServices uses offline fallbacks without Firebase',
    () async {
      registerCoreDeps();
      when(() => getIt<AuthRepository>().currentUser).thenReturn(null);
      when(
        () => getIt<StaffDemoTimeclockLocalStore>().loadOpenEntry(
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async => null);

      registerStaffAppDemoServices();

      expect(
        await getIt<StaffDemoShiftRepository>().findActiveShift(
          userId: 'u1',
          nowUtc: DateTime.utc(2026),
        ),
        isNull,
      );
      expect(await getIt<StaffDemoSiteRepository>().listSites(), isEmpty);
      expect(
        await getIt<StaffDemoProfileRepository>().loadProfile(userId: 'u1'),
        isNull,
      );
      expect(
        await getIt<StaffDemoTimeEntriesRepository>().fetchRecent(),
        isEmpty,
      );
      expect(
        await getIt<StaffDemoMessagingRepository>().sendShiftAssignment(
          toUserId: 'u2',
          body: 'shift',
          siteId: 'site',
          startAtUtc: DateTime.utc(2026, 1, 1),
          endAtUtc: DateTime.utc(2026, 1, 2),
          timezoneName: 'UTC',
        ),
        startsWith('offline-noop-'),
      );
      expect(
        await getIt<StaffDemoInboxRepository>().loadMessage('mid'),
        isNull,
      );
      expect(
        await getIt<StaffDemoContentRepository>().listPublished(),
        isEmpty,
      );
      await getIt<StaffDemoFormsRepository>().submitAvailability(
        userId: 'u1',
        weekStartUtc: DateTime.utc(2026, 1, 6),
        availabilityByIsoDate: const <String, bool>{'2026-01-06': true},
      );
      expect(
        () => getIt<StaffDemoTimeclockRepository>().clockIn(),
        throwsA(isA<StateError>()),
      );
    },
  );

  test(
    'registerStaffAppDemoServices noop repos cover signed-in offline flows',
    () async {
      registerCoreDeps();
      final _MockAuthRepository auth = _MockAuthRepository();
      getIt.unregister<AuthRepository>();
      getIt.registerSingleton<AuthRepository>(auth);
      when(
        () => auth.currentUser,
      ).thenReturn(const AuthUser(id: 'u1', isAnonymous: true));
      when(() => auth.authStateChanges).thenAnswer(
        (_) => Stream<AuthUser?>.value(
          const AuthUser(id: 'u1', isAnonymous: true),
        ),
      );
      when(
        () => getIt<StaffDemoTimeclockLocalStore>().loadOpenEntry(
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async => null);
      when(
        () => getIt<StaffDemoTimeclockLocalStore>().saveOpenEntry(
          userId: any(named: 'userId'),
          snapshot: any(named: 'snapshot'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => getIt<StaffDemoTimeclockLocalStore>().clearOpenEntry(
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async {});

      registerStaffAppDemoServices();

      final StaffDemoClockResult clockIn =
          await getIt<StaffDemoTimeclockRepository>().clockIn();
      expect(clockIn.entryId, startsWith('te_offline_u1_'));

      when(
        () => getIt<StaffDemoTimeclockLocalStore>().loadOpenEntry(
          userId: any(named: 'userId'),
        ),
      ).thenAnswer(
        (_) async => StaffDemoOpenEntrySnapshot(
          entryId: clockIn.entryId,
          clockInAtUtc: DateTime.utc(2026, 1, 1),
          shiftId: 'shift-1',
          siteId: 'site-1',
          payload: const <String, dynamic>{},
        ),
      );

      final StaffDemoClockResult clockOut =
          await getIt<StaffDemoTimeclockRepository>().clockOut();
      expect(clockOut.entryId, clockIn.entryId);

      await getIt<StaffDemoMessagingRepository>().confirmShiftAssignment(
        messageId: 'msg-1',
        shiftId: 'shift-1',
      );
      expect(
        await getIt<StaffDemoInboxRepository>().loadShiftStatus('shift-1'),
        isNull,
      );
      await getIt<StaffDemoFormsRepository>().submitManagerReport(
        userId: 'u1',
        siteId: 'site-1',
        notes: 'notes',
      );
      expect(
        getIt<StaffDemoInboxRepository>().watchRecipients(userId: 'u1'),
        emitsDone,
      );
      await expectLater(
        getIt<StaffDemoContentRepository>().getDownloadUrl(storagePath: 'clip'),
        throwsA(isA<StateError>()),
      );
      await expectLater(
        getIt<StaffDemoEventProofRepository>().submitProof(
          userId: 'u1',
          siteId: 'site-1',
          shiftId: 'shift-1',
          photoFilePaths: const <String>['a.jpg'],
          signaturePngFilePath: 'sig.png',
        ),
        throwsA(isA<StateError>()),
      );
      await getIt<StaffDemoPushTokenRepository>().registerTokens(userId: 'u1');
      expect(
        await getIt<StaffDemoSiteRepository>().loadSite(siteId: 'missing'),
        isNull,
      );
    },
  );

  test(
    'registerStaffAppDemoServices covers already-clocked-in and clock-out errors',
    () async {
      registerCoreDeps();
      final _MockAuthRepository auth = _MockAuthRepository();
      getIt.unregister<AuthRepository>();
      getIt.registerSingleton<AuthRepository>(auth);
      when(
        () => auth.currentUser,
      ).thenReturn(const AuthUser(id: 'u1', isAnonymous: true));
      when(
        () => getIt<StaffDemoTimeclockLocalStore>().loadOpenEntry(
          userId: any(named: 'userId'),
        ),
      ).thenAnswer(
        (_) async => StaffDemoOpenEntrySnapshot(
          entryId: 'open-1',
          clockInAtUtc: DateTime.utc(2026, 1, 1),
          shiftId: null,
          siteId: null,
          payload: const <String, dynamic>{},
        ),
      );

      registerStaffAppDemoServices();

      await expectLater(
        getIt<StaffDemoTimeclockRepository>().clockIn(),
        throwsA(isA<StateError>()),
      );

      when(
        () => getIt<StaffDemoTimeclockLocalStore>().loadOpenEntry(
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async => null);
      await expectLater(
        getIt<StaffDemoTimeclockRepository>().clockOut(),
        throwsA(isA<StateError>()),
      );
    },
  );
}
