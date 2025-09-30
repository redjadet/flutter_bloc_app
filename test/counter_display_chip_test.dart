import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/widgets/counter_display/counter_display.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, _) => MaterialApp(
      localizationsDelegates: const [AppLocalizations.delegate],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
  });

  group('CounterDisplay chip', () {
    CounterCubit createCubit({CounterRepository? repository}) {
      final cubit = CounterCubit(
        repository: repository ?? _NoopRepo(),
        startTicker: false,
      );
      addTearDown(cubit.close);
      return cubit;
    }

    testWidgets('shows Auto label when active', (tester) async {
      final cubit = createCubit();

      await tester.pumpWidget(
        _wrap(BlocProvider.value(value: cubit, child: const CounterDisplay())),
      );

      cubit.emit(
        CounterState(
          count: 2,
          lastChanged: DateTime.now(),
          countdownSeconds: 5,
          isAutoDecrementActive: true,
          status: CounterStatus.success,
        ),
      );
      await tester.pump();

      final en = AppLocalizationsEn();
      expect(find.text(en.autoLabel), findsOneWidget);
    });

    testWidgets('shows Paused label when inactive', (tester) async {
      final cubit = createCubit();

      await tester.pumpWidget(
        _wrap(BlocProvider.value(value: cubit, child: const CounterDisplay())),
      );

      cubit.emit(
        CounterState(
          count: 0,
          lastChanged: DateTime.now(),
          countdownSeconds: 5,
          isAutoDecrementActive: false,
          status: CounterStatus.success,
        ),
      );
      await tester.pump();

      final en = AppLocalizationsEn();
      expect(find.text(en.pausedLabel), findsOneWidget);
    });
  });
}

class _NoopRepo implements CounterRepository {
  @override
  Future<CounterSnapshot> load() async =>
      const CounterSnapshot(userId: 'noop', count: 0);
  @override
  Future<void> save(CounterSnapshot snapshot) async {}

  @override
  Stream<CounterSnapshot> watch() async* {
    yield await load();
  }
}
