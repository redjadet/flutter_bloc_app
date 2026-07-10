import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/config/app_constants.dart';
import 'package:flutter_bloc_app/features/counter/presentation/cubit/counter_cubit.dart';
import 'package:flutter_bloc_app/features/counter/presentation/widgets/counter_page_body.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../test_helpers.dart'
    show FakeTimerService, MockCounterRepository;

void main() {
  group('CounterPageBody', () {
    testWidgets('enables skeletons while loading', (tester) async {
      final CounterCubit cubit = CounterCubit(
        repository: MockCounterRepository(),
        timerService: FakeTimerService(),
        startTicker: false,
      );
      addTearDown(cubit.close);

      cubit.emit(cubit.state.asLoading());

      await tester.binding.setSurfaceSize(AppConstants.designSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pumpCounterPageBody(tester, cubit: cubit);

      final skeletonizer = tester.widget<Skeletonizer>(
        find.byWidgetPredicate((widget) => widget is Skeletonizer),
      );
      expect(skeletonizer.enabled, isTrue);
    });

    testWidgets('disables skeletons when not loading', (tester) async {
      final CounterCubit cubit = CounterCubit(
        repository: MockCounterRepository(),
        timerService: FakeTimerService(),
        startTicker: false,
      );
      addTearDown(cubit.close);

      cubit.emit(cubit.state.asLoading());

      await tester.binding.setSurfaceSize(AppConstants.designSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pumpCounterPageBody(tester, cubit: cubit);

      cubit.emit(cubit.state.asReady());
      await tester.pump();

      final skeletonizer = tester.widget<Skeletonizer>(
        find.byWidgetPredicate((widget) => widget is Skeletonizer),
      );
      expect(skeletonizer.enabled, isFalse);
    });
  });
}

Future<void> _pumpCounterPageBody(
  WidgetTester tester, {
  required CounterCubit cubit,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ResponsiveScope(
        child: BlocProvider<CounterCubit>.value(
          value: cubit,
          child: Builder(
            builder: (context) => CounterPageBody(
              theme: Theme.of(context),
              l10n: AppLocalizations.of(context),
              showFlavorBadge: false,
            ),
          ),
        ),
      ),
    ),
  );
}
