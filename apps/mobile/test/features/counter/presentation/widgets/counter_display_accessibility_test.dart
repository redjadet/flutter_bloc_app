import 'package:design_system/design_system.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/counter/presentation/cubit/counter_cubit.dart';
import 'package:flutter_bloc_app/features/counter/presentation/widgets/counter_display/counter_display.dart';
import 'package:flutter_bloc_app/features/counter/presentation/widgets/counter_display/counter_value_text.dart';
import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../test_helpers.dart'
    show FakeTimerService, MockCounterRepository;

void main() {
  testWidgets('animated count exposes only the current numeric value', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await _pumpValue(tester, count: 7);
      await _pumpValue(tester, count: 8);
      await tester.pump(const Duration(milliseconds: 40));

      expect(find.text('7'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'(^|\s)7$')), findsNothing);
      expect(find.bySemanticsLabel('8'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('long count stays visible on one line with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const count = 123456789012345;
    await _pumpValue(tester, count: count, textScale: 2);

    final finder = find.descendant(
      of: find.text('$count'),
      matching: find.byType(RichText),
    );
    final paragraph = tester.renderObject<RenderParagraph>(finder);
    final boxes = paragraph.getBoxesForSelection(
      TextSelection(baseOffset: 0, extentOffset: '$count'.length),
    );
    expect(boxes, isNotEmpty);
    expect(boxes.map((box) => box.top).toSet(), hasLength(1));
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(boxes.last.right, lessThanOrEqualTo(paragraph.size.width));
    expect(tester.getTopLeft(finder).dx, greaterThanOrEqualTo(0));
    expect(tester.getBottomRight(finder).dx, lessThanOrEqualTo(320));
    expect(tester.takeException(), isNull);
  });

  testWidgets('counter follows changes to reduced-motion preference', (
    tester,
  ) async {
    final cubit = CounterCubit(
      repository: MockCounterRepository(),
      timerService: FakeTimerService(),
      startTicker: false,
    );
    addTearDown(cubit.close);

    await _pumpDisplay(tester, cubit: cubit, reduceMotion: false);
    expect(
      tester
          .widget<CounterValueText>(find.byType(CounterValueText))
          .animDuration,
      isNot(Duration.zero),
    );

    await _pumpDisplay(tester, cubit: cubit, reduceMotion: true);
    for (final switcher in tester.widgetList<AnimatedSwitcher>(
      find.byType(AnimatedSwitcher),
    )) {
      expect(switcher.duration, Duration.zero);
    }
    expect(
      tester
          .widget<TweenAnimationBuilder<Color?>>(
            find.byType(TweenAnimationBuilder<Color?>),
          )
          .duration,
      Duration.zero,
    );
    expect(
      tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).duration,
      Duration.zero,
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpValue(
  WidgetTester tester, {
  required int count,
  double textScale = 1,
}) => tester.pumpWidget(
  MaterialApp(
    home: ResponsiveScope(
      child: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Center(
          child: SizedBox(
            width: 160,
            child: CounterValueText(
              count: count,
              textTheme: ThemeData.light().textTheme,
              animDuration: const Duration(milliseconds: 250),
            ),
          ),
        ),
      ),
    ),
  ),
);

Future<void> _pumpDisplay(
  WidgetTester tester, {
  required CounterCubit cubit,
  required bool reduceMotion,
}) => tester.pumpWidget(
  MaterialApp(
    localizationsDelegates: appLocalizationDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ResponsiveScope(
      child: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: BlocProvider<CounterCubit>.value(
          value: cubit,
          child: const Center(child: CounterDisplay()),
        ),
      ),
    ),
  ),
);
