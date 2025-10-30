import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/features/counter/presentation/pages/counter_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helpers.dart';

void main() {
  group('CounterPage Golden', () {
    setUpAll(() async {
      await loadAppFonts();
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testGoldens('renders correctly on common devices', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(
          devices: [
            Device.phone,
            Device.tabletPortrait,
            Device.tabletLandscape,
          ],
        )
        ..addScenario(
          name: 'Initial state',
          widget: const MyApp(requireAuth: false),
        );

      await tester.pumpDeviceBuilder(builder);
      await tester.pumpAndSettle();
      await screenMatchesGolden(tester, 'counter_page_initial');
    });

    testGoldens('renders loading state without settling', (tester) async {
      await tester.pumpWidgetBuilder(const MyApp(requireAuth: false));
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
      );
      await tester.pumpWidgetBuilder(
        BlocProvider.value(
          value: cubit..loadInitial(),
          child: const CounterPage(title: 'Counter'),
        ),
        wrapper: materialAppWrapper(
          localizations: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          theme: ThemeData.light(),
        ),
      );
      fakeTimer.tick(2);
      await tester.pump();
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
      );
      await tester.pumpWidgetBuilder(
        BlocProvider.value(
          value: cubit..loadInitial(),
          child: const CounterPage(title: 'Counter'),
        ),
        wrapper: materialAppWrapper(
          localizations: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          theme: ThemeData.light(),
        ),
      );
      await tester.pump();
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
      );
      await tester.pumpWidgetBuilder(
        BlocProvider.value(
          value: cubit..loadInitial(),
          child: const CounterPage(title: 'Counter'),
        ),
        wrapper: materialAppWrapper(
          localizations: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          theme: ThemeData.dark(),
        ),
      );
      fakeTimer.tick(2);
      await tester.pump();
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
      );
      await tester.pumpWidgetBuilder(
        BlocProvider.value(
          value: cubit..loadInitial(),
          child: const CounterPage(title: 'Counter'),
        ),
        wrapper: materialAppWrapper(
          localizations: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          theme: ThemeData.dark(),
        ),
      );
      await tester.pump();
      await multiScreenGolden(
        tester,
        'counter_page_paused_dark',
        devices: const [Device.phone, Device.tabletPortrait],
      );
      addTearDown(cubit.close);
    });
  });
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
