import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/widgets/counter_actions.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helpers.dart';

class _FabHost extends StatelessWidget {
  const _FabHost();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.expand(),
      floatingActionButton: CounterActions(),
    );
  }
}

void main() {
  group('FAB Alignment Goldens', () {
    setUpAll(() async {
      await loadAppFonts();
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testGoldens('FAB alignment - light', (tester) async {
      final cubit = CounterCubit(
        repository: MockCounterRepository(
          snapshot: const CounterSnapshot(count: 1),
        ),
        startTicker: false,
      );

      await tester.pumpWidgetBuilder(
        BlocProvider.value(value: cubit, child: const _FabHost()),
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
        'fab_alignment_light',
        devices: const [Device.phone, Device.tabletPortrait],
      );
      addTearDown(cubit.close);
    });

    testGoldens('FAB alignment - dark', (tester) async {
      final cubit = CounterCubit(
        repository: MockCounterRepository(
          snapshot: const CounterSnapshot(count: 1),
        ),
        startTicker: false,
      );

      await tester.pumpWidgetBuilder(
        BlocProvider.value(value: cubit, child: const _FabHost()),
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
        'fab_alignment_dark',
        devices: const [Device.phone, Device.tabletPortrait],
      );
      addTearDown(cubit.close);
    });
  });
}
