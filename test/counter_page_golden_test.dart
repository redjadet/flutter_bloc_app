import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/features/counter/presentation/pages/counter_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/platform/biometric_authenticator.dart';
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'test_helpers.dart' as test_helpers;

// Import test helpers directly for convenience
import 'test_helpers.dart'
    show MockCounterRepository, FakeTimerService, waitForCounterCubitsToLoad;

final DateTime _goldenTimestamp = DateTime.utc(2024, 1, 1, 12);

void main() {
  group('CounterPage Golden', () {
    setUpAll(() async {
      await loadAppFonts();
      await test_helpers.setupHiveForTesting();
    });

    setUp(() async {
      await test_helpers.setupTestDependencies(
        const test_helpers.TestSetupOptions(
          overrideCounterRepository: true,
          setFlavorToProd: true,
        ),
      );
    });

    tearDown(() async {
      await test_helpers.tearDownTestDependencies();
    });

    testGoldens('renders correctly on common devices', (tester) async {
      final cubit = CounterCubit(
        repository: MockCounterRepository(),
        timerService: FakeTimerService(),
        now: _fixedNow,
      )..loadInitial();
      addTearDown(cubit.close);
      await tester.pumpWidget(
        _buildCounterPageApp(cubit: cubit, theme: ThemeData.light()),
      );
      await tester.pump();
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      await waitForCounterCubitsToLoad(tester);
      expect(find.byType(CounterPage), findsOneWidget);
      expect(find.text('0'), findsWidgets);
      await multiScreenGolden(
        tester,
        'counter_page_initial',
        devices: const [
          Device.phone,
          Device.tabletPortrait,
          Device.tabletLandscape,
        ],
      );
    });

    testGoldens('renders loading state without settling', (tester) async {
      await tester.pumpWidgetBuilder(const MyApp(requireAuth: false));
      // Wait a bit for initial render but don't wait for full settle
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await multiScreenGolden(
        tester,
        'counter_page_loading',
        devices: const [Device.phone, Device.tabletPortrait],
      );
    });

    testGoldens('counter components in TR locale', (tester) async {
      final Widget demo = _CounterComponentsDemo();
      await tester.pumpWidgetBuilder(
        demo,
        wrapper: materialAppWrapper(
          localizations: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          theme: ThemeData.light(),
          localeOverrides: const [Locale('tr')],
        ),
      );
      await multiScreenGolden(
        tester,
        'counter_components_tr',
        devices: const [Device.phone],
      );
    });

    testGoldens('counter page active countdown', (tester) async {
      final fakeTimer = FakeTimerService();
      final cubit = CounterCubit(
        repository: MockCounterRepository(
          snapshot: const CounterSnapshot(count: 2),
        ),
        timerService: fakeTimer,
        now: _fixedNow,
      );
      cubit.loadInitial();
      await tester.pumpWidget(
        _buildCounterPageApp(cubit: cubit, theme: ThemeData.light()),
      );
      fakeTimer.tick(2);
      await tester.pump();
      await waitForCounterCubitsToLoad(tester);
      await multiScreenGolden(
        tester,
        'counter_page_active',
        devices: const [Device.phone, Device.tabletPortrait],
      );
      addTearDown(cubit.close);
    });

    testGoldens('counter page paused (count = 0)', (tester) async {
      final cubit = CounterCubit(
        repository: MockCounterRepository(
          snapshot: const CounterSnapshot(count: 0),
        ),
        timerService: FakeTimerService(),
        startTicker: true,
        now: _fixedNow,
      );
      cubit.loadInitial();
      await tester.pumpWidget(
        _buildCounterPageApp(cubit: cubit, theme: ThemeData.light()),
      );
      await tester.pump();
      await waitForCounterCubitsToLoad(tester);
      await multiScreenGolden(
        tester,
        'counter_page_paused',
        devices: const [Device.phone, Device.tabletPortrait],
      );
      addTearDown(cubit.close);
    });

    testGoldens('counter page active countdown - dark', (tester) async {
      final fakeTimer = FakeTimerService();
      final cubit = CounterCubit(
        repository: MockCounterRepository(
          snapshot: const CounterSnapshot(count: 3),
        ),
        timerService: fakeTimer,
        now: _fixedNow,
      );
      cubit.loadInitial();
      await tester.pumpWidget(
        _buildCounterPageApp(cubit: cubit, theme: ThemeData.dark()),
      );
      fakeTimer.tick(2);
      await tester.pump();
      await waitForCounterCubitsToLoad(tester);
      await multiScreenGolden(
        tester,
        'counter_page_active_dark',
        devices: const [Device.phone, Device.tabletPortrait],
      );
      addTearDown(cubit.close);
    });

    testGoldens('counter page paused (count = 0) - dark', (tester) async {
      final cubit = CounterCubit(
        repository: MockCounterRepository(
          snapshot: const CounterSnapshot(count: 0),
        ),
        timerService: FakeTimerService(),
        startTicker: true,
        now: _fixedNow,
      );
      cubit.loadInitial();
      await tester.pumpWidget(
        _buildCounterPageApp(cubit: cubit, theme: ThemeData.dark()),
      );
      await tester.pump();
      await waitForCounterCubitsToLoad(tester);
      await multiScreenGolden(
        tester,
        'counter_page_paused_dark',
        devices: const [Device.phone, Device.tabletPortrait],
      );
      addTearDown(cubit.close);
    });
  });
}

DateTime _fixedNow() => _goldenTimestamp;

Widget _buildCounterPageApp({required CounterCubit cubit, ThemeData? theme}) =>
    ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<CounterCubit>.value(value: cubit),
          BlocProvider<SyncStatusCubit>(
            create: (_) => SyncStatusCubit(
              networkStatusService: getIt<NetworkStatusService>(),
              coordinator: getIt<BackgroundSyncCoordinator>(),
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: theme ?? ThemeData.light(),
          home: CounterPage(
            title: 'Counter',
            errorNotificationService: _FakeErrorNotificationService(),
            biometricAuthenticator: _FakeBiometricAuthenticator(),
          ),
        ),
      ),
    );

class _FakeErrorNotificationService implements ErrorNotificationService {
  @override
  Future<void> showAlertDialog(
    BuildContext context,
    String title,
    String message,
  ) async {}

  @override
  Future<void> showSnackBar(BuildContext context, String message) async {}
}

class _FakeBiometricAuthenticator implements BiometricAuthenticator {
  @override
  Future<bool> authenticate({String? localizedReason}) async => true;
}

class _CounterComponentsDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer, size: 18, color: colors.primary),
                  const SizedBox(width: 6),
                  Text(
                    l10n.autoLabel,
                    style: textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: 0.6,
                minHeight: 8,
                backgroundColor: colors.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
