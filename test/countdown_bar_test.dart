import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/features/counter/presentation/widgets/widgets.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrapWithApp(Widget child) => ScreenUtilInit(
  designSize: const Size(390, 844),
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (context, _) => MaterialApp(
    localizationsDelegates: const [AppLocalizations.delegate],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(bottomNavigationBar: child),
  ),
);

void main() {
  group('CountdownBar', () {
    CounterCubit createCubit({CounterRepository? repository}) {
      final cubit = CounterCubit(
        repository: repository ?? _NoopRepo(),
        startTicker: false,
      );
      addTearDown(cubit.close);
      return cubit;
    }

    testWidgets('shows active label with remaining seconds', (tester) async {
      final cubit = createCubit();

      await tester.pumpWidget(
        _wrapWithApp(
          BlocProvider.value(value: cubit, child: const CountdownBar()),
        ),
      );

      // Force an active state with 3 seconds remaining
      cubit.emit(
        CounterState(
          count: 1,
          lastChanged: DateTime.now(),
          countdownSeconds: 3,
          status: ViewStatus.success,
        ),
      );
      await tester.pump();

      final en = AppLocalizationsEn();
      expect(find.text(en.nextAutoDecrementIn(3)), findsOneWidget);
    });

    testWidgets('shows paused label when inactive', (tester) async {
      final cubit = createCubit();

      await tester.pumpWidget(
        _wrapWithApp(
          BlocProvider.value(value: cubit, child: const CountdownBar()),
        ),
      );

      // Force an inactive state
      cubit.emit(
        CounterState(
          count: 0,
          lastChanged: DateTime.now(),
          countdownSeconds: 5,
          status: ViewStatus.success,
        ),
      );
      await tester.pump();

      final en = AppLocalizationsEn();
      expect(find.text(en.autoDecrementPaused), findsOneWidget);
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
